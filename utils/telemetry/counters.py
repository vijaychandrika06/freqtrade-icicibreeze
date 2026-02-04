from typing import Dict, Any


class TelemetryCounters:
    """
    Simple in-memory counter registry for telemetry.
    """

    _counters: Dict[str, int] = {}

    @classmethod
    def increment(cls, key: str, value: int = 1):
        cls._counters[key] = cls._counters.get(key, 0) + value

    @classmethod
    def set(cls, key: str, value: int):
        cls._counters[key] = value

    @classmethod
    def get(cls, key: str) -> int:
        return cls._counters.get(key, 0)

    @classmethod
    def snapshot(cls) -> Dict[str, int]:
        return cls._counters.copy()

    @classmethod
    def reset(cls):
        cls._counters.clear()
