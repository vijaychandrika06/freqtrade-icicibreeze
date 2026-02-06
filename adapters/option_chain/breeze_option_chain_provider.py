import json
import logging
import os
import math
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Optional, List, Dict, Any

from breeze_connect import BreezeConnect
from modules.option_chain.provider_port import OptionChainProvider
from modules.option_chain.schema import OptionChain, OptionChainRow

logger = logging.getLogger("breeze_chain_provider")


from adapters.time.clock import Clock, get_clock


class BreezeOptionChainProvider(OptionChainProvider):
    def __init__(
        self,
        api_key: str = "",
        api_secret: str = "",
        session_token: str = "",
        clock: "Clock | None" = None,
    ):
        self.mock_mode = os.environ.get("BREEZE_MOCK", "0") == "1"
        self.clock = clock or get_clock()
        self.cache_dir = Path("user_data/cache/option_chain")
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.cache_ttl = 60  # seconds

        self.breeze = None
        if not self.mock_mode:
            try:
                self.breeze = BreezeConnect(api_key=api_key)
                if session_token:
                    self.breeze.generate_session(api_secret=api_secret, session_token=session_token)
            except Exception as e:
                logger.warning(
                    f"Failed to init BreezeConnect: {e}. Falling back to behavior checks."
                )

    def get_option_chain(self, underlying: str, expiry: str, right: str) -> Optional[OptionChain]:
        cache_key = f"{underlying}_{expiry}_{right}".replace("-", "").replace(":", "")
        cache_file = self.cache_dir / f"{cache_key}.json"

        # Check cache
        if cache_file.exists():
            try:
                data = json.loads(cache_file.read_text())
                ts = data.get("timestamp_ts", 0)
                if self.clock.now_utc().timestamp() - ts < self.cache_ttl:
                    return self._deserialize(data)
            except Exception:
                pass

        # Fetch or Mock
        if self.mock_mode:
            chain = self._generate_mock_chain(underlying, expiry, right)
        else:
            if not self.breeze:
                logger.error("Breeze/Real requested but SDK not initialized.")
                return None
            try:
                # Breeze SDK format assumptions based on docs
                response = self.breeze.get_option_chain_quotes(
                    stock_code=underlying,
                    exchange_code="NFO",
                    product_type="options",
                    expiry_date=expiry,
                    right=right.lower(),
                    strike_price="",
                )
                if not response or str(response.get("Status", "")).lower() != "200":
                    logger.error(f"Breeze API Error: {response}")
                    return None

                rows_data = response.get("Success", [])
                chain = self._parse_breeze_response(underlying, expiry, right, rows_data)
            except Exception as e:
                logger.exception(f"Error fetching option chain for {underlying}: {e}")
                return None

        # Write cache
        if chain:
            try:
                self._write_cache(cache_file, chain)
            except Exception as e:
                logger.warning(f"Failed to write cache: {e}")

        return chain

    def _generate_mock_chain(self, underlying: str, expiry: str, right: str) -> OptionChain:
        if underlying == "FAIL":
            return OptionChain(
                underlying=underlying,
                exchange_code="NFO",
                expiry=expiry,
                right=right,
                spot_price=0.0,
                rows=[],
            )

        # Deterministic mock based on underlying name hash
        seed = sum(ord(c) for c in underlying)
        spot = 1000.0 + (seed % 100) * 10  # Arbitrary spot

        # Strikes: +/- 10%
        strikes = []
        center = round(spot / 50) * 50
        for i in range(-5, 6):
            strikes.append(float(center + i * 50))

        rows = []
        for k in strikes:
            # Simple intrinsic + time value
            if right.lower() == "call":
                intrinsic = max(0, spot - k)
            else:
                intrinsic = max(0, k - spot)

            time_value = 20.0 * math.exp(-0.01 * abs(k - spot))  # Decay away from ATM
            ltp = intrinsic + time_value

            rows.append(
                OptionChainRow(
                    strike=k,
                    ltp=round(ltp, 2),
                    bid=round(ltp * 0.99, 2),
                    ask=round(ltp * 1.01, 2),
                    volume=1000,
                    oi=5000,
                    d_oi=100,
                    timestamp=self.clock.now_utc().isoformat(),
                )
            )

        return OptionChain(
            underlying=underlying,
            exchange_code="NFO",
            expiry=expiry,
            right=right,
            spot_price=spot,
            rows=rows,
        )

    def _parse_breeze_response(
        self, underlying: str, expiry: str, right: str, data: List[Dict]
    ) -> OptionChain:
        rows = []
        spot = None
        # Data is list of quotes. Need to extract fields.
        # Example Breeze fields (hypothetical/typical): "ltp", "strike_price", "open_interest", "volume"
        for item in data:
            try:
                strike = float(item.get("strike_price", 0))
                if strike <= 0:
                    continue

                rows.append(
                    OptionChainRow(
                        strike=strike,
                        ltp=float(item.get("ltp", 0) or 0),
                        bid=float(item.get("best_bid_price", 0) or 0),
                        ask=float(item.get("best_offer_price", 0) or 0),
                        volume=float(item.get("show_volume", 0) or item.get("volume", 0) or 0),
                        oi=float(item.get("open_interest", 0) or 0),
                        d_oi=float(item.get("change_in_oi", 0) or 0),
                        timestamp=item.get("datetime"),
                    )
                )
            except (ValueError, TypeError):
                continue

        # Heuristic for spot: usually not in chain response, might need separate fetch or pass in?
        # For universal scanner, we often have spot from SecurityMaster or Ticker.
        # But provider interface expects to return it.
        # If not present, None.

        return OptionChain(
            underlying=underlying,
            exchange_code="NFO",
            expiry=expiry,
            right=right,
            spot_price=spot,
            rows=rows,
        )

    def _write_cache(self, path: Path, chain: OptionChain):
        data = {
            "underlying": chain.underlying,
            "expiry": chain.expiry,
            "right": chain.right,
            "spot_price": chain.spot_price,
            "rows": [
                {
                    "strike": r.strike,
                    "ltp": r.ltp,
                    "bid": r.bid,
                    "ask": r.ask,
                    "volume": r.volume,
                    "oi": r.oi,
                    "d_oi": r.d_oi,
                    "timestamp": r.timestamp,
                }
                for r in chain.rows
            ],
            "timestamp_ts": self.clock.now_utc().timestamp(),
        }
        path.write_text(json.dumps(data, indent=2))

    def _deserialize(self, data: Dict) -> OptionChain:
        rows = [
            OptionChainRow(
                strike=r.get("strike"),
                ltp=r.get("ltp"),
                bid=r.get("bid"),
                ask=r.get("ask"),
                volume=r.get("volume"),
                oi=r.get("oi"),
                d_oi=r.get("d_oi"),
                timestamp=r.get("timestamp"),
            )
            for r in data.get("rows", [])
        ]
        return OptionChain(
            underlying=data.get("underlying"),
            exchange_code="NFO",
            expiry=data.get("expiry"),
            right=data.get("right"),
            spot_price=data.get("spot_price"),
            rows=rows,
        )
