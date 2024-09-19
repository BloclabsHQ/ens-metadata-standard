# ENSMetadata Contract

## Overview

The ENSMetadata contract is designed to manage metadata for smart contracts, specifically focusing on integration with the Ethereum Name Service (ENS). It provides functionality to set and verify metadata, ensuring that the contract's address is correctly associated with an ENS name owned by the caller.

This contract is intended as a standard for associating ENS names with smart contracts, facilitating discoverability, and enhancing trust in decentralized applications. By submitting this as an Ethereum Improvement Proposal (EIP), we aim to establish a consistent approach for ENS metadata management across the Ethereum ecosystem.

## Motivation

As the Ethereum ecosystem grows, the need for standardized methods to associate human-readable names with smart contracts becomes increasingly important. ENS provides a decentralized naming system, but there's no standard way to link ENS names with contract metadata in a verifiable manner.

The ENSMetadata contract addresses this gap by providing a standard interface and implementation for:

- Managing contract metadata (title, description, ENS name).
- Verifying ownership of an ENS name.
- Ensuring the ENS name resolves to the contract's address.
- Emitting events for off-chain indexing and discovery.

By adopting this standard, developers can enhance the usability and trustworthiness of their smart contracts, making them more accessible to users and tools that rely on ENS.

### Features

- Metadata Management: Set and update the contract's title, description, and associated ENS name.
- ENS Verification: Verify that the ENS name is owned by the caller and resolves to the contract's address.
- Event Emission: Emit events when metadata is updated or verified, enabling off-chain indexing.
- Modular Design: Utilize libraries for metadata handling and ENS verification to promote code reuse and maintainability.

## Documentation

- [Detailed Documentation](docs/DOCUMENTATION.md): In-depth information about the contract's architecture and libraries.
- [EIP Proposal (Draft)](./EIP-xxxx.md): The Ethereum Improvement Proposal for standardizing ENS metadata management.

## Installation

Instructions on how to install the contract.

```bash
forge install BloclabsHQ/ens-metadata-standard  
```

## Usage

```solidity
// Deploying the contract
ENSMetadata ensMetadata = new ENSMetadata(
    "My Contract",
    "An example contract with ENS integration",
    "mycontract.eth",
    ensRegistryAddress
);

// Setting metadata (only owner can do this)
ensMetadata.setMetadata(
    "Updated Title",
    "Updated Description",
    "updatedname.eth"
);

// Verifying ENS association (ENS name owner should call this)
ensMetadata.verifyENS();
```

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
