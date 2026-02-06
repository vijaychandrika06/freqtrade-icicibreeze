# Adapter coverage matrix

## Files in `adapters/ccxt_shim`
- `adapters/ccxt_shim/__init__.py`
- `adapters/ccxt_shim/alerts.py`
- `adapters/ccxt_shim/breeze_ccxt.py`
- `adapters/ccxt_shim/degraded_mode.py`
- `adapters/ccxt_shim/health_snapshot.py`
- `adapters/ccxt_shim/icicibreeze/__init__.py`
- `adapters/ccxt_shim/icicibreeze/mock_ohlcv.py`
- `adapters/ccxt_shim/instrument.py`
- `adapters/ccxt_shim/live_readiness.py`
- `adapters/ccxt_shim/market_hours.py`
- `adapters/ccxt_shim/metrics_exporter.py`
- `adapters/ccxt_shim/order_idempotency.py`
- `adapters/ccxt_shim/order_router.py`
- `adapters/ccxt_shim/paper_ledger.py`
- `adapters/ccxt_shim/policy_codes.py`
- `adapters/ccxt_shim/rate_limiter.py`
- `adapters/ccxt_shim/risk_guard.py`
- `adapters/ccxt_shim/security_master.py`
- `adapters/ccxt_shim/security_master_normalize.py`

## Key symbols and API surface (grep)
```text
adapters/ccxt_shim/live_readiness.py:19:def _env_bool(name: str, default: bool = False) -> bool:
adapters/ccxt_shim/live_readiness.py:26:class LiveReadiness:
adapters/ccxt_shim/live_readiness.py:28:    def check_deadman(clock: "Clock | None" = None) -> dict:
adapters/ccxt_shim/live_readiness.py:69:    def check_readiness(config: dict, clock: "Clock | None" = None) -> dict:
adapters/ccxt_shim/rate_limiter.py:6:from freqtrade.exceptions import OperationalException
adapters/ccxt_shim/rate_limiter.py:11:class RateLimiter:
adapters/ccxt_shim/rate_limiter.py:18:    def __init__(self, now_fn=None, sleep_fn=None):
adapters/ccxt_shim/rate_limiter.py:43:                f"RateLimiter initialized: {self.per_minute}/min, "
adapters/ccxt_shim/rate_limiter.py:47:            logger.warning("RateLimiter is DISABLED via FT_RATE_LIMIT_DISABLE")
adapters/ccxt_shim/rate_limiter.py:49:    def _refill(self):
adapters/ccxt_shim/rate_limiter.py:58:    def allow(self, op: str, cost: int = 1) -> None:
adapters/ccxt_shim/rate_limiter.py:64:          - mode='block': Raises OperationalException
adapters/ccxt_shim/rate_limiter.py:86:    def _raise_block(self, op: str, cost: int):
adapters/ccxt_shim/rate_limiter.py:89:        raise OperationalException(f"rate_limit_block: {op}")
adapters/ccxt_shim/rate_limiter.py:91:    def _sleep_until_allowed(self, op: str, cost: int):
adapters/ccxt_shim/rate_limiter.py:98:            logger.warning(f"RateLimiter request to sleep {sleep_time:.2f}s clamped to 60s")
adapters/ccxt_shim/rate_limiter.py:111:    def _log_usage(self, op: str, cost: int):
adapters/ccxt_shim/rate_limiter.py:117:    def stats(self) -> dict[str, Any]:
adapters/ccxt_shim/market_hours.py:14:from freqtrade.exceptions import OperationalException
adapters/ccxt_shim/market_hours.py:28:class MarketHoursGuard:
adapters/ccxt_shim/market_hours.py:33:    def __init__(self):
adapters/ccxt_shim/market_hours.py:38:    def _reload_overrides(self):
adapters/ccxt_shim/market_hours.py:43:    def is_market_open(self, now: datetime | None = None) -> bool:
adapters/ccxt_shim/market_hours.py:81:    def assert_can_create_order(self, side: str, symbol: str):
adapters/ccxt_shim/market_hours.py:101:                        "action": "create_order",
adapters/ccxt_shim/market_hours.py:109:                raise OperationalException(f"market_hours_block:{msg}")
adapters/ccxt_shim/market_hours.py:113:    def assert_can_cancel_order(self, order_id: str, symbol: str):
adapters/ccxt_shim/market_hours.py:128:                    "action": "cancel_order",
adapters/ccxt_shim/market_hours.py:134:            raise OperationalException(f"market_hours_block:{msg}")
adapters/ccxt_shim/market_hours.py:136:    def assert_can_edit_order(self, order_id: str, symbol: str):
adapters/ccxt_shim/market_hours.py:145:                    "action": "edit_order",
adapters/ccxt_shim/market_hours.py:151:            raise OperationalException(f"market_hours_block:{msg}")
adapters/ccxt_shim/health_snapshot.py:13:class HealthSnapshot:
adapters/ccxt_shim/health_snapshot.py:16:    def __init__(self, now_fn: Callable[[], datetime] | None = None):
adapters/ccxt_shim/health_snapshot.py:24:            "fetch_ticker_utc": None,
adapters/ccxt_shim/health_snapshot.py:25:            "fetch_ohlcv_utc": None,
adapters/ccxt_shim/health_snapshot.py:26:            "create_order_utc": None,
adapters/ccxt_shim/health_snapshot.py:33:            "fetch_ticker": [],
adapters/ccxt_shim/health_snapshot.py:34:            "fetch_ohlcv": [],
adapters/ccxt_shim/health_snapshot.py:35:            "create_order": [],
adapters/ccxt_shim/health_snapshot.py:41:    def get_instance(cls):
adapters/ccxt_shim/health_snapshot.py:46:    def _ensure_dir(self):
adapters/ccxt_shim/health_snapshot.py:52:    def update_mode(self, mock: bool, paper: bool, live: bool):
adapters/ccxt_shim/health_snapshot.py:56:    def record_call(self, method_name: str, duration_ms: int | None = None):
adapters/ccxt_shim/health_snapshot.py:71:    def increment_counter(self, counter_name: str):
adapters/ccxt_shim/health_snapshot.py:76:    def record_error(self, code: str, message: str):
adapters/ccxt_shim/health_snapshot.py:83:    def update_circuit_breaker(self, data: dict):
adapters/ccxt_shim/health_snapshot.py:87:    def get_p50_latency(self, method_name: str) -> int:
adapters/ccxt_shim/health_snapshot.py:94:    def get_counters(self) -> dict:
adapters/ccxt_shim/health_snapshot.py:97:    def persist(self):
adapters/ccxt_shim/health_snapshot.py:119:    def load_into_self(self):
adapters/ccxt_shim/health_snapshot.py:130:    def load(self) -> dict:
adapters/ccxt_shim/health_snapshot.py:142:def update(event: str, payload: dict | None = None) -> None:
adapters/ccxt_shim/health_snapshot.py:175:def load() -> dict:
adapters/ccxt_shim/health_snapshot.py:179:def get_p50_latency(method: str) -> int:
adapters/ccxt_shim/health_snapshot.py:183:def get_counters() -> dict:
adapters/ccxt_shim/breeze_ccxt.py:23:from adapters.ccxt_shim.degraded_mode import DegradedModeGuard
adapters/ccxt_shim/breeze_ccxt.py:32:from adapters.ccxt_shim.market_hours import MarketHoursGuard
adapters/ccxt_shim/breeze_ccxt.py:34:from adapters.ccxt_shim.order_router import OrderRouter
adapters/ccxt_shim/breeze_ccxt.py:36:from adapters.ccxt_shim.rate_limiter import RateLimiter
adapters/ccxt_shim/breeze_ccxt.py:37:from adapters.ccxt_shim.risk_guard import RiskGuard
adapters/ccxt_shim/breeze_ccxt.py:43:from freqtrade.exceptions import OperationalException
adapters/ccxt_shim/breeze_ccxt.py:49:class BreezeCCXT(ccxt.Exchange):
adapters/ccxt_shim/breeze_ccxt.py:59:    def __init__(self, config: dict[str, Any] | None = None):
adapters/ccxt_shim/breeze_ccxt.py:104:        # Initialize RiskGuard AFTER super to prevent CCXT from overwriting it if 'risk_guard' is in config
adapters/ccxt_shim/breeze_ccxt.py:106:            self.risk_guard = RiskGuard(config)
adapters/ccxt_shim/breeze_ccxt.py:108:            # Pass a wrapper dict so RiskGuard sees {"risk_guard": ...} structure
adapters/ccxt_shim/breeze_ccxt.py:109:            self.risk_guard = RiskGuard({"risk_guard": config["ccxt_config"]["risk_guard"]})
adapters/ccxt_shim/breeze_ccxt.py:111:            self.risk_guard = RiskGuard({})  # Defaults to enabled=True, max=10
adapters/ccxt_shim/breeze_ccxt.py:114:        # P17: Switched to centralized RateLimiter with Env support
adapters/ccxt_shim/breeze_ccxt.py:115:        self.rate_limiter = RateLimiter()
adapters/ccxt_shim/breeze_ccxt.py:117:        self.market_hours = MarketHoursGuard()
adapters/ccxt_shim/breeze_ccxt.py:118:        self.degraded_guard = DegradedModeGuard()
adapters/ccxt_shim/breeze_ccxt.py:120:        # Initialize OrderRouter
adapters/ccxt_shim/breeze_ccxt.py:121:        self.order_router = OrderRouter(lambda: self.markets)
adapters/ccxt_shim/breeze_ccxt.py:160:                # But create_order will block if paper_mode is on.
adapters/ccxt_shim/breeze_ccxt.py:182:    def _setup_mock_breeze(self):
adapters/ccxt_shim/breeze_ccxt.py:185:        def mock_get_quotes(**kwargs):
adapters/ccxt_shim/breeze_ccxt.py:203:        def mock_get_historical_v2(**kwargs):
adapters/ccxt_shim/breeze_ccxt.py:232:    def _is_mock_mode(self) -> bool:
adapters/ccxt_shim/breeze_ccxt.py:252:    def _check_fault_inject(self, op: str):
adapters/ccxt_shim/breeze_ccxt.py:256:            raise OperationalException(f"FT_FAULT_INJECT: {op}")
adapters/ccxt_shim/breeze_ccxt.py:258:    def describe(self):
adapters/ccxt_shim/breeze_ccxt.py:299:    def _load_security_master(self) -> dict[str, Any]:
adapters/ccxt_shim/breeze_ccxt.py:315:    def _build_breeze_params(self, spec: InstrumentSpec, info: dict[str, Any]) -> dict[str, Any]:
adapters/ccxt_shim/breeze_ccxt.py:339:    def _parse_symbol(self, symbol: str) -> dict[str, Any]:
adapters/ccxt_shim/breeze_ccxt.py:343:            raise OperationalException(f"Invalid symbol format: {symbol}") from exc
adapters/ccxt_shim/breeze_ccxt.py:369:                raise OperationalException(f"Cash symbol not found in SecurityMaster: {symbol}")
adapters/ccxt_shim/breeze_ccxt.py:389:                raise OperationalException(f"Option contract not found in SecurityMaster: {symbol}")
adapters/ccxt_shim/breeze_ccxt.py:406:                raise OperationalException(f"Future contract not found in SecurityMaster: {symbol}")
adapters/ccxt_shim/breeze_ccxt.py:408:        raise OperationalException(f"Unsupported symbol type: {symbol}")
adapters/ccxt_shim/breeze_ccxt.py:410:    def fetch_markets(self, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:429:    def _fetch_specific_market(self, spec: InstrumentSpec, master: dict[str, Any]) -> dict | None:
adapters/ccxt_shim/breeze_ccxt.py:438:    def _fetch_option_market(self, spec: InstrumentSpec, contracts: dict) -> dict | None:
adapters/ccxt_shim/breeze_ccxt.py:485:    def _fetch_future_market(self, spec: InstrumentSpec, futures: dict) -> dict | None:
adapters/ccxt_shim/breeze_ccxt.py:528:    def _fetch_cash_market(self, spec: InstrumentSpec, cash_symbols: dict) -> dict | None:
adapters/ccxt_shim/breeze_ccxt.py:570:    def fetch_ticker(self, symbol: str, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:571:        self.rate_limiter.allow("fetch_ticker")
adapters/ccxt_shim/breeze_ccxt.py:577:            raise OperationalException("Breeze session not initialized.")
adapters/ccxt_shim/breeze_ccxt.py:586:                raise OperationalException(f"Breeze fetch_ticker failed: {err_msg}")
adapters/ccxt_shim/breeze_ccxt.py:609:            health_snapshot.update("call", {"method": "fetch_ticker"})
adapters/ccxt_shim/breeze_ccxt.py:613:            health_snapshot.update("error", {"code": "fetch_ticker_error", "message": str(e)})
adapters/ccxt_shim/breeze_ccxt.py:614:            logger.debug("fetch_ticker error: %s", e)
adapters/ccxt_shim/breeze_ccxt.py:615:            raise OperationalException("Error in fetch_ticker. See debug logs for details.") from e
adapters/ccxt_shim/breeze_ccxt.py:617:    def fetch_order_book(self, symbol: str, limit: int | None = None, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:623:        ticker = self.fetch_ticker(symbol)
adapters/ccxt_shim/breeze_ccxt.py:627:            raise OperationalException(
adapters/ccxt_shim/breeze_ccxt.py:639:            raise OperationalException("Invalid FT_SYNTH_OB_SPREAD_BPS") from None
adapters/ccxt_shim/breeze_ccxt.py:660:    def fetch_ohlcv(
adapters/ccxt_shim/breeze_ccxt.py:669:        # Validate symbol first - raises OperationalException if invalid
adapters/ccxt_shim/breeze_ccxt.py:676:            raise OperationalException("Breeze session not initialized.")
adapters/ccxt_shim/breeze_ccxt.py:680:            raise OperationalException(f"Unsupported timeframe: {timeframe}")
adapters/ccxt_shim/breeze_ccxt.py:724:            health_snapshot.update("call", {"method": "fetch_ohlcv"})
adapters/ccxt_shim/breeze_ccxt.py:728:            health_snapshot.update("error", {"code": "fetch_ohlcv_sdk_error", "message": msg})
adapters/ccxt_shim/breeze_ccxt.py:730:                f"event=icicibreeze_fetch_ohlcv_sdk_error symbol={symbol} "
adapters/ccxt_shim/breeze_ccxt.py:735:    def fetch_balance(self, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:763:                logger.warning(f"fetch_balance failed in real mode (fallback used): {e}")
adapters/ccxt_shim/breeze_ccxt.py:775:    def _is_paper_trading(self) -> bool:
adapters/ccxt_shim/breeze_ccxt.py:781:    def create_order(
adapters/ccxt_shim/breeze_ccxt.py:784:        logger.info(f"BreezeCCXT.create_order (Sync) called for {symbol} {side}")
adapters/ccxt_shim/breeze_ccxt.py:792:            self._check_fault_inject("create_order_fail")
adapters/ccxt_shim/breeze_ccxt.py:793:            self.rate_limiter.allow("create_order")
adapters/ccxt_shim/breeze_ccxt.py:794:            self.market_hours.assert_can_create_order(side, symbol)
adapters/ccxt_shim/breeze_ccxt.py:814:                    raise OperationalException(msg)
adapters/ccxt_shim/breeze_ccxt.py:822:                    raise OperationalException(msg)
adapters/ccxt_shim/breeze_ccxt.py:828:                    raise OperationalException(msg)
adapters/ccxt_shim/breeze_ccxt.py:844:                raise OperationalException(f"idempotency_block:{msg}")
adapters/ccxt_shim/breeze_ccxt.py:849:                ticker = self.fetch_ticker(symbol)
adapters/ccxt_shim/breeze_ccxt.py:858:                logger.warning(f"RiskGuard BLOCKED {side} order for {symbol}: {reason}")
adapters/ccxt_shim/breeze_ccxt.py:859:                raise OperationalException(f"risk_block:{reason}")
adapters/ccxt_shim/breeze_ccxt.py:865:            def position_check(sym: str) -> bool:
adapters/ccxt_shim/breeze_ccxt.py:867:                    positions = self.fetch_positions([sym])
adapters/ccxt_shim/breeze_ccxt.py:875:                        f"OrderRouter: fetch_positions failed during buyer_only check for {sym}"
adapters/ccxt_shim/breeze_ccxt.py:887:                logger.info("Intercepting create_order for Paper Execution Mode")
adapters/ccxt_shim/breeze_ccxt.py:922:                health_snapshot.update("call", {"method": "create_order", "duration": 0})
adapters/ccxt_shim/breeze_ccxt.py:944:                    raise OperationalException("Limit order requires price")
adapters/ccxt_shim/breeze_ccxt.py:979:                    raise OperationalException(f"Breeze place_order failed: {err}")
adapters/ccxt_shim/breeze_ccxt.py:987:                    raise OperationalException(f"Breeze place_order no ID: {success_data}")
adapters/ccxt_shim/breeze_ccxt.py:995:                health_snapshot.update("call", {"method": "create_order", "duration": 0})
adapters/ccxt_shim/breeze_ccxt.py:1015:                raise OperationalException(f"Live Execution Error: {e}")
adapters/ccxt_shim/breeze_ccxt.py:1021:    def _create_paper_order(self, symbol, order_type, side, amount):
adapters/ccxt_shim/breeze_ccxt.py:1024:            ticker = self.fetch_ticker(symbol)
adapters/ccxt_shim/breeze_ccxt.py:1088:            raise OperationalException(f"Paper Execution Error: {e}")
adapters/ccxt_shim/breeze_ccxt.py:1090:    def cancel_order(self, order_id, symbol=None, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:1094:                f"Paper mode cancel_order called for {order_id}. "
adapters/ccxt_shim/breeze_ccxt.py:1107:        self.rate_limiter.allow("cancel_order")
adapters/ccxt_shim/breeze_ccxt.py:1108:        self.market_hours.assert_can_cancel_order(order_id, str(symbol))
adapters/ccxt_shim/breeze_ccxt.py:1114:            raise OperationalException(f"Mock order {order_id} not found.")
adapters/ccxt_shim/breeze_ccxt.py:1115:        raise OperationalException("cancel_order not supported in real mode yet.")
adapters/ccxt_shim/breeze_ccxt.py:1117:    def edit_order(
adapters/ccxt_shim/breeze_ccxt.py:1130:        Enforces OrderRouter modification policies.
adapters/ccxt_shim/breeze_ccxt.py:1137:        logger.info(f"BreezeCCXT.edit_order called for {id} {symbol}")
adapters/ccxt_shim/breeze_ccxt.py:1144:        self.market_hours.assert_can_edit_order(id, str(symbol))
adapters/ccxt_shim/breeze_ccxt.py:1153:        logger.info(f"edit_order: Cancelling {id} to replace...")
adapters/ccxt_shim/breeze_ccxt.py:1154:        self.cancel_order(id, symbol)
adapters/ccxt_shim/breeze_ccxt.py:1158:        return self.create_order(symbol, order_type, side, amount, price, params)
adapters/ccxt_shim/breeze_ccxt.py:1160:    def fetch_order(self, order_id, symbol=None, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:1164:            raise OperationalException(f"Mock order {order_id} not found.")
adapters/ccxt_shim/breeze_ccxt.py:1165:        raise OperationalException("fetch_order not supported in real mode yet.")
adapters/ccxt_shim/breeze_ccxt.py:1167:    def fetch_open_orders(
adapters/ccxt_shim/breeze_ccxt.py:1179:        raise OperationalException("fetch_open_orders not supported in real mode yet.")
adapters/ccxt_shim/breeze_ccxt.py:1181:    def fetch_orders(
adapters/ccxt_shim/breeze_ccxt.py:1193:        raise OperationalException("fetch_orders not supported in real mode yet.")
adapters/ccxt_shim/breeze_ccxt.py:1195:    def fetch_positions(self, symbols: list[str] | None = None, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:1198:        raise OperationalException("fetch_positions not supported in real mode yet.")
adapters/ccxt_shim/breeze_ccxt.py:1200:    def _generate_mock_ticker(self, symbol: str) -> dict[str, Any]:
adapters/ccxt_shim/breeze_ccxt.py:1216:        health_snapshot.update("call", {"method": "fetch_ticker", "duration": 0})
adapters/ccxt_shim/breeze_ccxt.py:1219:    def _get_mock_data_path(self, symbol: str, timeframe: str) -> Path:
adapters/ccxt_shim/breeze_ccxt.py:1232:    def _generate_mock_ohlcv(
adapters/ccxt_shim/breeze_ccxt.py:1311:            health_snapshot.update("call", {"method": "fetch_ohlcv", "duration": 0})
adapters/ccxt_shim/breeze_ccxt.py:1314:        health_snapshot.update("call", {"method": "fetch_ohlcv", "duration": 0})
adapters/ccxt_shim/breeze_ccxt.py:1318:    def _mock_base_price(self, symbol: str) -> float:
adapters/ccxt_shim/breeze_ccxt.py:1335:class BreezeAsyncCCXT(ccxt_async.Exchange):
adapters/ccxt_shim/breeze_ccxt.py:1338:    def __init__(self, config: dict[str, Any] | None = None):
adapters/ccxt_shim/breeze_ccxt.py:1350:    def _is_mock_mode(self) -> bool:
adapters/ccxt_shim/breeze_ccxt.py:1353:    def _check_fault_inject(self, op: str):
adapters/ccxt_shim/breeze_ccxt.py:1357:            raise OperationalException(f"FT_FAULT_INJECT: {op}")
adapters/ccxt_shim/breeze_ccxt.py:1359:    def describe(self):
adapters/ccxt_shim/breeze_ccxt.py:1382:    async def load_markets(self, reload: bool = False, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:1395:    async def fetch_markets(self, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:1398:    async def fetch_ticker(self, symbol: str, params: dict | None = None):
adapters/ccxt_shim/breeze_ccxt.py:1399:        return 
```

## Coverage areas
- Market data fetch methods.
- Balance/account endpoints.
- Order lifecycle methods.
- Guard/exception pathways where implemented.
