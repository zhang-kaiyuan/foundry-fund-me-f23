// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelpConfig is Script {
    NetworkConfig private s_activeNetworkConfig;

	uint8 private constant DECIMALS = 8;
	int256 private constant INITIAL_PRICE = 2000e8;

    // 本地mock
    // 链上选择地址
    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 421614) {
            s_activeNetworkConfig = getSepoliaEthConfig();
        } else {
            s_activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() private pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({
            priceFeed: 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165
        });
        return config;
    }

    function getOrCreateAnvilEthConfig() private returns (NetworkConfig memory) {
		if(s_activeNetworkConfig.priceFeed != address(0)) {
			return s_activeNetworkConfig;
		}
        // 1.deploy mocks
		// 2.return mocks address

		vm.startBroadcast();
		MockV3Aggregator aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
		vm.stopBroadcast();

		NetworkConfig memory config = NetworkConfig({
		    priceFeed: address(aggregator)
		});
		return config;
    }

	function getActiveNetworkConfig() public view returns (address) {
        return s_activeNetworkConfig.priceFeed;
	}
}
