import logging
import os
import random
from typing import Dict, Any

logger = logging.getLogger("gdelt_client")


class GDELTClient:
    def __init__(self):
        self.mock_mode = os.environ.get("BREEZE_MOCK", "0") == "1"

    def check_sentiment(self, query: str = "Indian Economy") -> Dict[str, Any]:
        """
        Return sentiment metrics.
        Mock: Returns stable/unsafe based on query or random deterministic?
        Constraint: default_allow in mock.
        """
        if self.mock_mode:
            # Deterministic: safe
            return {"tone": -1.0, "volume": 100, "status": "ok"}

        # Real impl would use requests
        # try: import requests; ... except ...
        # For now return default safe
        return {"tone": -2.0, "volume": 500, "status": "mock_real"}
