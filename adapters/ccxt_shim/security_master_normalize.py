from datetime import datetime
import logging

logger = logging.getLogger(__name__)


def normalize_expiry(expiry_str: str) -> str:
    """
    Normalizes varied expiry string formats to YYYYMMDD.
    Supports:
      - YYYYMMDD
      - DD-MMM-YYYY (e.g., 26-FEB-2026)
      - DDMMMYYYY (e.g., 26FEB2026)
    Returns:
      Canonical YYYYMMDD string or original if parse fails.
    """
    if not expiry_str:
        return ""

    s = expiry_str.strip().upper()

    # Already YYYYMMDD?
    if len(s) == 8 and s.isdigit():
        # Basic validation
        try:
            datetime.strptime(s, "%Y%m%d")
            return s
        except ValueError:
            pass

    # DD-MMM-YYYY
    if "-" in s:
        try:
            dt = datetime.strptime(s, "%d-%b-%Y")
            return dt.strftime("%Y%m%d")
        except ValueError:
            pass

    # DDMMMYYYY
    try:
        dt = datetime.strptime(s, "%d%b%Y")
        return dt.strftime("%Y%m%d")
    except ValueError:
        pass

    # Fallback / Log
    # logger.debug(f"Could not normalize expiry: {expiry_str}")
    return s
