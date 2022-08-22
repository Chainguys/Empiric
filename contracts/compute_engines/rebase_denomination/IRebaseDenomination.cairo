%lang starknet

@contract_interface
namespace IOracleController:
    #
    # Getters
    #

    func get_rebased_value(quote_currency : felt, base_currency : felt) -> (
        value : felt, decimals : felt, last_updated_timestamp : felt, num_sources_aggregated : felt
    ):
    end
end
