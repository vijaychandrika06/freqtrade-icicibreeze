#!/bin/bash
cd "$(dirname "$0")/.."
source .venv/bin/activate
export PYTHONPATH="$PWD${PYTHONPATH:+:$PYTHONPATH}"

set +x
set -a; . ./.env; set +a
set -x

export BREEZE_MOCK=0

RUN="post_soak_check_$(date -u +%Y%m%d_%H%M%SZ)"
OUT="user_data/generated/${RUN}"
mkdir -p "$OUT"

# 1) Confirm markets expose options/futures (they currently do NOT)
bash scripts/lib/ft_cmd.sh list-markets -c user_data/config_icicibreeze.json --userdir user_data \
  |& tee "$OUT/list_markets.log"
rg -n "FUT/INR|-CE/INR|-PE/INR" "$OUT/list_markets.log" || true

# 2) Verify SecurityMaster actually contains NIFTY 2026-02-26 FUT + that CE strike
python3 - <<'PY' |& tee "$OUT/master_lookup.log"
import json, re
p="user_data/cache/security_master/latest.json"
try:
    d=json.load(open(p))
    opts=d.get("options",[])
    futs=d.get("futures",[])
    def has(pattern, rows, limit=5):
        r=re.compile(pattern)
        hit=[x for x in rows if r.search(str(x))][:limit]
        return hit
    print("options_count", len(opts), "futures_count", len(futs))
    print("FUT_hits", has(r"NIFTY.*20260226.*FUT", futs))
    print("CE_hits", has(r"NIFTY.*20260226.*22000.*CE", opts))
except Exception as e:
    print(f"Error checking security master: {e}")
PY

# 3) Check your generated shortlist (should not be empty if scanner works)
test -f user_data/generated/p51/shortlist.json && cat user_data/generated/p51/shortlist.json | head -c 2000 || true

# 4) Bundle evidence
tar -czf "$OUT.tar.gz" "$OUT"
echo "BUNDLE=$OUT.tar.gz"
