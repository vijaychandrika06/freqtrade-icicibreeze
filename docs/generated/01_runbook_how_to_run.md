# Runbook — how to run

## Preconditions
- Python virtual environment and dependencies installed for this repository.
- Configuration files under `user_data/`.
- Strategy classes under `user_data/strategies/`.

## Common Freqtrade command families (referenced in repo)
- `freqtrade list-markets ...`
- `freqtrade download-data ...`
- `freqtrade backtesting ...`
- `freqtrade trade --dry-run ...`

## Config files discovered (`user_data/*.json|yaml|yml`)
- `user_data/config_icicibreeze.json`
- `user_data/india_strategy.yaml`

## Strategy files discovered
- `user_data/strategies/IcbcSmokeStrategy.py`
- `user_data/strategies/IndiaEquitySmokeStrategy.py`
- `user_data/strategies/IndiaIndexOptionsStrategy.py`
- `user_data/strategies/IndiaOptionsAutoStrategy.py`
- `user_data/strategies/IndiaOptionsBaseStrategy.py`
- `user_data/strategies/IndiaStockOptionsStrategy.py`
- `user_data/strategies/data_integrity_fr202.py`
- `user_data/strategies/guards.py`
- `user_data/strategies/indicator_registry.py`
- `user_data/strategies/smart_money_fr203.py`

## Entrypoint references (grep)
```text
./pyproject.toml:57:  "fastapi",
./pyproject.toml:61:  "uvicorn",
./pyproject.toml:322:# Allow default arguments like, e.g., `data: List[str] = fastapi.Query(None)`.
./pyproject.toml:323:extend-immutable-calls = ["fastapi.Depends", "fastapi.Query"]
./freqtrade.service.watchdog:9:ExecStart=/usr/bin/freqtrade trade --sd-notify
./requirements.txt:33:fastapi==0.125.0
./requirements.txt:35:uvicorn==0.38.0
./freqtrade.service:9:ExecStart=/usr/bin/freqtrade trade
./scripts/freqtrade--ui:74:exec .venv/bin/freqtrade webserver \
./scripts/p20_api_smoke.sh:31:freqtrade trade --dry-run \
./scripts/p20_api_smoke.sh:51:    if grep -q "Uvicorn running on http://127.0.0.1:$API_PORT" "$LOG_FILE"; then
./scripts/run_debug_bundle.sh:50:  freqtrade list-markets -c "${CONFIG}" --userdir "${USERDIR}" \
./scripts/run_debug_bundle.sh:63:    freqtrade trade --dry-run -c "${CONFIG}" --userdir "${USERDIR}" -s "${STRATEGY}" ${VERB} \
./scripts/p22_real_data_smoke.sh:59:freqtrade list-markets -c "$TEMP_CONF" --print-json > user_data/p22_markets.json
./scripts/p22_real_data_smoke.sh:70:freqtrade download-data -c "$TEMP_CONF" --days 1 -t 5m -p RELIANCE/INR
./scripts/post_soak_check.sh:17:freqtrade list-markets -c user_data/config_icicibreeze.json --userdir user_data \
./scripts/run_p09.sh:22:freqtrade list-markets -c "$CFG" --userdir user_data | rg -n "$UNDERLYING|/INR" | head -n 120
./scripts/run_p09.sh:24:freqtrade download-data -c "$CFG" --userdir user_data --timeframes 5m --days 5 -v | tail -n 140
./scripts/run_p09.sh:26:freqtrade backtesting -c "$CFG" --userdir user_data -s IndiaOptionsAutoStrategy \
./scripts/run_p09.sh:30:freqtrade trade --dry-run -c "$CFG" --userdir user_data -s IndiaOptionsAutoStrategy -vv | sed -n '1,260p'
./scripts/accept_p09x.sh:123:$PYTHON -m freqtrade list-markets --config "$V1_CONFIG"
./scripts/accept_p09x.sh:126:$PYTHON -m freqtrade download-data --config "$V1_CONFIG" --timeframes 1d --days 100
./scripts/accept_p09x.sh:129:$PYTHON -m freqtrade backtesting --config "$V1_CONFIG" --timeframe 1d --strategy IndiaEquitySmokeStrategy
./scripts/accept_p09x.sh:132:timeout 15s $PYTHON -m freqtrade trade --config "$V1_CONFIG" --strategy IndiaEquitySmokeStrategy --dry-run || true
./scripts/gates/p20_ui_webserver_smoke.sh:3:# Verification gate for Freqtrade webserver authentication
./scripts/gates/p20_ui_webserver_smoke.sh:30:    timeout 10s $FREQTRADE webserver -c "$OUT_CONFIG" --userdir user_data -v > "$ARTIFACT_DIR/webserver_pos.log" 2>&1 || true
./scripts/gates/p20_ui_webserver_smoke.sh:33:    if grep -q "Starting HTTP Server at" "$ARTIFACT_DIR/webserver_pos.log" || grep -q "Uvicorn running on" "$ARTIFACT_DIR/webserver_pos.log"; then
./scripts/gates/p20_ui_webserver_smoke.sh:49:    if $FREQTRADE webserver -c "$OUT_CONFIG" --userdir user_data -v > "$ARTIFACT_DIR/webserver_neg.log" 2>&1; then
./scripts/gates/p02_mock_download_ohlcv.sh:16:    freqtrade download-data -c user_data/config_icicibreeze.json --userdir user_data --pairs RELIANCE/INR --timeframes "$TIMEFRAME" --days "$DAYS" || finish_gate $?
./scripts/gates/p02_mock_download_ohlcv.sh:50:    if freqtrade download-data -c user_data/config_icicibreeze.json --userdir user_data --pairs "INVALID/PAIR" --timeframes "$TIMEFRAME" --days "$DAYS" 2>&1 | grep -q "not found in whitelist"; then
./scripts/gates/p05_running_state.sh:18:    timeout 15s freqtrade trade -c user_data/config_icicibreeze.json --userdir user_data --strategy IndiaEquitySmokeStrategy --dry-run > "$LOG_FILE" 2>&1 || true
./scripts/gates/p05_running_state.sh:34:    timeout 5s freqtrade trade -c "$ARTIFACT_DIR/bad_config.json" --userdir user_data --strategy IndiaEquitySmokeStrategy --dry-run > "$LOG_FILE" 2>&1 || true
./scripts/gates/p12_backtest_paper_validation_and_metrics.sh:25:    freqtrade download-data -c "$CFG" --userdir user_data --timeframes "$TF" --days 7 || finish_gate $?
./scripts/gates/p12_backtest_paper_validation_and_metrics.sh:44:    freqtrade backtesting -c "$BT_CFG" \
./scripts/gates/p12_backtest_paper_validation_and_metrics.sh:106:    if freqtrade backtesting -c "$CFG" --userdir user_data -s IndiaEquitySmokeStrategy --pairs "INVALID/INR" --timeframe "$TF" --days 7 > "$LOG_FILE" 2>&1; then
./scripts/gates/p46_soak_stability_mock_ohlcv.sh:73:    $FREQTRADE download-data \
./scripts/gates/p46_soak_stability_mock_ohlcv.sh:83:    timeout 120s $FREQTRADE trade \
./scripts/gates/p46_soak_stability_mock_ohlcv.sh:157:    $FREQTRADE download-data \
./scripts/gates/p46_soak_stability_mock_ohlcv.sh:164:    timeout 60s $FREQTRADE trade \
./scripts/gates/p09x_universe_scanner_accept.sh:81:freqtrade list-markets -c "$V1_CONFIG" --userdir user_data > "$MARKETS_FILE" || finish_gate $?
./scripts/gates/p09x_universe_scanner_accept.sh:93:freqtrade download-data -c "$V1_CONFIG" --userdir user_data --timeframes "$TIMEFRAME" --days "$DAYS" || finish_gate $?
./scripts/gates/p09x_universe_scanner_accept.sh:96:freqtrade backtesting -c "$V1_CONFIG" --userdir user_data --strategy IndiaOptionsAutoStrategy --timeframe "$TIMEFRAME" || finish_gate $?
./scripts/gates/p09x_universe_scanner_accept.sh:99:timeout 15s freqtrade trade -c "$V1_CONFIG" --userdir user_data --strategy IndiaOptionsAutoStrategy --dry-run || true
./scripts/gates/p09_options_strategy_accept.sh:26:freqtrade download-data -c "$CONFIG_FILE" --userdir user_data --timeframes "$TIMEFRAME" --days "$DAYS" || finish_gate $?
./scripts/gates/p09_options_strategy_accept.sh:34:    freqtrade backtesting -c "$CONFIG_FILE" --userdir user_data --strategy IndiaOptionsAutoStrategy --timeframe "$TIMEFRAME" $RANGE_ARG || finish_gate $?
./scripts/gates/p09_options_strategy_accept.sh:38:    timeout 60s freqtrade trade -c "$CONFIG_FILE" --userdir user_data --strategy IndiaOptionsAutoStrategy --dry-run > "$LOG_FILE" 2>&1 || true
./scripts/gates/p09_options_strategy_accept.sh:62:    if timeout 15s freqtrade trade -c "$CONFIG_FILE" --userdir user_data --strategy BadStrategy --dry-run > "$LOG_FILE" 2>&1; then
./scripts/gates/p03_inr_pairs_presence.sh:14:    echo "Step 1: Freqtrade list-markets and check for RELIANCE/INR (Positive)"
./scripts/gates/p03_inr_pairs_presence.sh:16:    freqtrade list-markets -c user_data/config_icicibreeze.json --userdir user_data > "$MARKETS_FILE" 2>&1 || finish_gate $?
./scripts/gates/p03_inr_pairs_presence.sh:26:    echo "Step 1: Freqtrade list-markets with missing SecurityMaster (Negative)"
./scripts/gates/p03_inr_pairs_presence.sh:45:    if freqtrade list-markets -c "$CONFIG_ABS" --userdir . > "$MARKETS_FILE_ABS" 2>&1; then
./scripts/gates/p01_ccxt_presence.sh:16:    echo "Step 2: Freqtrade list-markets (mock)"
./scripts/gates/p01_ccxt_presence.sh:17:    freqtrade list-markets -c user_data/config_icicibreeze.json --userdir user_data || finish_gate $?
./scripts/gates/p04_mode_routing_failfast.sh:21:    freqtrade list-markets -c user_data/config_nokeys.json --userdir user_data > "$LOG_FILE" 2>&1 || true
./scripts/gates/p04_mode_routing_failfast.sh:47:    freqtrade list-markets -c user_data/config_icicibreeze.json --userdir user_data > "$LOG_FILE" 2>&1 || true
./scripts/gates/p12c_mock_30d_backtesting.sh:26:freqtrade download-data -c "$CFG" --userdir user_data --pairs "$PAIR" --timeframes "$TF" --days "$DAYS" --erase
./scripts/gates/p12c_mock_30d_backtesting.sh:59:freqtrade backtesting -c "$BT_CFG" --userdir user_data -s "$STRAT" \
./scripts/gates/p08_equity_strategy_smoke.sh:17:freqtrade backtesting -c user_data/config_icicibreeze.json --userdir user_data --strategy IndiaEquitySmokeStrategy --timeframe "$TIMEFRAME" || finish_gate $?
./scripts/gates/p08_equity_strategy_smoke.sh:21:timeout 15s freqtrade trade -c user_data/config_icicibreeze.json --userdir user_data --strategy IndiaEquitySmokeStrategy --dry-run > "$LOG_FILE" 2>&1 || true
./scripts/green_gate.sh:37:freqtrade list-markets -c user_data/config_icicibreeze.json --userdir user_data >"$OUT_DIR/markets.txt"
./scripts/green_gate.sh:49:    freqtrade download-data -c user_data/config_icicibreeze.json --userdir user_data --timeframes "$TIMEFRAME" --pairs BTC/USDT --days "$DAYS" -v >"$OUT_DIR/dl_btc.txt" 2>&1
./scripts/green_gate.sh:53:freqtrade download-data -c user_data/config_icicibreeze.json --userdir user_data --timeframes "$TIMEFRAME" --pairs RELIANCE/INR --days "$DAYS" -v >"$OUT_DIR/dl_inr.txt" 2>&1
./scripts/green_gate.sh:57:freqtrade trade --dry-run -c user_data/config_icicibreeze.json --userdir user_data -s IndiaEquitySmokeStrategy -vv >"$OUT_DIR/trade.txt" 2>&1 &
./README_GREEN_GATE.md:11:3. **Market Listing**: `freqtrade list-markets` runs successfully.
./README_GREEN_GATE.md:13:5. **Data Download**: `freqtrade download-data` runs specifically for `BTC/USDT` (verifying `fetchOHLCV` and `fetch_markets` filtering).
./README_GREEN_GATE.md:14:6. **Dry Run**: `freqtrade trade --dry-run` starts up, correctly resolves the `Icicibreeze` exchange class, and reaches the "Wallets synced" state.
./docs/PHASE_P38.md:13:- Runs `freqtrade trade --dry-run` in mock mode.
./docs/advanced-setup.md:28:freqtrade trade -c MyConfig.json -s MyStrategy
./docs/advanced-setup.md:30:freqtrade trade -c MyConfig.json -s MyStrategy --db-url sqlite:///tradesv3.dryrun.sqlite
./docs/advanced-setup.md:39:freqtrade trade -c MyConfigBTC.json -s MyCustomStrategy --db-url sqlite:///user_data/tradesBTC.dryrun.sqlite
./docs/advanced-setup.md:41:freqtrade trade -c MyConfigUSDT.json -s MyCustomStrategy --db-url sqlite:///user_data/tradesUSDT.dryrun.sqlite
./docs/advanced-setup.md:48:freqtrade trade -c MyConfigBTC.json -s MyCustomStrategy --db-url sqlite:///user_data/tradesBTC.live.sqlite
./docs/advanced-setup.md:50:freqtrade trade -c MyConfigUSDT.json -s MyCustomStrategy --db-url sqlite:///user_data/tradesUSDT.live.sqlite
./docs/bot-basics.md:38:Starting freqtrade in dry-run or live mode (using `freqtrade trade`) will start the bot and start the bot iteration loop.
./docs/PHASE_P20.md:12:- **NO** Custom Streamlit or Gradio dashboards.
./docs/PHASE_P20.md:31:- **API Server**: We use the standard Freqtrade API server (FastAPI/Uvicorn).
./docs/bot-usage.md:25:freqtrade trade -c path/far/far/away/config.json
./docs/bot-usage.md:44:freqtrade trade -c ./config.json
./docs/bot-usage.md:50:freqtrade trade -c ./config.json -c path/to/secrets/keys.config.json
./docs/bot-usage.md:99:freqtrade trade --strategy AwesomeStrategy
./docs/bot-usage.md:114:freqtrade trade --strategy AwesomeStrategy --strategy-path /some/directory
./docs/bot-usage.md:130:freqtrade trade -c config.json --db-url sqlite:///tradesv3.dry_run.sqlite
./docs/utils.md:269:$ freqtrade list-markets --exchange kraken --all
./docs/utils.md:317:You can use `docker compose run --rm -p 127.0.0.1:8080:8080 freqtrade webserver` to start a one-off container that'll be removed once you stop it. This assumes that port 8080 is still available and no other bot is running on that port.
./docs/utils.md:365:freqtrade hyperopt-list
./docs/utils.md:370:freqtrade hyperopt-list --profitable --no-details
./docs/utils.md:388:freqtrade hyperopt-show -n 168
./docs/utils.md:394:freqtrade hyperopt-show --best -n -1 --print-json --no-header
./docs/data-download.md:5:To download data (candles / OHLCV) needed for backtesting and hyperoptimization use the `freqtrade download-data` command.
./docs/data-download.md:23:    `freqtrade download-data --exchange binance --pairs ".*/USDT" <...>`. The provided "pairs" string will be expanded to contain all active pairs on the exchange.
./docs/data-download.md:36:freqtrade download-data --exchange binance
./docs/data-download.md:44:freqtrade download-data --exchange binance --pairs ETH/USDT XRP/USDT BTC/USDT
./docs/data-download.md:50:freqtrade download-data --exchange binance --pairs ".*/USDT"
./docs/data-download.md:84:freqtrade download-data --exchange binance --pairs ETH/USDT XRP/USDT BTC/USDT --prepend --timerange 20210101-20220101
./docs/data-download.md:216:freqtrade trades-to-ohlcv --exchange kraken -t 5m 1h 1d --pairs BTC/EUR ETH/EUR
./docs/data-download.md:275:freqtrade download-data --exchange kraken --pairs XRP/EUR ETH/EUR --days 20 --dl-trades
./docs/advanced-backtesting.md:17:freqtrade backtesting -c <config.json> --timeframe <tf> --strategy <strategy_name> --timerange=<timerange> --export=signals
./docs/advanced-backtesting.md:29:To analyze the entry/exit tags, we now need to use the `freqtrade backtesting-analysis` command
./docs/advanced-backtesting.md:33:freqtrade backtesting-analysis -c <config.json> --analysis-groups 0 1 2 3 4 5
./docs/advanced-backtesting.md:55:freqtrade backtesting -c <config.json> --strategy <strategy_name> --timerange <timerange> --export signals --backtest-filename backtest-result-2025-03-05_20-38-34.zip
./docs/advanced-backtesting.md:67:freqtrade backtesting-analysis -c <config.json> --backtest-filename=backtest-result-2025-03-05_20-38-34.zip
./docs/advanced-backtesting.md:73:freqtrade backtesting-analysis -c <config.json> --backtest-directory custom_results/ --backtest-filename backtest-result-2025-03-05_20-38-34.zip
./docs/advanced-backtesting.md:88:freqtrade backtesting-analysis -c <config.json> --analysis-groups 0 2 --enter-reason-list enter_tag_a enter_tag_b --exit-reason-list roi custom_exit_tag_a stop_loss
./docs/advanced-backtesting.md:93:The real power of `freqtrade backtesting-analysis` comes from the ability to print out the indicator
./docs/advanced-backtesting.md:99:freqtrade backtesting-analysis -c <config.json> --analysis-groups 0 2 --enter-reason-list enter_tag_a enter_tag_b --exit-reason-list roi custom_exit_tag_a stop_loss --indicator-list rsi rsi_1h bb_lowerband ema_9 macd macdsignal
./docs/advanced-backtesting.md:128:freqtrade backtesting-analysis -c user_data/config.json --analysis-groups 0 --indicator-list chikou_span tenkan_sen 
./docs/advanced-backtesting.md:161:freqtrade backtesting-analysis -c user_data/config.json --analysis-groups 0 --indicator-list chikou_span tenkan_sen --entry-only
./docs/advanced-backtesting.md:167:freqtrade backtesting-analysis -c user_data/config.json --analysis-groups 0 --indicator-list chikou_span tenkan_sen --exit-only
./docs/advanced-backtesting.md:184:freqtrade backtesting-analysis -c <config.json> --timerange 20220101-20220201
./docs/advanced-backtesting.md:192:freqtrade backtesting-analysis -c <config.json> --rejected-signals
./docs/advanced-backtesting.md:201:freqtrade backtesting-analysis -c <config.json> --analysis-to-csv
./docs/advanced-backtesting.md:207:freqtrade backtesting-analysis -c <config.json> --analysis-to-csv --rejected-signals --analysis-groups 0 1
./docs/advanced-backtesting.md:219:freqtrade backtesting-analysis -c <config.json> --analysis-to-csv --analysis-csv-path another/data/path/
./docs/docker_quickstart.md:127:    Trade commands (`freqtrade trade <...>`) should not be ran via `docker compose run` - but should use `docker compose up -d` instead.
./docs/docker_quickstart.md:132:    Including `--rm` will remove the container after completion, and is highly recommended for all modes except trading mode (running with `freqtrade trade` command).
./docs/docker_quickstart.md:145:docker compose run --rm freqtrade download-data --pairs ETH/BTC --exchange binance --days 5 -t 1h
./docs/docker_quickstart.md:155:docker compose run --rm freqtrade backtesting --config user_data/config.json --strategy SampleStrategy --timerange 20190801-20191001 -i 5m
./docs/installation.md:390:freqtrade trade --config user_data/config.json --strategy SampleStrategy
./docs/exchanges.md:203:freqtrade trades-to-ohlcv -p BTC/EUR BCH/EUR --exchange kraken -t 1m 5m 15m 1h
./docs/exchanges.md:209:freqtrade download-data --exchange kraken --dl-trades -p BTC/EUR BCH/EUR 
./docs/freqai.md:32:freqtrade trade --config config_examples/config_freqai.example.json --strategy FreqaiExampleStrategy --freqaimodel LightGBMRegressor --strategy-path freqtrade/templates
./docs/deprecated.md:12:Since this leads to much confusion, and slows down backtesting (while not being part of backtesting) this has been singled out as a separate freqtrade sub-command `freqtrade download-data`.
./docs/deprecated.md:108:You can either re-download everything (`freqtrade download-data [...] --erase` - :warning: can take a long time) - or download the updated data selectively.
./docs/deprecated.md:127:freqtrade download-data -t 1h --trading-mode futures --candle-types funding_rate mark [...] --timerange <full timerange you've got other data for>
./docs/commands/hyperopt-show.md:2:usage: freqtrade hyperopt-show [-h] [-v] [--no-color] [--logfile FILE] [-V]
./docs/commands/backtesting-show.md:2:usage: freqtrade backtesting-show [-h] [-v] [--no-color] [--logfile FILE] [-V]
./docs/commands/download-data.md:2:usage: freqtrade download-data [-h] [-v] [--no-color] [--logfile FILE] [-V]
./docs/commands/backtesting.md:2:usage: freqtrade backtesting [-h] [-v] [--no-color] [--logfile FILE] [-V]
./docs/commands/webserver.md:2:usage: freqtrade webserver [-h] [-v] [--no-color] [--logfile FILE] [-V]
./docs/commands/backtesting-analysis.md:2:usage: freqtrade backtesting-analysis [-h] [-v] [--no-color] [--logfile FILE]
./docs/commands/hyperopt-list.md:2:usage: freqtrade hyperopt-list [-h] [-v] [--no-color] [--logfile FILE] [-V]
./docs/commands/hyperopt.md:2:usage: freqtrade hyperopt [-h] [-v] [--no-color] [--logfile FILE] [-V]
./docs/commands/list-markets.md:2:usage: freqtrade list-markets [-h] [-v] [--no-color] [--logfile FILE] [-V]
./docs/commands/trade.md:2:usage: freqtrade trade [-h] [-v] [--no-color] [--logfile FILE] [-V] [-c PATH]
./docs/commands/trades-to-ohlcv.md:2:usage: freqtrade trades-to-ohlcv [-h] [-v] [--no-color] [--logfile FILE] [-V]
./docs/freqai-configuration.md:252:freqtrade trade --config config_examples/config_freqai.example.json --strategy FreqaiExampleStrategy --freqaimodel PyTorchMLPRegressor --strategy-path freqtrade/templates 
./docs/strategy-customization.md:69:freqtrade trade --strategy AwesomeStrategy
./docs/strategy-customization.md:270:freqtrade backtesting --timerange 20190101-20190201 --timeframe 5m
./docs/strategy-customization.md:517:freq
```

## Acceptance runner
- `bash scripts/accept_all.sh`
