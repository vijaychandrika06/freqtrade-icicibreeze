# Class inventory

Extracted via `rg -n "^class\s+"` across adapter/modules/strategies/freqtrade.

```text
user_data/strategies/IcbcSmokeStrategy.py:40:class IcbcSmokeStrategy(IStrategy):
user_data/strategies/IndiaStockOptionsStrategy.py:19:class IndiaStockOptionsStrategy(IStrategy):
user_data/strategies/smart_money_fr203.py:11:class StrikeRow:
user_data/strategies/smart_money_fr203.py:21:class OptionChainSnapshot:
user_data/strategies/smart_money_fr203.py:28:class SmartMoneyDecision:
user_data/strategies/smart_money_fr203.py:34:class SmartMoneyEngine:
user_data/strategies/IndiaIndexOptionsStrategy.py:19:class IndiaIndexOptionsStrategy(IStrategy):
user_data/strategies/IndiaOptionsBaseStrategy.py:4:class IndiaOptionsBaseStrategy(IStrategy):
user_data/strategies/indicator_registry.py:11:class IndicatorSpec:
user_data/strategies/indicator_registry.py:18:class IndicatorRegistry:
user_data/strategies/IndiaEquitySmokeStrategy.py:17:class IndiaEquitySmokeStrategy(IStrategy):
user_data/strategies/IndiaOptionsAutoStrategy.py:20:class IndiaOptionsAutoStrategy(IStrategy):
adapters/telemetry/udp_bus.py:15:class UdpTelemetryBus:
adapters/telemetry/schema.py:10:class TelemetryLevel(str, Enum):
adapters/telemetry/schema.py:16:class Layer(str, Enum):
adapters/telemetry/schema.py:23:class Severity(str, Enum):
adapters/ccxt_shim/live_readiness.py:26:class LiveReadiness:
adapters/ccxt_shim/rate_limiter.py:11:class RateLimiter:
adapters/ccxt_shim/market_hours.py:28:class MarketHoursGuard:
freqtrade/persistence/usedb_context.py:27:class FtNoDBContext:
adapters/ccxt_shim/health_snapshot.py:13:class HealthSnapshot:
freqtrade/persistence/pairlock_middleware.py:14:class PairLocks:
freqtrade/persistence/key_value_store.py:14:class ValueTypesEnum(str, Enum):
freqtrade/persistence/key_value_store.py:28:class _KeyValueStoreModel(ModelBase):
freqtrade/persistence/key_value_store.py:48:class KeyValueStore:
freqtrade/persistence/pairlock.py:11:class PairLock(ModelBase):
adapters/ccxt_shim/breeze_ccxt.py:49:class BreezeCCXT(ccxt.Exchange):
adapters/ccxt_shim/breeze_ccxt.py:1335:class BreezeAsyncCCXT(ccxt_async.Exchange):
freqtrade/persistence/base.py:7:class ModelBase(DeclarativeBase):
adapters/ccxt_shim/paper_ledger.py:13:class PaperLedger:
adapters/ccxt_shim/policy_codes.py:7:class PolicyCode:
freqtrade/persistence/custom_data.py:18:class _CustomData(ModelBase):
freqtrade/persistence/custom_data.py:81:class CustomDataWrapper:
adapters/ccxt_shim/alerts.py:8:class AlertManager:
adapters/ccxt_shim/security_master.py:15:class SecurityMaster:
adapters/ccxt_shim/instrument.py:8:class InstrumentType(str, Enum):
adapters/ccxt_shim/instrument.py:15:class InstrumentSpec:
freqtrade/persistence/trade_model.py:58:class ProfitStruct:
freqtrade/persistence/trade_model.py:65:class Order(ModelBase):
freqtrade/persistence/trade_model.py:381:class LocalTrade:
freqtrade/persistence/trade_model.py:1645:class Trade(ModelBase, LocalTrade):
adapters/ccxt_shim/degraded_mode.py:12:class DegradedModeGuard:
adapters/ccxt_shim/risk_guard.py:16:class RiskGuard:
adapters/ccxt_shim/order_router.py:12:class OrderRouter:
adapters/ccxt_shim/order_idempotency.py:15:class OrderIdempotency:
adapters/time/clock.py:12:class Clock:
adapters/time/clock.py:22:class SystemClock(Clock):
adapters/time/clock.py:29:class EnvClock(Clock):
adapters/option_chain/breeze_option_chain_provider.py:19:class BreezeOptionChainProvider(OptionChainProvider):
freqtrade/loggers/std_err_stream_handler.py:5:class FTStdErrStreamHandler(Handler):
freqtrade/loggers/ft_rich_handler.py:9:class FtRichHandler(Handler):
adapters/news/gdelt_client.py:9:class GDELTClient:
freqtrade/loggers/json_formatter.py:5:class JsonFormatter(logging.Formatter):
freqtrade/loggers/buffering_handler.py:4:class FTBufferingHandler(BufferingHandler):
freqtrade/plugins/pairlistmanager.py:26:class PairListManager(LoggingMixin):
freqtrade/plugins/protectionmanager.py:20:class ProtectionManager:
freqtrade/configuration/timerange.py:18:class TimeRange:
freqtrade/plugins/pairlist/PriceFilter.py:15:class PriceFilter(IPairList):
freqtrade/configuration/configuration.py:34:class Configuration:
freqtrade/plugins/pairlist/VolumePairList.py:25:class VolumePairList(IPairList):
freqtrade/plugins/pairlist/PercentChangePairList.py:26:class SymbolWithPercentage(TypedDict):
freqtrade/plugins/pairlist/PercentChangePairList.py:31:class PercentChangePairList(IPairList):
freqtrade/plugins/pairlist/VolatilityFilter.py:23:class VolatilityFilter(IPairList):
freqtrade/plugins/pairlist/RemotePairList.py:26:class RemotePairList(IPairList):
freqtrade/plugins/pairlist/AgeFilter.py:22:class AgeFilter(IPairList):
freqtrade/plugins/pairlist/FullTradesFilter.py:15:class FullTradesFilter(IPairList):
freqtrade/strategy/strategy_validation.py:12:class StrategyResultValidator:
freqtrade/plugins/pairlist/ShuffleFilter.py:21:class ShuffleFilter(IPairList):
freqtrade/strategy/informative_decorator.py:16:class InformativeData:
freqtrade/plugins/pairlist/rangestabilityfilter.py:21:class RangeStabilityFilter(IPairList):
freqtrade/strategy/strategyupdater.py:9:class StrategyUpdater:
freqtrade/strategy/strategyupdater.py:115:class NameUpdater(ast_comments.NodeTransformer):
freqtrade/plugins/pairlist/IPairList.py:21:class __PairlistParameterBase(TypedDict):
freqtrade/plugins/pairlist/IPairList.py:26:class __NumberPairlistParameter(__PairlistParameterBase):
freqtrade/plugins/pairlist/IPairList.py:31:class __StringPairlistParameter(__PairlistParameterBase):
freqtrade/plugins/pairlist/IPairList.py:36:class __OptionPairlistParameter(__PairlistParameterBase):
freqtrade/plugins/pairlist/IPairList.py:42:class __ListPairListParamenter(__PairlistParameterBase):
freqtrade/plugins/pairlist/IPairList.py:47:class __BoolPairlistParameter(__PairlistParameterBase):
freqtrade/plugins/pairlist/IPairList.py:61:class SupportsBacktesting(str, Enum):
freqtrade/plugins/pairlist/IPairList.py:72:class IPairList(LoggingMixin, ABC):
freqtrade/plugins/pairlist/ProducerPairList.py:17:class ProducerPairList(IPairList):
freqtrade/strategy/parameters.py:30:class BaseParameter(ABC):
freqtrade/strategy/parameters.py:87:class NumericParameter(BaseParameter):
freqtrade/strategy/parameters.py:132:class IntParameter(NumericParameter):
freqtrade/strategy/parameters.py:189:class RealParameter(NumericParameter):
freqtrade/strategy/parameters.py:229:class DecimalParameter(NumericParameter):
freqtrade/strategy/parameters.py:298:class CategoricalParameter(BaseParameter):
freqtrade/strategy/parameters.py:354:class BooleanParameter(CategoricalParameter):
freqtrade/plugins/pairlist/SpreadFilter.py:15:class SpreadFilter(IPairList):
freqtrade/plugins/pairlist/DelistFilter.py:17:class DelistFilter(IPairList):
freqtrade/strategy/hyper.py:26:class HyperStrategyMixin:
freqtrade/plugins/pairlist/OffsetFilter.py:15:class OffsetFilter(IPairList):
freqtrade/plugins/pairlist/MarketCapPairList.py:20:class MarketCapPairList(IPairList):
freqtrade/plugins/pairlist/PerformanceFilter.py:19:class PerformanceFilter(IPairList):
freqtrade/plugins/pairlist/StaticPairList.py:20:class StaticPairList(IPairList):
freqtrade/strategy/interface.py:51:class IStrategy(ABC, HyperStrategyMixin):
freqtrade/plugins/pairlist/PrecisionFilter.py:16:class PrecisionFilter(IPairList):
freqtrade/plugins/protections/stoploss_guard.py:14:class StoplossGuard(IProtection):
freqtrade/plugins/protections/cooldown_period.py:12:class CooldownPeriod(IProtection):
freqtrade/plugins/protections/iprotection.py:18:class ProtectionReturn:
freqtrade/plugins/protections/iprotection.py:25:class IProtection(LoggingMixin, ABC):
freqtrade/plugins/protections/max_drawdown_protection.py:16:class MaxDrawdown(IProtection):
freqtrade/freqtradebot.py:73:class FreqtradeBot(LoggingMixin):
freqtrade/plugins/protections/low_profit_pairs.py:13:class LowProfitPairs(IProtection):
freqtrade/enums/marginmode.py:4:class MarginMode(str, Enum):
freqtrade/data/metrics.py:191:class DrawDownResult:
freqtrade/enums/pricetype.py:4:class PriceType(str, Enum):
freqtrade/enums/exitchecktuple.py:4:class ExitCheckTuple:
freqtrade/enums/runmode.py:4:class RunMode(str, Enum):
freqtrade/enums/candletype.py:4:class CandleType(str, Enum):
freqtrade/enums/state.py:4:class State(Enum):
freqtrade/enums/ordertypevalue.py:4:class OrderTypeValues(str, Enum):
freqtrade/enums/exittype.py:4:class ExitType(Enum):
freqtrade/enums/signaltype.py:4:class SignalType(Enum):
freqtrade/enums/signaltype.py:18:class SignalTagType(Enum):
freqtrade/enums/signaltype.py:30:class SignalDirection(str, Enum):
freqtrade/enums/backteststate.py:4:class BacktestState(Enum):
freqtrade/enums/marketstatetype.py:4:class MarketDirection(Enum):
freqtrade/enums/tradingmode.py:4:class TradingMode(str, Enum):
freqtrade/enums/hyperoptstate.py:4:class HyperoptState(Enum):
freqtrade/data/history/datahandlers/idatahandler.py:33:class IDataHandler(ABC):
freqtrade/enums/rpcmessagetype.py:4:class RPCMessageType(str, Enum):
freqtrade/enums/rpcmessagetype.py:35:class RPCRequestType(str, Enum):
freqtrade/data/history/datahandlers/jsondatahandler.py:18:class JsonDataHandler(IDataHandler):
freqtrade/data/history/datahandlers/jsondatahandler.py:149:class JsonGzDataHandler(JsonDataHandler):
freqtrade/data/history/datahandlers/parquetdatahandler.py:15:class ParquetDataHandler(IDataHandler):
freqtrade/data/history/datahandlers/featherdatahandler.py:16:class FeatherDataHandler(IDataHandler):
freqtrade/resolvers/pairlist_resolver.py:18:class PairListResolver(IResolver):
freqtrade/resolvers/iresolver.py:22:class PathModifier:
freqtrade/resolvers/iresolver.py:38:class IResolver:
freqtrade/resolvers/freqaimodel_resolver.py:19:class FreqaiModelResolver(IResolver):
freqtrade/resolvers/exchange_resolver.py:18:class ExchangeResolver(IResolver):
freqtrade/data/dataprovider.py:39:class DataProvider:
freqtrade/resolvers/protection_resolver.py:16:class ProtectionResolver(IResolver):
freqtrade/resolvers/hyperopt_resolver.py:19:class HyperOptLossResolver(IResolver):
freqtrade/resolvers/strategy_resolver.py:26:class StrategyResolver(IResolver):
freqtrade/exceptions.py:1:class FreqtradeException(Exception):
freqtrade/exceptions.py:8:class OperationalException(FreqtradeException):
freqtrade/exceptions.py:15:class ConfigurationError(OperationalException):
freqtrade/exceptions.py:21:class DependencyException(FreqtradeException):
freqtrade/exceptions.py:28:class PricingError(DependencyException):
freqtrade/exceptions.py:36:class ExchangeError(DependencyException):
freqtrade/exceptions.py:43:class InvalidOrderException(ExchangeError):
freqtrade/exceptions.py:51:class RetryableOrderError(InvalidOrderException):
freqtrade/exceptions.py:58:class InsufficientFundsError(InvalidOrderException):
freqtrade/exceptions.py:65:class TemporaryError(ExchangeError):
freqtrade/exceptions.py:73:class DDosProtection(TemporaryError):
freqtrade/exceptions.py:80:class StrategyError(FreqtradeException):
freqtrade/ft_types/valid_exchanges_type.py:6:class TradeModeType(TypedDict):
freqtrade/ft_types/valid_exchanges_type.py:11:class ValidExchangesType(TypedDict):
freqtrade/ft_types/plot_annotation_type.py:8:class _BaseAnnotationType(TypedDict, total=False):
freqtrade/ft_types/plot_annotation_type.py:14:class _Base2DAnnotationType(_BaseAnnotationType, total=False):
freqtrade/ft_types/plot_annotation_type.py:21:class AreaAnnotationType(_Base2DAnnotationType, total=False):
freqtrade/ft_types/plot_annotation_type.py:25:class LineAnnotationType(_Base2DAnnotationType, total=False):
freqtrade/ft_types/plot_annotation_type.py:31:class PointAnnotationType(_BaseAnnotationType, total=False):
freqtrade/ft_types/backtest_result_type.py:10:class BacktestMetadataType(TypedDict):
freqtrade/ft_types/backtest_result_type.py:15:class BacktestResultType(TypedDict):
freqtrade/ft_types/backtest_result_type.py:34:class BacktestHistoryEntryType(BacktestMetadataType):
freqtrade/ft_types/backtest_result_type.py:44:class BacktestContentTypeIcomplete(TypedDict, total=False):
freqtrade/ft_types/backtest_result_type.py:60:class BacktestContentType(BacktestContentTypeIcomplete, total=True):
freqtrade/templates/sample_strategy.py:40:class SampleStrategy(IStrategy):
freqtrade/commands/cli_options.py:39:class Arg:
freqtrade/templates/base_strategy.py.j2:40:class {{ strategy }}(IStrategy):
freqtrade/templates/FreqaiExampleHybridStrategy.py:15:class FreqaiExampleHybridStrategy(IStrategy):
freqtrade/templates/sample_hyperopt_loss.py:27:class SampleHyperOptLoss(IHyperOptLoss):
freqtrade/commands/arguments.py:307:class Arguments:
freqtrade/templates/FreqaiExampleStrategy.py:14:class FreqaiExampleStrategy(IStrategy):
freqtrade/freqai/torch/PyTorchDataConvertor.py:7:class PyTorchDataConvertor(ABC):
freqtrade/freqai/torch/PyTorchDataConvertor.py:28:class DefaultPyTorchDataConvertor(PyTorchDataConvertor):
freqtrade/freqai/torch/PyTorchTrainerInterface.py:9:class PyTorchTrainerInterface(ABC):
freqtrade/freqai/torch/datasets.py:4:class WindowDataset(torch.utils.data.Dataset):
freqtrade/freqai/torch/PyTorchTransformerModel.py:14:class PyTorchTransformerModel(nn.Module):
freqtrade/freqai/torch/PyTorchTransformerModel.py:80:class PositionalEncoding(nn.Module):
freqtrade/freqai/torch/PyTorchModelTrainer.py:20:class PyTorchModelTrainer(PyTorchTrainerInterface):
freqtrade/freqai/torch/PyTorchModelTrainer.py:199:class PyTorchTransformerTrainer(PyTorchModelTrainer):
freqtrade/freqai/torch/PyTorchMLPModel.py:10:class PyTorchMLPModel(nn.Module):
freqtrade/freqai/torch/PyTorchMLPModel.py:58:class Block(nn.Module):
freqtrade/freqai/torch/PyTorchMLPModel.py:80:class FeedForward(nn.Module):
freqtrade/freqai/data_drawer.py:39:class pair_info(TypedDict):
freqtrade/freqai/data_drawer.py:46:class FreqaiDataDrawer:
freqtrade/freqai/tensorboard/TensorboardCallback.py:10:class TensorboardCallback(BaseCallback):
freqtrade/freqai/tensorboard/tensorboard.py:17:class TensorboardLogger(BaseTensorboardLogger):
freqtrade/freqai/tensorboard/tensorboard.py:33:class TensorBoardCallback(BaseTensorBoardCallback):
freqtrade/exchange/idex.py:12:class Idex(Exchange):
freqtrade/freqai/tensorboard/base_tensorboard.py:11:class BaseTensorboardLogger:
freqtrade/freqai/tensorboard/base_tensorboard.py:22:class BaseTensorBoardCallback(TrainingCallback):
freqtrade/exchange/cryptocom.py:12:class Cryptocom(Exchange):
freqtrade/exchange/modetrade.py:11:class Modetrade(Exchange):
freqtrade/freqai/RL/Base3ActionRLEnv.py:12:class Actions(Enum):
freqtrade/freqai/RL/Base3ActionRLEnv.py:18:class Base3ActionRLEnv(BaseEnvironment):
freqtrade/exchange/bitget.py:23:class Bitget(Exchange):
freqtrade/exchange/kraken.py:21:class Kraken(Exchange):
freqtrade/freqai/RL/BaseEnvironment.py:19:class BaseActions(Enum):
freqtrade/freqai/RL/BaseEnvironment.py:31:class Positions(Enum):
freqtrade/freqai/RL/BaseEnvironment.py:40:class BaseEnvironment(gym.Env):
freqtrade/exchange/icicibreeze.py:42:class Icicibreeze(Exchange):
freqtrade/freqai/RL/Base4ActionRLEnv.py:12:class Actions(Enum):
freqtrade/freqai/RL/Base4ActionRLEnv.py:19:class Base4ActionRLEnv(BaseEnvironment):
freqtrade/exchange/bybit.py:19:class Bybit(Exchange):
freqtrade/freqai/RL/Base5ActionRLEnv.py:12:class Actions(Enum):
freqtrade/freqai/RL/Base5ActionRLEnv.py:20:class Base5ActionRLEnv(BaseEnvironment):
freqtrade/exchange/luno.py:10:class Luno(Exchange):
freqtrade/exchange/binance_public_data.py:27:class Http404(Exception):
freqtrade/exchange/binance_public_data.py:34:class BadHttpStatus(Exception):
freqtrade/exchange/gate.py:19:class Gate(Exchange):
freqtrade/freqai/RL/BaseReinforcementLearningModel.py:40:class BaseReinforcementLearningModel(IFreqaiModel):
freqtrade/freqai/freqai_interface.py:36:class IFreqaiModel(ABC):
freqtrade/freqai/data_kitchen.py:35:class FreqaiDataKitchen:
freqtrade/exchange/exchange.py:121:class Exchange:
freqtrade/exchange/exchange_ws.py:22:class ExchangeWS:
freqtrade/freqai/base_models/BaseRegressionModel.py:17:class BaseRegressionModel(IFreqaiModel):
freqtrade/exchange/binance.py:30:class Binance(Exchange):
freqtrade/exchange/binance.py:556:class Binanceusdm(Binance):
freqtrade/exchange/binance.py:569:class Binanceus(Binance):
freqtrade/freqai/base_models/BasePyTorchClassifier.py:20:class BasePyTorchClassifier(BasePyTorchModel):
freqtrade/freqai/base_models/FreqaiMultiOutputClassifier.py:11:class FreqaiMultiOutputClassifier(MultiOutputClassifier):
freqtrade/freqai/base_models/FreqaiMultiOutputRegressor.py:6:class FreqaiMultiOutputRegressor(MultiOutputRegressor):
freqtrade/freqai/base_models/BasePyTorchModel.py:13:class BasePyTorchModel(IFreqaiModel, ABC):
freqtrade/freqai/base_models/BaseClassifierModel.py:17:class BaseClassifierModel(IFreqaiModel):
freqtrade/freqai/base_models/BasePyTorchRegressor.py:16:class BasePyTorchRegressor(BasePyTorchModel):
freqtrade/freqai/prediction_models/LightGBMRegressorMultiTarget.py:14:class LightGBMRegressorMultiTarget(BaseRegressionModel):
freqtrade/freqai/prediction_models/LightGBMRegressor.py:13:class LightGBMRegressor(BaseRegressionModel):
freqtrade/freqai/prediction_models/XGBoostRegressor.py:14:class XGBoostRegressor(BaseRegressionModel):
freqtrade/freqai/prediction_models/PyTorchMLPRegressor.py:15:class PyTorchMLPRegressor(BasePyTorchRegressor):
freqtrade/freqai/prediction_models/LightGBMClassifierMultiTarget.py:14:class LightGBMClassifierMultiTarget(BaseClassifierModel):
freqtrade/freqai/prediction_models/PyTorchMLPClassifier.py:15:class PyTorchMLPClassifier(BasePyTorchClassifier):
freqtrade/freqai/prediction_models/XGBoostRegressorMultiTarget.py:14:class XGBoostRegressorMultiTarget(BaseRegressionModel):
freqtrade/freqai/prediction_models/ReinforcementLearner_multiproc.py:18:class ReinforcementLearner_multiproc(ReinforcementLearner):
freqtrade/freqai/prediction_models/SKLearnRandomForestClassifier.py:17:class SKLearnRandomForestClassifier(BaseClassifierModel):
freqtrade/freqai/prediction_models/PyTorchTransformerRegressor.py:18:class PyTorchTransformerRegressor(BasePyTorchRegressor):
freqtrade/freqai/prediction_models/XGBoostRFRegressor.py:13:class XGBoostRFRegressor(BaseRegressionModel):
freqtrade/freqai/prediction_models/XGBoostClassifier.py:19:class XGBoostClassifier(BaseClassifierModel):
freqtrade/freqai/prediction_models/LightGBMClassifier.py:13:class LightGBMClassifier(BaseClassifierModel):
freqtrade/freqai/prediction_models/ReinforcementLearner.py:17:class ReinforcementLearner(BaseReinforcementLearningModel):
freqtrade/freqai/prediction_models/XGBoostRFClassifier.py:19:class XGBoostRFClassifier(BaseClassifierModel):
freqtrade/util/ft_precise.py:9:class FtPrecise(Precise):
freqtrade/util/coin_gecko.py:4:class FtCoinGeckoApi(CoinGeckoAPI):
freqtrade/util/singleton.py:4:class SingletonMeta(type):
freqtrade/util/measure_time.py:11:class MeasureTime:
freqtrade/util/ft_ttlcache.py:6:class FtTTLCache(TTLCache):
freqtrade/util/periodic_cache.py:6:class PeriodicCache(TTLCache):
freqtrade/util/rich_progress.py:8:class CustomProgress(Progress):
freqtrade/optimize/analysis/recursive.py:28:class RecursiveAnalysis(BaseAnalysis):
freqtrade/optimize/analysis/recursive_helpers.py:16:class RecursiveAnalysisSubFunctions:
freqtrade/optimize/analysis/base_analysis.py:14:class VarHolder:
freqtrade/optimize/analysis/base_analysis.py:27:class BaseAnalysis:
freqtrade/optimize/analysis/lookahead.py:23:class Analysis:
freqtrade/optimize/analysis/lookahead.py:32:class LookaheadAnalysis(BaseAnalysis):
freqtrade/optimize/analysis/lookahead_helpers.py:19:class LookaheadAnalysisSubFunctions:
freqtrade/optimize/bt_progress.py:4:class BTProgress:
freqtrade/optimize/hyperopt/hyperopt_output.py:15:class HyperoptOutput:
freqtrade/optimize/hyperopt/hyperopt.py:35:class Hyperopt:
freqtrade/optimize/hyperopt/hyperopt_interface.py:25:class IHyperOpt(ABC):
freqtrade/optimize/hyperopt/hyperopt_optimizer.py:67:class HyperOptimizer:
freqtrade/optimize/hyperopt/hyperopt_auto.py:38:class HyperOptAuto(IHyperOpt):
freqtrade/optimize/space/optunaspaces.py:7:class DimensionProtocol(Protocol):
freqtrade/optimize/space/optunaspaces.py:11:class ft_CategoricalDistribution(CategoricalDistribution):
freqtrade/optimize/space/optunaspaces.py:28:class ft_IntD
```
