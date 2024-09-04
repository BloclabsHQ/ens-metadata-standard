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

interface IENSResolver {
    function addr(bytes32 node) external view returns (address);
}

/// @title ENS Verification Library
/// @notice Provides functions to verify ENS names and their associated addresses.
/// @dev This library relies on the ENS registry to fetch the resolver and verify addresses.
library ENSVerificationLib {
    /// @notice Verifies that the ENS name resolves to the expected contract address.
    /// @param ensRegistry The address of the ENS registry contract.
    /// @param node The ENS node (namehash) associated with the ENS name.
    /// @param contractAddress The address that is expected to be associated with the ENS name.
    /// @return isValid A boolean indicating whether the ENS name resolves to the expected address.
    function verifyENS(
        address ensRegistry,
        bytes32 node,
        address contractAddress
    ) internal view returns (bool) {
        // Get the ENS contract instance
        ENS ens = ENS(ensRegistry);

        // Get the resolver address for the given node (ENS name)
        address resolverAddress = ens.resolver(node);
        // console.log("Resolver Address:", resolverAddress);

        // Cast the resolver address to the IENSResolver interface
        IENSResolver resolver = IENSResolver(resolverAddress);

        // Get the address associated with the ENS name from the resolver
        address resolvedAddress = resolver.addr(node);
        // console.log("Resolved Address:", resolvedAddress);
        // console.log("Expected Contract Address:", contractAddress);
        // Verify that the resolved address matches the expected contract address
        return resolvedAddress == contractAddress;
    }

    /// @notice Converts an ENS name to its corresponding ENS node (namehash).
    /// @param ensName The ENS name as a string (e.g., "example.eth").
    /// @return node The ENS node (namehash) derived from the ENS name.
    function getENSNode(string memory ensName) internal pure returns (bytes32) {
        // Convert the ENS name to a bytes32 hash
        return keccak256(abi.encodePacked(ensName));
    }
}
