%lang starknet

from starkware.cairo.common.pow import pow
from starkware.cairo.common.math_cmp import is_le

from contracts.oracle_controller.IOracleController import IOracleController, EmpiricAggregationModes

#
# Consts
#

const SLASH_USD = 796226404  # str_to_felt("/usd")
const SLASH_USD_BITS = 32

@view
func get_rebased_value{range_check_ptr}(quote_currency : felt, base_currency : felt) -> (
    value : felt, decimals : felt, last_updated_timestamp : felt, num_sources_aggregated : felt
):
    let (quote_asset_key) = _convert_currency_to_asset_key(
        quote_currency, SLASH_USD, SLASH_USD_BITS
    )
    let (
        quote_value, quote_decimals, quote_last_updated_timestamp, quote_num_sources_aggregated
    ) = IOracleController.get_value(quote_asset_key, EmpiricAggregationModes.MEDIAN)
    if quote_last_updated_timestamp == 0:
        return ((0, 0, 0, 0))
    end

    let (base_asset_key) = _convert_currency_to_asset_key(base_currency, SLASH_USD, SLASH_USD_BITS)
    let (
        base_value, base_decimals, base_last_updated_timestamp, base_num_sources_aggregated
    ) = IOracleController.get_value(base_asset_key, EmpiricAggregationModes.MEDIAN)
    if base_last_updated_timestamp == 0:
        return ((0, 0, 0, 0))
    end

    # TODO: Do conversion

    let (decimals) = _min(quote_decimals, base_decimals)
    let (last_updated_timestamp) = _max(quote_last_updated_timestamp, base_last_updated_timestamp)
    let (num_sources_aggregated) = _max(quote_num_sources_aggregated, base_num_sources_aggregated)
    return ((0, decimals, last_updated_timestamp, num_sources_aggregated))
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

func _max(a : felt, b : felt) -> (max_val : felt):
    let (a_is_less) = is_le(a, b)
    if a_is_less == TRUE:
        return (b)
    end
    return (a)
end

func _min(a : felt, b : felt) -> (min_val : felt):
    let (a_is_less) = is_le(a, b)
    if a_is_less == TRUE:
        return (a)
    end
    return (b)
end
