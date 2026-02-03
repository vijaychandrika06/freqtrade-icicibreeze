import pytest
import os
from unittest.mock import MagicMock
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT
from freqtrade.exceptions import OperationalException


def test_fetch_ohlcv_mock_no_security_master():
    """
    Assert that with BREEZE_MOCK=1, fetch_ohlcv works for an option pair
    even if it's not in the SecurityMaster.
    """
    os.environ["BREEZE_MOCK"] = "1"

    # Mocking config to be in mock mode
    config = {
        "exchange": {"name": "icicibreeze", "pair_whitelist": ["RELIANCE-20991231-9999-CE/INR"]}
    }

    exchange = BreezeCCXT(config)

    # Intentionally use a pair that is definitely NOT in any actual master
    symbol = "RELIANCE-20991231-9999-CE/INR"

    # Should not raise OperationalException("Option contract not found in SecurityMaster")
    try:
        ohlcv = exchange.fetch_ohlcv(symbol, timeframe="5m", limit=5)
        assert len(ohlcv) > 0
        # Check if first candle has expected structure [ts, o, h, l, c, v]
        assert len(ohlcv[0]) == 6
    except OperationalException as e:
        pytest.fail(f"fetch_ohlcv raised OperationalException: {e}")


def test_fetch_ohlcv_mock_determinism():
    """
    Assert that mock OHLCV is deterministic for a given symbol and timeframe.
    """
    os.environ["BREEZE_MOCK"] = "1"
    config = {"exchange": {"name": "icicibreeze"}}
    exchange = BreezeCCXT(config)

    symbol = "NIFTY-20991231-20000-CE/INR"

    ohlcv1 = exchange.fetch_ohlcv(symbol, timeframe="5m", limit=5)
    ohlcv2 = exchange.fetch_ohlcv(symbol, timeframe="5m", limit=5)

    assert ohlcv1 == ohlcv2
