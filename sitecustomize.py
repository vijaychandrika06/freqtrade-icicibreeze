"""
CCXT bootstrap for in-repo development.
Ensures ccxt.icicibreeze and ccxt.async_support.icicibreeze are registered early.
Safe: no secrets, no network, no side effects besides class registration.
"""

import os


def _truthy(name: str, default: str = "0") -> bool:
    v = os.environ.get(name, default).strip().lower()
    return v in ("1", "true", "yes", "y", "on")


# Allow opt-out
if _truthy("FT_DISABLE_CCXT_BOOTSTRAP", "0"):
    raise SystemExit  # stops loading sitecustomize

try:
    import ccxt
    import ccxt.async_support as ccxt_async
except Exception:
    # If ccxt isn't installed/available, do nothing.
    ccxt = None
    ccxt_async = None

if ccxt is None:
    # nothing to do
    pass
else:
    try:
        # Import our shim classes (these must be pure imports; no session side effects)
        from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT, BreezeAsyncCCXT
    except Exception:
        # If the shim cannot import, do not break interpreter startup.
        BreezeCCXT = None
        BreezeAsyncCCXT = None

    def _register(module, klass):
        if module is None or klass is None:
            return
        # ccxt expects lowercase exchange id
        if not hasattr(module, "icicibreeze"):
            setattr(module, "icicibreeze", klass)
        # Also keep ccxt.exchanges list aligned when present
        try:
            ex_list = getattr(module, "exchanges", None)
            if isinstance(ex_list, list) and "icicibreeze" not in ex_list:
                ex_list.append("icicibreeze")
        except Exception:
            pass

    _register(ccxt, BreezeCCXT)
    _register(ccxt_async, BreezeAsyncCCXT)
