// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {MetadataERC20} from "../src/MetadataERC20.sol";
import {ENSMetadata} from "../src/ENSMetadata.sol";

contract DeployMetadataTokenScript is Script {
    // Token configuration
    string constant TOKEN_NAME = "Metadata Enhanced Token";
    string constant TOKEN_SYMBOL = "MET";
    uint256 constant INITIAL_SUPPLY = 1000000; // 1 million tokens
    
    // ENS Metadata configuration
    string constant METADATA_TITLE = "ENS Metadata for ERC20";
    string constant METADATA_DESCRIPTION = "An example token using ENS Metadata standard";
    string constant METADATA_ENS_NAME = "token-metadata.eth";
    
    // BSC Testnet ENS Registry address (placeholder)
    address constant ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;

    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // First deploy the ENSMetadata contract
        ENSMetadata ensMetadata = new ENSMetadata(
            METADATA_TITLE,
            METADATA_DESCRIPTION,
            METADATA_ENS_NAME,
            ENS_REGISTRY
        );
        
        console.log("ENSMetadata deployed at:", address(ensMetadata));

        // Then deploy the ERC-20 token with a link to the ENSMetadata
        MetadataERC20 token = new MetadataERC20(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            address(ensMetadata),
            msg.sender // The deployer will be the initial owner
        );
        
        console.log("MetadataERC20 deployed at:", address(token));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
} 