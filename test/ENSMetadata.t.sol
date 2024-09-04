// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ENSMetadata} from "../src/ENSMetadata.sol";
import {ENSVerificationLib} from "../src/ENSVerificationLib.sol";
import {MockENSRegistry} from "./utils/MockENSRegistry.t.sol";
import {MockENSResolver} from "./utils/MockENSResolver.t.sol";

contract ENSMetadataTest is Test {
    ENSMetadata ensMetadata;
    MockENSRegistry mockENSRegistry;
    MockENSResolver mockENSResolver;
    bytes32 ensNode;

    function setUp() public {
        // Deploy the mock ENS registry and resolver
        mockENSRegistry = new MockENSRegistry();
        mockENSResolver = new MockENSResolver();

        // Calculate the ENS node (namehash) for "ensname.eth"
        ensNode = keccak256(abi.encodePacked("ensname.eth"));

        // Set the resolver for the ENS name in the registry
        mockENSRegistry.setResolver(ensNode, address(mockENSResolver));

        // Set the address associated with the ENS name in the resolver
        mockENSResolver.setAddr(ensNode, address(ensMetadata)); // Example: pointing to the test contract's address

        // Deploy the ENSMetadata contract with the mock ENS registry
        ensMetadata = new ENSMetadata(
            "Initial Title",
            "Initial Description",
            "ensname.eth",
            address(mockENSRegistry)
        );
    }

    function testInitialMetadata() public view {
        (
            string memory title,
            string memory description,
            string memory ENS_name,
            bool verification
        ) = ensMetadata.getMetadata();

        assertEq(title, "Initial Title");
        assertEq(description, "Initial Description");
        assertEq(ENS_name, "ensname.eth");
        assertEq(verification, false); // Assuming verification is false initially
    }

    function testSetMetadata() public {
        // Set up the ENS resolver to resolve "newname.eth" to the ENSMetadata contract's address
        bytes32 newEnsNode = keccak256(abi.encodePacked("newname.eth"));
        mockENSRegistry.setResolver(newEnsNode, address(mockENSResolver));
        mockENSResolver.setAddr(newEnsNode, address(ensMetadata)); // Pointing to the ENSMetadata contract's address

        // Call the setMetadata function and expect it to succeed
        ensMetadata.setMetadata("New Title", "New Description", "newname.eth");

        // Verify the metadata was set correctly
        (
            string memory title,
            string memory description,
            string memory ENS_name,
            bool verification
        ) = ensMetadata.getMetadata();

        assertEq(title, "New Title");
        assertEq(description, "New Description");
        assertEq(ENS_name, "newname.eth");
        assertFalse(verification, "ENS name should not be verified yet");
    }

    function testNonOwnerCannotSetMetadata() public {
        vm.prank(address(0x1234)); // Simulate a different caller
        vm.expectRevert("Only the owner can modify the metadata");
        ensMetadata.setMetadata(
            "Unauthorized Title",
            "Unauthorized Description",
            "unauthorized.eth"
        );
    }

    function testVerifyENSName() public {
        // Set up the ENS resolver to resolve "ensname.eth" to the contract address
        mockENSResolver.setAddr(ensNode, address(ensMetadata));

        // Call a method to verify the ENS name
        bytes32 node = keccak256(abi.encodePacked("ensname.eth"));
        bool isVerified = ENSVerificationLib.verifyENS(
            address(mockENSRegistry),
            node,
            address(ensMetadata)
        );

        assertTrue(isVerified, "ENS name should be verified correctly");
    }

    function testVerifyENS() public {
        // Set up the ENS resolver to resolve "ensname.eth" to the ENSMetadata contract's address
        mockENSResolver.setAddr(ensNode, address(ensMetadata));

        // Call the verifyENS function to verify the ENS name
        ensMetadata.verifyENS();

        // Verify the metadata was correctly verified
        (
            string memory title,
            string memory description,
            string memory ENS_name,
            bool verification
        ) = ensMetadata.getMetadata();

        assertEq(title, "Initial Title");
        assertEq(description, "Initial Description");
        assertEq(ENS_name, "ensname.eth");
        assertTrue(verification, "ENS name should be correctly verified");
    }
}
