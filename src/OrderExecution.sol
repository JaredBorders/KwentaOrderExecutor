// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.18;

import {IAccount} from "src/interfaces/IAccount.sol";
import {IPerpsV2ExchangeRate} from "src/interfaces/IPerpsV2ExchangeRate.sol";
import {IPyth} from "src/interfaces/IPyth.sol";

/// @title utility contract for executing conditional orders
/// @author JaredBorders (jaredborders@pm.me)
contract OrderExecution {
    address payable public immutable BENEFICIARY;
    IPerpsV2ExchangeRate internal immutable PERPS_V2_EXCHANGE_RATE;
    IPyth internal immutable ORACLE;

    error PythPriceUpdateFailed();

    constructor(address payable _beneficiary, address _perpsV2ExchangeRate) {
        BENEFICIARY = _beneficiary;
        PERPS_V2_EXCHANGE_RATE = IPerpsV2ExchangeRate(_perpsV2ExchangeRate);
        ORACLE = PERPS_V2_EXCHANGE_RATE.offchainOracle();
    }

    /// @notice updates the Pyth oracle price feed and executes a batch of conditional orders
    /// @dev reverts if the Pyth price update fails
    /// @param priceUpdateData: array of price update data
    /// @param accounts: array of SM account addresses
    /// @param ids: array of conditional order Ids
    function updatePriceThenExecuteOrders(
        bytes[] calldata priceUpdateData,
        address[] calldata accounts,
        uint256[] calldata ids
    ) external payable {
        updatePythPrice(priceUpdateData);
        executeOrders(accounts, ids);
    }

    /// @notice withdraws ETH from the contract to the BENEFICIARY
    /// @dev reverts if the transfer fails
    function withdrawEth() external {
        (bool success,) = BENEFICIARY.call{value: address(this).balance}("");
        assert(success);
    }

    /// @dev updates the Pyth oracle price feed
    /// @dev refunds the caller any unused value not used to update feed
    /// @param priceUpdateData: array of price update data
    function updatePythPrice(bytes[] calldata priceUpdateData) public payable {
        uint256 fee = ORACLE.getUpdateFee(priceUpdateData);

        // try to update the price data (and pay the fee)
        try ORACLE.updatePriceFeeds{value: fee}(priceUpdateData) {}
        catch {
            revert PythPriceUpdateFailed();
        }

        uint256 refund = msg.value - fee;
        if (refund > 0) {
            // refund caller the unused value
            (bool success,) = msg.sender.call{value: refund}("");
            assert(success);
        }
    }

    /// @dev executes a batch of conditional orders in reverse order (i.e. LIFO)
    /// @param accounts: array of SM account addresses
    /// @param ids: array of conditional order Ids
    function executeOrders(address[] calldata accounts, uint256[] calldata ids) public {
        uint256 i = accounts.length;
        do {
            unchecked {
                --i;
            }

            (bool canExec,) = IAccount(accounts[i]).checker(ids[i]);
            if (!canExec) continue; // skip to next order without reverting

            IAccount(accounts[i]).executeConditionalOrder(ids[i]);
        } while (i != 0);
    }
}
