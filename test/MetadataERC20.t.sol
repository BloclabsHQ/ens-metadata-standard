// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {ENSMetadata} from "../src/ENSMetadata.sol";
import {MetadataERC20} from "../src/MetadataERC20.sol";

contract MetadataERC20Test is Test {
    // Mock ENS Registry address
    address constant ENS_REGISTRY = address(0x123);
    
    // Contract instances
    ENSMetadata ensMetadata;
    MetadataERC20 token;
    
    // Test values
    string constant METADATA_TITLE = "ENS Metadata for ERC20";
    string constant METADATA_DESCRIPTION = "An example token using ENS Metadata standard";
    string constant METADATA_ENS_NAME = "token-metadata.eth";
    
    string constant TOKEN_NAME = "Metadata Enhanced Token";
    string constant TOKEN_SYMBOL = "MET";
    uint256 constant INITIAL_SUPPLY = 1000000; // 1 million tokens
    
    // Test accounts
    address deployer = address(this);
    address user1 = address(0xABCD);
    address user2 = address(0xEF12);

    function setUp() public {
        // Deploy the ENSMetadata contract
        ensMetadata = new ENSMetadata(
            METADATA_TITLE,
            METADATA_DESCRIPTION,
            METADATA_ENS_NAME,
            ENS_REGISTRY
        );
        
        // Deploy the token with a link to the ENSMetadata contract
        token = new MetadataERC20(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            address(ensMetadata),
            deployer
        );
        
        // Give some tokens to test users
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
        token.transfer(user1, 1000 * 10**18);
        token.transfer(user2, 2000 * 10**18);
        
        // Log setup information
        console.log("ENSMetadata deployed at:", address(ensMetadata));
        console.log("MetadataERC20 deployed at:", address(token));
    }

    function testTokenMetadata() public {
        // Get metadata through the token's interface
        (
            string memory tokenTitle,
            string memory tokenDescription,
            string memory tokenEnsName,
            bool tokenVerification
        ) = token.getTokenMetadata();
        
        // Verify metadata from token matches expected values
        assertEq(tokenTitle, METADATA_TITLE, "Token title mismatch");
        assertEq(tokenDescription, METADATA_DESCRIPTION, "Token description mismatch");
        assertEq(tokenEnsName, METADATA_ENS_NAME, "Token ENS name mismatch");
        assertEq(tokenVerification, false, "Token verification should be false initially");
        
        // Log the retrieved metadata
        console.log("Retrieved Token Metadata:");
        console.log("Title:", tokenTitle);
        console.log("Description:", tokenDescription);
        console.log("ENS Name:", tokenEnsName);
        console.log("Verification:", tokenVerification ? "true" : "false");
    }

    function testERC20Functionality() public {
        // Test basic ERC-20 functions while maintaining metadata
        uint256 user1Balance = token.balanceOf(user1);
        uint256 user2Balance = token.balanceOf(user2);
        
        assertEq(user1Balance, 1000 * 10**18, "User1 balance incorrect");
        assertEq(user2Balance, 2000 * 10**18, "User2 balance incorrect");
        
        // Test transfer between users
        vm.prank(user1);
        token.transfer(user2, 500 * 10**18);
        
        assertEq(token.balanceOf(user1), 500 * 10**18, "User1 balance after transfer incorrect");
        assertEq(token.balanceOf(user2), 2500 * 10**18, "User2 balance after transfer incorrect");
        
        // Verify metadata still accessible after ERC-20 operations
        (
            string memory title,
            string memory description,
            string memory ensName,
            bool verification
        ) = token.getTokenMetadata();
        
        assertEq(title, METADATA_TITLE, "Metadata title should remain unchanged after transfers");
        assertEq(description, METADATA_DESCRIPTION, "Metadata description should remain unchanged after transfers");
    }

    function testUpdateMetadata() public {
        // Update the metadata via ENSMetadata contract
        string memory newTitle = "Updated Token Metadata";
        string memory newDescription = "This metadata has been updated";
        string memory newEnsName = "updated-token.eth";
        
        ensMetadata.setMetadata(newTitle, newDescription, newEnsName);
        
        // Get updated metadata through the token
        (
            string memory tokenTitle,
            string memory tokenDescription,
            string memory tokenEnsName,
            bool tokenVerification
        ) = token.getTokenMetadata();
        
        // Verify the updated metadata
        assertEq(tokenTitle, newTitle, "Updated title mismatch");
        assertEq(tokenDescription, newDescription, "Updated description mismatch");
        assertEq(tokenEnsName, newEnsName, "Updated ENS name mismatch");
        
        // Log the updated metadata
        console.log("Updated Token Metadata:");
        console.log("Title:", tokenTitle);
        console.log("Description:", tokenDescription);
        console.log("ENS Name:", tokenEnsName);
    }
} 