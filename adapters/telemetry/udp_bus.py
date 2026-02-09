import json
import logging
import socket
import time
import os
from collections import defaultdict
from typing import Any, Dict

from adapters.telemetry.schema import TelemetryLevel, Layer, Severity, PORT_UI
from adapters.time.clock import get_clock

logger = logging.getLogger(__name__)


class UdpTelemetryBus:
    """
    Core Telemetry Bus sending JSONL via UDP.
    Handles Levels (0, 1, 2) and throttling.
    """

    def __init__(self, port: int, layer: str, run_id: str | None = None):
        self.port = port
        self.layer = layer
        self.host = os.environ.get("TELEMETRY_BIND", "127.0.0.1")
        self.run_id = run_id or f"run_{int(time.time())}"

        # Level configuration
        lvl = os.environ.get("TELEMETRY_LEVEL", "0")
        try:
            self.level = TelemetryLevel(lvl)
        except ValueError:
            self.level = TelemetryLevel.IDLE
            logger.warning(f"Invalid TELEMETRY_LEVEL {lvl}, defaulting to 0")

        self._sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self._sock.setblocking(False)

        # Anti-spam state
        self._last_emit = defaultdict(float)  # key -> timestamp
        self._emit_counts = defaultdict(int)  # key -> count in window

        # Emit startup ping if telemetry enabled
        if self.level != TelemetryLevel.IDLE:
            self._emit_startup_ping()

    def _emit_startup_ping(self):
        """Emit telemetry_ping event on initialization."""
        payload = {
            "telemetry_level": self.level.value,
            "bind": self.host,
            "port": self.port,
            "layer": self.layer,
        }
        # Use direct emit to bypass level checks for ping
        data = {
            "ts_utc": get_clock().now_utc().isoformat(),
            "layer": self.layer,
            "event": "telemetry_ping",
            "severity": "info",
            "run_id": self.run_id,
            "payload": payload,
        }
        try:
            msg = json.dumps(data).encode("utf-8")
            self._sock.sendto(msg, (self.host, self.port))
        except Exception:
            pass  # Silently ignore startup ping failures

    def emit(
        self,
        event: str,
        payload: Dict[str, Any] | None = None,
        severity: str = "info",
        level: str = "1",
    ):
        """
        Emit a telemetry event if current level allows.

        Args:
            event: Event ID string
            payload: Dict data
            severity: "debug", "info", "warn", "error"
            level: Minimum level required to emit this event ("1" or "2")
        """
        if self.level == TelemetryLevel.IDLE:
            return

        # Check level requirement
        # If event requires L2 ("2") but we are at L1 ("1"), skip.
        # Levels: 0 < 1 < 2
        req_val = int(level)
        curr_val = int(self.level.value)

        if curr_val < req_val:
            return

        # Throttle L2 events (simple anti-spam)
        if level == "2":
            key = f"{event}"
            now = time.time()
            # Max 5 per second per event type (rough)
            if now - self._last_emit[key] > 1.0:
                self._last_emit[key] = now
                self._emit_counts[key] = 0

            if self._emit_counts[key] > 5:
                return  # Throttled

            self._emit_counts[key] += 1

        # Construct Packet
        data = {
            "ts_utc": get_clock().now_utc().isoformat(),
            "layer": self.layer,
            "event": event,
            "severity": severity,
            "run_id": self.run_id,
            "payload": payload or {},
        }

        try:
            msg = json.dumps(data).encode("utf-8")
            self._sock.sendto(msg, (self.host, self.port))
        except Exception as e:
            # Telemetry should never crash app
            # Only log once periodically if needed, or suppress
            pass

    def close(self):
        try:
            self._sock.close()
        except:
            pass
