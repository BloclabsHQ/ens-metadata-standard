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
// TODO: replace string with bytes32?

/// @title ENS Metadata Contract
/// @notice Manages metadata for a contract and verifies its associated ENS name.
/// @dev Uses the ENSVerificationLib library to verify the ENS name.
contract ENSMetadata {
    using MetadataLib for MetadataLib.Metadata;

    MetadataLib.Metadata public metadata;
    address public owner;
    address public ensRegistry;
    bool public isVerified = false;

    event MetadataUpdated(
        string title,
        string description,
        string ENS_name,
        bool verification
    );

    constructor(
        string memory _title,
        string memory _description,
        string memory _ENS_name,
        address _ensRegistry
    ) {
        // Update the metadata with the new values
        metadata.setMetadata(_title, _description, _ENS_name);
        owner = msg.sender; // Set the contract deployer as the owner
        ensRegistry = _ensRegistry; // Set the ENS registry address based on the blockchain and environment
    }

    modifier onlyOwner() {
        // Ensure that the caller is the owner
        require(msg.sender == owner, "Only the owner can modify the metadata");
        _;
    }

    function setMetadata(
        string memory _title,
        string memory _description,
        string memory _ENS_name
    ) public onlyOwner {
        // Update the metadata with the new values
        metadata.setMetadata(_title, _description, _ENS_name);

        // Reset verification status, requires re-verification
        isVerified = false;
        metadata.verification = false;

        // Emit the event with the new metadata
        emit MetadataUpdated(
            _title,
            _description,
            _ENS_name,
            metadata.verification // Emit the event with the current verification status
        );
    }

    function verifyENS() public returns (bool) {
        require(
            bytes(metadata.ENS_name).length > 0,
            "ENS name cannot be empty"
        );

        // Call the verification function in the library
        ENSVerificationLib.verifyENS(
            ensRegistry,
            metadata.ENS_name,
            address(this),
            msg.sender
        );

        // If verification passes, set verification status to true
        isVerified = true;
        metadata.verification = true;

        // Emit the event with the updated metadata
        emit MetadataUpdated(
            metadata.title,
            metadata.description,
            metadata.ENS_name,
            metadata.verification
        );

        return true;
    }

    function getMetadata()
        public
        view
        returns (
            string memory title,
            string memory description,
            string memory ENS_name,
            bool verification
        )
    {
        // Return the metadata
        return metadata.getMetadata();
    }
}
