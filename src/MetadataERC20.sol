// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {ENSMetadata} from "./ENSMetadata.sol";

/**
 * @title MetadataERC20
 * @notice An ERC-20 token that integrates with ENSMetadata
 */
contract MetadataERC20 is ERC20, Ownable {
    // ENSMetadata integration
    ENSMetadata public ensMetadata;
    
    // Event for tracking metadata changes
    event MetadataLinked(address ensMetadataAddress);

    /**
     * @notice Constructor
     * @param name_ Token name
     * @param symbol_ Token symbol
     * @param initialSupply Initial token supply
     * @param _ensMetadata Address of the ENSMetadata contract
     * @param initialOwner Address of the token owner
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        address _ensMetadata,
        address initialOwner
    ) ERC20(name_, symbol_) Ownable(initialOwner) {
        // Mint initial supply to the token owner
        _mint(initialOwner, initialSupply * 10**decimals());
        
        // Link to ENSMetadata
        ensMetadata = ENSMetadata(_ensMetadata);
        emit MetadataLinked(address(ensMetadata));
    }
    
    /**
     * @notice Retrieve metadata from the linked ENSMetadata contract
     * @return title The title metadata
     * @return description The description metadata
     * @return ENS_name The ENS name
     * @return verification Whether the ENS name is verified
     */
    function getTokenMetadata() public view returns (
        string memory title, 
        string memory description, 
        string memory ENS_name, 
        bool verification
    ) {
        return ensMetadata.getMetadata();
    }
    
    /**
     * @notice Update the linked ENSMetadata contract address (owner only)
     * @param _newEnsMetadata The new ENSMetadata contract address
     */
    function updateEnsMetadata(address _newEnsMetadata) public onlyOwner {
        ensMetadata = ENSMetadata(_newEnsMetadata);
        emit MetadataLinked(address(ensMetadata));
    }
} 