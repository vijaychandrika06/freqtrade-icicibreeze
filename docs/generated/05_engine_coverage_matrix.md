# Engine coverage matrix (`modules/`)

## Module file inventory
- `modules/news_filter/__init__.py`
- `modules/news_filter/blackout_flag.py`
- `modules/option_chain/__init__.py`
- `modules/option_chain/provider_port.py`
- `modules/option_chain/schema.py`
- `modules/options_valuation/__init__.py`
- `modules/options_valuation/greeks.py`
- `modules/options_valuation/iv.py`
- `modules/options_valuation/theo.py`
- `modules/regime/__init__.py`
- `modules/regime/classifier.py`
- `modules/strike_selector/__init__.py`
- `modules/strike_selector/scoring.py`
- `modules/strike_selector/selector.py`
- `modules/universal_funnel/__init__.py`
- `modules/universal_funnel/config.py`
- `modules/universal_funnel/funnel.py`

## Key symbols (grep)
```text
modules/strike_selector/selector.py:3:from modules.option_chain.schema import OptionChain
modules/strike_selector/selector.py:7:logger = logging.getLogger("strike_selector")
modules/strike_selector/selector.py:10:class StrikeSelector:
modules/strike_selector/selector.py:11:    def __init__(self):
modules/strike_selector/selector.py:14:    def select_strikes(
modules/strike_selector/selector.py:16:        chain: OptionChain,
modules/strike_selector/selector.py:18:        regime_info: Any,  # RegimeOutput
modules/strike_selector/selector.py:28:        # Determine direction based on regime? Or passes "right" explicitly?
modules/strike_selector/selector.py:38:            # 2. Calc Greeks (On demand cost)
modules/strike_selector/selector.py:51:            score = score_contract(row, greeks, iv, regime_info.regime, regime_info.vol_state)
modules/strike_selector/scoring.py:4:def score_contract(
modules/strike_selector/scoring.py:5:    row: Any,  # OptionChainRow
modules/strike_selector/scoring.py:8:    regime: str,
modules/strike_selector/scoring.py:23:    if regime == "trend":
modules/regime/classifier.py:1:from dataclasses import dataclass
modules/regime/classifier.py:7:@dataclass
modules/regime/classifier.py:8:class RegimeOutput:
modules/regime/classifier.py:9:    regime: Literal["trend", "range", "unknown"]
modules/regime/classifier.py:14:class RegimeClassifier:
modules/regime/classifier.py:15:    def classify(self, df: pd.DataFrame) -> RegimeOutput:
modules/regime/classifier.py:37:                regime = "trend"
modules/regime/classifier.py:40:                regime = "range"
modules/regime/classifier.py:60:            return RegimeOutput(regime, vol, trend_score)
modules/news_filter/blackout_flag.py:4:def is_blackout(sentiment: Dict[str, Any], tone_threshold: float = -5.0) -> bool:
modules/option_chain/__init__.py:1:from .schema import OptionChain, OptionChainRow
modules/option_chain/__init__.py:2:from .provider_port import OptionChainProvider
modules/option_chain/__init__.py:4:__all__ = ["OptionChain", "OptionChainRow", "OptionChainProvider"]
modules/option_chain/provider_port.py:3:from .schema import OptionChain
modules/option_chain/provider_port.py:6:class OptionChainProvider(ABC):
modules/option_chain/provider_port.py:8:    def get_option_chain(self, underlying: str, expiry: str, right: str) -> Optional[OptionChain]:
modules/option_chain/schema.py:1:from dataclasses import dataclass
modules/option_chain/schema.py:5:@dataclass(frozen=True)
modules/option_chain/schema.py:6:class OptionChainRow:
modules/option_chain/schema.py:17:@dataclass(frozen=True)
modules/option_chain/schema.py:18:class OptionChain:
modules/option_chain/schema.py:24:    rows: List[OptionChainRow]
modules/options_valuation/greeks.py:9:def calculate_greeks(sigma: float, S: float, K: float, t: float, r: float, right: str) -> dict:
modules/options_valuation/iv.py:11:def calculate_iv(
modules/options_valuation/theo.py:11:def calculate_theo(
modules/universal_funnel/config.py:1:from dataclasses import dataclass, field
modules/universal_funnel/config.py:7:class InstrumentType(Enum):
modules/universal_funnel/config.py:12:class Direction(Enum):
modules/universal_funnel/config.py:18:class RejectStage(Enum):
modules/universal_funnel/config.py:27:@dataclass
modules/universal_funnel/config.py:28:class FunnelConfig:
modules/universal_funnel/config.py:41:@dataclass
modules/universal_funnel/config.py:42:class FunnelInput:
modules/universal_funnel/config.py:46:    # Snapshot dict with 'expiry', 'rows' (list of OptionChainRow-like objs or dicts)
modules/universal_funnel/config.py:50:    regime: str  # "trend", "range", "unknown"
modules/universal_funnel/config.py:54:@dataclass
modules/universal_funnel/config.py:55:class FunnelResult:
modules/universal_funnel/funnel.py:12:def evaluate(input_data: FunnelInput, config: FunnelConfig) -> FunnelResult:
modules/universal_funnel/funnel.py:95:    # The scanner uses OptionChainRow objects.
modules/universal_funnel/funnel.py:98:    def get_attr(item, key, default=None):
```

## Coverage areas
- Scanner and selection logic in `modules/`.
- Option/IV/regime related utilities where present.
