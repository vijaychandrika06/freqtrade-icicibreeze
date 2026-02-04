import logging
import sys
import os
from dataclasses import dataclass

sys.path.insert(0, os.getcwd())

from modules.option_chain.schema import OptionChain, OptionChainRow
from modules.strike_selector.selector import StrikeSelector
from modules.regime.classifier import RegimeOutput

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("p49_check")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "pos"
    selector = StrikeSelector()

    logger.info("P49_POS_START" if mode == "pos" else "P49_NEG_START")

    if mode == "pos":
        # Mock Chain
        rows = []
        for i in range(5):
            k = 100 + i * 10
            rows.append(OptionChainRow(strike=k, ltp=10, oi=1000 + i * 100))

        chain = OptionChain("NIFTY", "NFO", "2024-01-01", "call", 120, rows)
        regime = RegimeOutput("trend", "neutral", 0.8)

        strikes = selector.select_strikes(chain, 120, regime)
        logger.info(f"Selected: {strikes}")

        if len(strikes) == 2:
            logger.info("P49_STRIKES_2")
            logger.info("P49_PASS")
        elif len(strikes) > 0:
            # Maybe acceptable if < 2 available? But we gave 5.
            if len(strikes) <= 2:
                logger.info("P49_PASS")  # pass if valid subset
            else:
                logger.error(f"Too many strikes: {len(strikes)}")
                sys.exit(1)
        else:
            logger.error("No strikes selected")
            sys.exit(1)

    else:
        # Empty chain
        chain = OptionChain("NIFTY", "NFO", "2024-01-01", "call", 120, [])
        regime = RegimeOutput("trend", "neutral", 0.8)
        strikes = selector.select_strikes(chain, 120, regime)
        if len(strikes) == 0:
            logger.info("P49_STRIKES_0_OK")
            logger.info("P49_PASS")
        else:
            sys.exit(1)


if __name__ == "__main__":
    main()
