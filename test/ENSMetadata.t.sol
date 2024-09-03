// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ENSMetadata} from "../src/ENSMetadata.sol";
import {ENSVerificationLib} from "../src/ENSVerificationLib.sol";

contract ENSMetadataTest is Test {
    ENSMetadata ensMetadata;

    function setUp() public {
        ensMetadata = new ENSMetadata(
            "Initial Title",
            "Initial Description",
            "ensname.eth",
            address(0)
        );
    }

    function testInitialMetadata() public view {
        (
            string memory title,
            string memory description,
            string memory ENS_name,
            bool verification
        ) = ensMetadata.getMetadata();

        assertEq(title, "Initial Title");
        assertEq(description, "Initial Description");
        assertEq(ENS_name, "ensname.eth");
        assertEq(verification, false);
    }

    function testSetMetadata() public {
        ensMetadata.setMetadata("New Title", "New Description", "newname.eth");

        (
            string memory title,
            string memory description,
            string memory ENS_name,
            bool verification
        ) = ensMetadata.getMetadata();

        assertEq(title, "New Title");
        assertEq(description, "New Description");
        assertEq(ENS_name, "newname.eth");
        assertEq(verification, false);
    }

    function testNonOwnerCannotSetMetadata() public {
        vm.prank(address(0x1234)); // Simulate a different caller
        vm.expectRevert("Only the owner can modify the metadata");
        ensMetadata.setMetadata(
            "Unauthorized Title",
            "Unauthorized Description",
            "unauthorized.eth"
        );
    }
}
