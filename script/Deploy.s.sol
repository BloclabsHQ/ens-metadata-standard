// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {ENSMetadata} from "../src/ENSMetadata.sol";

/**
 * @title DeployScript
 * @notice Script for deploying ENSMetadata contract to the BNB Chain testnet
 */
contract DeployScript is Script {
    // Configuration parameters
    string constant TITLE = "ENS Metadata Standard";
    string constant DESCRIPTION = "A standard for associating metadata with ENS names";
    string constant ENS_NAME = "ens-metadata.eth";
    
    // BSC Testnet ENS Registry address
    // Note: For BNB Chain testnet, we're using a placeholder address
    // In a real deployment, you would use the actual ENS registry address for the network
    address constant ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e; // Replace with actual registry on BSC

    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the ENSMetadata contract
        ENSMetadata ensMetadata = new ENSMetadata(
            TITLE,
            DESCRIPTION,
            ENS_NAME,
            ENS_REGISTRY
        );

        // Log deployment information
        console.log("ENSMetadata deployed at:", address(ensMetadata));
        console.log("Title:", TITLE);
        console.log("Description:", DESCRIPTION);
        console.log("ENS Name:", ENS_NAME);
        console.log("ENS Registry:", ENS_REGISTRY);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
