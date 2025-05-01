// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/*
 This is a Solidity library that handles operations related to metadata management.
 Libraries in Solidity are similar to utility classes in other programming languages—they
 provide reusable functions that can be called by contracts.
    
Key Features:
- Functions to create, update, and retrieve metadata for smart contracts.
- Utilities for handling common tasks related to metadata, such as formatting or validation.
- Helps to keep the ENSMetadata.sol contract clean by abstracting metadata logic into a separate module.
*/
// TODO: replace string with bytes32?

/// @title Metadata Library
/// @notice Provides a structure and functions for managing metadata within a smart contract.
/// @dev This library defines a Metadata struct and includes a function for setting metadata values.
library MetadataLib {
    /// @notice A struct to store metadata associated with a contract.
    /// @dev Contains fields for title, description, ENS name, verification status, social media links, external data URI, and last update timestamp.
    struct Metadata {
        string title;
        string description;
        string ENS_name;
        bool verification;
        string[] socialMediaLinks;
        string externalDataURI;
        uint256 lastUpdated;
    }

    event MetadataUpdated(
        string title,
        string description,
        string ENS_name,
        bool verification,
        string[] socialMediaLinks,
        string externalDataURI,
        uint256 lastUpdated
    );
    event ContextProvided(string context);
    event SocialMediaLinksUpdated(string[] socialMediaLinks);
    event ExternalDataURIUpdated(string externalDataURI);

    /// @notice Modifier to provide context to function calls.
    /// @param context The context string to be emitted.
    modifier withContext(string memory context) {
        emit ContextProvided(context);
        _;
    }

    /// @notice Sets the metadata for a contract including all fields.
    /// @dev Updates all fields in the Metadata struct except verification status which is reset to false.
    /// @param metadata The storage pointer to the Metadata struct to be updated.
    /// @param _title The new title to set in the metadata.
    /// @param _description The new description to set in the metadata.
    /// @param _ENS_name The new ENS name to associate with the contract.
    /// @param _socialMediaLinks Array of social media links.
    /// @param _externalDataURI URI pointing to additional external metadata.
    function setMetadata(
        Metadata storage metadata,
        string memory _title,
        string memory _description,
        string memory _ENS_name,
        string[] memory _socialMediaLinks,
        string memory _externalDataURI
    ) internal {
        metadata.title = _title;
        metadata.description = _description;
        metadata.ENS_name = _ENS_name;
        metadata.verification = false; // Automatically reset verification
        metadata.socialMediaLinks = _socialMediaLinks;
        metadata.externalDataURI = _externalDataURI;
        metadata.lastUpdated = block.timestamp; // Update the timestamp

        // Emit the event with the updated metadata
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

    /// @notice Updates the social media links.
    /// @dev Updates only the social media links array and the last updated timestamp.
    /// @param metadata The storage pointer to the Metadata struct to be updated.
    /// @param _socialMediaLinks The new array of social media links.
    function setSocialMediaLinks(
        Metadata storage metadata,
        string[] memory _socialMediaLinks
    ) internal {
        metadata.socialMediaLinks = _socialMediaLinks;
        metadata.lastUpdated = block.timestamp;
        
        emit SocialMediaLinksUpdated(_socialMediaLinks);
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

    /// @notice Updates the external data URI.
    /// @dev Updates only the external data URI and the last updated timestamp.
    /// @param metadata The storage pointer to the Metadata struct to be updated.
    /// @param _externalDataURI The new external data URI.
    function setExternalDataURI(
        Metadata storage metadata,
        string memory _externalDataURI
    ) internal {
        metadata.externalDataURI = _externalDataURI;
        metadata.lastUpdated = block.timestamp;
        
        emit ExternalDataURIUpdated(_externalDataURI);
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

    /// @notice Retrieves the current metadata.
    /// @dev Returns all metadata fields.
    /// @param metadata The storage pointer to the Metadata struct.
    /// @return All metadata fields.
    function getMetadata(
        Metadata storage metadata
    )
        internal
        view
        returns (
            string memory, 
            string memory, 
            string memory, 
            bool, 
            string[] memory, 
            string memory, 
            uint256
        )
    {
        return (
            metadata.title,
            metadata.description,
            metadata.ENS_name,
            metadata.verification,
            metadata.socialMediaLinks,
            metadata.externalDataURI,
            metadata.lastUpdated
        );
    }

    /// @notice Retrieves only the social media links.
    /// @param metadata The storage pointer to the Metadata struct.
    /// @return The array of social media links.
    function getSocialMediaLinks(
        Metadata storage metadata
    ) internal view returns (string[] memory) {
        return metadata.socialMediaLinks;
    }

    /// @notice Retrieves only the external data URI.
    /// @param metadata The storage pointer to the Metadata struct.
    /// @return The external data URI.
    function getExternalDataURI(
        Metadata storage metadata
    ) internal view returns (string memory) {
        return metadata.externalDataURI;
    }

    /// @notice Retrieves the last update timestamp.
    /// @param metadata The storage pointer to the Metadata struct.
    /// @return The timestamp of the last update.
    function getLastUpdated(
        Metadata storage metadata
    ) internal view returns (uint256) {
        return metadata.lastUpdated;
    }
}
