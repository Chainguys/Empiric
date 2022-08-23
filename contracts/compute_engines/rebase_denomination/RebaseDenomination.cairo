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

# @param admin_address: admin for contract
# @param oracle_controller_address: address of oracle controller
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

# @notice Given a quote currency Q and a base currency B returns the value of Q/B
# @param quote_currency the quote currency: (ex. felt for ETH)
# @param base_currency the base currency: (ex. felt for BTC)
# @return value: the aggregated value
# @return decimals: the number of decimals in the Entry
# @return last_updated_timestamp: timestamp the Entries were last updated
# @return num_sources_aggregated: number of sources used in aggregation
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

    # TODO: Do conversion
    return (0, decimals, last_updated_timestamp, num_sources_aggregated)
end

# @notice get address for admin
# @return admin_address: returns admin's address
@view
func get_admin_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    admin_address : felt
):
    let (admin_address) = Admin.get_admin_address()
    return (admin_address)
end

# @notice get oracle controller for admin
# @return oracle_controller_address: address for oracle controller
@view
func get_oracle_controller_address{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}() -> (oracle_controller_address : felt):
    let (oracle_controller_address) = oracle_controller_address_storage.read()
    return (oracle_controller_address)
end

#
# Setters
#

# @notice update admin address
# @dev only the admin can set the new address
# @param new_address
@external
func set_admin_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_address : felt
):
    Admin.only_admin()
    Admin.set_admin_address(new_address)
    return ()
end

# @notice update oracle controller address
# @dev only the admin can update this
# @param oracle_controller_address: new oracle controller address
@external
func set_oracle_controller_address{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(oracle_controller_address : felt) -> ():
    Admin.only_admin()
    oracle_controller_address_storage.write(oracle_controller_address)
    return ()
end

#
# Helpers
#

# @dev converts a currency to an asset key
#      by constructing felt equivalent of "{currency}/{denominator}"
# @param currency: the currency to be turned into an asset_key
# @param denominator: the value the asset is denominated in
# @param denominator_bits: the number of bits needed to represent the denominator
# @return asset_key: the asset key as felt of "{currency}/{denominator}"
func _convert_currency_to_asset_key{range_check_ptr}(
    currency : felt, denominator : felt, denominator_bits : felt
) -> (asset_key : felt):
    let (shifted) = _bitshift_left(currency, denominator_bits)
    let asset_key = shifted + denominator
    return (asset_key)
end

# @dev Rounds value given the divisor and remainder of a division
# @param value: the value to be rounded
# @param divisor: the divisor of the division
# @param remainder: the remainder of the division
# @return shifted: the rounded felt
func _round_after_div{range_check_ptr}(value : felt, divisor : felt, remainder : felt) -> (
    rounded : felt
):
    let doubled = remainder * 2
    let (doubled_is_less) = is_le(doubled, divisor)
    if doubled_is_less == FALSE:
        return (value + 1)
    end
    return (value)
end

# @dev left shifts value by specified number of bits
# @param value: the value to be shifted
# @param num_bits: the number of bits to shift by
# @return shifted: the shifted felt
func _bitshift_left{range_check_ptr}(value : felt, num_bits : felt) -> (shifted : felt):
    # Check for overflow?
    let (multiplier) = pow(2, num_bits)
    let shifted = value * multiplier
    return (shifted)
end

# @param a: the first felt
# @param b: the second felt
# @return min_val: the bigger felt
func _max{range_check_ptr}(a : felt, b : felt) -> (max_val : felt):
    let (a_is_less) = is_le(a, b)
    if a_is_less == TRUE:
        return (b)
    end
    return (a)
end

# @param a: the first felt
# @param b: the second felt
# @return min_val: the smaller felt
func _min{range_check_ptr}(a : felt, b : felt) -> (min_val : felt):
    let (a_is_less) = is_le(a, b)
    if a_is_less == TRUE:
        return (a)
    end
    return (b)
end
