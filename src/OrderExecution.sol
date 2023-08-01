// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.18;

import {IAccount} from "src/interfaces/IAccount.sol";
import {IPerpsV2ExchangeRate, IPyth} from "src/interfaces/IPerpsV2ExchangeRate.sol";

/// @title utility contract for executing conditional orders
/// @author JaredBorders (jaredborders@pm.me)
contract OrderExecution {
    address internal immutable OWNER;
    IPerpsV2ExchangeRate internal immutable PERPS_V2_EXCHANGE_RATE;
    IPyth internal immutable ORACLE;

    error PythPriceUpdateFailed();
    error OnlyOwner();

    modifier onlyOwner() {
        if (msg.sender != OWNER) revert OnlyOwner();
        _;
    }

    constructor(address _owner, address _perpsV2ExchangeRate) {
        OWNER = _owner;
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

    /// @dev updates the Pyth oracle price feed
    /// @dev refunds the caller any unused value not used to update feed
    /// @param priceUpdateData: array of price update data
    function updatePythPrice(bytes[] calldata priceUpdateData) public payable {
        uint256 fee = ORACLE.getUpdateFee(priceUpdateData);

        // try to update the price data (and pay the fee)
        /// @dev excess value is *not* automatically refunded
        /// and the caller must withdraw it manually
        try ORACLE.updatePriceFeeds{value: fee}(priceUpdateData) {}
        catch {
            revert PythPriceUpdateFailed();
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

    /*//////////////////////////////////////////////////////////////
                      MODIFY CONTRACT ETH BALANCE
    //////////////////////////////////////////////////////////////*/

    /// @notice withdraws ETH from the contract to the _beneficiary
    /// @dev reverts if the transfer fails
    /// @param _beneficiary: address to send ETH to
    function withdrawEth(address payable _beneficiary) external onlyOwner {
        (bool success,) = _beneficiary.call{value: address(this).balance}("");
        assert(success);
    }

    receive() external payable {}
}
