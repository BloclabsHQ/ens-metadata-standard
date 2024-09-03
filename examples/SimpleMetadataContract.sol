// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ENSMetadata} from "../src/ENSMetadata.sol";

contract SimpleMetadataContract is ENSMetadata {
    constructor() ENSMetadata() {}
}
