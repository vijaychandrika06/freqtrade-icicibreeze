import os
from unittest import mock
import pytest
from adapters.ccxt_shim.live_readiness import _env_bool, LiveReadiness


def test_env_bool_parsing():
    """Verify strict boolean parsing logic."""
    # Truthy values
    for val in ["1", "true", "True", "TRUE", "yes", "YES", "y", "on"]:
        with mock.patch.dict(os.environ, {"TEST_VAR": val}):
            assert _env_bool("TEST_VAR") is True

    # Falsy values
    for val in ["0", "false", "False", "no", "off", "random", ""]:
        with mock.patch.dict(os.environ, {"TEST_VAR": val}):
            assert _env_bool("TEST_VAR") is False

    # Missing
    with mock.patch.dict(os.environ, {}, clear=True):
        assert _env_bool("TEST_VAR", default=False) is False
        assert _env_bool("TEST_VAR", default=True) is True


def test_readiness_mock_flag_bool():
    """Verify check_readiness respects strict BREEZE_MOCK boolean."""
    config = {"icicibreeze": {}}  # No session token

    # CASE 1: BREEZE_MOCK="1" -> Should PASS (Token missing ignored)
    with mock.patch.dict(os.environ, {"BREEZE_MOCK": "1"}):
        # We need to mock other checks to pass or specifically check TOKEN code
        # We expect it NOT to return TOKEN_MISSING
        res = LiveReadiness.check_readiness(config)
        # It might fail on Disk or SM, but NOT Token
        if not res["ok"]:
            assert res["code"] != "TOKEN_MISSING"

    # CASE 2: BREEZE_MOCK="0" -> Should FAIL (Token missing)
    with mock.patch.dict(os.environ, {"BREEZE_MOCK": "0"}):
        res = LiveReadiness.check_readiness(config)
        assert res["ok"] is False
        assert res["code"] == "TOKEN_MISSING"

    # CASE 3: BREEZE_MOCK="random" -> Should FAIL (Token missing)
    with mock.patch.dict(os.environ, {"BREEZE_MOCK": "random"}):
        res = LiveReadiness.check_readiness(config)
        assert res["ok"] is False
        assert res["code"] == "TOKEN_MISSING"
