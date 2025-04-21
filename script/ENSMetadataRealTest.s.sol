// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ENSMetadata} from "../src/ENSMetadata.sol";
import {ENSVerificationLib} from "../src/ENSVerificationLib.sol";

interface IENSRegistry {
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function setResolver(bytes32 node, address resolver) external;
}

interface IENSResolver {
    function addr(bytes32 node) external view returns (address);
    function setAddr(bytes32 node, address addr) external;
}

contract ENSMetadataRealTest is Script {
    // Mainnet ENS Registry address
    address constant ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    
    // Known ENS name
    string constant VITALIK_ENS = "vitalik.eth";
    address constant VITALIK_ADDR = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    
    function setUp() public {}

    function run() public {
        console.log("=== ENS METADATA VERIFICATION WITH REAL REGISTRY ===\n");
        
        // Calculate namehash
        bytes32 vitalikNode = ENSVerificationLib.namehash(VITALIK_ENS);
        
        // 1. Check the current owner and resolver
        address currentOwner = IENSRegistry(ENS_REGISTRY).owner(vitalikNode);
        address currentResolver = IENSRegistry(ENS_REGISTRY).resolver(vitalikNode);
        address currentResolvedAddr = IENSResolver(currentResolver).addr(vitalikNode);
        
        console.log("Current state:");
        console.log("- Owner of", VITALIK_ENS, ":", currentOwner);
        console.log("- Resolver:", currentResolver);
        console.log("- Resolves to:", currentResolvedAddr);
        
        // 2. Deploy our ENS Metadata contract for vitalik.eth
        vm.startPrank(VITALIK_ADDR); // Impersonate Vitalik
        
        ENSMetadata ensMetadata = new ENSMetadata(
            "Vitalik's Metadata",
            "Testing metadata for vitalik.eth",
            VITALIK_ENS,
            ENS_REGISTRY
        );
        
        console.log("\nMetadata contract deployed at:", address(ensMetadata));
        
        // 3. Try to verify the ENS name
        console.log("\nCurrent verification status:");
        bool initialVerification = getVerificationStatus(ensMetadata);
        
        console.log("\nAttempting to verify the ENS name...");
        // This will fail because the resolver doesn't point to our contract
        try ensMetadata.verifyENS() returns (bool result) {
            console.log("Verification result:", result);
        } catch Error(string memory reason) {
            console.log("Verification failed with reason:", reason);
        } catch {
            console.log("Verification failed with unknown reason");
        }
        
        // 4. Modify the resolver to point to our contract (this is only possible in the forked environment)
        console.log("\nUpdating the resolver to point to our contract...");
        try IENSResolver(currentResolver).setAddr(vitalikNode, address(ensMetadata)) {
            console.log("Successfully updated the resolver");
            
            address newResolvedAddr = IENSResolver(currentResolver).addr(vitalikNode);
            console.log("Now", VITALIK_ENS, "resolves to:", newResolvedAddr);
            
            // 5. Try to verify again
            console.log("\nAttempting to verify the ENS name again...");
            try ensMetadata.verifyENS() returns (bool result) {
                console.log("Verification result:", result);
            } catch Error(string memory reason) {
                console.log("Verification failed with reason:", reason);
            } catch {
                console.log("Verification failed with unknown reason");
            }
            
            // 6. Check the verification status
            console.log("\nFinal verification status:");
            getVerificationStatus(ensMetadata);
        } catch Error(string memory reason) {
            console.log("Failed to update resolver with reason:", reason);
        } catch {
            console.log("Failed to update resolver with unknown reason");
        }
        
        vm.stopPrank();
    }
    
    function getVerificationStatus(ENSMetadata ensMetadata) internal returns (bool) {
        (string memory title, string memory description, string memory ensName, bool verification) = 
            ensMetadata.getMetadata();
            
        console.log("Metadata:");
        console.log("- Title:", title);
        console.log("- Description:", description);
        console.log("- ENS Name:", ensName);
        console.log("- Verification:", verification);
        
        return verification;
    }
}