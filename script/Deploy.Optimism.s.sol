// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.18;

import "forge-std/Script.sol";

import {OrderExecution} from "src/OrderExecution.sol";

/**
 * TO DEPLOY:
 *
 * To load the variables in the .env file
 * > source .env
 *
 * To deploy and verify our contract
 * > forge script script/Deploy.Optimism.s.sol:Deploy --rpc-url $OPTIMISM_RPC_URL --broadcast --verify -vvvv
 */

contract Deploy is Script {
    address payable public owner = payable(0xC78a0fc7887844775f07191Ca921065ecc9E6F6E);
    address public perpsV2ExchangeRate = 0x2C15259D4886e2C0946f9aB7a5E389c86b3c3b04;

    OrderExecution public orderExecution;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        orderExecution = new OrderExecution({
            _owner: owner,
            _perpsV2ExchangeRate: perpsV2ExchangeRate
        });

        vm.stopBroadcast();
    }
}
