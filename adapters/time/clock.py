import os
import logging
from datetime import datetime, timezone, timedelta
from typing import Optional

logger = logging.getLogger(__name__)

# IST: UTC + 5:30
IST_OFFSET = timezone(timedelta(hours=5, minutes=30))


class Clock:
    """Base Clock interface."""

    def now_utc(self) -> datetime:
        raise NotImplementedError

    def now_ist(self) -> datetime:
        return self.now_utc().astimezone(IST_OFFSET)


class SystemClock(Clock):
    """Uses real system time (UTC)."""

    def now_utc(self) -> datetime:
        return datetime.now(timezone.utc)


class EnvClock(Clock):
    """
    Deterministically overrides time if FT_IST_NOW is set.
    Otherwise falls back to system time.
    """

    def __init__(self):
        self._override: Optional[datetime] = None
        self.reload()

    def reload(self):
        val = os.environ.get("FT_IST_NOW")
        if val:
            try:
                # Expect ISO8601, typically with offset, or we assume IST?
                # Prompt example: "2026-02-05T10:15:00+05:30"
                dt = datetime.fromisoformat(val)
                if dt.tzinfo is None:
                    # If naive, assume it's the IST time the user wanted
                    # But better to assume strict ISO.
                    # Let's align with market_hours logic: "injected_time"
                    # We will treat it as "Target Time".
                    # To be safe, convert to UTC internally.
                    dt = dt.replace(tzinfo=IST_OFFSET)  # Assume input was IST if naive

                self._override = dt.astimezone(timezone.utc)
            except ValueError:
                logger.warning(f"Invalid FT_IST_NOW: {val}. Using system time.")
                self._override = None
        else:
            self._override = None

    def now_utc(self) -> datetime:
        self.reload()  # Check env every call to allow dynamic updates in tests
        if self._override:
            return self._override
        return datetime.now(timezone.utc)


def get_clock() -> Clock:
    """Factory to get the appropriate clock."""
    # We always use EnvClock which handles fallback
    return EnvClock()
