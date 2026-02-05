from enum import Enum

# Ports
PORT_BREEZE = 17100
PORT_ENGINE = 17101
PORT_ORDERS = 17102
PORT_UI = 17103


class TelemetryLevel(str, Enum):
    IDLE = "0"
    L1 = "1"
    L2 = "2"


class Layer(str, Enum):
    BREEZE = "breeze"
    ENGINE = "engine"
    ORDERS = "orders"
    UI = "ui"


class Severity(str, Enum):
    DEBUG = "debug"
    INFO = "info"
    WARN = "warn"
    ERROR = "error"
