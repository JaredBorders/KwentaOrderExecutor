// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.18;

interface IAccount {
    /// @param _conditionalOrderId: key for an active conditional order
    function executeConditionalOrder(uint256 _conditionalOrderId) external;
}
