// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {OrderExecution} from "src/OrderExecution.sol";
import {IPerpsV2ExchangeRate} from "src/interfaces/IPerpsV2ExchangeRate.sol";

contract OrderExecutionTest is Test {
    OrderExecution public orderExecution;

    function setUp() public {
        vm.mockCall(
            address(0), abi.encodeWithSelector(IPerpsV2ExchangeRate.offchainOracle.selector), abi.encode(address(0))
        );
        orderExecution = new OrderExecution(payable(address(this)), address(0));
    }

    receive() external payable {}

    function testWithdrawEth() public {
        vm.deal(address(orderExecution), 1 ether);
        uint256 balanceBefore = address(this).balance;
        orderExecution.withdrawEth();
        uint256 balanceAfter = address(this).balance;
        assertGt(balanceAfter, balanceBefore);
    }
}
