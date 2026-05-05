// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.34;

/// @title Counter
/// @author Nomev Labs
/// @notice This contract is a simple counter
/// @dev This contract is a simple counter
contract Counter {
    /// @notice The current number
    uint256 public number;

    /// @notice Set the number
    /// @param newNumber The new number
    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    /// @notice Increment the number
    function increment() public {
        number++;
    }
}
