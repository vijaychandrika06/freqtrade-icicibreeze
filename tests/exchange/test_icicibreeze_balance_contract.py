import pytest
from unittest import mock
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT

MOCK_CONFIG = {
    "dry_run": True,
    "breeze_mock": True,
    "options": {"mode": "mock"},
    "risk_guard": {"enabled": False},
    "icicibreeze": {"session_token": "dummy"},
}

REAL_CONFIG = {
    "dry_run": False,
    "breeze_mock": False,
    "exchange": {"key": "k", "secret": "s"},
    "icicibreeze": {"session_token": "dummy"},
}


def test_fetch_balance_mock_contract():
    """Verify mock balance returns CCXT structure with INR."""
    exchange = BreezeCCXT(MOCK_CONFIG)
    bal = exchange.fetch_balance()

    # Must have free/used/total
    assert "free" in bal
    assert "used" in bal
    assert "total" in bal

    # Must have INR
    assert "INR" in bal["free"]
    assert bal["free"]["INR"] > 0


def test_fetch_balance_real_no_raise():
    """Verify real mode returns fallback without raising."""

    # We need to mock UdpTelemetryBus to avoid networking in real mode init if needed
    # But usually it binds localhost which is fine.

    # We must mock BreezeConnect validation or assume fail-fast passes if creds present
    # BREEZE_MOCK=False requires keys. We provided them in REAL_CONFIG.

    # We need to ensure we don't actually hit API.
    # BreezeCCXT in real mode tries to init BreezeConnect.
    # We should mock it.

    with mock.patch("adapters.ccxt_shim.breeze_ccxt.BreezeConnect"):
        exchange = BreezeCCXT(REAL_CONFIG)

        # Ensure fallback is hit (no get_funds on mock by default unless added)
        bal = exchange.fetch_balance()

        # Verify Fallback Contract
        assert bal["info"]["status"] == "unavailable"
        assert bal["info"]["mode"] == "real"
        assert bal["free"]["INR"] == 0.0
        assert bal["total"]["INR"] == 0.0


def test_fetch_balance_real_sdk_exception_safe():
    """Verify exception in SDK call is caught and fallback returned."""

    with mock.patch("adapters.ccxt_shim.breeze_ccxt.BreezeConnect") as MockBreeze:
        # Check if BreezeCCXT logic tries to call get_funds
        # The logic checks: if hasattr(self.breeze, "get_funds")

        mock_instance = MockBreeze.return_value
        # Setup get_funds to raise
        mock_instance.get_funds.side_effect = Exception("SDK Connection Error")

        exchange = BreezeCCXT(REAL_CONFIG)

        # Should not raise
        bal = exchange.fetch_balance()
        assert bal["info"]["status"] == "unavailable"
