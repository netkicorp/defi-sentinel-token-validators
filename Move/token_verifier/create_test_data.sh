#!/bin/bash

# Generate a random seed using openssl
SEED=$(openssl rand -hex 32)

# Generate private key using sigs-cli
PRIVATE_KEY=$(target/debug/sigs-cli keygen --scheme ed25519 --seed "$SEED" | grep "Private key in hex:" | cut -d' ' -f5-)
PRIVATE_KEY=${PRIVATE_KEY//\"/}

# Define the message to sign
MESSAGE=$(cat <<EOF
{
  "types": {
    "EIP712Domain": [
      {"name": "name", "type": "string"},
      {"name": "version", "type": "string"}
    ],
    "SignedData": [
      {"name": "signer", "type": "address"},
      {"name": "user", "type": "address"},
      {"name": "dateTimeOfValidation", "type": "uint256"}
    ]
  },
  "primaryType": "SignedData",
  "domain": {
    "name": "MyDApp",
    "version": "3.0"
  },
  "message": {
    "signer": "0xeafD54E545c077ca1Bb9259fa2F90091Db96F8CC",
    "user": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "dateTimeOfValidation": 1356099130
  }
}
EOF
)

# Remove spaces and line breaks from the message
MESSAGE=$(echo "$MESSAGE" | tr -d '[:space:]')

# Convert message to hex
HEX_MSG=$(echo -n "$MESSAGE" | xxd -p | tr -d '\n')

# Print the hex message to the console
echo "Hex Message: $HEX_MSG"

# Sign the message using sigs-cli
target/debug/sigs-cli sign --msg "$HEX_MSG" --secret-key "$PRIVATE_KEY" --scheme ed25519
