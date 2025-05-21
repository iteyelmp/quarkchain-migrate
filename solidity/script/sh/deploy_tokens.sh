#!/bin/bash
set -e

export $(grep -v '^#' .env | xargs)

echo "🚀 Deploying Mock Tokens..."
output=$(forge script script/TokenDeployScript.s.sol:TokenDeployScript \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY_DEPLOYER" \
  --broadcast \
  2>&1 | tee /dev/tty)

old_token=$(echo "$output" | grep "oldQKC:" | awk '{print $2}')
new_token=$(echo "$output" | grep "newQKC:" | awk '{print $2}')

if [[ -z "$new_token" || -z "$old_token" ]]; then
  echo "❌ Failed to extract token addresses"
  exit 1
fi

echo "✅ Tokens deployed:"
echo "OLD_QKC_ADDRESS=$old_token"
echo "NEW_QKC_ADDRESS=$new_token"

# update .env
sed -i.bak '/^OLD_QKC_ADDRESS=/d' .env
sed -i.bak '/^NEW_QKC_ADDRESS=/d' .env
echo "OLD_QKC_ADDRESS=$old_token" >> .env
echo "NEW_QKC_ADDRESS=$new_token" >> .env
