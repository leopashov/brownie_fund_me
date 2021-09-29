//SPDX-License-identifier: MIT
pragma solidity ^0.6.6;

import "smartcontractkit/chainlink-brownie-contracts@1.1.1/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
//import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

import "smartcontractkit/chainlink-brownie-contracts@1.1.1/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

//import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

//takes code importing and stick it at top of this contract

//pragma solidity ^0.8.0;
/*
interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}
*/

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders; //creates an array for funders to go in
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        //price feed is input parameter
        // anything in here will get run immediately when we deploy the smart contract
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        //payable function means can be used to pay for things
        uint256 minimumUSD = 50 * 10**18; //50 usd in wei
        /*if(msg.value <minimumUSD){
            revert
        } one option for setting minimum spend*/

        require(
            getConversionRate(msg.value) >= minimumUSD,
            "you need to spend more ETH!"
        ); //if condition is not met code will stop running at this point
        addressToAmountFunded[msg.sender] += msg.value;
        //msg.sender is keyword returning sender of function call
        //msg.value is keyword giving value of wei sent;
        // here we are saving the value and sender in the mapping(dictionary) called addresstoamountfunded mapping
        funders.push(msg.sender); //adds address of person funding contract to 'funders' array
        //to use: enter value in deploy sidebar, click fund in deployed area, then copy account address into address to amount funded box and cal the address to amount fudned function

        //what is the eth to usd conversion rate? - where do we get this data from?
    }

    function getVersion() public view returns (uint256) {
        // line above creates an object of type AgreggatorV3Interface with name "priceFeed". we initialise AggregatorV3Interface with the contract address for the eth usd price price feed
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        /*(uint80 roundId,
         int256 answer,
         uint256 startedAt,
         uint256 updatedAt,
         uint80 answeredInRound) 
         = priceFeed.latestRoundData();*/

        (, int256 answer, , , ) = priceFeed.latestRoundData(); //same as above but doesnt use most variables

        return uint256(answer * 10000000000); //convert from wei
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        //minimum USD
        uint256 minimumUSD = 5 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _; //this means run modifier then run the rest of the code after
        // ie underscore says "run the function"
    }

    function withdraw() public payable onlyOwner {
        //only want contract owner to withdraw all funds from contract
        msg.sender.transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex]; //using the address of the funder relating to the index of the funder array we:
            addressToAmountFunded[funder] = 0; //... set the amount of funding relating to the address of the funder (in the mapping) to zero
        }
        funders = new address[](0); //set funders array to a new empty array
    }
}
