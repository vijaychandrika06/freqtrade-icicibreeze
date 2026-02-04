from typing import Dict, Any, Optional


def score_contract(
    row: Any,  # OptionChainRow
    greeks: Dict[str, float],
    iv: Optional[float],
    regime: str,
    vol_state: str,
) -> float:
    score = 100.0

    # 1. Liquidity Score
    # Prefer higher OI/Vol
    if row.oi and row.oi > 0:
        score += math.log(row.oi) * 2

    # 2. Delta Alignment
    # Trend -> Delta 0.4-0.6 preferred?
    # Range -> ?
    delta = abs(greeks.get("delta", 0)) if greeks else 0.5

    if regime == "trend":
        # Target 50 delta
        dist = abs(delta - 0.50)
        score -= dist * 200
    else:
        # Range/Unknown: target slightly OTM?
        # Say 30 delta
        dist = abs(delta - 0.30)
        score -= dist * 200

    # 3. Theta Decay
    # If vol contracting, avoid high theta?
    theta = greeks.get("theta", 0)
    if vol_state == "contracting" and abs(theta) > 10:
        score -= 50

    return max(0.0, score)


import math
