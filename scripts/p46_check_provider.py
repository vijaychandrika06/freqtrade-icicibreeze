import logging
import os
import sys

# Add project root to sys.path
sys.path.insert(0, os.getcwd())

from adapters.option_chain.breeze_option_chain_provider import BreezeOptionChainProvider

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("p46_check")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "pos"

    # Mock mode forced for deterministic gate check
    os.environ["BREEZE_MOCK"] = "1"

    provider = BreezeOptionChainProvider()

    logger.info("P46_SCAN_START" if mode == "pos" else "P46_NEG_START")

    if mode == "pos":
        # Test valid fetch
        logger.info("Fetching mock chain for NIFTY...")
        chain = provider.get_option_chain("NIFTY", "2026-02-26", "call")

        if chain and len(chain.rows) > 0:
            logger.info(f"Chain received: {len(chain.rows)} rows. Spot: {chain.spot_price}")
            logger.info("P46_CHAIN_NONEMPTY")
            logger.info("P46_PASS")
        else:
            logger.error("Chain empty or None in pos mode")
            sys.exit(1)

    else:
        # P55: Negative Test validating failure handling
        logger.info("Simulating negative case with underlying='FAIL'...")

        # We expect a valid OptionChain object but with 0 rows
        chain = provider.get_option_chain("FAIL", "2026-02-26", "call")

        if chain is None:
            # This is also acceptable if provider returns None on partial fail,
            # but mock implementation returns object with rows=[]
            logger.info("Provider returned None (acceptable failure).")
        elif len(chain.rows) == 0:
            logger.info("Provider returned empty chain (expected).")
        else:
            logger.error(f"Expected empty/failure, got {len(chain.rows)} rows")
            sys.exit(1)

        logger.info("P46_EXPECTED_EMPTY_OK")
        logger.info("P46_PASS")


if __name__ == "__main__":
    main()
