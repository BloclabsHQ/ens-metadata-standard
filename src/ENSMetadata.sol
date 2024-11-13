// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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

    event MetadataUpdated(string title, string description, string ENS_name, bool verification);

    constructor(string memory _title, string memory _description, string memory _ENS_name, address _ensRegistry) {
        // Update the metadata with the new values
        metadata.setMetadata(_title, _description, _ENS_name);
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
    function setMetadata(string memory _title, string memory _description, string memory _ENS_name) public {
        metadata.setMetadata(_title, _description, _ENS_name);
    }

    /// @notice Retrieves the current metadata.
    function getMetadata()
        public
        view
        returns (string memory title, string memory description, string memory ENS_name, bool verification)
    {
        return metadata.getMetadata();
    }
}
