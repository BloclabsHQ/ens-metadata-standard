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

        // Create empty array for social media links
        string[] memory socialMediaLinks = new string[](0);

        // Deploy the ENSMetadata contract with the mock ENS registry
        ensMetadata = new ENSMetadata(
            "Test Title",
            "Test Description",
            "example.eth",
            address(mockENSRegistry),
            socialMediaLinks,
            ""
        );
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
    }

    // ============================
    function testVerifyENSEmptyName() public {
        // Create empty array for social media links
        string[] memory socialMediaLinks = new string[](0);
        
        // Set the ENS name to an empty string
        vm.prank(contractOwner);
        ensMetadata.setMetadata("Test Title", "Test Description", "", socialMediaLinks, "");

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
    
    // Test for setting and retrieving social media links
    function testSetAndGetSocialMediaLinks() public {
        // Create array for social media links
        string[] memory socialMediaLinks = new string[](2);
        socialMediaLinks[0] = "https://twitter.com/example";
        socialMediaLinks[1] = "https://github.com/example";
        
        vm.prank(contractOwner);
        ensMetadata.setSocialMediaLinks(socialMediaLinks);
        
        string[] memory retrievedLinks = ensMetadata.getSocialMediaLinks();
        
        assertEq(retrievedLinks.length, 2);
        assertEq(retrievedLinks[0], "https://twitter.com/example");
        assertEq(retrievedLinks[1], "https://github.com/example");
    }
    
    // Test for setting and retrieving external data URI
    function testSetAndGetExternalDataURI() public {
        string memory testURI = "https://metadata.example.com/data.json";
        
        vm.prank(contractOwner);
        ensMetadata.setExternalDataURI(testURI);
        
        string memory retrievedURI = ensMetadata.getExternalDataURI();
        
        assertEq(retrievedURI, testURI);
    }
    
    // Test retrieving all metadata fields
    function testGetMetadata() public {
        // Create array for social media links
        string[] memory socialMediaLinks = new string[](1);
        socialMediaLinks[0] = "https://example.com/social";
        
        string memory externalURI = "https://example.com/metadata.json";
        
        vm.prank(contractOwner);
        ensMetadata.setMetadata("New Title", "New Description", "new.eth", socialMediaLinks, externalURI);
        
        (
            string memory title,
            string memory description,
            string memory ensName,
            bool verification,
            string[] memory retrievedLinks,
            string memory retrievedURI,
            uint256 lastUpdated
        ) = ensMetadata.getMetadata();
        
        assertEq(title, "New Title");
        assertEq(description, "New Description");
        assertEq(ensName, "new.eth");
        assertEq(verification, false);
        assertEq(retrievedLinks.length, 1);
        assertEq(retrievedLinks[0], "https://example.com/social");
        assertEq(retrievedURI, externalURI);
        assertTrue(lastUpdated > 0);
    }
}
