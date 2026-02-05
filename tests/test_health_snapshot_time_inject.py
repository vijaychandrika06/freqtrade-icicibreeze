import pytest
from datetime import datetime, timezone
from unittest import mock
from adapters.ccxt_shim.health_snapshot import HealthSnapshot


def test_health_snapshot_time_injection(tmp_path):
    """Verify HealthSnapshot uses injected time."""

    fixed_time = datetime(2025, 1, 1, 12, 0, 0, tzinfo=timezone.utc)
    mock_now = mock.Mock(return_value=fixed_time)

    # Use distinct file for test
    test_file = tmp_path / "health.json"
    with mock.patch("adapters.ccxt_shim.health_snapshot.HEALTH_FILE", test_file):
        # We must create a fresh instance since it's a Singleton pattern,
        # but __init__ resets state anyway.
        # Wait, get_instance stores it. We should ideally bypass get_instance
        # or reset the singleton _instance for test isolation.

        HealthSnapshot._instance = None
        hs = HealthSnapshot(now_fn=mock_now)

        # 1. Record Call uses injected time
        hs.record_call("fetch_ticker")
        assert hs._last_calls["fetch_ticker_utc"] == fixed_time.isoformat()

        # 2. Persist uses injected time in meta
        hs.persist()

        import json

        with open(test_file) as f:
            data = json.load(f)
            assert data["meta"]["generated_at_utc"] == fixed_time.isoformat()


def test_health_snapshot_default_time(tmp_path):
    """Verify default behavior."""
    test_file = tmp_path / "health_default.json"
    with mock.patch("adapters.ccxt_shim.health_snapshot.HEALTH_FILE", test_file):
        HealthSnapshot._instance = None
        hs = HealthSnapshot()

        hs.record_call("fetch_ticker")
        # Should be recent
        stored = datetime.fromisoformat(hs._last_calls["fetch_ticker_utc"])
        assert (datetime.now(timezone.utc) - stored).total_seconds() < 2
