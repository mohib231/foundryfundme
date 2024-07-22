//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "lib/forge-std/src/Test.sol";

import {FundMe} from "../src/FundMe.sol";
import {FundMeScript} from "../script/FundMeScript.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 constant SEND_VALUE = 0.2 ether;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        FundMeScript fundMeScript = new FundMeScript();
        fundMe = fundMeScript.run();
        vm.deal(USER, STARTING_BALANCE);
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
    }

    function test_minimumUsd() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e19);
    }

    function test_isOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function test_feedVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function test_fundFailsWithoutEth() public {
        vm.expectRevert();
        fundMe.fund();
    }
    function test_funderValue() public view {
        uint256 amountFunded = fundMe.getAddressToFunds(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
    function test_funderAddress() public view {
        address funderAddress = fundMe.getFunders(0);
        assertEq(funderAddress, USER);
    }
    function test_OnlyOwnerCanWithDraw() public {
        vm.prank(address(this));
        vm.expectRevert();
        fundMe.withdraw();
    }
    function test_withDrawWithASingleOwner() public {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function test_withdrawfromMultipleFunders() public {
        uint160 totalFunders = 10;
        uint160 startingFunderIndex = 1;

        for (
            uint160 index = startingFunderIndex;
            index < totalFunders;
            index++
        ) {
            hoax(address(index), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingOwnerBalance + startingFundMeBalance ==
                fundMe.getOwner().balance
        );
    }
}
