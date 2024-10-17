// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ENS} from "ens-contracts/contracts/registry/ENS.sol";

/*
Purpose: This is another Solidity library, but it specifically focuses on ENS (Ethereum Name Service) verification.
It provides reusable functions that handle the process of verifying that a smart contract’s address matches a registered ENS name.

Key Features:
- Functions to verify the ENS name associated with a contract.
- Logic for checking if the ENS name is correctly linked to the contract's address.
- Abstracts the ENS verification logic from the main contract (ENSMetadata.sol), making the code more modular and easier to maintain.
*/

interface IENSRegistry {
    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);
}

interface IENSResolver {
    function addr(bytes32 node) external view returns (address);
}

/// @title ENS Verification Library
/// @notice Provides functions to verify ENS names and their associated addresses.
/// @dev This library relies on the ENS registry to fetch the resolver and verify addresses.
library ENSVerificationLib {
    event ENSVerified(string ensName, address contractAddress, address caller);

    /// @notice Verifies that the ENS name is owned by the caller and resolves to the expected contract address.
    /// @param ensRegistry The address of the ENS registry contract.
    /// @param ensName The ENS name as a string (e.g., "example.eth").
    /// @param contractAddress The address that is expected to be associated with the ENS name.
    /// @param caller The address of the caller (msg.sender).
    function verifyENS(
        address ensRegistry,
        string memory ensName,
        address contractAddress,
        address caller
    ) internal returns (bool) {
        require(bytes(ensName).length > 0, "ENS name cannot be empty");
        // Compute the node (namehash) from the ENS name
        bytes32 node = namehash(ensName);

        // Step 1: Verify that the caller is the owner of the ENS name
        address ensNameOwner = IENSRegistry(ensRegistry).owner(node);
        require(
            caller == ensNameOwner,
            "Caller is not the owner of the ENS name"
        );

        // Step 2: Verify that the ENS name resolves to the contract's address
        address resolverAddress = IENSRegistry(ensRegistry).resolver(node);
        require(resolverAddress != address(0), "Resolver not set for ENS name");

        address resolvedAddress = IENSResolver(resolverAddress).addr(node);
        require(
            resolvedAddress == contractAddress,
            "ENS name does not resolve to the contract address"
        );
        // Emit the ENSVerified event upon successful verification
        emit ENSVerified(ensName, contractAddress, caller);

        return true;
    }

    /// @notice Converts an ENS name to its corresponding ENS node (namehash).
    /// @param name The ENS name as a string (e.g., "example.eth").
    /// @return node The ENS node (namehash) derived from the ENS name.
    function namehash(string memory name) internal pure returns (bytes32) {
        bytes32 node = 0x0;
        if (bytes(name).length == 0) {
            return node;
        }
        bytes memory labels = bytes(name);
        uint256 i = labels.length;
        while (i > 0) {
            uint256 j = i;
            while (j > 0 && labels[j - 1] != ".") {
                j--;
            }
            bytes32 label = keccak256(
                abi.encodePacked(slice(labels, j, i - j))
            );
            node = keccak256(abi.encodePacked(node, label));
            if (j > 0) {
                i = j - 1;
            } else {
                break;
            }
        }
        return node;
    }

    /// @notice Slices a byte array.
    /// @param data The byte array to slice.
    /// @param start The starting index.
    /// @param length The length of the slice.
    /// @return result The sliced byte array.
    function slice(
        bytes memory data,
        uint256 start,
        uint256 length
    ) internal pure returns (bytes memory) {
        bytes memory result = new bytes(length);
        for (uint256 k = 0; k < length; k++) {
            result[k] = data[start + k];
        }
        return result;
    }
}
