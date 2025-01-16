// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Utils {

    function _isArithmeticOverflow(bytes memory returnData) internal pure returns (bool) {
        return (keccak256(abi.encodePacked(_getRevertMsg(returnData))) == keccak256(abi.encodePacked("Panic(17)")));
    }

    function _isRevertReasonEqual(bytes memory returnData, string memory reason) internal pure returns (bool) {
        return (keccak256(abi.encodePacked(_getRevertMsg(returnData))) == keccak256(abi.encodePacked(reason)));
    }

    function _isRevertReasonNotEqual(bytes memory reason, string memory reasonString) internal pure returns (bool) {
        return keccak256(reason) != keccak256(abi.encodeWithSignature(reasonString));
    }

    // https://ethereum.stackexchange.com/a/83577
    function _getRevertMsg(bytes memory returnData) internal pure returns (string memory) {
        // TODO: Need to check for custome errors

        // Check that the data has the right size: 4 bytes for signature + 32 bytes for panic code
        if (returnData.length == 4 + 32) {
            // Check that the data starts with the Panic signature
            bytes4 panicSignature = bytes4(keccak256(bytes("Panic(uint256)")));
            for (uint256 i = 0; i < 4; i++) {
                if (returnData[i] != panicSignature[i]) return "Undefined signature";
            }

            uint256 panicCode;
            for (uint256 i = 4; i < 36; i++) {
                panicCode = panicCode << 8;
                panicCode |= uint8(returnData[i]);
            }

            // Now convert the panic code into its string representation
            if (panicCode == 17) {
                return "Panic(17)";
            }

            // Add other panic codes as needed or return a generic "Unknown panic"
            return "Undefined panic code";
        }

        // If the returnData length is less than 68, then the transaction failed silently (without a revert message)
        if (returnData.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            returnData := add(returnData, 0x04)
        }
        return abi.decode(returnData, (string)); // All that remains is the revert string
    }
}