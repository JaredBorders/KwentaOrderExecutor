// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.18;

import {IPyth} from "src/interfaces/IPyth.sol";

interface IPerpsV2ExchangeRate {
    /// @notice fetches the Pyth oracle contract address from Synthetix
    /// @return Pyth contract
    function offchainOracle() external view returns (IPyth);
}
