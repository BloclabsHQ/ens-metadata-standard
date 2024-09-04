// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MetadataLib} from "./MetadataLib.sol";
import {ENSVerificationLib} from "./ENSVerificationLib.sol";

/*
Purpose: This is the main contract that manages the ENS metadata for smart contracts.
It uses the MetadataLib and ENSVerificationLib to handle the logic for managing ENS metadata.
*/

// TODO: replace string with bytes32?

/// @title ENS Metadata Contract
/// @notice Manages metadata for a contract and verifies its associated ENS name.
/// @dev Uses the ENSVerificationLib library to verify the ENS name.
contract ENSMetadata {
    using MetadataLib for MetadataLib.Metadata;
    using ENSVerificationLib for address;

    MetadataLib.Metadata public metadata;
    address public owner;
    address public ensRegistry; // Declare ensRegistry as a state variable

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
        metadata.setMetadata(_title, _description, _ENS_name);
        owner = msg.sender; // Set the contract deployer as the owner
        ensRegistry = _ensRegistry; // Set the ENS registry address
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can modify the metadata");
        _;
    }

    function setMetadata(
        string memory _title,
        string memory _description,
        string memory _ENS_name
    ) public onlyOwner {
        metadata.setMetadata(_title, _description, _ENS_name);

        emit MetadataUpdated(
            _title,
            _description,
            _ENS_name,
            metadata.verification // Emit the event with the current verification status
        );
    }

    function verifyENS() public onlyOwner {
        bytes32 node = ENSVerificationLib.getENSNode(metadata.ENS_name);
        bool isVerified = ensRegistry.verifyENS(node, address(this)); // Reusing verifyENS from ENSVerificationLib

        metadata.verification = isVerified;

        emit MetadataUpdated(
            metadata.title,
            metadata.description,
            metadata.ENS_name,
            metadata.verification // Emit the event with the new verification status
        );
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
        return metadata.getMetadata();
    }
}
