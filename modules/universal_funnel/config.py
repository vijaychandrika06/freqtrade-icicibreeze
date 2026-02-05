from dataclasses import dataclass, field
from enum import Enum
from typing import List, Dict, Any, Optional
import pandas as pd


class InstrumentType(Enum):
    STOCK = "STOCK"
    INDEX = "INDEX"


class Direction(Enum):
    CE = "CE"
    PE = "PE"
    NONE = "NONE"


class RejectStage(Enum):
    NONE = "none"
    STAGE1 = "stage1"
    STAGE2 = "stage2"
    STAGE3 = "stage3"
    STAGE4 = "stage4"
    STAGE5 = "stage5"


@dataclass
class FunnelConfig:
    instrument_type: InstrumentType
    atr_pct_min: float
    liquidity_value_min: float
    atm_total_volume_min: float
    max_candidates_stage4: int = 5
    shortlist_max_underlyings: int = 3
    # Stage 3 check
    atm_window: int = 1  # ATM +/- 1
    # Stage 5
    penalize_blackout: bool = True


@dataclass
class FunnelInput:
    underlying: str
    instrument_type: InstrumentType
    ohlcv_5m: pd.DataFrame
    # Snapshot dict with 'expiry', 'rows' (list of OptionChainRow-like objs or dicts)
    # Expected fields in rows: ltp, volume, oi, strike, right (CE/PE)
    option_chain_snapshot: Dict[str, Any]
    direction_signal: Direction
    regime: str  # "trend", "range", "unknown"
    news_blackout_flag: bool


@dataclass
class FunnelResult:
    passed: bool
    reject_stage: RejectStage = RejectStage.NONE
    reject_reason: str = ""
    selected_direction: Direction = Direction.NONE
    selected_expiry: str = ""
    selected_strikes: List[float] = field(default_factory=list)
    score: float = 0.0
    debug: Dict[str, Any] = field(default_factory=dict)


# Calibrated Defaults from P52 Request
CALIBRATED_DEFAULTS = {
    InstrumentType.STOCK: FunnelConfig(
        instrument_type=InstrumentType.STOCK,
        atr_pct_min=0.65,
        liquidity_value_min=2000000.0,
        atm_total_volume_min=75000.0,
    ),
    InstrumentType.INDEX: FunnelConfig(
        instrument_type=InstrumentType.INDEX,
        atr_pct_min=0.77,
        liquidity_value_min=50000.0,
        atm_total_volume_min=150000.0,
    ),
}
