# Future development guide

## Directory ownership guidance
- Adapter/exchange boundary: `adapters/ccxt_shim/`
- Analytics/domain modules: `modules/`
- Strategy logic: `user_data/strategies/`
- Operational automation: `scripts/`
- Generated docs: `docs/generated/`

## Safe extension principles
- Keep runtime broker calls at adapter boundary.
- Keep strategy logic focused on Freqtrade strategy interface.
- Prefer deterministic helper functions for new analytics modules.
- Add or extend gate scripts/tests when adding behavior.
