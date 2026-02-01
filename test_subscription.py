# Standalone Breeze API Audit Tool (Refactored from trade-bot)
import json
import time
import requests
import os
import sys
import logging
from datetime import datetime, timedelta
from breeze_connect import BreezeConnect

# --- CONFIGURATION & LOGGING ---
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("BreezeStandaloneTest")

# Test Symbols
SYMBOL_EQUITY = "RELIND"  # Reliance
SYMBOL_INDEX = "NIFTY"
EXCHANGE_NSE = "NSE"
EXCHANGE_NFO = "NFO"


def load_env_credentials():
    """Simple .env loader for standalone use."""
    env_path = ".env"
    creds = {}
    if os.path.exists(env_path):
        with open(env_path, "r") as f:
            for line in f:
                if line.strip() and not line.startswith("#"):
                    key, value = line.strip().split("=", 1)
                    # Remove surrounding quotes if present
                    value = value.strip("'").strip('"')
                    creds[key] = value

    # Override/fallback to actual ENV
    return {
        "API_KEY": creds.get("BREEZE_API_KEY") or os.getenv("BREEZE_API_KEY"),
        "API_SECRET": creds.get("BREEZE_API_SECRET") or os.getenv("BREEZE_API_SECRET"),
        "SESSION_TOKEN": creds.get("BREEZE_SESSION_TOKEN") or os.getenv("BREEZE_SESSION_TOKEN"),
    }


class BreezeStandaloneAudit:
    def __init__(self):
        creds = load_env_credentials()
        self.api_key = creds["API_KEY"]
        self.api_secret = creds["API_SECRET"]
        self.session_token = creds["SESSION_TOKEN"]

        if not all([self.api_key, self.api_secret, self.session_token]):
            raise RuntimeError(f"Missing credentials in .env: {creds}")

        self.breeze = BreezeConnect(api_key=self.api_key)
        self.is_initialized = False

    def log(self, step, status, msg, data=None):
        icon = "[PASS]" if status == "PASS" else "[FAIL]" if status == "FAIL" else "[INFO]"
        print(f"\n{icon} [{step}] {msg}")
        if data:
            print(json.dumps(data, indent=2, default=str))

    def step_1_authenticate(self):
        try:
            print(f"DEBUG: Authenticating with API_KEY={self.api_key[:4]}...")
            self.breeze.generate_session(
                api_secret=self.api_secret, session_token=self.session_token
            )
            self.is_initialized = True
            self.log("AUTH", "PASS", "Session Generated Successfully")

            # Verify details
            res = self.breeze.get_customer_details()
            if res.get("Status") == 200:
                self.log("AUTH.Details", "PASS", "Customer Details Verified", res.get("Success"))
            else:
                self.log("AUTH.Details", "FAIL", "Fetch Failed", res)
            return True
        except Exception as e:
            self.log("AUTH", "FAIL", f"Authentication Failed: {e}")
            return False

    def step_2_market_data(self):
        if not self.is_initialized:
            return

        # Quotes
        try:
            res = self.breeze.get_quotes(stock_code=SYMBOL_EQUITY, exchange_code=EXCHANGE_NSE)
            self.log(
                "MKT.Quotes", "PASS", f"Snapshot for {SYMBOL_EQUITY}", res.get("Success", [])[:1]
            )
        except Exception as e:
            self.log("MKT.Quotes", "FAIL", str(e))

        # Historical V2
        try:
            to_date = datetime.now().strftime("%Y-%m-%dT%H:%M:%S.000Z")
            from_date = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%dT%H:%M:%S.000Z")
            res = self.breeze.get_historical_data_v2(
                interval="1minute",
                from_date=from_date,
                to_date=to_date,
                stock_code="NIFTY",
                exchange_code="NSE",
                product_type="cash",
            )
            count = len(res.get("Success", [])) if res.get("Success") else 0
            self.log("MKT.HistV2", "PASS", f"Bar Data Fetched ({count} bars)")
        except Exception as e:
            self.log("MKT.HistV2", "FAIL", str(e))

    def step_3_trading_view(self):
        if not self.is_initialized:
            return
        try:
            res = self.breeze.get_portfolio_positions()
            self.log("TRADE.Positions", "PASS", "Positions Fetched", res.get("Success", []))
        except Exception as e:
            self.log("TRADE.Positions", "FAIL", str(e))

    def step_4_websocket(self):
        if not self.is_initialized:
            return
        self.log("WS", "INFO", "Connecting to WebSocket for 5 seconds...")
        self.tick_count = 0

        def on_ticks(data):
            self.tick_count += 1
            if self.tick_count == 1:
                print(f"First Tick Received: {data}")

        self.breeze.on_ticks = on_ticks
        try:
            self.breeze.ws_connect()
            self.breeze.subscribe_feeds(stock_token=SYMBOL_EQUITY, interval="1second")
            time.sleep(5)
            if self.tick_count > 0:
                self.log("WS", "PASS", f"Received {self.tick_count} ticks")
            else:
                self.log("WS", "WARN", "Connected but No Ticks Received (Market Closed?)")
            self.breeze.ws_disconnect()
        except Exception as e:
            self.log("WS", "FAIL", str(e))

    def run_all(self):
        print(f"--- Breeze Standalone Audit Run: {datetime.now()} ---")
        if self.step_1_authenticate():
            self.step_2_market_data()
            self.step_3_trading_view()
            self.step_4_websocket()
        print("\n--- Audit Completed ---")


if __name__ == "__main__":
    try:
        audit = BreezeStandaloneAudit()
        audit.run_all()
    except Exception as e:
        print(f"FATAL: {e}")
