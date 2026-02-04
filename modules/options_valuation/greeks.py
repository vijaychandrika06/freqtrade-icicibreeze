try:
    from py_vollib.black_scholes.greeks.analytical import delta, gamma, theta, vega

    PY_VOLLIB_AVAILABLE = True
except ImportError:
    PY_VOLLIB_AVAILABLE = False


def calculate_greeks(sigma: float, S: float, K: float, t: float, r: float, right: str) -> dict:
    if not PY_VOLLIB_AVAILABLE or sigma is None:
        return {}
    try:
        flag = right.lower()[0]
        return {
            "delta": delta(flag, S, K, t, r, sigma),
            "gamma": gamma(flag, S, K, t, r, sigma),
            "theta": theta(flag, S, K, t, r, sigma),
            "vega": vega(flag, S, K, t, r, sigma),
        }
    except Exception:
        return {}
