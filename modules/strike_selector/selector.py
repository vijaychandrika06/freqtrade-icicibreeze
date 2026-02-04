import logging
from typing import List, Dict, Any
from modules.option_chain.schema import OptionChain
from .scoring import score_contract
from modules.options_valuation import calculate_iv, calculate_greeks

logger = logging.getLogger("strike_selector")


class StrikeSelector:
    def __init__(self):
        pass

    def select_strikes(
        self,
        chain: OptionChain,
        spot: float,
        regime_info: Any,  # RegimeOutput
        risk_free_rate: float = 0.06,
        time_to_expiry_years: float = 0.05,
    ) -> List[float]:
        """
        Select exactly top 2 strikes.
        Returns list of strike prices.
        """
        candidates = []

        # Determine direction based on regime? Or passes "right" explicitly?
        # The chain has "right". We select strikes from that chain.
        # Assuming chain is already filtered for direction CE or PE required.

        # Filter first
        for row in chain.rows:
            # 1. Price sanity
            if row.ltp is None or row.ltp <= 0:
                continue

            # 2. Calc Greeks (On demand cost)
            # time_to_expiry should ideally come from expiry calc, passed in estimate for now

            iv = calculate_iv(
                row.ltp, spot, row.strike, time_to_expiry_years, risk_free_rate, chain.right
            )
            greeks = {}
            if iv:
                greeks = calculate_greeks(
                    iv, spot, row.strike, time_to_expiry_years, risk_free_rate, chain.right
                )

            # 3. Score
            score = score_contract(row, greeks, iv, regime_info.regime, regime_info.vol_state)

            candidates.append({"strike": row.strike, "score": score, "row": row})

        # Sort desc
        candidates.sort(key=lambda x: x["score"], reverse=True)

        # Pick top 2
        selected = [c["strike"] for c in candidates[:2]]

        # Sort strikes for cleanliness (e.g. ascending)
        selected.sort()

        return selected
