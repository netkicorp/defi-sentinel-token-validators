# 

#!/bin/bash

# Constants
KEYSTORE_PATH="YOUR_KEYSTORE"
FASTCRYPTO_PATH="YOUR_FASTCRYTPTO_PATH"
SIGS_CLI_PATH="$FASTCRYPTO_PATH/target/debug/sigs-cli"
SUI_PACKAGE="0xa09ae5b504cbc7e6191cd7615ad6f20b6b504c91cc54b4e734b6f21cb366ae16"
SUI_MODULE="token"
SUI_FUNCTION="verify_token_unfold"
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
    "user": "YOUR_WALLET_ADDRESS",
    "dateTimeOfValidation": CURRENT_TIMESTAMP_IN_MILLISECONDS
  }
}
EOF
)

# Step 1: Load the keystore
echo "Loading the keystore from $KEYSTORE_PATH..."
KEY_CONTENT=$(jq -r '.[0]' "$KEYSTORE_PATH")

# Step 2: Decode the Base64 string from the keystore
echo "Decoding the Base64-encoded private key..."
decoded_key=$(base64 --decode <<< "$KEY_CONTENT")

# Step 3: Remove the first byte (flag) and extract the private key
echo "Extracting the private key..."
private_key=${decoded_key:1}

# Step 4: Convert the private key to a hexadecimal string
echo "Converting the private key to a hexadecimal string..."
private_key_hex=$(echo -n "$private_key" | xxd -p -l 32 | tr -d '\n')

# Step 6: Remove spaces and line breaks from the message and convert it to hexadecimal
echo "Cleaning and converting the message to a hex string..."
clean_message=$(echo "$MESSAGE" | tr -d '[:space:]')
hex_message=$(echo -n "$clean_message" | xxd -p | tr -d '\n')

# Step 8: Sign the message using sigs-cli and capture the output
echo "Signing the message using sigs-cli..."
sign_output=$($SIGS_CLI_PATH sign --msg "$hex_message" --secret-key "$private_key_hex" --scheme ed25519)

# Step 9: Extract the signature and public key from the sigs-cli output
echo "Extracting the signature and public key..."
signature=$(echo "$sign_output" | grep "Signature in hex" | awk -F': ' '{print $2}' | tr -d '"')
public_key=$(echo "$sign_output" | grep "Public key in hex" | awk -F': ' '{print $2}' | tr -d '"')

# Step 10: Function to convert hex string to vector<u8>
hex_to_vector_u8() {
    local hex_string=$1

    # Remove any leading "0x" if present
    hex_string=${hex_string#0x}

    # Ensure the hex string has an even number of characters
    if [ $(( ${#hex_string} % 2 )) -ne 0 ]; then
        echo "Invalid hex string length"
        exit 1
    fi

    # Convert hex string to vector<u8>
    echo "["
    echo $hex_string | awk '{
        for (i=1; i<=length; i+=2) {
            printf "0x%s", substr($0, i, 2)
            if (i < length-1) {
                printf ", "
            }
        }
    }'
    echo "]"
}

# Step 11: Convert the hex values to vector<u8> format
echo "Converting the hex message to vector<u8> format..."
message_vector=$(hex_to_vector_u8 "$hex_message")

echo "Converting the hex signature to vector<u8> format..."
signature_vector=$(hex_to_vector_u8 "$signature")

echo "Converting the hex public key to vector<u8> format..."
public_key_vector=$(hex_to_vector_u8 "$public_key")

# Step 12: Execute the Sui client call
echo "Executing the Sui client call to verify the signature..."
sui client call --package "$SUI_PACKAGE" --module "$SUI_MODULE" --function "$SUI_FUNCTION" --args "$message_vector" "$public_key_vector" "$signature_vector" 0x6

echo "Sui client call complete."
