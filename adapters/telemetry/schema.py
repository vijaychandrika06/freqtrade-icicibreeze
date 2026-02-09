"""Telemetry event schema and serialization."""

import json
from dataclasses import dataclass
from datetime import datetime, timezone
from enum import Enum
from typing import Any

# Ports
PORT_BREEZE = 17100
PORT_ENGINE = 17101
PORT_ORDERS = 17102
PORT_UI = 17103


class TelemetryLevel(str, Enum):
    IDLE = "0"
    L1 = "1"
    L2 = "2"


class Layer(str, Enum):
    BREEZE = "breeze"
    ENGINE = "engine"
    ORDERS = "orders"
    UI = "ui"


class Severity(str, Enum):
    DEBUG = "debug"
    INFO = "info"
    WARN = "warn"
    ERROR = "error"


@dataclass
class TelemetryEvent:
    """Standard telemetry event structure."""

    layer: str  # breeze, engine, orders, ui
    event: str  # event type (init, ping, contract_not_found, etc.)
    severity: str  # info, warn, error, debug
    timestamp: str  # ISO 8601 UTC
    payload: dict[str, Any]  # event-specific data

    @classmethod
    def create(
        cls,
        layer: str,
        event: str,
        severity: str = "info",
        payload: dict[str, Any] | None = None,
    ) -> "TelemetryEvent":
        """Create a new telemetry event with auto-generated timestamp."""
        return cls(
            layer=layer,
            event=event,
            severity=severity,
            timestamp=datetime.now(timezone.utc).isoformat(),
            payload=payload or {},
        )

    def to_json_line(self) -> str:
        """Serialize to JSON line (with newline)."""
        data = {
            "layer": self.layer,
            "event": self.event,
            "severity": self.severity,
            "timestamp": self.timestamp,
            "payload": self.payload,
        }
        return json.dumps(data, separators=(",", ":")) + "\n"
