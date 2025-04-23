// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {MetadataLib} from "./MetadataLib.sol";
import {ENSVerificationLib} from "./ENSVerificationLib.sol";

/*
Purpose: This is the main contract that manages the ENS metadata for smart contracts.
It uses the MetadataLib and ENSVerificationLib to handle the logic for managing ENS metadata.
*/
interface IENSRegistry {
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
}

/// @title ENS Metadata Management Contract
/// @notice Manages metadata for a contract and verifies its associated ENS name.
/// @dev Designed as a standard for associating ENS names with smart contract metadata.
/// @author Bloclabs LLC
contract ENSMetadata {
    using MetadataLib for MetadataLib.Metadata;

    MetadataLib.Metadata public metadata;
    address public ensRegistry;

    event MetadataUpdated(
        string title, 
        string description, 
        string ENS_name, 
        bool verification,
        string[] socialMediaLinks,
        string externalDataURI,
        uint256 lastUpdated
    );
    event SocialMediaLinksUpdated(string[] socialMediaLinks);
    event ExternalDataURIUpdated(string externalDataURI);

    constructor(
        string memory _title, 
        string memory _description, 
        string memory _ENS_name, 
        address _ensRegistry,
        string[] memory _socialMediaLinks,
        string memory _externalDataURI
    ) {
        // Update the metadata with the new values
        metadata.setMetadata(
            _title, 
            _description, 
            _ENS_name, 
            _socialMediaLinks, 
            _externalDataURI
        );
        ensRegistry = _ensRegistry; // Set the ENS registry address based on the blockchain and environment
    }

    /// @notice Verifies that the ENS name is owned by the caller and resolves to this contract.
    function verifyENS() external returns (bool) {
        // Call the verification function in the library
        bool verification = ENSVerificationLib.verifyENS(ensRegistry, metadata.ENS_name, address(this), msg.sender);

        // If verification passes, set verification status to true
        metadata.verification = verification;

        return verification;
    }
    
    /// @notice Sets the metadata for the contract with a title, description, and ENS name.
    /// @dev This function updates the metadata and emits an event.
    /// It should only be called by the contract owner.
    function setMetadata(
        string memory _title,
        string memory _description,
        string memory _ENS_name,
        string[] memory _socialMediaLinks,
        string memory _externalDataURI
    ) public {
        metadata.setMetadata(
            _title,
            _description,
            _ENS_name,
            _socialMediaLinks,
            _externalDataURI
        );
        
        emit MetadataUpdated(
            metadata.title,
            metadata.description,
            metadata.ENS_name,
            metadata.verification,
            metadata.socialMediaLinks,
            metadata.externalDataURI,
            metadata.lastUpdated
        );
    }

    /// @notice Updates only the social media links.
    /// @dev Does not affect other metadata fields except lastUpdated.
    function setSocialMediaLinks(string[] memory _socialMediaLinks) public {
        metadata.setSocialMediaLinks(_socialMediaLinks);
        emit SocialMediaLinksUpdated(_socialMediaLinks);
    }

    /// @notice Updates only the external data URI.
    /// @dev Does not affect other metadata fields except lastUpdated.
    function setExternalDataURI(string memory _externalDataURI) public {
        metadata.setExternalDataURI(_externalDataURI);
        emit ExternalDataURIUpdated(_externalDataURI);
    }

    /// @notice Retrieves the current metadata.
    function getMetadata()
        public
        view
        returns (
            string memory title,
            string memory description,
            string memory ENS_name,
            bool verification,
            string[] memory socialMediaLinks,
            string memory externalDataURI,
            uint256 lastUpdated
        )
    {
        return metadata.getMetadata();
    }

    /// @notice Retrieves only the social media links.
    function getSocialMediaLinks() public view returns (string[] memory) {
        return metadata.getSocialMediaLinks();
    }

    /// @notice Retrieves only the external data URI.
    function getExternalDataURI() public view returns (string memory) {
        return metadata.getExternalDataURI();
    }

    /// @notice Retrieves the last update timestamp.
    function getLastUpdated() public view returns (uint256) {
        return metadata.getLastUpdated();
    }
}
