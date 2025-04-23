// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {MetadataLib} from "../src/MetadataLib.sol";

contract MetadataLibTest is Test {
    using MetadataLib for MetadataLib.Metadata;
    
    MetadataLib.Metadata metadata;
    
    function setUp() public {
        // Initialize metadata with default values
        string[] memory initialLinks = new string[](0);
        metadata.setMetadata("Initial Title", "Initial Description", "initial.eth", initialLinks, "");
    }
    
    function testSetMetadata() public {
        string[] memory links = new string[](2);
        links[0] = "https://twitter.com/test";
        links[1] = "https://github.com/test";
        
        metadata.setMetadata("Test Title", "Test Description", "test.eth", links, "https://test.com/metadata.json");
        
        (
            string memory title,
            string memory description,
            string memory ensName,
            bool verification,
            string[] memory retrievedLinks,
            string memory externalDataURI,
            uint256 lastUpdated
        ) = metadata.getMetadata();
        
        assertEq(title, "Test Title");
        assertEq(description, "Test Description");
        assertEq(ensName, "test.eth");
        assertEq(verification, false);
        assertEq(retrievedLinks.length, 2);
        assertEq(retrievedLinks[0], "https://twitter.com/test");
        assertEq(retrievedLinks[1], "https://github.com/test");
        assertEq(externalDataURI, "https://test.com/metadata.json");
        assertTrue(lastUpdated > 0);
    }
    
    function testSetSocialMediaLinks() public {
        string[] memory links = new string[](1);
        links[0] = "https://example.com/social";
        
        uint256 timestampBefore = block.timestamp;
        metadata.setSocialMediaLinks(links);
        
        string[] memory retrievedLinks = metadata.getSocialMediaLinks();
        uint256 lastUpdated = metadata.getLastUpdated();
        
        assertEq(retrievedLinks.length, 1);
        assertEq(retrievedLinks[0], "https://example.com/social");
        assertTrue(lastUpdated >= timestampBefore);
    }
    
    function testSetExternalDataURI() public {
        string memory uri = "https://example.com/data.json";
        
        uint256 timestampBefore = block.timestamp;
        metadata.setExternalDataURI(uri);
        
        string memory retrievedURI = metadata.getExternalDataURI();
        uint256 lastUpdated = metadata.getLastUpdated();
        
        assertEq(retrievedURI, uri);
        assertTrue(lastUpdated >= timestampBefore);
    }
    
    function testVerificationStatusReset() public {
        // First manually set verification to true (not the normal way, but for testing)
        metadata.verification = true;
        assertTrue(metadata.verification);
        
        // Now update metadata which should reset verification
        string[] memory links = new string[](0);
        metadata.setMetadata("New Title", "New Description", "new.eth", links, "");
        
        (,,, bool verification,,,) = metadata.getMetadata();
        assertFalse(verification);
    }
    
    function testLastUpdatedChanges() public {
        // Record initial timestamp
        (,,,,,,uint256 initialTimestamp) = metadata.getMetadata();
        
        // Wait for a block
        vm.warp(block.timestamp + 1);
        
        // Update metadata
        string[] memory links = new string[](0);
        metadata.setMetadata("New Title", "New Description", "new.eth", links, "");
        
        // Get new timestamp
        (,,,,,,uint256 newTimestamp) = metadata.getMetadata();
        
        // Verify timestamp changed
        assertTrue(newTimestamp > initialTimestamp);
    }
}
