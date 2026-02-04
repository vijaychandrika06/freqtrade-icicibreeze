from dataclasses import dataclass
from typing import Literal
import pandas as pd
import numpy as np


@dataclass
class RegimeOutput:
    regime: Literal["trend", "range", "unknown"]
    vol_state: Literal["expanding", "contracting", "neutral", "unknown"]
    confidence: float


class RegimeClassifier:
    def classify(self, df: pd.DataFrame) -> RegimeOutput:
        if df.empty or len(df) < 50:
            return RegimeOutput("unknown", "unknown", 0.0)

        # Simple Logic: SMA alignment
        try:
            close = df["close"]
            smashort = close.rolling(20).mean()
            smalong = close.rolling(50).mean()

            curr_short = smashort.iloc[-1]
            curr_long = smalong.iloc[-1]

            # Trend: Short > Long (Bull) or Short < Long (Bear).
            # Range: Close bouncing around means?
            # Let's use ADX proxy: High High - Low Low range?
            # Or just check slope of SMAs?

            # Simple Trend:
            trend_score = 0
            if abs(curr_short - curr_long) / curr_long > 0.005:
                # Diverged enough
                regime = "trend"
                trend_score = 0.8
            else:
                regime = "range"
                trend_score = 0.6

            # Volatility: Bollinger Band Width
            std = close.rolling(20).std()
            bb_upper = smashort + 2 * std
            bb_lower = smashort - 2 * std
            width = (bb_upper - bb_lower) / smashort

            width_ma = width.rolling(10).mean()
            curr_width = width.iloc[-1]
            prev_width = width_ma.iloc[-1]

            if curr_width > prev_width * 1.05:
                vol = "expanding"
            elif curr_width < prev_width * 0.95:
                vol = "contracting"
            else:
                vol = "neutral"

            return RegimeOutput(regime, vol, trend_score)

        except Exception:
            return RegimeOutput("unknown", "unknown", 0.0)
