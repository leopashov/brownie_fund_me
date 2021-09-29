# from scripts.deploy import DECIMALS, STARTING_PRICE
from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]

DECIMALS = 8
STARTING_PRICE = 200000000000


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[
            0
        ]  # if were on one of the development chains we just use the first account ganache gives us
    else:
        # return accounts.load("web3_programming")  # using brownie accounts function
        return accounts.add(
            config["wallets"]["from_key"]
        )  # taking private key from .env file


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("Deploying Mocks...")
    if (
        len(MockV3Aggregator) <= 0
    ):  # MockV3Aggregator is a list of all mock aggregators we have deployed
        MockV3Aggregator.deploy(
            DECIMALS, STARTING_PRICE, {"from": get_account()}
        )  # deploys mock aggregator contract and writes mock aggregator contract address to variable mock_aggregator
    print("Mocks Deployed!")


# Adding network:
# brownie networks add Ethereum rinkeby host=https://rinkeby.infura.io/v3/8fd1f62325db45758c5dc327762b01f1 chainid=4 explorer=https://api-rinkeby.etherscan.io/api
