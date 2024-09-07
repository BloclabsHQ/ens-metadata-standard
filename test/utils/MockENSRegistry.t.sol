// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MockENSRegistry {
    // Mapping from node to resolver addresses
    mapping(bytes32 => address) public resolvers;

    // Mapping from node to owner addresses
    mapping(bytes32 => address) public owners;

    // Set the resolver for a specific node
    function setResolver(bytes32 node, address resolverAddress) public {
        resolvers[node] = resolverAddress;
    }

    // Retrieve the resolver for a specific node
    function resolver(bytes32 node) external view returns (address) {
        return resolvers[node];
    }

    // Set the owner for a specific node
    function setOwner(bytes32 node, address newOwner) public {
        owners[node] = newOwner;
    }

    // Retrieve the owner for a specific node
    function owner(bytes32 node) external view returns (address) {
        return owners[node];
    }
}
