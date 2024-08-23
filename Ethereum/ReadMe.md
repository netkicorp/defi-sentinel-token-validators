# DeFi Sentinel Token Authenticator

Solidity based utility which validates DeFi Sentinel access token, ensuring authenticity and validity of the token, stopping the code if there is an error.

### Key Features

- **User Address Verification**: Verifies that the token is meant for the current user.
- **Date and Time Validation**: Verifies that the token is being accessed within the designated timeframe.
- **Signature Verification**: Verifies the token's integrity by verifiying it was signed by DeFi Sentinel.
- **Error Raising**: Will raise an error if any of the aforementioned verifications fail, preventing the contract from continuing.

## Usage

There are two primary ways to use the code in your own smart contract: **Copying the code directly** or **Importing the contract**.

### 1. Copy the Code Directly
- Open the **'tokenVerifier.sol'** file, copy the entire code and paste it into your existing contract file.
- Make Sure to include the **'import'** statement at the top of your file.
- Example:

```
pragma solidity ^0.8.13;

import "github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract MyContract {
    using strings for *;

    // Paste the copied code here

    function myFunction(bytes memory _tokenData) public {
        tokenVerification(_tokenData);
        // Additional logic
    }
}
```

### 2. Import and Extend the Contract
- Download the file **'tokenVerifier.sol'** and add it to the same directory as the contract you intend to apply it to.
- Import and extend the file into your contract using inheritance to call it.
- Example:

```
pragma solidity ^0.8.13;

import "./tokenVerifier.sol";

contract MyContract is tokenVerifier {

    function myFunction(bytes memory _tokenData) public {
        tokenVerification(_tokenData);
        // Additional logic
    }

    // Additional functions specific to MyContract
}
```

## Functions

### tokenVerification(bytes memory _tokenData) internal view
Converts the hexadecimal token into a string then will isolate the various items within the string that need to be verified.
Will call functions: **verifyUserAddress**, **verifyTimeStamp**, **verifyTokenSignature**. Will raise an error if any of the information isn't correct, otherwise will continue.

Arguments:

- _tokenData: the access token given by sentinel in hexadecimal format.

### verifyTokenSignature(bytes memory _signature, bytes32 _messageHash, address _signer) internal pure
Will split the signature into its components (r, s, v) and will then use those along with messagehash to derive the address of the signer of the token.
Will then compare the found address to that of the actual signer to ensure it is correct, will raise an error if they do not match.

Arguments:

- _signature: 65 byte signature data field from the access token.
- _messageHash: 32 byte messageHash data field from the access token.
- _signer: the address of the sentinel wallet.

### verifyUserAddress(address _user) internal pure
Will compare the address of the user who initiated the transaction to that of the current user calling the contract to make sure the authorized person is the one accessing the token.
Will raise an error if the two do not match.

Arguments:

- _user: the wallet address of the user who initiated the transaction.

### verifyTimeStamp(uint _dateTime) internal pure
Will compare the timestamp of when the access token will expire to the current time to verify that it is within the acceptable usage timeframe.
Will raise an error if the current time is past the valid timeframe. All done in the UTC timezone.

Arguments:

-_dateTime: the time at which the the access tokens validity will expire.

### splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v)
Will take the 65 byte signature of the token and break it down into its components necessary for verification.

Arguments:

- _sig: 65 byte signature data field from the access token.

Returns the components (r, s, v)

## Helper Functions

### removeHexPrefix(string memory _string) internal pure returns (string memory) 
Will check if a hex string has the 0x prefix and remove it if present. Otherwise will leave the string as is.

Arguments:

- _string: Hexadecimal string.

Returns modified hex string.

### hexCharToByte(bytes1 char) internal pure returns (uint8)
Used in tandem with **hexStringToBytes** to convert a hexadecimal string to the same hexadecimal number but in byte form

Arguments:

- char: single character of a hexadecimal string.

Returns uint8 version of the character.

### hexStringToBytes(string memory _hex) internal pure returns (bytes memory)
Will convert a string of hexadecimal values into a byte array of the same hex values.

Arguments:

- _hex: Hexadecimal string.

Returns the byte version of the hex string.

### stringToUint(string memory s) internal pure returns (uint)
Will convert a string containing a number into a uint type.

Arguments:

- s: String containing a number.

Returns the number as a uint type.