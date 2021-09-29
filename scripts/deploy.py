from brownie import FundMe, MockV3Aggregator, network, config
from scripts.helpful_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)  # reads get ccount and deploy mocks functions from helpful scritps file


def deploy_fund_me():
    account = get_account()
    # need to pass price feed address to fundme contract

    # if we are on persistent network(eg rinkeby) use associated address
    # otherwise deploy mocks:
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]  # address of rinkeby chainlink eth price feed
        # ie if not on development chain (ie on persistent chain) take price feed data from contract written under the active chain's section in the borwnie config.yaml file
        # if on developmetn chain we need to deploy our own verison of the price feed contract AKA 'mocking':
    else:
        deploy_mocks()  # deploys mock aggregator contract and writes mock aggregator contract address to variable mock_aggregator
        price_feed_address = MockV3Aggregator[
            -1
        ].address  # use most recently deployed v3 aggregator

        # to deploy the price feed ourselves, we need the solidity code associated to it
        # check folder called 'test' in contracts section of the brownie fund me folder
    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get(
            "verify"
        ),  # .get verify helps in case we forget to write verify in config file
    )  # deploy and we would like to publish our source code
    print(
        f"contract deployed to {fund_me.address}"
    )  # will return address of fund_me contract
    return fund_me


def main():
    deploy_fund_me()
