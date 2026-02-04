from abc import ABC, abstractmethod
from typing import Optional
from .schema import OptionChain


class OptionChainProvider(ABC):
    @abstractmethod
    def get_option_chain(self, underlying: str, expiry: str, right: str) -> Optional[OptionChain]:
        """
        Fetch option chain for a specific underlying, expiry, and right.
        Returns None if data unavailable or error.
        """
        pass
