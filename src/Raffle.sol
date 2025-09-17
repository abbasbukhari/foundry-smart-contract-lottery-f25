// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A Sample Raffle Contract
 * @author Abbas Bukhari
 * @notice This contract is a simple implementation of a raffle system.
 * @dev Implements Chainlink VRFv2.5
 */

contract Raffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error Raffle__NotEnoughETHEntered();

    /* State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_enteranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    /* Events */
    event RaffleEntered(address indexed player);

    constructor(
        uint256 enteranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_enteranceFee = enteranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        // s_vrfCoordinator.requestRandomWords();
    }

    // Building some of the skeleton functions

    function enterRaffle() external payable {
        // require(msg.value >= i_enteranceFee, "Not enough ETH sent!");

        if (msg.value < i_enteranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        s_players.push(payable(msg.sender));
        // Reasons to have Events
        // 1. Makes migration easier
        // 2. Makes front end "Indexing" easier
        emit RaffleEntered(msg.sender);
    }

    // What we want to achieve with this function
    // 1. Get a random number
    // 2. Use random number to pick a winner
    // 3. Be automatically called

    function pickWinner() external {
        // check to see if enough time has passed
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert("Not enough time has passed");
        }
        // Get our random number from Chainlink VRF, its a 2 transaction process
        // 1. We make a request for a RNG (Random Number Generator)
        // 2. The Chainlink oracle will send a transaction to give us or add some random number on chain.
        // What we have been doing so far has been atomic or in a single transaction.
        // The 2 transaction process, the pickwinner will be us requesting for a random number, and then the chainlink VRF is going to give us that random number.

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal virtual override {
        // We will implement the logic to pick a winner using the randomWords array
    }

    /** Getter Functions */

    function getEnteranceFee() external view returns (uint256) {
        return i_enteranceFee;
    }
}
