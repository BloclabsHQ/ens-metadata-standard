# ENS Metadata Standard

## Overview

The ENS Metadata Standard is a framework for associating Ethereum Name Service (ENS) domains with smart contracts and providing rich metadata about those contracts. This standard enables decentralized applications (dApps) and interfaces to retrieve human-readable information about contracts, verify their association with an ENS name, and access additional resources.

## Purpose

- **Human-Readable Contract Information**: Make smart contracts more accessible by associating human-readable ENS names and descriptive metadata.
- **Standardized Metadata Format**: Provide a consistent way to store and retrieve contract metadata.
- **Verification Mechanism**: Enable verification that an ENS name correctly resolves to a contract's address and is owned by the appropriate entity.
- **Extensibility**: Allow for additional metadata to be linked via social media links and external data URIs.

## Contract Architecture

### ENSMetadata Contract

The main contract that implements the ENS Metadata Standard. It allows contract owners to associate their contract with an ENS name and provide descriptive metadata.

#### Features

- Store and retrieve contract metadata (title, description, ENS name, etc.)
- Verify ENS name ownership and resolution
- Update social media links and external data URIs independently
- Track when metadata was last updated

#### Installation

To implement the ENS Metadata Standard in your project:

1. Import the ENSMetadata contract:
```solidity
import {ENSMetadata} from "ens-metadata-standard/ENSMetadata.sol";
```

2. Inherit from the ENSMetadata contract in your contract:
```solidity
contract YourContract is ENSMetadata {
    constructor(
        string memory _title,
        string memory _description,
        string memory _ENS_name,
        address _ensRegistry,
        string[] memory _socialMediaLinks,
        string memory _externalDataURI
    ) ENSMetadata(
        _title,
        _description,
        _ENS_name,
        _ensRegistry,
        _socialMediaLinks,
        _externalDataURI
    ) {
        // Your contract initialization logic
    }
}
```

## Usage Guide

### Setting Metadata

```solidity
// Initialize the contract with metadata
ENSMetadata myContract = new ENSMetadata(
    "My Contract", 
    "This is a description of my contract", 
    "mycontract.eth",
    0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e, // ENS Registry address (mainnet)
    new string[](0), // No social media links initially
    "" // No external data URI initially
);

// Update metadata later
myContract.setMetadata(
    "Updated Title",
    "Updated description",
    "updatedname.eth",
    ["https://twitter.com/mycontract", "https://github.com/myproject"],
    "ipfs://QmXyz..."
);

// Update only social media links
string[] memory newLinks = new string[](2);
newLinks[0] = "https://twitter.com/newhandle";
newLinks[1] = "https://discord.gg/newserver";
myContract.setSocialMediaLinks(newLinks);

// Update only external data URI
myContract.setExternalDataURI("ipfs://QmNew...");
```

### Verifying ENS Name

```solidity
// Verify ENS name ownership and resolution
// This must be called by the owner of the ENS name
bool verified = myContract.verifyENS();
```

### Retrieving Metadata

```solidity
// Get all metadata
(
    string memory title,
    string memory description,
    string memory ensName,
    bool verified,
    string[] memory socialMediaLinks,
    string memory externalDataURI,
    uint256 lastUpdated
) = myContract.getMetadata();

// Get only social media links
string[] memory links = myContract.getSocialMediaLinks();

// Get only external data URI
string memory uri = myContract.getExternalDataURI();

// Get last updated timestamp
uint256 timestamp = myContract.getLastUpdated();
```

## External Data URI

The `externalDataURI` field can point to additional metadata stored off-chain. This can be an IPFS hash, HTTP URL, or any other URI format. The recommended format for external data is JSON with the following schema:

```json
{
  "name": "Contract Name",
  "description": "Detailed description",
  "logo": "https://example.com/logo.png",
  "website": "https://example.com",
  "repository": "https://github.com/example/repo",
  "socials": {
    "twitter": "https://twitter.com/example",
    "discord": "https://discord.gg/example",
    "telegram": "https://t.me/example"
  },
  "documentation": "https://docs.example.com",
  "additionalFields": {
    // Any additional metadata
  }
}
```

## Best Practices

1. **Set Meaningful Metadata**: Provide clear and concise information about your contract.
2. **Update Regularly**: Keep metadata up-to-date, especially when contract functionality changes.
3. **Verify ENS Names**: Always verify ENS names after setting or updating them.
4. **Use External Data**: For extensive metadata, use the externalDataURI to point to more comprehensive information.
5. **Include Social Links**: Provide social media links for community engagement. 