# Freqtrade coverage matrix

## Core responsibilities (framework)
- Trade loop and execution orchestration.
- Backtesting and optimization tooling.
- Strategy interface and lifecycle hooks.
- Exchange abstraction and wallet integration.

## Repository-specific integration points
- Adapter implementation under `adapters/ccxt_shim/`.
- Strategies under `user_data/strategies/`.
- Operational and gate scripts under `scripts/`.
