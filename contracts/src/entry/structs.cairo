%lang starknet

struct Entry:
    member key : felt  # UTF-8 encoded lowercased string, e.g. "eth/usd"
    member value : felt
    member timestamp : felt
    member source : felt
    member publisher : felt
end

struct Checkpoint:
    member timestamp : felt
    member value : felt
end
