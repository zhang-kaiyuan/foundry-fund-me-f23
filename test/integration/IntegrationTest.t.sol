// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract IntegrationTest is Test {
    FundMe private fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 5 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
		fundMe = deployer.run();
        vm.deal(USER, START_BALANCE);
    }

	function testUserCanFundInteractions() public {
		FundFundMe funder = new FundFundMe();
		funder.fundFundMe(address(fundMe));

		WithdrawFundMe withdrawer = new WithdrawFundMe();
		withdrawer.withdrawFundMe(address(fundMe));

		assert(address(fundMe).balance == 0);
	}
}
