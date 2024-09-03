// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ENSMetadata} from "../src/ENSMetadata.sol";

contract ENSVerifiedContract is ENSMetadata {
    constructor() ENSMetadata() {}
}
