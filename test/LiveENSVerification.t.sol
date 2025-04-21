// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ENSMetadata} from "../src/ENSMetadata.sol";
import {ENSVerificationLib} from "../src/ENSVerificationLib.sol";

contract LiveENSVerificationTest is Test {
    // Mainnet ENS Registry address
    address constant ENS_REGISTRY = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;
    
    // We'll use the test ENS name
    string constant TEST_ENS_NAME = "test-metadata.eth";
    
    // Test wallet with permissions
    address testWallet;
    uint256 testWalletKey;
    
    ENSMetadata ensMetadata;
    
    // Mock contracts for testing
    MockENSRegistry mockRegistry;
    MockENSResolver mockResolver;

    function setUp() public {
        // Create test wallet with some ETH
        (testWallet, testWalletKey) = makeAddrAndKey("TestWallet");
        vm.deal(testWallet, 10 ether);
        
        // Deploy mock ENS infrastructure
        mockRegistry = new MockENSRegistry();
        mockResolver = new MockENSResolver();
        
        // Set up test ENS name
        bytes32 node = ENSVerificationLib.namehash(TEST_ENS_NAME);
        
        // Deploy ENSMetadata with our mock registry
        vm.startPrank(testWallet);
        ensMetadata = new ENSMetadata(
            "Test ENS Metadata",
            "A test for ENS metadata verification",
            TEST_ENS_NAME,
            address(mockRegistry)
        );
        vm.stopPrank();
        
        // Set up the ENS name to be owned by our test wallet and point to our contract
        mockRegistry.setOwner(node, testWallet);
        mockRegistry.setResolver(node, address(mockResolver));
        mockResolver.setAddr(node, address(ensMetadata));
        
        console.log("Test setup completed");
        console.log("ENSMetadata deployed at:", address(ensMetadata));
        console.log("Test wallet:", testWallet);
        console.log("ENS Node:", uint256(node));
    }

    function testGetMetadata() public {
        // Get current metadata
        (string memory title, string memory description, string memory ensName, bool verification) = 
            ensMetadata.getMetadata();
            
        console.log("Initial metadata:");
        console.log("Title:", title);
        console.log("Description:", description);
        console.log("ENS Name:", ensName);
        console.log("Verification:", verification);
        
        // Initially verification should be false
        assertEq(verification, false);
    }
    
    function testSuccessfulVerification() public {
        // Get the initial verification status
        (, , , bool initialVerification) = ensMetadata.getMetadata();
        assertEq(initialVerification, false, "Initial verification should be false");
        
        // Call verifyENS as the test wallet (which owns the ENS name)
        vm.prank(testWallet);
        bool verificationResult = ensMetadata.verifyENS();
        
        // The verification should succeed
        assertTrue(verificationResult, "ENS verification should succeed");
        
        // Check that the metadata was updated with the verification status
        (, , , bool updatedVerification) = ensMetadata.getMetadata();
        assertTrue(updatedVerification, "Verification status should be updated to true");
    }
    
    function test_RevertWhen_NonOwnerCallsVerify() public {
        address nonOwner = makeAddr("NonOwner");
        
        // Try to verify as non-owner, should fail
        vm.expectRevert("Caller is not the owner of the ENS name");
        vm.prank(nonOwner);
        ensMetadata.verifyENS();
    }
}

// Mock contracts for testing
contract MockENSRegistry {
    mapping(bytes32 => address) public owners;
    mapping(bytes32 => address) public resolvers;
    
    function setOwner(bytes32 node, address owner_) public {
        owners[node] = owner_;
    }
    
    function setResolver(bytes32 node, address resolver_) public {
        resolvers[node] = resolver_;
    }
    
    function owner(bytes32 node) public view returns (address) {
        return owners[node];
    }
    
    function resolver(bytes32 node) public view returns (address) {
        return resolvers[node];
    }
}

contract MockENSResolver {
    mapping(bytes32 => address) public addresses;
    
    function setAddr(bytes32 node, address addr_) public {
        addresses[node] = addr_;
    }
    
    function addr(bytes32 node) public view returns (address) {
        return addresses[node];
    }
} 