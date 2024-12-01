// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns(FundMe) {
		// startBroadcast 之前的不是真正的交易
        HelpConfig config = new HelpConfig();
		address ehtUsdPriceFeed = config.getActiveNetworkConfig();

        vm.startBroadcast();
		// startBroadcast 之后的才是真正的交易
        FundMe fundMe = new FundMe(ehtUsdPriceFeed);
        vm.stopBroadcast();

		return fundMe;
    }
}
