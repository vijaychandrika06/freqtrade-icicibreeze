from dataclasses import dataclass
from typing import List, Optional


@dataclass(frozen=True)
class OptionChainRow:
    strike: float
    ltp: Optional[float] = None
    bid: Optional[float] = None
    ask: Optional[float] = None
    volume: Optional[float] = None
    oi: Optional[float] = None
    d_oi: Optional[float] = None
    timestamp: Optional[str] = None


@dataclass(frozen=True)
class OptionChain:
    underlying: str
    exchange_code: str
    expiry: str
    right: str  # "call" | "put"
    spot_price: Optional[float]
    rows: List[OptionChainRow]
