#!/bin/bash
set -e

export $(grep -v '^#' .env | xargs)

echo "🚀 TokenTransfer Mock Tokens..."
forge script script/TokenTransferScript.s.sol:TokenTransferScript \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY_DEPLOYER" \
  --broadcast

