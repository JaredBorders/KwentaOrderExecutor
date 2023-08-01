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

    function test_WithdrawEth() public {
        vm.deal(address(orderExecution), 1 ether);
        uint256 balanceBefore = address(this).balance;
        orderExecution.withdrawEth(payable(address(this)));
        uint256 balanceAfter = address(this).balance;
        assertGt(balanceAfter, balanceBefore);
    }

    function test_DepositEth() public {
        uint256 balanceBefore = address(orderExecution).balance;
        (bool s,) = address(orderExecution).call{value: 1 ether}("");
        assert(s);
        uint256 balanceAfter = address(orderExecution).balance;
        assertGt(balanceAfter, balanceBefore);
    }
}
