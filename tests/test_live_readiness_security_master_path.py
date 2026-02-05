import os
import time
from pathlib import Path
from unittest import mock
import pytest
from adapters.ccxt_shim.live_readiness import LiveReadiness


@pytest.fixture
def clean_env():
    with mock.patch.dict(os.environ, {}, clear=True):
        yield


def test_readiness_finds_master_file(tmp_path, clean_env):
    """Verify readiness uses find_latest_master_file logic."""

    # Create valid config to bypass Token check
    config = {"icicibreeze": {"session_token": "dummy"}}

    # Mock disk space check to pass
    with mock.patch("shutil.disk_usage", return_value=(100, 50, 50 * 1024**3)):  # 50GB free
        # 1. No File -> FAIL
        with mock.patch(
            "adapters.ccxt_shim.security_master.find_latest_master_file", return_value=None
        ):
            res = LiveReadiness.check_readiness(config)
            assert res["ok"] is False
            assert res["code"] == "SEC_MASTER_MISSING"

        # 2. File Found (Fresh) -> PASS
        master_file = tmp_path / "FONSEScripMaster.txt"
        master_file.touch()

        with mock.patch(
            "adapters.ccxt_shim.security_master.find_latest_master_file",
            return_value=str(master_file),
        ):
            # Mock pair whitelist to pass step 4
            config["exchange"] = {"pair_whitelist": ["RELIANCE/INR"]}

            res = LiveReadiness.check_readiness(config)
            assert res["ok"] is True

        # 3. File Found (Stale) -> FAIL
        # Create a stale file (48 hours old)
        stale_time = time.time() - (48 * 3600)
        os.utime(master_file, (stale_time, stale_time))

        with mock.patch(
            "adapters.ccxt_shim.security_master.find_latest_master_file",
            return_value=str(master_file),
        ):
            res = LiveReadiness.check_readiness(config)
            assert res["ok"] is False
            assert res["code"] == "SEC_MASTER_STALE"
