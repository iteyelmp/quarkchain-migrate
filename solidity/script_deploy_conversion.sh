#!/bin/bash
set -e

export $(grep -v '^#' .env | xargs)

if [[ -z "$NEW_QKC_ADDRESS" || -z "$OLD_QKC_ADDRESS" ]]; then
  echo "❌ Missing token addresses in .env"
  exit 1
fi

echo "🚀 Deploying TokenConversion..."
forge script script/DeployTokenConversion.s.sol \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY_DEPLOYER" \
  --broadcast \
  --verify
