// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MockENSResolver {
    mapping(bytes32 => address) public addresses;

    function setAddr(bytes32 node, address addrValue) public {
        addresses[node] = addrValue;
    }

    function addr(bytes32 node) external view returns (address) {
        return addresses[node];
    }
}
