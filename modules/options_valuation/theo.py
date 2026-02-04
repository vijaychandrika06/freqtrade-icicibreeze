from typing import Optional

try:
    from py_vollib.black_scholes import black_scholes

    PY_VOLLIB_AVAILABLE = True
except ImportError:
    PY_VOLLIB_AVAILABLE = False


def calculate_theo(
    sigma: float, S: float, K: float, t: float, r: float, right: str
) -> Optional[float]:
    if not PY_VOLLIB_AVAILABLE or sigma is None:
        return None
    try:
        flag = right.lower()[0]
        return black_scholes(flag, S, K, t, r, sigma)
    except Exception:
        return None
