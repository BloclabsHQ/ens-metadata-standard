---
title: Metadata and ENS Verification for Searchable Contracts
description: A standard for adding verifiable metadata to smart contracts, enabling enhanced searchability and trust through ENS-based verification.
author: Cristian Romero <cristian@madgeniusblink.com>, Md Moksedul Hoque (@uzzolsse) <uzzol.sse@gmail.com>,
discussions-to: 
status: Draft
type: Standards Track
category: Interface
created: 2024-09-01
requires: 
---


## Abstract

This EIP proposes a standard for associating ENS names with smart contracts through a metadata management contract. The **ENSMetadata** contract allows contract owners to set metadata (title, description, ENS name) and verify the ENS name's ownership and resolution to the contract's address. This standard aims to enhance discoverability and trust in smart contracts by leveraging ENS as a decentralized naming system.

## Specification

The **ENSMetadata** contract MUST implement the following functions and events:

### Functions

- `function setMetadata(string memory _title, string memory _description, string memory _ENS_name) public;`
  - **Access Control**: Only callable by the contract owner.
  - **Description**: Updates the contract's metadata and resets the verification status.

- `function verifyENS() public returns (bool);`
  - **Description**: Verifies that the caller owns the ENS name and that it resolves to the contract's address. Updates the verification status upon success.

- `function getMetadata() public view returns (string memory title, string memory description, string memory ENS_name, bool verification);`
  - **Description**: Retrieves the current metadata.

### Events

- `event MetadataUpdated(string title, string description, string ENS_name, bool verification);`
  - **Emitted**: When metadata is updated or verified.

### Data Structures

- **Metadata Struct**:
  - `string title;`
  - `string description;`
  - `string ENS_name;`
  - `bool verification;`

**Dependencies**:

- The contract uses two libraries:
  - `MetadataLib`: For managing metadata.
  - `ENSVerificationLib`: For ENS name ownership and resolution verification.


## Rationale

The **ENSMetadata** contract separates metadata management and ENS verification into libraries to promote modularity and reusability. Using `MetadataLib` allows for consistent handling of metadata fields, and `ENSVerificationLib` encapsulates the logic for ENS interactions, which can be complex due to namehash computations and ENS contract interfaces.

By requiring the ENS name to resolve to the contract's address and the caller to be the owner of the ENS name, we ensure a strong association between the ENS name and the contract. This prevents unauthorized entities from falsely associating an ENS name with a contract they do not own.

The use of events like `MetadataUpdated` facilitates off-chain indexing and monitoring, which is essential for decentralized applications that rely on real-time data.

## Backwards Compatibility

This proposal introduces a new standard and does not affect existing contracts or standards. Contracts that do not implement the **ENSMetadata** interface will continue to function as before. Adoption of this standard is voluntary, and existing contracts can integrate it through upgrades or by deploying new contracts that implement the interface.

## Test Cases

- **Test Case 1: Successful ENS Verification**
  - **Setup**: ENS name is owned by the caller and resolves to the contract's address.
  - **Action**: Caller invokes `verifyENS()`.
  - **Expected Result**: Verification succeeds, `isVerified` is set to `true`, and `MetadataUpdated` event is emitted.

- **Test Case 2: Caller Not ENS Owner**
  - **Setup**: ENS name is not owned by the caller.
  - **Action**: Caller invokes `verifyENS()`.
  - **Expected Result**: Verification fails, and the transaction reverts with "Caller is not the owner of the ENS name".

- **Test Case 3: ENS Name Does Not Resolve to Contract Address**
  - **Setup**: ENS name is owned by the caller but does not resolve to the contract's address.
  - **Action**: Caller invokes `verifyENS()`.
  - **Expected Result**: Verification fails, and the transaction reverts with "ENS name does not resolve to the contract address".

## Security Considerations

- **Ownership Verification**: The contract relies on the ENS registry to verify ownership of an ENS name. If the ENS registry is compromised or behaves maliciously, this could affect the verification process.

- **Resolver Trust**: The ENS resolver's correctness is assumed. A malicious resolver could return incorrect addresses, leading to false verification.

- **Reentrancy**: While the contract does not perform external calls that modify state after changing its own state, implementers should remain cautious of potential reentrancy issues, especially if extending the contract.

- **Denial of Service**: There is a minimal risk of denial of service attacks as functions use proper `require` statements to revert on invalid conditions.

## Implementation

A reference implementation is available in the [GitHub repository](https://github.com/your-repo/ensmetadata). The repository includes:

- **Contracts**: Source code for `ENSMetadata`, `MetadataLib`, and `ENSVerificationLib`.
- **Test Suite**: Comprehensive tests using Foundry.
- **Mocks**: Mock contracts for `ENSRegistry` and `ENSResolver` to simulate ENS interactions during testing.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/BloclabsHQ/ens-metadata-standard/blob/main/LICENSE) file for details.
