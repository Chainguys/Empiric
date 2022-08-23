%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.pow import pow
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import unsigned_div_rem

from contracts.admin.library import Admin
from contracts.oracle_controller.IOracleController import IOracleController, EmpiricAggregationModes

#
# Consts
#

const SLASH_USD = 796226404  # str_to_felt("/usd")
const SLASH_USD_BITS = 32

@storage_var
func oracle_controller_address_storage() -> (oracle_controller_address : felt):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt, oracle_controller_address : felt
):
    Admin.initialize_admin_address(admin_address)
    oracle_controller_address_storage.write(oracle_controller_address)
    return ()
end

#
# Getters
#

@view
func get_rebased_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    quote_currency : felt, base_currency : felt
) -> (value : felt, decimals : felt, last_updated_timestamp : felt, num_sources_aggregated : felt):
    alloc_locals
    let (local oracle_controller_address) = oracle_controller_address_storage.read()

    let (quote_asset_key) = _convert_currency_to_asset_key(
        quote_currency, SLASH_USD, SLASH_USD_BITS
    )
    let (
        quote_value, quote_decimals, quote_last_updated_timestamp, quote_num_sources_aggregated
    ) = IOracleController.get_value(
        oracle_controller_address, quote_asset_key, EmpiricAggregationModes.MEDIAN
    )
    if quote_last_updated_timestamp == 0:
        return (0, 0, 0, 0)
    end

    let (base_asset_key) = _convert_currency_to_asset_key(base_currency, SLASH_USD, SLASH_USD_BITS)
    let (
        base_value, base_decimals, base_last_updated_timestamp, base_num_sources_aggregated
    ) = IOracleController.get_value(
        oracle_controller_address, base_asset_key, EmpiricAggregationModes.MEDIAN
    )
    if base_last_updated_timestamp == 0:
        return (0, 0, 0, 0)
    end

    let (decimals) = _min(quote_decimals, base_decimals)
    let (last_updated_timestamp) = _max(quote_last_updated_timestamp, base_last_updated_timestamp)
    let (num_sources_aggregated) = _max(quote_num_sources_aggregated, base_num_sources_aggregated)

    # Prevent division by zero
    if base_value == 0:
        return (0, decimals, last_updated_timestamp, num_sources_aggregated)
    end

    # TODO: Do conversion
    return (0, decimals, last_updated_timestamp, num_sources_aggregated)
end

#
# Helpers
#

func _convert_currency_to_asset_key{range_check_ptr}(
    currency : felt, asset : felt, asset_bits : felt
) -> (asset_key : felt):
    let (shifted) = _bitshift_left(currency, asset_bits)
    let asset_key = shifted + asset
    return (asset_key)
end

func _bitshift_left{range_check_ptr}(value : felt, num_bits : felt) -> (shifted : felt):
    # Check for overflow?
    let (multiplier) = pow(2, num_bits)
    let shifted = value * multiplier
    return (shifted)
end

func _max{range_check_ptr}(a : felt, b : felt) -> (max_val : felt):
    let (a_is_less) = is_le(a, b)
    if a_is_less == TRUE:
        return (b)
    end
    return (a)
end

func _min{range_check_ptr}(a : felt, b : felt) -> (min_val : felt):
    let (a_is_less) = is_le(a, b)
    if a_is_less == TRUE:
        return (a)
    end
    return (b)
end
