// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract tokenVerifier {
    using strings for *;

    function tokenVerification(bytes memory _tokenData) internal view {
        string memory strx = string(_tokenData);
        strings.slice memory s = strx.toSlice();
        // Isolate the message of the payload only
        s = s.find("message".toSlice());
        strings.slice memory temp;
        /* User Address Verification */
        temp = s.copy().find("user': '".toSlice()).beyond("user': '".toSlice()).rfind("', 'date".toSlice()).until("', 'date".toSlice());
        address user_address = address(bytes20(abi.encodePacked(hexStringToBytes(removeHexPrefix(temp.toString())))));
        verifyUserAddress(user_address);
        /* Date Time Validation Verification */
        temp = s.copy().find("dateTimeOfValidation': ".toSlice()).beyond("dateTimeOfValidation': ".toSlice()).rfind(", 'signature'".toSlice()).until(", 'signature'".toSlice());
        verifyTimeStamp(stringToUint(temp.toString()));
        /* Token Signature Verification */
        temp = s.copy().find("signer': '".toSlice()).beyond("signer': '".toSlice()).rfind("', 'user'".toSlice()).until("', 'user'".toSlice());
        address signer_address = address(bytes20(abi.encodePacked(hexStringToBytes(removeHexPrefix(temp.toString())))));
        temp = s.copy().find("signature': '".toSlice()).beyond("signature': '".toSlice()).rfind("', 'messageHash'".toSlice()).until("', 'messageHash'".toSlice());
        bytes memory signature = abi.encodePacked(hexStringToBytes(removeHexPrefix(temp.toString())));
        temp = s.copy().find("messageHash': '".toSlice()).beyond("messageHash': '".toSlice()).rfind("'}}".toSlice()).until("'}}".toSlice());
        bytes memory messageHash = abi.encodePacked(hexStringToBytes(removeHexPrefix(temp.toString())));
        verifyTokenSignature(signature, bytes32(messageHash), signer_address);
    }

    /*  Will split the signature into its r, s, v then use ecrecover to resolve the address 
        that was used to create that signature and message hash.
        Will Fail if the ecrecover is not equivalent to the signer address passed in to the token */
    function verifyTokenSignature(bytes memory _signature, bytes32 _messageHash, address _signer) internal pure {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        require(ecrecover(_messageHash, v, r, s) == _signer, "Invalid Token Signature.");
    }

    function verifyUserAddress(address _user) internal pure {
        require(_user == msg.sender, "Incorrect user address");
    }

    function verifyTimeStamp(uint _dateTime) internal pure {
        // UTC
        require(_dateTime > block.timestamp, "Expired Token");
    }

    /* Helper Functions */
    
    function splitSignature(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
        // implicitly return (r, s, v)
    }

    /*  Will check if a hex string has the 0x prefix and remove it if it is there, otherwise will leave it as it is.
        necessary for converting hex strings to bytes */
    function removeHexPrefix(string memory _string) internal pure returns (string memory) {
        strings.slice memory s = _string.toSlice();
        if (s.startsWith("0x".toSlice())) {
            s.beyond("0x".toSlice());
            return s.toString();
        }
        else {
            return s.toString();
        }
    }

    function hexCharToByte(bytes1 char) internal pure returns (uint8) {
        if (uint8(char) >= 48 && uint8(char) <= 57) {
            return uint8(char) - 48;
        } else if (uint8(char) >= 65 && uint8(char) <= 70) {
            return uint8(char) - 65 + 10;
        } else if (uint8(char) >= 97 && uint8(char) <= 102) {
            return uint8(char) - 97 + 10;
        } else {
            revert("Invalid hex character");
        }
    }

    /*  Along with hexCharToByte will convert a string of hexadecimal values 
        into a byte array without altering the contents */
    function hexStringToBytes(string memory _hex) internal pure returns (bytes memory) {
        bytes memory hexBytes = bytes(_hex);
        require(hexBytes.length % 2 == 0, "Hex string length must be even");

        bytes memory result = new bytes(hexBytes.length / 2);

        for (uint i = 0; i < hexBytes.length; i += 2) {
            result[i / 2] = bytes1(
                hexCharToByte(hexBytes[i]) * 16 + hexCharToByte(hexBytes[i + 1])
            );
        }
        return result;
    }

    /* Will convert a string containing a number into a uint type */
    function stringToUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }
}
