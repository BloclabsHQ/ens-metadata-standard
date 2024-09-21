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
    address contractOwner;
    address ensOwner;
    address otherAccount;

    function setUp() public {
        contractOwner = address(this); // The address running the test
        ensOwner = address(0x1234); // Simulated ENS name owner
        otherAccount = address(0x5678);
        // Deploy the mock ENS registry and resolver
        mockENSRegistry = new MockENSRegistry();
        mockENSResolver = new MockENSResolver();

        // Deploy the ENSMetadata contract with the mock ENS registry
        ensMetadata = new ENSMetadata("Test Title", "Test Description", "example.eth", address(mockENSRegistry));
    }

    function test_RevertIf_NotOwner() public {
        string memory ensName = "example.eth";
        bytes32 node = ENSVerificationLib.namehash(ensName);

        // Set ownership of the ENS name to ensOwner
        mockENSRegistry.setOwner(node, ensOwner);

        // Set resolver for the ENS name
        mockENSRegistry.setResolver(node, address(mockENSResolver));

        // Set the address record to point to the contract's address
        mockENSResolver.setAddr(node, address(ensMetadata));

        // Attempt to call verifyENS and expect it to revert
        vm.expectRevert("Caller is not the owner of the ENS name");
        // Simulate the call from otherAccount
        vm.prank(otherAccount);
        ensMetadata.verifyENS();
    }

    function test_RevertWhen_ResolverAddressIsWrong() public {
        string memory ensName = "example.eth";
        bytes32 node = ENSVerificationLib.namehash(ensName);

        // Set ownership of the ENS name to ensOwner
        mockENSRegistry.setOwner(node, ensOwner);

        // Set resolver for the ENS name
        mockENSRegistry.setResolver(node, address(mockENSResolver));

        // Set the address record to point to a different address
        mockENSResolver.setAddr(node, otherAccount);

        // Expect the function to revert with the specific error message
        vm.expectRevert("ENS name does not resolve to the contract address");
        // Simulate the call from ensOwner
        vm.prank(ensOwner);
        ensMetadata.verifyENS();
    }

    function testVerifyENSSuccess() public {
        string memory ensName = "example.eth";
        bytes32 node = ENSVerificationLib.namehash(ensName);

        // Set ownership of the ENS name to ensOwner
        mockENSRegistry.setOwner(node, ensOwner);

        // Set resolver for the ENS name
        mockENSRegistry.setResolver(node, address(mockENSResolver));

        // Set the address record to point to the contract's address
        mockENSResolver.setAddr(node, address(ensMetadata));

        // Simulate the call from ensOwner
        vm.prank(ensOwner);

        // Call verifyENS
        bool success = ensMetadata.verifyENS();
        assertTrue(success);

        // Check that verification status is true
        bool isVerified = ensMetadata.isVerified();
        assertTrue(isVerified);
    }

    // ============================
    function testVerifyENSEmptyName() public {
        // Set the ENS name to an empty string
        vm.prank(contractOwner);
        ensMetadata.setMetadata("Test Title", "Test Description", "");

        // Attempt to call verifyENS and expect it to revert
        vm.expectRevert("ENS name cannot be empty");
        ensMetadata.verifyENS();
    }
    // Purpose: Checks that verifyENS() reverts when the resolver is not set for the ENS name.

    function test_RevertIf_ENSResolverNotSet() public {
        // testVerifyENSResolverNotSet
        string memory ensName = "example.eth";
        bytes32 node = ENSVerificationLib.namehash(ensName);

        // Set ownership of the ENS name to ensOwner
        mockENSRegistry.setOwner(node, ensOwner);

        // Do not set the resolver for the ENS name
        // Expect the function to revert with the specific error message
        vm.expectRevert("Resolver not set for ENS name");
        // Simulate the call from ensOwner
        vm.prank(ensOwner);
        ensMetadata.verifyENS();
    }
}
