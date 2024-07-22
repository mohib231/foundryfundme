//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "lib/forge-std/src/Test.sol";

import {FundMeScript} from "../../script/FundMeScript.s.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsFundMe is Test {
    FundMe fundMe;
    uint256 constant SEND_VALUE = 0.2 ether;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        FundMeScript fundMeScript = new FundMeScript();
        fundMe = fundMeScript.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function test_UserFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        // address funder = FundMe.getFunders(0);
        // assertEq(funder,USER);
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }
}
