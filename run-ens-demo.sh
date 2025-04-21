#!/bin/bash

# Set a default private key for demo purposes
# WARNING: This is just for demonstration, in production, use a real private key set via environment variable
if [ -z "$PRIVATE_KEY" ]; then
  export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" # Default Anvil private key
fi

# Check if Anvil is running
if ! nc -z localhost 8545 &>/dev/null; then
  echo "Anvil needs to be running. Start it with:"
  echo "anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY --fork-block-number 18741020"
  exit 1
fi

# Run the script in fork mode
echo "Running ENS Metadata Demo..."
forge script script/ENSMetadataDemo.s.sol --rpc-url http://localhost:8545 -vvv 