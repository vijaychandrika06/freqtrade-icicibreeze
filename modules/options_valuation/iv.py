from typing import Optional

try:
    from py_vollib.black_scholes.implied_volatility import implied_volatility as iv_calc

    PY_VOLLIB_AVAILABLE = True
except ImportError:
    PY_VOLLIB_AVAILABLE = False


def calculate_iv(
    price: float, S: float, K: float, t: float, r: float, right: str
) -> Optional[float]:
    if not PY_VOLLIB_AVAILABLE:
        return None
    try:
        if t <= 0 or price <= 0:
            return None
        flag = right.lower()[0]
        return iv_calc(price, S, K, t, r, flag)
    except Exception:
        return None
