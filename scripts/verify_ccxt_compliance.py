import ccxt
import logging
import sys
import os

# Ensure project root is in path
sys.path.insert(0, os.getcwd())

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Ensure we can import freqtrade.exchange.icicibreeze
# This import is needed to register the shim
try:
    import freqtrade.exchange.icicibreeze
    from freqtrade.exchange.icicibreeze import patch_ccxt

    patch_ccxt()
except ImportError as e:
    logger.error(f"Could not import freqtrade.exchange.icicibreeze: {e}")
    import traceback

    traceback.print_exc()
    sys.exit(1)
except Exception as e:
    logger.exception(f"Unexpected error during import: {e}")
    sys.exit(1)

logger.info(f"ccxt.icicibreeze present: {hasattr(ccxt, 'icicibreeze')}")

try:
    ex = ccxt.icicibreeze({"enableRateLimit": True, "breeze_mock": True})
    mk = ex.load_markets()

    logger.info(f"Markets count: {len(mk)}")
    logger.info(f"Symbols count: {len(ex.symbols) if ex.symbols else 0}")

    has_market = "BTC/USDT" in mk
    logger.info(f"has BTC/USDT in markets: {has_market}")

    has_symbol = "BTC/USDT" in ex.symbols if ex.symbols else False
    logger.info(f"symbols contains BTC/USDT: {has_symbol}")

    if has_market:
        logger.info(f"market: {ex.market('BTC/USDT')}")

        m = ex.market("BTC/USDT")
        logger.info(f"market active: {m.get('active')}")
        logger.info(f"market base: {m.get('base')}")
        logger.info(f"market quote: {m.get('quote')}")

except Exception:
    logger.exception("P19: Verification failed")
    sys.exit(1)
