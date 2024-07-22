// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "../files/AggregatorV3Interface.sol";

error FundMe__notOwner();

contract FundMe {
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address[] s_funder;
    mapping(address => uint256) s_addressToFunds;

    address  immutable i_owner;
    AggregatorV3Interface s_priceFeed;

    constructor(address priceFeedAddress) {
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_owner = msg.sender;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    using PriceConverter for uint256;

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "funds are not enough"
        );
        s_funder.push(msg.sender);
        s_addressToFunds[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 index = 0; index < s_funder.length; index++) {
            s_addressToFunds[s_funder[index]] = 0;
        }
        (bool callbackSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callbackSuccess, "call failed");
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__notOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getFunders(uint256 index) external view returns (address) {
        return s_funder[index];
    }

    function getAddressToFunds(address add) external view returns (uint256){
        return s_addressToFunds[add];
    }
    function getOwner() external view returns(address){
        return i_owner;
    }
}
