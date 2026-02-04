import logging
import sys
import os

sys.path.insert(0, os.getcwd())
from modules.options_valuation import calculate_iv, calculate_greeks

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("p47_check")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "pos"

    logger.info("P47_POS_START" if mode == "pos" else "P47_NEG_START")

    if mode == "pos":
        # Known case: Price=10, S=100, K=100, t=0.08 (1 month), r=0.05
        # Rough check
        iv = calculate_iv(10, 100, 100, 0.08, 0.05, "call")
        if iv and iv > 0:
            logger.info(f"IV: {iv}")
            logger.info("P47_IV_OK")

            g = calculate_greeks(iv, 100, 100, 0.08, 0.05, "call")
            if g.get("delta") and g.get("theta"):
                logger.info(f"Greeks: {g}")
                logger.info("P47_GREEKS_OK")
                logger.info("P47_PASS")
            else:
                logger.error("Greeks missing")
                sys.exit(1)
        else:
            logger.error("IV calc failed")
            sys.exit(1)

    else:
        # Invalid input
        iv = calculate_iv(0, 100, 100, 0.08, 0.05, "call")
        if iv is None:
            logger.info("P47_INVALID_INPUT_HANDLED")
            logger.info("P47_PASS")
        else:
            logger.error(f"Expected None for invalid input, got {iv}")
            sys.exit(1)


if __name__ == "__main__":
    main()
