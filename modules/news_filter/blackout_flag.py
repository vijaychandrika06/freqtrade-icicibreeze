from typing import Dict, Any


def is_blackout(sentiment: Dict[str, Any], tone_threshold: float = -5.0) -> bool:
    """
    Returns True if trading should be blacked out (high risk).
    """
    if sentiment.get("status") == "error":
        # Policy: fail open or closed?
        # Prompt: "define explicit fallback policy... default_allow"
        return False

    tone = sentiment.get("tone", 0.0)
    # GDELT Tone: range -10 to +10 usually. Very negative means bad news.
    if tone < tone_threshold:
        return True

    return False
