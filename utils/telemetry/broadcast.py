import json
import logging
import os
import socket
import time
from datetime import datetime, timezone
from typing import Dict, Any, Optional

logger = logging.getLogger(__name__)


class UdpBroadcaster:
    """
    Best-effort UDP broadcaster for localhost telemetry.
    Swallows errors to prevent impacting the main bot.
    """

    def __init__(
        self, port: int, topic: str, host: str = "127.0.0.1", enabled_env: str = "FT_TELEMETRY"
    ):
        self.host = host
        self.port = port
        self.topic = topic
        self.enabled = os.environ.get(enabled_env, "0") == "1"
        self.sock: Optional[socket.socket] = None
        self.last_emit = 0.0
        self.rate_limit_sec = 1.0  # Max 1 msg/sec per topic (unless error)

        if self.enabled:
            try:
                self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                self.sock.setblocking(False)
            except Exception as e:
                logger.debug(f"Telemetry socket init failed: {e}")

    def emit(
        self,
        msg: str,
        data: Optional[Dict[str, Any]] = None,
        level: str = "info",
        force: bool = False,
    ):
        if not self.enabled or not self.sock:
            return

        # Rate limit check (skip for errors or force)
        now = time.time()
        if level != "error" and not force and (now - self.last_emit < self.rate_limit_sec):
            return

        try:
            payload = {
                "ts": datetime.now(timezone.utc).isoformat(),
                "topic": self.topic,
                "level": level,
                "msg": msg,
                "data": data or {},
            }

            # Simple serialization
            # Redaction should happen caller-side, but we ensure basic safety here if feasible?
            # No, prompt says "secrets: never emit... redact". Caller responsibility.

            payload_bytes = json.dumps(payload, default=str).encode("utf-8")

            if len(payload_bytes) > 1400:
                # Truncate data if too large to avoid frag issues (best effort)
                payload["data"] = {"error": "payload_too_large", "len": len(payload_bytes)}
                payload_bytes = json.dumps(payload).encode("utf-8")

            self.sock.sendto(payload_bytes, (self.host, self.port))
            self.last_emit = now

        except Exception:
            # Swallow all errors
            pass

    def close(self):
        if self.sock:
            try:
                self.sock.close()
            except Exception:
                pass
            self.sock = None
