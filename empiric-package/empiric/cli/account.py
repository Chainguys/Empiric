import configparser
from pathlib import Path

import typer

from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.client import Client
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.models.address import AddressRepresentation
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.transactions.deploy import make_deploy_tx

from cli import SUCCESS

from .compiled_account_contract import COMPILED_ACCOUNT_CONTRACT


async def deploy_account_contract(
    client: Client, public_key: int
) -> AddressRepresentation:
    deploy_tx = make_deploy_tx(
        constructor_calldata=[public_key],
        compiled_contract=COMPILED_ACCOUNT_CONTRACT,
    )
    result = await client.deploy(deploy_tx)
    await client.wait_for_tx(
        tx_hash=result.hash,
    )
    return result.address


async def create_account(client: GatewayClient, config_file: Path):
    config_parser = configparser.ConfigParser()
    config_parser.read(config_file)

    account_private_key = int(config_parser["SECRET"]["admin-private-key"])

    key_pair = KeyPair.from_private_key(account_private_key)
    address = await deploy_account_contract(client, key_pair.public_key)
    typer.echo("created address:", address)

    return SUCCESS
