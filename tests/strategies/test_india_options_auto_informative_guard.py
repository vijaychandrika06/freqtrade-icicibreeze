import pytest
from unittest.mock import MagicMock
from datetime import datetime
import pandas as pd
from pandas import DataFrame
from user_data.strategies.IndiaOptionsAutoStrategy import IndiaOptionsAutoStrategy


def test_strategy_informative_guard():
    """
    Assert that if informative is empty or lacks 'close', strategy does not raise
    and emits P46_WARN_INFORMATIVE_MISSING.
    """
    strategy = IndiaOptionsAutoStrategy(config={})
    strategy.dp = MagicMock()

    # Mock empty dataframe for informative
    strategy.dp.get_pair_dataframe.return_value = DataFrame()

    metadata = {"pair": "RELIANCE-20260226-2800-CE/INR"}
    dataframe = DataFrame({"date": [datetime.now()], "close": [100.0]})

    # Reset warning cache
    strategy._last_warned = {}

    # Should not raise
    try:
        processed = strategy.populate_indicators(dataframe, metadata)
        # Columns should be ensured
        assert "ema_5_underlying" in processed.columns
        assert pd.isna(processed["ema_5_underlying"].iloc[0])
    except Exception as e:
        pytest.fail(f"populate_indicators raised an exception with empty informative: {e}")

    # Check if warning was cached
    assert (metadata["pair"], "P46_WARN_INFORMATIVE_MISSING") in strategy._last_warned


def test_strategy_informative_missing_close_column():
    """
    Assert that if informative lacks 'close' column, it still doesn't raise.
    """
    strategy = IndiaOptionsAutoStrategy(config={})
    strategy.dp = MagicMock()

    # Mock dataframe missing 'close'
    informative = DataFrame({"date": [datetime.now()], "volume": [1000]})
    strategy.dp.get_pair_dataframe.return_value = informative

    metadata = {"pair": "RELIANCE-20260226-2800-CE/INR"}
    dataframe = DataFrame({"date": [datetime.now()], "close": [100.0]})

    strategy._last_warned = {}

    try:
        processed = strategy.populate_indicators(dataframe, metadata)
        assert "ema_5_underlying" in processed.columns
    except Exception as e:
        pytest.fail(f"populate_indicators raised an exception with missing close column: {e}")

    assert (metadata["pair"], "P46_WARN_INFORMATIVE_MISSING") in strategy._last_warned
