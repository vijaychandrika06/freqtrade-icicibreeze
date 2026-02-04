import logging
import sys
import os

sys.path.insert(0, os.getcwd())
from adapters.news.gdelt_client import GDELTClient
from modules.news_filter.blackout_flag import is_blackout

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("p50_check")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "pos"
    client = GDELTClient()

    logger.info("P50_POS_START" if mode == "pos" else "P50_NEG_START")

    if mode == "pos":
        # Simulate Negative News
        # Manually verify logic not just client
        bad_sentiment = {"tone": -6.0, "status": "ok"}
        if is_blackout(bad_sentiment, tone_threshold=-5.0):
            logger.info("Blackout logic verified for bad sentiment.")
            logger.info("P50_BLACKOUT_TRUE")
            logger.info("P50_PASS")
        else:
            logger.error("Blackout failed to trigger")
            sys.exit(1)
    else:
        # Simulate Provider Error
        err_sentiment = {"status": "error"}
        if not is_blackout(err_sentiment):
            logger.info("Provider error handled (default allow).")
            logger.info("P50_PROVIDER_DOWN_HANDLED")
            logger.info("P50_PASS")
        else:
            logger.error("Blackout triggered on error (should default allow)")
            sys.exit(1)


if __name__ == "__main__":
    main()
