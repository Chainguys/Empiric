%lang starknet

from starkware.cairo.common.pow import pow

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
    let (base_asset_key) = _convert_currency_to_asset_key(base_currency, SLASH_USD, SLASH_USD_BITS)
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
