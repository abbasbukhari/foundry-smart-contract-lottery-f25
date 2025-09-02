// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

/**
 * @title A Sample Raffle Contract
 * @author Abbas Bukhari
 * @notice This contract is a simple implementation of a raffle system.
 * @dev Implements Chainlink VRFv2.5
 */

contract Raffle {
    uint256 private immutable i_enteranceFee;

    constructor(uint256 enteranceFee) {
        i_enteranceFee = enteranceFee;
    }

    // Building some of the skeleton functions

    function enterRaffle() public payable {}

    function pickWinner() public {}

    /** Getter Functions */

    function getEnteranceFee() external view returns (uint256) {
        return i_enteranceFee;
    }
}
