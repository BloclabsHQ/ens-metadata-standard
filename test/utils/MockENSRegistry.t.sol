// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MockENSRegistry {
    mapping(bytes32 => address) public resolvers;

    function setResolver(bytes32 node, address resolverAddress) public {
        resolvers[node] = resolverAddress;
    }

    function resolver(bytes32 node) external view returns (address) {
        return resolvers[node];
    }
}
