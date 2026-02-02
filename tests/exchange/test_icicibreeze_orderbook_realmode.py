import pytest
import os
from unittest.mock import MagicMock, patch
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT
from freqtrade.exceptions import OperationalException


def test_fetch_order_book_synthetic_success():
    ex = BreezeCCXT({"apiKey": "key", "secret": "secret"})

    # Mock ticker
    mock_ticker = {
        "symbol": "RELIANCE/INR",
        "last": 2500.0,
        "bid": 2499.0,
        "ask": 2501.0,
        "timestamp": 1600000000000,
        "datetime": "2020-09-13T12:26:40.000Z",
    }
    ex.fetch_ticker = MagicMock(return_value=mock_ticker)

    ob = ex.fetch_order_book("RELIANCE/INR")

    assert ob["symbol"] == "RELIANCE/INR"
    assert ob["bids"][0][0] == 2499.0  # Uses ticker bid
    assert ob["asks"][0][0] == 2501.0  # Uses ticker ask
    assert ob["bids"][0][1] == 1.0  # Default qty
    assert ob["timestamp"] == 1600000000000


def test_fetch_order_book_synthetic_from_last_price():
    ex = BreezeCCXT({"apiKey": "key", "secret": "secret"})

    # Ticker with only last price
    mock_ticker = {
        "symbol": "RELIANCE/INR",
        "last": 2500.0,
        "bid": None,
        "ask": None,
        "timestamp": 1600000000000,
        "datetime": "2020-09-13T12:26:40.000Z",
    }
    ex.fetch_ticker = MagicMock(return_value=mock_ticker)

    # Spread default 5 BPS (0.05%)
    # bid = 2500 * (1 - 0.0005) = 2498.75
    # ask = 2500 * (1 + 0.0005) = 2501.25

    ob = ex.fetch_order_book("RELIANCE/INR")

    assert ob["bids"][0][0] == 2498.75
    assert ob["asks"][0][0] == 2501.25
    assert ob["bids"][0][0] < ob["asks"][0][0]


@patch.dict(os.environ, {"FT_SYNTH_OB_SPREAD_BPS": "100", "FT_SYNTH_OB_QTY": "5.5"})
def test_fetch_order_book_env_overrides():
    ex = BreezeCCXT({"apiKey": "key", "secret": "secret"})

    mock_ticker = {
        "symbol": "RELIANCE/INR",
        "last": 2500.0,
        "bid": None,
        "ask": None,
        "timestamp": 1600000000000,
    }
    ex.fetch_ticker = MagicMock(return_value=mock_ticker)

    # spread 100 BPS = 1%
    # bid = 2500 * (1 - 0.01) = 2475.0
    # ask = 2500 * (1 + 0.01) = 2525.0
    # qty = 5.5

    ob = ex.fetch_order_book("RELIANCE/INR")

    assert ob["bids"][0][0] == 2475.0
    assert ob["asks"][0][0] == 2525.0
    assert ob["bids"][0][1] == 5.5
    assert ob["asks"][0][1] == 5.5


def test_fetch_order_book_ticker_missing_failure():
    ex = BreezeCCXT({"apiKey": "key", "secret": "secret"})

    # Ticker missing last
    mock_ticker = {"symbol": "RELIANCE/INR", "last": 0, "bid": None, "ask": None}
    ex.fetch_ticker = MagicMock(return_value=mock_ticker)

    with pytest.raises(OperationalException, match="ticker missing or invalid"):
        ex.fetch_order_book("RELIANCE/INR")


@patch.dict(os.environ, {"FT_SYNTH_OB_SPREAD_BPS": "invalid"})
def test_fetch_order_book_invalid_spread_env():
    ex = BreezeCCXT({"apiKey": "key", "secret": "secret"})
    ex.fetch_ticker = MagicMock(return_value={"last": 100})

    with pytest.raises(OperationalException, match="Invalid FT_SYNTH_OB_SPREAD_BPS"):
        ex.fetch_order_book("RELIANCE/INR")
