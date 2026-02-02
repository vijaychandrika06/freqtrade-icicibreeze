#!/usr/bin/env python3
import argparse
import json
import logging
import os
import secrets
import string
import sys
from datetime import datetime, timezone
from pathlib import Path


def setup_logging(verbosity: str):
    level = logging.INFO if verbosity == "info" else logging.ERROR
    logging.basicConfig(level=level, format="%(message)s")
    return logging.getLogger(__name__)


def generate_random_password(length=16):
    alphabet = string.ascii_letters + string.digits
    return "".join(secrets.choice(alphabet) for _ in range(length))


def resolve_credentials(username_arg, password_arg, auth_file: Path):
    # 1. CLI Args
    username = username_arg
    password = password_arg

    # 2. Environment Variables
    if not username:
        username = os.environ.get("FT_API_USERNAME")
    if not password:
        password = os.environ.get("FT_API_PASSWORD")

    # 3. Cache File
    if (not username or not password) and auth_file.exists():
        try:
            with auth_file.open("r") as f:
                data = json.load(f)
                if not username:
                    username = data.get("username")
                if not password:
                    password = data.get("password")
        except (json.JSONDecodeError, OSError):
            pass

    # 4. Defaults / Generation
    if not username:
        username = "admin"
    if not password:
        password = generate_random_password()

    return username, password


def persist_auth(username, password, auth_file: Path):
    auth_file.parent.mkdir(parents=True, exist_ok=True)
    with auth_file.open("w") as f:
        json.dump(
            {
                "username": username,
                "password": password,
                "updated_at_utc": datetime.now(timezone.utc).isoformat(),
            },
            f,
            indent=2,
        )
    auth_file.chmod(0o600)


def main():
    parser = argparse.ArgumentParser(description="Create UI-ready Freqtrade config.")
    parser.add_argument("--in-path", dest="in_path", required=True, help="Input config JSON")
    parser.add_argument("--out", dest="out_path", required=True, help="Output config JSON")
    parser.add_argument("--ip", default="127.0.0.1", help="API listen IP")
    parser.add_argument("--port", type=int, default=8080, help="API listen port")
    parser.add_argument("--username", help="API Username")
    parser.add_argument("--password", help="API Password")
    parser.add_argument(
        "--verbosity", choices=["error", "info"], default="error", help="API verbosity"
    )

    args = parser.parse_args()
    logger = setup_logging("info")

    auth_file = Path("user_data/cache/ui_api_auth.json")
    username, password = resolve_credentials(args.username, args.password, auth_file)
    persist_auth(username, password, auth_file)

    try:
        with Path(args.in_path).open() as f:
            config = json.load(f)
    except Exception as e:
        logger.error(f"Failed to read input config: {e}")
        sys.exit(1)

    config["api_server"] = {
        "enabled": True,
        "listen_ip_address": args.ip,
        "listen_port": args.port,
        "username": username,
        "password": password,
        "verbosity": args.verbosity,
    }

    try:
        out_path = Path(args.out_path)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        with out_path.open("w") as f:
            json.dump(config, f, indent=2)
    except Exception as e:
        logger.error(f"Failed to write output config: {e}")
        sys.exit(1)

    print(f"Wrote {args.out_path}")
    print(f"API server user: {username}")
    print("API server password: [stored in user_data/cache/ui_api_auth.json]")


if __name__ == "__main__":
    main()
