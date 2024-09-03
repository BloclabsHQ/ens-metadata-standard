// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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
    /// @dev Contains fields for title, description, ENS name, and verification status.
    struct Metadata {
        string title;
        string description;
        string ENS_name;
        bool verification;
    }

    /// @notice Sets the metadata for a contract.
    /// @dev Updates the Metadata struct with a new title, description, and ENS name. The verification status is not modified by this function.
    /// @param metadata The storage pointer to the Metadata struct to be updated.
    /// @param _title The new title to set in the metadata.
    /// @param _description The new description to set in the metadata.
    /// @param _ENS_name The new ENS name to associate with the contract.
    function setMetadata(
        Metadata storage metadata,
        string memory _title,
        string memory _description,
        string memory _ENS_name
    ) internal {
        metadata.title = _title;
        metadata.description = _description;
        metadata.ENS_name = _ENS_name;
    }

    function getMetadata(
        Metadata storage metadata
    )
        internal
        view
        returns (string memory, string memory, string memory, bool)
    {
        return (
            metadata.title,
            metadata.description,
            metadata.ENS_name,
            metadata.verification
        );
    }
}
