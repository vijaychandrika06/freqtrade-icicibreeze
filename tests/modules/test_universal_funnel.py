import unittest
import pandas as pd
import sys
import os
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from unittest.mock import MagicMock
from modules.universal_funnel.config import (
    FunnelInput,
    FunnelConfig,
    InstrumentType,
    Direction,
    RejectStage,
)
from modules.universal_funnel.funnel import evaluate


class TestUniversalFunnel(unittest.TestCase):
    def setUp(self):
        self.stock_config = FunnelConfig(
            instrument_type=InstrumentType.STOCK,
            atr_pct_min=1.0,
            liquidity_value_min=1000000.0,
            atm_total_volume_min=50000.0,
        )
        self.index_config = FunnelConfig(
            instrument_type=InstrumentType.INDEX,
            atr_pct_min=0.5,
            liquidity_value_min=5000000.0,
            atm_total_volume_min=100000.0,
        )

        # Mock Data
        self.dates = pd.date_range("2024-01-01", periods=100, freq="5min")
        self.close = [100.0] * 100
        # Make ATR calc possible
        self.high = [102.0] * 100
        self.low = [98.0] * 100
        self.volume = [10000] * 100  # 100 * 10000 = 1M liquidity

        self.df = pd.DataFrame(
            {
                "open": self.close,
                "high": self.high,
                "low": self.low,
                "close": self.close,
                "volume": self.volume,
            },
            index=self.dates,
        )

    def test_stage2_reject_atr(self):
        # ATR ~ 4.0. % = 4%. Passes 1.0.
        # Let's make ATR very low.
        df_flat = self.df.copy()
        df_flat["high"] = 100.1
        df_flat["low"] = 99.9
        # ATR ~ 0.2. % = 0.2%. Fails 1.0.

        inp = FunnelInput(
            underlying="TEST",
            instrument_type=InstrumentType.STOCK,
            ohlcv_5m=df_flat,
            option_chain_snapshot={
                "rows": []
            },  # Empty chain usually stage 1, but if stage 2 runs first?
            # Code checks chain presence in Stage 1.
            # So providing empty dict fails stage 1.
            # Need dummy chain.
            direction_signal=Direction.CE,
            regime="trend",
            news_blackout_flag=False,
        )
        # Add dummy chain row
        inp.option_chain_snapshot = {"rows": [{"strike": 100, "ltp": 5, "volume": 100000}]}

        res = evaluate(inp, self.stock_config)
        # Should fail Stage 2 due to low ATR
        self.assertEqual(res.reject_stage, RejectStage.STAGE2)
        self.assertIn("Low Volatility", res.reject_reason)

    def test_stage2_reject_liquidity(self):
        # Liquidity 1M. Config min 1M. (Passes)
        # Set Vol to 0
        df_low = self.df.copy()
        df_low["volume"] = 0

        inp = FunnelInput(
            underlying="TEST",
            instrument_type=InstrumentType.STOCK,
            ohlcv_5m=df_low,
            option_chain_snapshot={"rows": [{"strike": 100, "ltp": 5, "volume": 100000}]},
            direction_signal=Direction.CE,
            regime="trend",
            news_blackout_flag=False,
        )

        res = evaluate(inp, self.stock_config)
        self.assertEqual(res.reject_stage, RejectStage.STAGE2)
        self.assertIn("Low Liquidity", res.reject_reason)

    def test_stage3_reject_volume(self):
        # Config Min 50k.
        # ATM Volume 100k (passes).
        # Set chain volume low.

        inp = FunnelInput(
            underlying="TEST",
            instrument_type=InstrumentType.STOCK,
            ohlcv_5m=self.df,  # Passes S2
            option_chain_snapshot={"rows": [{"strike": 100, "ltp": 5, "volume": 100}]},  # 100 < 50k
            direction_signal=Direction.CE,
            regime="trend",
            news_blackout_flag=False,
        )

        res = evaluate(inp, self.stock_config)
        self.assertEqual(res.reject_stage, RejectStage.STAGE3)
        self.assertIn("Low Option Volume", res.reject_reason)

    def test_stage4_pass(self):
        # Should pass all
        inp = FunnelInput(
            underlying="TEST",
            instrument_type=InstrumentType.STOCK,
            ohlcv_5m=self.df,
            option_chain_snapshot={
                "rows": [
                    {"strike": 99, "ltp": 6, "volume": 30000},
                    {"strike": 100, "ltp": 5, "volume": 30000},
                    {"strike": 101, "ltp": 4, "volume": 30000},
                ],
                "expiry": "2024-02-28",
            },  # Total vol 90k > 50k
            direction_signal=Direction.CE,
            regime="trend",
            news_blackout_flag=False,
        )

        res = evaluate(inp, self.stock_config)
        self.assertTrue(res.passed)
        self.assertEqual(len(res.selected_strikes), 3)  # ATM+/-1
        self.assertEqual(res.selected_direction, Direction.CE)


if __name__ == "__main__":
    unittest.main()
