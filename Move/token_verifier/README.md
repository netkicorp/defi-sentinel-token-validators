# Verifier Token Move Module

A Move module for verifying tokens on the Sui blockchain.

## Dependencies
- [Sui Move CLI](https://docs.sui.io/references/cli/move)
- [Fastcrypto](https://github.com/MystenLabs/fastcrypto) (To create test data)

## Overview

This module provides a set of functions for verifying tokens, including checking the signature, user address, transaction time, and signer. It's designed to be used in conjunction with the Sui blockchain and the Move programming language.

## Features

* Verifies token signatures using the Ed25519 algorithm
* Checks user addresses to ensure they match the transaction sender
* Validates transaction times
* Verifies the signer of the token to ensure it's a trusted source

## Building

To build the project, run the following command:

```Bash
# Build the project
sui move build
```

## Usage

Here's an example of how to use the `verify_token` function:

```move
use verifier::token;

// Create a new SignedMessage instance
let signed_msg = token::new(message, public_key, signature);

// Verify the token
let is_valid = token::verify_token(&signed_msg, &clock, &mut ctx);

or

// Verify the token with unfolded data
let is_valid = token::verify_token_unfold(message, public_key, signature, &clock, &mut ctx);

// Check if the token is valid
if (is_valid) {
  // Token is valid, proceed with the transaction
} else {
  // Token is invalid, abort the transaction
}
```

## Testing
This project includes a set of unit tests that can be executed using:

```move
sui move test
```

These tests cover various scenarios and edge cases to ensure the correctness of the token verification logic.

## Consuming smart contract
The `token_verifier.sh` is provided to handle the verification of signed messages using Sui and FastCrypto. This script is designed to sign messages using the sigs-cli tool, convert them to the appropriate format, and verify the signatures against a smart contract.

### Using token_verifier.sh
To sign and verify messages on the Sui blockchain, follow these steps:
Set Up: Ensure that the required tools are installed and accessible on your machine.
Run the Script: From the command line, run the following command:

```bash
 sh token_verifier_client/token_verifier.sh
```

This script performs the following tasks:

- Loads the private key from the keystore.
- Signs the provided message using the sigs-cli tool with the Ed25519 scheme.
- Converts the signed message, public key, and signature into the vector<u8> format.
- Verifies the token signature against the smart contract using the Sui client.

### Customizing the Script
You can modify the script to customize the keystore location, message, or smart contract parameters:

Keystore Path: The path to your Sui keystore file.
FastCrypto Path: Update the path to your FastCrypto installation.
Message: Customize the message to be signed.

The format of the message that is creating to test is 

```json
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
```

## Author
Netki, ops@netki.com

## License
This module is available under the MIT license.
