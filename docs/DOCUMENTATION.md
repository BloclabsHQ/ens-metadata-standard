## Contract Architecture

### ENSMetadata Contract

The ENSMetadata contract is the core component responsible for managing metadata and verifying ENS associations. It uses two libraries:

- MetadataLib: Handles the storage and retrieval of metadata.
- ENSVerificationLib: Performs ENS ownership and resolution verification.

#### Key Functions

- constructor(string _title, string _description, string _ENS_name, address _ensRegistry, string[] _socialMediaLinks, string _externalDataURI): Initializes the contract with metadata and ENS registry address.
- setMetadata(string _title, string _description, string _ENS_name, string[] _socialMediaLinks, string _externalDataURI): Updates the contract's metadata.
- setSocialMediaLinks(string[] _socialMediaLinks): Updates only the social media links.
- setExternalDataURI(string _externalDataURI): Updates only the external data URI.
- verifyENS(): Verifies that the caller owns the ENS name and that it resolves to the contract's address.
- getMetadata(): Retrieves the current metadata.
- getSocialMediaLinks(): Retrieves only the social media links.
- getExternalDataURI(): Retrieves only the external data URI.
- getLastUpdated(): Retrieves the last update timestamp.

#### Events

- MetadataUpdated(string title, string description, string ENS_name, bool verification, string[] socialMediaLinks, string externalDataURI, uint256 lastUpdated): Emitted when metadata is updated or verified.
- SocialMediaLinksUpdated(string[] socialMediaLinks): Emitted when social media links are updated.
- ExternalDataURIUpdated(string externalDataURI): Emitted when the external data URI is updated.

## MetadataLib Library

The MetadataLib library provides a structured way to handle metadata within the ENSMetadata contract. It defines a Metadata struct and includes functions for setting and getting metadata values.

### Metadata Struct

```solidity
struct Metadata {
    string title;
    string description;
    string ENS_name;
    bool verification;
    string[] socialMediaLinks;
    string externalDataURI;
    uint256 lastUpdated;
}
```

### Functions

- setMetadata(Metadata storage metadata, string memory _title, string memory _description, string memory _ENS_name, string[] memory _socialMediaLinks, string memory _externalDataURI): Updates all metadata fields. The verification status is reset to false whenever metadata is updated.
- setSocialMediaLinks(Metadata storage metadata, string[] memory _socialMediaLinks): Updates only the social media links.
- setExternalDataURI(Metadata storage metadata, string memory _externalDataURI): Updates only the external data URI.
- getMetadata(Metadata storage metadata): Returns all metadata fields.
- getSocialMediaLinks(Metadata storage metadata): Returns the social media links.
- getExternalDataURI(Metadata storage metadata): Returns the external data URI.
- getLastUpdated(Metadata storage metadata): Returns the last update timestamp.

### Purpose

- Separation of Concerns: Abstracts metadata management from the main contract logic, promoting cleaner and more maintainable code.
- Reusability: Allows for the metadata management functionality to be reused in other contracts if needed.
- Encapsulation: Encapsulates metadata operations, ensuring consistent handling of metadata across the contract.

## ENSVerificationLib Library

The ENSVerificationLib library provides functions to verify ENS ownership and resolution.

### Functions

- verifyENS(address ensRegistry, string memory ensName, address contractAddress, address caller): Verifies that the caller owns the ENS name and that it resolves to the contract's address. It reverts with specific error messages if verification fails.
- namehash(string memory name): Computes the ENS namehash for a given ENS name.
- slice(bytes memory data, uint256 start, uint256 length): Helper function to slice byte arrays.

### Events

- ENSVerified(string ensName, address contractAddress, address caller): Emitted when ENS verification succeeds.
- ContextProvided(string context): Emitted to provide context.

### Purpose

- ENS Ownership Verification: Checks if the caller is the owner of the specified ENS name.
- ENS Resolution Verification: Ensures the ENS name resolves to the contract's address.
- Error Handling: Provides detailed revert messages to aid in debugging and user feedback.

### Usage in ENSMetadata Contract

The ENSMetadata contract calls the verifyENS function from ENSVerificationLib:

```solidity
function verifyENS() external returns (bool) {
    // Call the verification function in the library
    bool verification = ENSVerificationLib.verifyENS(ensRegistry, metadata.ENS_name, address(this), msg.sender);

    // If verification passes, set verification status to true
    metadata.verification = verification;

    return verification;
}
```
