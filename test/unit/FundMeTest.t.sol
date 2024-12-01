// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe private fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant START_BALANCE = 10 ether;
	uint256 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, START_BALANCE);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund{value: 0}();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testAddrsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = address(msg.sender).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = address(msg.sender).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingFundMeBalance + startingOwnerBalance
        );
    }

	function testWithdrawFromMultipleFunders() public funded {
		// Arrange
		for (uint256 i = 1; i< 5; i++) {
			address funder = makeAddr(string(abi.encodePacked("funder", i)));
			hoax(funder, START_BALANCE);
			fundMe.fund{value: SEND_VALUE}();
		}
		uint256 startingFundMeBalance = address(fundMe).balance;
		uint256 startingOwnerBalance = address(msg.sender).balance;

		// Act
		uint256 gasStart = gasleft();
		vm.txGasPrice(GAS_PRICE);
		vm.prank(fundMe.getOwner());
		fundMe.withdraw();
		uint256 gasEnd = gasleft();
		uint256 gasUsed = gasStart - gasEnd;
		console.log(gasUsed);

		// Assert
		assertEq(address(fundMe).balance, 0);
		assertEq(startingFundMeBalance + startingOwnerBalance, address(msg.sender).balance);
	}

		function testWithdrawFromMultipleFundersCheaper() public funded {
		// Arrange
		for (uint256 i = 1; i< 5; i++) {
			address funder = makeAddr(string(abi.encodePacked("funder", i)));
			hoax(funder, START_BALANCE);
			fundMe.fund{value: SEND_VALUE}();
		}
		uint256 startingFundMeBalance = address(fundMe).balance;
		uint256 startingOwnerBalance = address(msg.sender).balance;

		// Act
		uint256 gasStart = gasleft();
		vm.txGasPrice(GAS_PRICE);
		vm.prank(fundMe.getOwner());
		fundMe.cheaperWithdraw();
		uint256 gasEnd = gasleft();
		uint256 gasUsed = gasStart - gasEnd;
		console.log(gasUsed);

		// Assert
		assertEq(address(fundMe).balance, 0);
		assertEq(startingFundMeBalance + startingOwnerBalance, address(msg.sender).balance);
	}
}
