__app_name__ = "empiric_cli"

(
    SUCCESS,
    STARKNET_READ_ERROR,
    STARKNET_WRITE_ERROR,
) = range(3)

ERRORS = {
    STARKNET_READ_ERROR: "starknet read error",
    STARKNET_WRITE_ERROR: "starknet write error",
}
