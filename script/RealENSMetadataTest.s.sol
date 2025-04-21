// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ENSMetadata} from "../src/ENSMetadata.sol";
import {ENSVerificationLib} from "../src/ENSVerificationLib.sol";

interface IENSRegistry {
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
}

interface IENSResolver {
    function addr(bytes32 node) external view returns (address);
    function setAddr(bytes32 node, address addr) external;
}

contract RealENSMetadataTest is Script {
    // Mainnet ENS Registry address
    address constant ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    
    // Well-known ENS name to check (vitalik.eth)
    string constant KNOWN_ENS_NAME = "vitalik.eth";
    bytes32 constant KNOWN_ENS_NODE = 0xee6c4522aab0003e8d14cd40a6af439055fd2577951148c14b6cea9a53475835;
    address constant KNOWN_ENS_OWNER = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    
    // Our test name that we will impersonate ownership for
    string constant TEST_ENS_NAME = "test-ens-metadata.eth";
    
    function setUp() public {}

    function run() public {
        // We won't broadcast any transactions, just test the view functions
        vm.startPrank(KNOWN_ENS_OWNER);
        
        console.log("=== REAL ENS METADATA TEST ON FORKED MAINNET ===\n");
        
        // 1. First verify we can read data from the real ENS registry
        bytes32 knownNode = ENSVerificationLib.namehash(KNOWN_ENS_NAME);
        console.log("Computed namehash for", KNOWN_ENS_NAME, ":");
        console.logBytes32(knownNode);
        console.log("Should match known value:", uint256(KNOWN_ENS_NODE));
        require(knownNode == KNOWN_ENS_NODE, "Namehash computation is incorrect");
        
        // 2. Check we can access the ENS registry
        address ownerFromRegistry = IENSRegistry(ENS_REGISTRY).owner(knownNode);
        console.log("\nOwner of", KNOWN_ENS_NAME, "from ENS registry:", ownerFromRegistry);
        console.log("Expected owner (vitalik):", KNOWN_ENS_OWNER);
        require(ownerFromRegistry == KNOWN_ENS_OWNER, "Owner from registry doesn't match expected");
        
        // 3. Check if we can access resolver data
        address resolverAddress = IENSRegistry(ENS_REGISTRY).resolver(knownNode);
        console.log("\nResolver for", KNOWN_ENS_NAME, ":", resolverAddress);
        
        if (resolverAddress != address(0)) {
            address resolvedAddress = IENSResolver(resolverAddress).addr(knownNode);
            console.log("Address that", KNOWN_ENS_NAME, "resolves to:", resolvedAddress);
        }
        
        // 4. Create metadata for a real ENS name
        console.log("\n=== Testing ENSMetadata with Real ENS Registry ===\n");
        
        // Calculate namehash for our test ENS name
        bytes32 testNode = ENSVerificationLib.namehash(TEST_ENS_NAME);
        console.log("Test ENS node (namehash):", uint256(testNode));
        
        // Create metadata contract that uses the real ENS registry
        ENSMetadata ensMetadata = new ENSMetadata(
            "Real ENS Metadata Test",
            "Using the real ENS registry from forked mainnet",
            TEST_ENS_NAME,
            ENS_REGISTRY
        );
        
        console.log("ENSMetadata deployed at:", address(ensMetadata));
        
        // Check initial metadata
        (string memory title, string memory description, string memory ensName, bool verification) = 
            ensMetadata.getMetadata();
            
        console.log("\nInitial metadata:");
        console.log("Title:", title);
        console.log("Description:", description);
        console.log("ENS Name:", ensName);
        console.log("Verification:", verification);
        
        // Unfortunately, we can't modify the real ENS registry in a meaningful way
        // to test verification in this script. In a real test, we would need to:
        // 1. Own an ENS name on the real network
        // 2. Set its resolver to point to our contract
        // 3. Call verifyENS
        
        console.log("\nTest completed successfully! The forked ENS registry is accessible.");
        
        vm.stopPrank();
    }
} 