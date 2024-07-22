// SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import "lib/forge-std/src/Script.sol";
import "../src/FundMe.sol";
import "./HelperConfig.s.sol";

contract FundMeScript is Script {
    function run() public returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();

        address priceFeedEthUsd = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedEthUsd);
        vm.stopBroadcast();
        return fundMe;
    }
}
