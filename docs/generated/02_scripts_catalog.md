# Scripts catalog

## Scripts inventory (`scripts/`, depth<=3)
- `scripts/__init__.py`
- `scripts/accept_all.sh`
- `scripts/accept_p09x.sh`
- `scripts/backup_state.sh`
- `scripts/collect/p44_release_bundle.sh`
- `scripts/freqtrade--ui`
- `scripts/gates/common.sh`
- `scripts/gates/p00_governance.sh`
- `scripts/gates/p01_ccxt_presence.sh`
- `scripts/gates/p02_mock_download_ohlcv.sh`
- `scripts/gates/p03_inr_pairs_presence.sh`
- `scripts/gates/p04_mode_routing_failfast.sh`
- `scripts/gates/p05_running_state.sh`
- `scripts/gates/p06_green_gate.sh`
- `scripts/gates/p07_pair_naming_contract_listing.sh`
- `scripts/gates/p08_equity_strategy_smoke.sh`
- `scripts/gates/p09_options_strategy_accept.sh`
- `scripts/gates/p09x_universe_scanner_accept.sh`
- `scripts/gates/p10_execution_surface.sh`
- `scripts/gates/p12_backtest_paper_validation_and_metrics.sh`
- `scripts/gates/p12c_mock_30d_backtesting.sh`
- `scripts/gates/p13_ops_security_and_deployment.sh`
- `scripts/gates/p14_market_hours.sh`
- `scripts/gates/p15_risk_guardrails.sh`
- `scripts/gates/p16_order_router.sh`
- `scripts/gates/p17_degraded_mode.sh`
- `scripts/gates/p17_invalid_symbol.sh`
- `scripts/gates/p17_rate_limit.sh`
- `scripts/gates/p18_paper_forward_test.sh`
- `scripts/gates/p19_observability_audit.sh`
- `scripts/gates/p20_no_open_ports_pos.sh`
- `scripts/gates/p20_ui_webserver_smoke.sh`
- `scripts/gates/p21_secrets_hygiene.sh`
- `scripts/gates/p22_real_mode_market_data.sh`
- `scripts/gates/p23_session_token_telegram.sh`
- `scripts/gates/p25_security_master_refresh.sh`
- `scripts/gates/p26_indicator_governance.sh`
- `scripts/gates/p27_smart_money.sh`
- `scripts/gates/p28_execution_microstructure.sh`
- `scripts/gates/p29_real_mode_paper_trade.sh`
- `scripts/gates/p30_live_guard.sh`
- `scripts/gates/p30_neg_check.py`
- `scripts/gates/p31_health_snapshot.sh`
- `scripts/gates/p32_alerting_transitions.sh`
- `scripts/gates/p33_backup_restore.sh`
- `scripts/gates/p34_circuit_breaker.sh`
- `scripts/gates/p35_ops_runbook.sh`
- `scripts/gates/p36_metrics_exporter.sh`
- `scripts/gates/p37_scheduler_templates.sh`
- `scripts/gates/p38_soak_stability.sh`
- `scripts/gates/p39_ops_hardening.sh`
- `scripts/gates/p40_live_readiness.sh`
- `scripts/gates/p40_live_readiness_path_consistency.sh`
- `scripts/gates/p41_deadman_auto_renew.sh`
- `scripts/gates/p42_incident_response.sh`
- `scripts/gates/p43_restart_reconcile.sh`
- `scripts/gates/p44_release_bundle.sh`
- `scripts/gates/p45_universe_rotation.sh`
- `scripts/gates/p46_option_chain_provider.sh`
- `scripts/gates/p46_soak_stability_mock_ohlcv.sh`
- `scripts/gates/p46_ui_shortlist_contract.sh`
- `scripts/gates/p46_universe_actionable_pairs.sh`
- `scripts/gates/p47_options_valuation.sh`
- `scripts/gates/p48_regime.sh`
- `scripts/gates/p49_strike_selector.sh`
- `scripts/gates/p50_news_blackout.sh`
- `scripts/gates/p51_universal_scanner.sh`
- `scripts/gates/p52_debug_broadcast_ports.sh`
- `scripts/gates/p52_universal_funnel.sh`
- `scripts/gates/p53_telemetry_smoke.sh`
- `scripts/gates/p54_balance_contract.sh`
- `scripts/gen_actionable_universe_pairs.py`
- `scripts/gen_option_whitelist.py`
- `scripts/green_gate.sh`
- `scripts/list_icici_contracts.py`
- `scripts/listen_telemetry.sh`
- `scripts/make_config_ui.py`
- `scripts/make_config_with_pairs.py`
- `scripts/normalize_pair.py`
- `scripts/ops/env_snapshot.sh`
- `scripts/ops/export_ui_shortlist.py`
- `scripts/ops/p19_scan_exc_logging.py`
- `scripts/ops/p20_scan_port_exposure.py`
- `scripts/ops/p41_deadman_renew.py`
- `scripts/ops/p43_reconcile.py`
- `scripts/ops/ports_snapshot.sh`
- `scripts/ops/soak_monitor_10min.sh`
- `scripts/ops/sync_security_master.py`
- `scripts/ops/with_lock.py`
- `scripts/p12_metrics_from_trades.py`
- `scripts/p12_timerange.sh`
- `scripts/p12_timerange_from_data.py`
- `scripts/p19_raise_and_log.py`
- `scripts/p20_api_smoke.sh`
- `scripts/p21_session_check.py`
- `scripts/p22_real_data_smoke.sh`
- `scripts/p23_session_store.py`
- `scripts/p25_build_security_master_json.py`
- `scripts/p25_fetch_security_master.py`
- `scripts/p29_check_paper_execution.py`
- `scripts/p30_check_live_guard.py`
- `scripts/p46_check_provider.py`
- `scripts/p47_check_valuation.py`
- `scripts/p48_check_regime.py`
- `scripts/p49_check_selector.py`
- `scripts/p50_check_news.py`
- `scripts/paper_ledger_report.sh`
- `scripts/post_soak_check.sh`
- `scripts/rest_client.py`
- `scripts/restore_state.sh`
- `scripts/run_debug_bundle.sh`
- `scripts/run_p09.sh`
- `scripts/security/file_perms_audit.sh`
- `scripts/security/secret_scan_strict.sh`
- `scripts/smoke_icicibreeze_auth.py`
- `scripts/smoke_icicibreeze_markets_data.py`
- `scripts/smoke_icicibreeze_security_master_fo.py`
- `scripts/smoke_icicibreeze_ticker.py`
- `scripts/telegram/p23_token_bot.py`
- `scripts/universal_scanner.py`
- `scripts/universe_scan_and_generate_pairs.py`
- `scripts/verify_ccxt_compliance.py`
- `scripts/verify_fetch_ohlcv.py`
- `scripts/verify_fetch_ticker.py`
- `scripts/verify_inr_support.py`
- `scripts/ws_client.py`

## Usage/CLI hints (grep)
```text
scripts/p23_session_store.py:11:import argparse
scripts/p23_session_store.py:81:    parser = argparse.ArgumentParser(description="Secure Session Store")
scripts/list_icici_contracts.py:1:import argparse
scripts/list_icici_contracts.py:121:    parser = argparse.ArgumentParser(
scripts/restore_state.sh:4:if [ "$#" -ne 1 ]; then
scripts/restore_state.sh:16:if [ ! -f "$BACKUP_FILE" ]; then
scripts/restore_state.sh:38:if [ ! -d "$RESTORE_TMP/user_data" ]; then
scripts/restore_state.sh:49:if [ -d "$USER_DATA" ]; then
scripts/freqtrade--ui:51:if [ -z "${FT_UI_PASS:-}" ]; then
scripts/p25_fetch_security_master.py:2:import argparse
scripts/p25_fetch_security_master.py:100:    parser = argparse.ArgumentParser()
scripts/gen_actionable_universe_pairs.py:2:import argparse
scripts/gen_actionable_universe_pairs.py:119:    parser = argparse.ArgumentParser(description="Generate actionable universe pairs.")
scripts/collect/p44_release_bundle.sh:24:if [ -n "$LATEST_RUN" ] && [ -d "$LATEST_RUN" ]; then
scripts/collect/p44_release_bundle.sh:28:    if [ -f "generated/accept_runs/${RUN_NAME}.tar.gz" ]; then
scripts/collect/p44_release_bundle.sh:46:if [ -f "config_example.json" ]; then
scripts/collect/p44_release_bundle.sh:71:if [ "$LEAKS_FOUND" -eq 1 ]; then
scripts/p20_api_smoke.sh:67:if [[ "$RESPONSE" == *"status"* ]]; then
scripts/run_debug_bundle.sh:56:  if [ "${LTRIM}" = "1" ]; then
scripts/run_debug_bundle.sh:67:  if [ -d user_data/generated/p51 ]; then
scripts/run_debug_bundle.sh:71:  if [ -f user_data/cache/security_master/latest.json ]; then
scripts/run_debug_bundle.sh:78:  if [ -f "${OUT}/telemetry/udp_${P}.pid" ]; then
scripts/universe_scan_and_generate_pairs.py:1:import argparse
scripts/universe_scan_and_generate_pairs.py:179:def _parse_args() -> argparse.Namespace:
scripts/universe_scan_and_generate_pairs.py:180:    parser = argparse.ArgumentParser(description="Scan universe and generate pairs.")
scripts/p25_build_security_master_json.py:8:import argparse
scripts/p25_build_security_master_json.py:101:    parser = argparse.ArgumentParser()
scripts/universal_scanner.py:1:import argparse
scripts/universal_scanner.py:330:    parser = argparse.ArgumentParser()
scripts/p22_real_data_smoke.sh:74:if [ -f "$DATA_FILE" ]; then
scripts/p22_real_data_smoke.sh:78:    if [ "$LINE_COUNT" -gt 0 ]; then
scripts/ops/p41_deadman_renew.py:7:import argparse
scripts/ops/p41_deadman_renew.py:19:    parser = argparse.ArgumentParser(description="Renew deadman lease")
scripts/ops/soak_monitor_10min.sh:21:    if [ -z "$SOAK_DIR" ]; then
scripts/ops/soak_monitor_10min.sh:39:    if [ $i -lt 10 ]; then
scripts/ops/export_ui_shortlist.py:2:import argparse
scripts/ops/export_ui_shortlist.py:137:    parser = argparse.ArgumentParser()
scripts/ops/with_lock.py:8:import argparse
scripts/ops/with_lock.py:20:    parser = argparse.ArgumentParser(description="Run command with exclusive lock.")
scripts/ops/p43_reconcile.py:5:import argparse
scripts/ops/p43_reconcile.py:18:    parser = argparse.ArgumentParser(description="Reconcile bot state with exchange")
scripts/security/secret_scan_strict.sh:30:if [ -d .git ]; then
scripts/security/secret_scan_strict.sh:44:    if [ -d .git ]; then
scripts/security/secret_scan_strict.sh:52:    if [ -n "$MATCHES" ]; then
scripts/security/secret_scan_strict.sh:57:        if [ -n "$FILTERED" ]; then
scripts/security/secret_scan_strict.sh:71:if [ $EXIT_CODE -eq 0 ]; then
scripts/security/file_perms_audit.sh:18:    if [ -e "$PATH_TO_CHECK" ]; then
scripts/security/file_perms_audit.sh:22:        if [ -n "$(find "$PATH_TO_CHECK" -perm -o=r)" ]; then
scripts/security/file_perms_audit.sh:28:        if [ -n "$(find "$PATH_TO_CHECK" -perm -o=w)" ]; then
scripts/security/file_perms_audit.sh:34:        if [ -n "$(find "$PATH_TO_CHECK" -perm -g=w)" ]; then
scripts/security/file_perms_audit.sh:44:if [ -d "user_data" ]; then
scripts/security/file_perms_audit.sh:46:    if [ -n "$WORLD_WRITABLE" ]; then
scripts/security/file_perms_audit.sh:53:if [ $EXIT_CODE -eq 0 ]; then
scripts/paper_ledger_report.sh:15:if [ ! -d "$LEDGER_DIR" ]; then
scripts/paper_ledger_report.sh:20:if [ -f "$DAILY_FILE" ]; then
scripts/paper_ledger_report.sh:30:if [ -f "$TRADES_FILE" ]; then
scripts/p12_timerange_from_data.py:1:import argparse
scripts/p12_timerange_from_data.py:47:    parser = argparse.ArgumentParser(description="Compute timerange from stored OHLCV data.")
scripts/accept_all.sh:93:    case $1 in
scripts/accept_all.sh:150:        if [[ "$h" == "$gate" ]]; then
scripts/accept_all.sh:160:if [ ${#GATES_ARGS[@]} -gt 0 ]; then
scripts/accept_all.sh:164:        if [[ "$TARGET" =~ ^(.*)_(pos|neg)$ ]]; then
scripts/accept_all.sh:171:                if [[ "$g" == "$BASE_NAME" ]]; then
scripts/accept_all.sh:177:            if [ -n "$MATCH" ]; then
scripts/accept_all.sh:188:                if [[ "$g" == "$TARGET" ]]; then
scripts/accept_all.sh:195:            if [ -z "$MATCH" ]; then
scripts/accept_all.sh:199:                    if [[ "$g" == "$TARGET"* ]]; then
scripts/accept_all.sh:205:                if [ "$MATCH_COUNT" -eq 1 ]; then
scripts/accept_all.sh:207:                elif [ "$MATCH_COUNT" -gt 1 ]; then
scripts/accept_all.sh:213:            if [ -n "$MATCH" ]; then
scripts/accept_all.sh:215:                if [[ "$TARGET_MODE" == "neg" ]]; then
scripts/accept_all.sh:217:                elif [[ "$TARGET_MODE" == "pos" ]]; then
scripts/accept_all.sh:240:        if [[ "$TARGET_MODE" == "neg" ]]; then
scripts/accept_all.sh:242:        elif [[ "$TARGET_MODE" == "pos" ]]; then
scripts/accept_all.sh:253:    if [[ "$TARGET_MODE" == "auto" ]]; then
scripts/accept_all.sh:276:    if [ ! -f "$GATE_SCRIPT" ]; then
scripts/accept_all.sh:299:if [ "$FAILED" -eq 1 ]; then
scripts/accept_all.sh:306:if [ "$FAILED" -eq 0 ]; then
scripts/ws_client.py:10:import argparse
scripts/ws_client.py:39:    parser = argparse.ArgumentParser()
scripts/accept_p09x.sh:13:if [ ! -f "$PYTHON" ]; then
scripts/accept_p09x.sh:76:if [ "$H1_PAIRS" != "$H2_PAIRS" ]; then
scripts/accept_p09x.sh:83:if [ "$H1_REPORT" != "$H2_REPORT" ]; then
scripts/accept_p09x.sh:90:if [ "$H1_CONFIG" != "$H2_CONFIG" ]; then
scripts/accept_p09x.sh:103:if [ "$PAIR_LEN" -eq 0 ]; then
scripts/accept_p09x.sh:111:if [ "$WL_LEN" -eq 0 ]; then
scripts/accept_p09x.sh:116:if [ "$WL_LEN" -ne "$PAIR_LEN" ]; then
scripts/make_config_with_pairs.py:1:import argparse
scripts/make_config_with_pairs.py:33:def _parse_args() -> argparse.Namespace:
scripts/make_config_with_pairs.py:34:    parser = argparse.ArgumentParser(description="Create config with generated pairs whitelist.")
scripts/p12_metrics_from_trades.py:1:import argparse
scripts/p12_metrics_from_trades.py:53:    parser = argparse.ArgumentParser(description="Extract metrics from backtest trades.")
scripts/gates/p26_indicator_governance.sh:10:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p26_indicator_governance.sh:62:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p26_indicator_governance.sh:73:    if [ $PYTEST_EXIT -ne 0 ]; then
scripts/gates/p46_ui_shortlist_contract.sh:14:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p46_ui_shortlist_contract.sh:63:    if [ "$COUNT" -ne 2 ]; then
scripts/gates/p46_ui_shortlist_contract.sh:70:    if [ "$TOKEN" != "12345" ]; then
scripts/gates/p46_ui_shortlist_contract.sh:77:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p46_ui_shortlist_contract.sh:102:    if [ "$REASON" != "parse_error" ]; then
scripts/gates/p46_universe_actionable_pairs.sh:15:if [ -z "$MASTER_FILE" ]; then
scripts/gates/p46_universe_actionable_pairs.sh:21:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p46_universe_actionable_pairs.sh:33:    if [ -n "$INVALID_COUNTS" ]; then
scripts/gates/p46_universe_actionable_pairs.sh:42:    if [ -n "$DUP_UNDERLYINGS" ]; then
scripts/gates/p46_universe_actionable_pairs.sh:49:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p46_universe_actionable_pairs.sh:61:    if [ "$MAX_COUNT" -gt 2 ]; then
scripts/gates/p19_observability_audit.sh:17:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p19_observability_audit.sh:65:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p20_ui_webserver_smoke.sh:18:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p20_ui_webserver_smoke.sh:41:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p16_order_router.sh:18:if [ ! -f "$BASE_CFG" ]; then
scripts/gates/p16_order_router.sh:27:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p16_order_router.sh:83:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p40_live_readiness.sh:93:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p40_live_readiness.sh:126:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p02_mock_download_ohlcv.sh:14:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p02_mock_download_ohlcv.sh:21:    if [ ! -f "$DATA_FILE" ]; then
scripts/gates/p02_mock_download_ohlcv.sh:25:    if [ ! -f "$DATA_FILE" ]; then
scripts/gates/p02_mock_download_ohlcv.sh:47:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p02_mock_download_ohlcv.sh:52:    elif [ ${PIPESTATUS[0]} -ne 0 ]; then
scripts/gates/p02_mock_download_ohlcv.sh:58:         if [ -f "$DATA_FILE" ]; then
scripts/gates/p48_regime.sh:7:if [ "$MODE" == "pos" ]; then
scripts/gates/p48_regime.sh:9:elif [ "$MODE" == "neg" ]; then
scripts/gates/p28_execution_microstructure.sh:10:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p28_execution_microstructure.sh:39:    if [ $FAILED -eq 0 ]; then
scripts/gates/p28_execution_microstructure.sh:46:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p35_ops_runbook.sh:25:if [ "$MODE" == "pos" ]; then
scripts/gates/p35_ops_runbook.sh:29:    if [ ! -f "$DOCS_FILE" ]; then
scripts/gates/p35_ops_runbook.sh:36:    if [ ! -f "$BACKUP_SCRIPT" ]; then
scripts/gates/p35_ops_runbook.sh:40:    if [ ! -f "$RESTORE_SCRIPT" ]; then
scripts/gates/p35_ops_runbook.sh:47:    if [ ! -f "$HEALTH_FILE" ]; then
scripts/gates/p35_ops_runbook.sh:55:    if [ ! -d "$LOG_DIR" ]; then
scripts/gates/p35_ops_runbook.sh:72:elif [ "$MODE" == "neg" ]; then
scripts/gates/p03_inr_pairs_presence.sh:13:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p03_inr_pairs_presence.sh:25:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p36_metrics_exporter.sh:19:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p36_metrics_exporter.sh:32:    if [ ! -f "$METRICS_JSON" ]; then
scripts/gates/p36_metrics_exporter.sh:36:    if [ ! -f "$METRICS_PROM" ]; then
scripts/gates/p36_metrics_exporter.sh:59:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p36_metrics_exporter.sh:77:    if [ -f "$METRICS_JSON" ]; then
scripts/gates/common.sh:6:if [ -z "$GATE_ID" ]; then
scripts/gates/common.sh:25:if [[ "$GATE_MODE" != "pos" && "$GATE_MODE" != "neg" ]]; then
scripts/gates/common.sh:69:if [ ! -f "$PYTHON" ]; then
scripts/gates/common.sh:74:if [ ! -f "$FREQTRADE" ]; then
scripts/gates/common.sh:86:    if [ "$EXIT_CODE" -ne 0 ]; then
scripts/gates/p01_ccxt_presence.sh:11:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p01_ccxt_presence.sh:19:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p51_universal_scanner.sh:7:if [ "$MODE" == "pos" ]; then
scripts/gates/p51_universal_scanner.sh:11:elif [ "$MODE" == "neg" ]; then
scripts/gates/p46_option_chain_provider.sh:9:if [ "$MODE" == "pos" ]; then
scripts/gates/p46_option_chain_provider.sh:12:elif [ "$MODE" == "neg" ]; then
scripts/gates/p17_rate_limit.sh:12:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p17_rate_limit.sh:23:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p41_deadman_auto_renew.sh:26:    if [ ! -f "$TEST_LEASE_FILE" ]; then
scripts/gates/p41_deadman_auto_renew.sh:121:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p41_deadman_auto_renew.sh:123:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p17_invalid_symbol.sh:12:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p17_invalid_symbol.sh:18:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p45_universe_rotation.sh:16:if [ ! -f "$STRATEGY_YAML" ]; then
scripts/gates/p45_universe_rotation.sh:33:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p45_universe_rotation.sh:48:    if [ "$CURSOR" -ne 70 ]; then
scripts/gates/p45_universe_rotation.sh:65:    if [ "$CURSOR" -ne 140 ]; then
scripts/gates/p45_universe_rotation.sh:77:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p30_live_guard.sh:19:if [ -f "$CACHE_MASTER" ]; then
scripts/gates/p30_live_guard.sh:24:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p30_live_guard.sh:34:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p39_ops_hardening.sh:10:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p39_ops_hardening.sh:20:    if [ -f "scripts/gates/p20_no_open_ports_pos.sh" ]; then
scripts/gates/p39_ops_hardening.sh:28:    if [ -f "scripts/gates/p21_secrets_hygiene.sh" ]; then
scripts/gates/p39_ops_hardening.sh:54:    if [ "$FIXME_COUNT" -gt 0 ]; then
scripts/gates/p39_ops_hardening.sh:62:    if [ -f "docs/OPS_RUNBOOK.md" ]; then
scripts/gates/p39_ops_hardening.sh:72:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p04_mode_routing_failfast.sh:12:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p04_mode_routing_failfast.sh:37:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p43_restart_reconcile.sh:104:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p43_restart_reconcile.sh:106:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p53_telemetry_smoke.sh:105:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p53_telemetry_smoke.sh:145:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p53_telemetry_smoke.sh:155:    if [ -s "$TELE_LOG_DIR/breeze.jsonl" ]; then
scripts/gates/p20_no_open_ports_pos.sh:17:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p20_no_open_ports_pos.sh:25:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p22_real_mode_market_data.sh:21:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p22_real_mode_market_data.sh:25:    if [[ "${BREEZE_MOCK:-0}" == "1" ]]; then
scripts/gates/p22_real_mode_market_data.sh:32:    if [ -z "${BREEZE_API_KEY:-}" ] || [ -z "${BREEZE_API_SECRET:-}" ] || [ -z "${BREEZE_SESSION_TOKEN:-}" ]; then
scripts/gates/p22_real_mode_market_data.sh:88:            if [ -f "$path" ]; then
scripts/gates/p22_real_mode_market_data.sh:95:    if [ -z "$FOUND_FILE" ]; then
scripts/gates/p22_real_mode_market_data.sh:103:    if [ -s "$FOUND_FILE" ]; then
scripts/gates/p22_real_mode_market_data.sh:105:        if [ "$SIZE" -lt 100 ]; then
scripts/gates/p22_real_mode_market_data.sh:119:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p22_real_mode_market_data.sh:133:        if [ -z "${BREEZE_API_KEY:-}" ]; then
scripts/gates/p22_real_mode_market_data.sh:143:    if [ $RES -eq 0 ]; then
scripts/gates/p13_ops_security_and_deployment.sh:18:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p13_ops_security_and_deployment.sh:39:        if [ ! -f "$FILE" ]; then
scripts/gates/p13_ops_security_and_deployment.sh:47:    freqtrade --help > /dev/null || finish_gate 1
scripts/gates/p13_ops_security_and_deployment.sh:48:    if [ -d "tests/unit" ]; then
scripts/gates/p13_ops_security_and_deployment.sh:52:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p52_universal_funnel.sh:18:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p52_universal_funnel.sh:37:    if [ -f "$REPORT_FILE" ]; then
scripts/gates/p52_universal_funnel.sh:53:    if [ ! -f "$PAIRS_FILE" ]; then
scripts/gates/p52_universal_funnel.sh:77:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p52_debug_broadcast_ports.sh:17:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p52_debug_broadcast_ports.sh:68:    if [ ! -f config_p52.json ]; then
scripts/gates/p52_debug_broadcast_ports.sh:69:        if [ -f config.json.example ]; then
scripts/gates/p52_debug_broadcast_ports.sh:120:if [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p52_debug_broadcast_ports.sh:126:    if [ ! -f config_p52.json ]; then
scripts/gates/p44_release_bundle.sh:29:    if [ -f "$BUNDLE_FILE" ]; then
scripts/gates/p44_release_bundle.sh:72:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p44_release_bundle.sh:74:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p37_scheduler_templates.sh:14:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p37_scheduler_templates.sh:31:        if [ ! -f "$SYSTEMD_DIR/$f" ]; then
scripts/gates/p37_scheduler_templates.sh:55:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p37_scheduler_templates.sh:76:    if [ "$RET" -eq 1 ]; then
scripts/gates/p15_risk_guardrails.sh:13:if [ ! -f "$CFG" ]; then
scripts/gates/p15_risk_guardrails.sh:40:if [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p15_risk_guardrails.sh:65:    if [ "$BLOCK_CONFIRMED" -eq 0 ]; then
scripts/gates/p15_risk_guardrails.sh:73:elif [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p15_risk_guardrails.sh:103:    if [ "$ALLOW_CONFIRMED" -eq 0 ]; then
scripts/gates/p05_running_state.sh:13:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p05_running_state.sh:28:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p34_circuit_breaker.sh:20:if [ -f ".venv/bin/python3" ]; then
scripts/gates/p34_circuit_breaker.sh:28:if [ "$MODE" == "pos" ]; then
scripts/gates/p34_circuit_breaker.sh:72:elif [ "$MODE" == "neg" ]; then
scripts/gates/p00_governance.sh:11:if [ "$GATE_MODE" == "pos" ]; then
scripts/gates/p00_governance.sh:18:elif [ "$GATE_MODE" == "neg" ]; then
scripts/gates/p12c_mock_30d_backtesting.sh:33:if [ ! -f "$JSON_FILE" ]; then
scripts/gates/p12c_mock_30d_backtesting.sh:41:if [ "$COUNT" -lt "$EXPECTED" ]; then
scripts/gates/p12c_mock_30d_backtesting.sh:71:if [ -z "$REAL_TRADES_FILE" ]; then
scripts/gates/p12c_mock_30d_backtesting.sh:74:    if [ -n "$ZIP_FILE" ]; then
scripts/gates/p12c_mock_30d_backtesting.sh:80:if [ -z "$REAL_TRADES_FILE" ]; then
scripts/gates/p49_strike_selector.sh:7:if [ "$MODE" == "pos" ]; then
scripts/gates/p49_strike_selector.sh:9:elif [ "$MODE" == "neg" ]; then
scripts/gates/p47_options_valuation.sh:7:if [ "$MODE" == "pos" ]; then
scripts/gates/p47_options_valuation.sh:9:elif [ "$MODE" == "neg" ]; then
scripts/gates/p50_news_blackout.sh:7:if [ "$MODE" == "pos" ]; then
scripts/gates/p50_news_blackout.sh:9:elif [ "$MODE" == "neg" ]; then
scripts/gates/p1
```
