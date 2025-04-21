// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ENSMetadata} from "../src/ENSMetadata.sol";
import {ENSVerificationLib} from "../src/ENSVerificationLib.sol";
import {MockENSRegistry, MockENSResolver} from "../test/LiveENSVerification.t.sol";

contract ENSMetadataDemo is Script {
    // Constants
    address constant MAINNET_ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    string constant TEST_ENS_NAME = "test-demo.eth";
    
    // State variables
    ENSMetadata public ensMetadata;
    MockENSRegistry public mockRegistry;
    MockENSResolver public mockResolver;
    
    function setUp() public {}

    function run() public {
        // Start broadcasting transactions
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deployer address:", deployer);
        
        // Step 1: Deploy mock ENS infrastructure (for testing purposes)
        console.log("Deploying mock ENS infrastructure...");
        mockRegistry = new MockENSRegistry();
        mockResolver = new MockENSResolver();
        
        // Step 2: Deploy ENSMetadata contract
        console.log("Deploying ENSMetadata contract...");
        ensMetadata = new ENSMetadata(
            "Demo ENS Metadata",
            "This is a demonstration of the ENS Metadata standard",
            TEST_ENS_NAME,
            address(mockRegistry)
        );
        
        console.log("ENSMetadata deployed at:", address(ensMetadata));
        
        // Step 3: Set up the ENS name ownership and resolution
        bytes32 node = ENSVerificationLib.namehash(TEST_ENS_NAME);
        console.log("ENS node (namehash):", uint256(node));
        
        // Set the owner and resolver in the mock registry
        mockRegistry.setOwner(node, deployer);
        mockRegistry.setResolver(node, address(mockResolver));
        
        // Set the address to point to our contract
        mockResolver.setAddr(node, address(ensMetadata));
        
        console.log("ENS records configured");
        
        // Step 4: Check the initial metadata
        (string memory title, string memory description, string memory ensName, bool verification) = 
            ensMetadata.getMetadata();
            
        console.log("\nInitial metadata:");
        console.log("Title:", title);
        console.log("Description:", description);
        console.log("ENS Name:", ensName);
        console.log("Verification:", verification);
        
        // Step 5: Verify the ENS name
        console.log("\nVerifying ENS name...");
        bool verificationResult = ensMetadata.verifyENS();
        
        if (verificationResult) {
            console.log("ENS verification successful!");
        } else {
            console.log("ENS verification failed!");
        }
        
        // Step 6: Check the updated metadata after verification
        (title, description, ensName, verification) = ensMetadata.getMetadata();
            
        console.log("\nUpdated metadata after verification:");
        console.log("Title:", title);
        console.log("Description:", description);
        console.log("ENS Name:", ensName);
        console.log("Verification:", verification);
        
        // Step 7: Update the metadata
        console.log("\nUpdating metadata...");
        ensMetadata.setMetadata(
            "Updated ENS Metadata Title",
            "This metadata has been updated after verification",
            TEST_ENS_NAME
        );
        
        // Step 8: Check the final metadata
        (title, description, ensName, verification) = ensMetadata.getMetadata();
            
        console.log("\nFinal metadata after update:");
        console.log("Title:", title);
        console.log("Description:", description);
        console.log("ENS Name:", ensName);
        console.log("Verification:", verification, "\n");
        
        vm.stopBroadcast();
    }
} 