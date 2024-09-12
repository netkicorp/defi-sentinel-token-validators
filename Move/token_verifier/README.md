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
let is_valid = token::verify_token(&signed_msg, &tx_context, &mut clock);

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

Additionally, a script called `create_test_data.sh` is provided to generate test data for the token verification tests. This script can be used to create test cases with different inputs and expected outputs, making it easier to test the token verification logic.
To use the create_test_data script, simply run it from the command line:

```Bash
sh create_test_data.sh
```

This will generate a set of test data that can be used with the set of unit tests.

## Author
Netki, ops@netki.com

## License
This module is available under the MIT license.
