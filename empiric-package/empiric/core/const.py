import os

ADMIN_ADDRESS = 0x0704CC0F2749637A0345D108AC9CD597BB33CCF7F477978D52E236830812CD98
PUBLISHER_REGISTRY_ADDRESS = (
    0x0743E8140A56D5EE9ED08EB77A92BCBCF8257DA34AB2A2EE93110709E61AB11A
)
ORACLE_CONTROLLER_ADDRESS = (
    0x012FADD18EC1A23A160CC46981400160FBF4A7A5EED156C4669E39807265BCD4
)

NETWORK = "testnet"
DEFAULT_AGGREGATION_MODE = 0

if os.environ.get("__EMPIRIC_STAGING_ENV__") == "TRUE":
    print("Warning: Communicating with staging contracts, not production")
    ORACLE_CONTROLLER_ADDRESS = (
        0x00225A37DE623DBD4D2287DDED4E0CB0EB4A5D7D9051D0E89A1321D4BCF9FDB2
    )
    PUBLISHER_REGISTRY_ADDRESS = (
        0x051949605AB53FCC2C0ADC1D53A72DD0FBCBF83E52399A8B05552F675B1DB4E9
    )
