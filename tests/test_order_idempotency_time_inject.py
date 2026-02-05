import pytest
import time
from unittest import mock
from adapters.ccxt_shim.order_idempotency import OrderIdempotency


def test_idempotency_time_injection(tmp_path):
    """Verify OrderIdempotency uses injected time."""

    # Controlled time: 1000.0
    mock_now = mock.Mock(return_value=1000.0)

    # Needs to mock CACHE_FILE to avoid messing with real state
    with mock.patch(
        "adapters.ccxt_shim.order_idempotency.CACHE_FILE", tmp_path / "idempotency.json"
    ):
        idem = OrderIdempotency(now_fn=mock_now)

        # 1. Register uses injected time
        idem.register("order_1")
        assert idem._cache["order_1"] == 1000.0

        # 2. Cleanup uses injected time
        # Advance mock time to 1000 + 86401 (Expire items)
        mock_now.return_value = 1000.0 + 86400 + 1

        idem._cleanup()
        assert "order_1" not in idem._cache


def test_idempotency_default_time(tmp_path):
    """Verify OrderIdempotency defaults to system time if no injection."""

    with mock.patch(
        "adapters.ccxt_shim.order_idempotency.CACHE_FILE", tmp_path / "idempotency_default.json"
    ):
        idem = OrderIdempotency()
        # Should be roughly current time
        now = time.time()
        idem.register("order_default")

        stored = idem._cache["order_default"]
        assert stored == pytest.approx(now, abs=1.0)
