#!/bin/bash
set -e

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "❌ .env file not found!"
  exit 1
fi

if [[ -z "$RPC_URL" || -z "$PRIVATE_KEY_DEPLOYER" ]]; then
  echo "❌ Missing required environment variables: RPC_URL or PRIVATE_KEY_DEPLOYER"
  exit 1
fi

forge script script/DeployTokenConversion.s.sol \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY_DEPLOYER" \
  --broadcast
