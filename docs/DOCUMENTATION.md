## Contract Architecture

### ENSMetadata Contract

The ENSMetadata contract is the core component responsible for managing metadata and verifying ENS associations. It uses two libraries:

- MetadataLib: Handles the storage and retrieval of metadata.
- ENSVerificationLib: Performs ENS ownership and resolution verification.

#### Key Functions

- setMetadata(string _title, string _description, string _ENS_name): Updates the contract's metadata. Only callable by the contract owner.
- verifyENS(): Verifies that the caller owns the ENS name and that it resolves to the contract's address.
- getMetadata(): Retrieves the current metadata.

#### Events

- MetadataUpdated(string title, string description, string ENS_name, bool verification): Emitted when metadata is updated or verified.

## MetadataLib Library

The MetadataLib library provides a structured way to handle metadata within the ENSMetadata contract. It defines a Metadata struct and includes functions for setting and getting metadata values.

### Metadata Struct

```solidity
struct Metadata {
    string title;
    string description;
    string ENS_name;
    bool verification;
}
```

### Functions

- setMetadata(Metadata storage metadata, string memory _title, string memory _description, string memory _ENS_name): Updates the metadata fields. The verification status is reset to false whenever metadata is updated.
- getMetadata(Metadata storage metadata): Returns the metadata fields.

### Purpose

- Separation of Concerns: Abstracts metadata management from the main contract logic, promoting cleaner and more maintainable code.
- Reusability: Allows for the metadata management functionality to be reused in other contracts if needed.
- Encapsulation: Encapsulates metadata operations, ensuring consistent handling of metadata across the contract.

### Usage in ENSMetadata Contract

The ENSMetadata contract uses MetadataLib to manage its metadata:

```solidity
    using MetadataLib for MetadataLib.Metadata;

    MetadataLib.Metadata public metadata;

    function setMetadata(
        string memory _title,
        string memory _description,
        string memory _ENS_name
    ) public onlyOwner {
        metadata.setMetadata(_title, _description, _ENS_name);

        // Reset verification status, requires re-verification
        isVerified = false;
        metadata.verification = false;

        emit MetadataUpdated(
            _title,
            _description,
            _ENS_name,
            metadata.verification
        );
    }

    function getMetadata()
        public
        view
        returns (
            string memory title,
            string memory description,
            string memory ENS_name,
            bool verification
        )
    {
        return metadata.getMetadata();
    }
```

## ENSVerificationLib Library

The ENSVerificationLib library provides functions to verify ENS ownership and resolution.

#### Functions

- verifyENS(address ensRegistry, string memory ensName, address contractAddress, address caller): Verifies that the caller owns the ENS name and that it resolves to the contract's address. It reverts with specific error messages if verification fails.
- namehash(string memory name): Computes the ENS namehash for a given ENS name.

#### Purpose

- ENS Ownership Verification: Checks if the caller is the owner of the specified ENS name.
- ENS Resolution Verification: Ensures the ENS name resolves to the contract's address.
- Error Handling: Provides detailed revert messages to aid in debugging and user feedback.

#### Usage in ENSMetadata Contract

The ENSMetadata contract calls the verifyENS function from ENSVerificationLib:

```solidity
    function verifyENS() public returns (bool) {
        require(
            bytes(metadata.ENS_name).length > 0,
            "ENS name cannot be empty"
        );

        ENSVerificationLib.verifyENS(
            ensRegistry,
            metadata.ENS_name,
            address(this),
            msg.sender
        );

        isVerified = true;
        metadata.verification = true;

        emit MetadataUpdated(
            metadata.title,
            metadata.description,
            metadata.ENS_name,
            metadata.verification
        );

        return true;
    }
```
