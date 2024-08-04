//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC918} from "../interfaces/IERC918.sol";

/**
 * @dev ERC Draft Token Standard #918 Interface
 * Proof of Work Mineable Token
 *
 * This Abstract contract describes a minimal set of behaviors (hash, reward, epoch, and difficulty adjustment)
 * and state required to build a Proof of Work driven mineable token.
 *
 * https://github.com/ethereum/EIPs/pull/918
 */
abstract contract AbstractERC918 is IERC918 {
    // generate a new challenge number after a new reward is minted
    bytes32 public challengeNumber;

    // the current mining difficulty
    uint256 public difficulty = 10 ** 32;

    // cumulative counter of the total minted tokens
    uint256 public tokensMinted;

    // Variable to keep track of when rewards were given
    uint256 public timeOfLastProof;

    /**
     * @dev Track read-only minting statistics
     * @param lastRewardTo: the target of the last reward
     * @param lastRewardAmount: the amount of tokens minted during the last reward
     * @param lastRewardEthBlockNumber: the eth block number in which the last reward was minted
     * @param lastRewardTimestamp: the timestamp at which the last reward was minted
     */
    struct Statistics {
        address lastRewardTo;
        uint256 lastRewardAmount;
        uint256 lastRewardEthBlockNumber;
        uint256 lastRewardTimestamp;
    }

    Statistics public statistics;

    /**
     * @dev Externally facing mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     *
     */
    function mint(uint256 nonce, bytes32 challengeDigest) external virtual returns (bool success) {}

    /**
     * @dev
     */
    function _hash(uint256 nonce, bytes32 challengeDigest) internal view returns (bytes32 digest) {
        // Generate a random hash based on input
        digest = bytes32(keccak256(abi.encode(nonce, challengeDigest)));
        // Check if it's under the difficulty
        require(digest >= bytes32(difficulty));
    }
    /**
     * @dev
     */

    function _reward() internal view returns (uint256 rewardAmount) {
        // Calculate time since last reward was given
        uint256 timeSinceLastProof = (block.timestamp - timeOfLastProof);
        // Rewards cannot be given too quickly
        require(timeSinceLastProof >= 5 seconds);
        rewardAmount = timeSinceLastProof / 60 seconds;
    }

    /**
     * @dev
     */
    function _newEpoch(uint256 nonce) internal returns (uint256) {
        // Reset the counter
        timeOfLastProof = block.timestamp;
        // Save a hash that will be used as the next proof
        challengeNumber = keccak256(abi.encode(nonce, challengeNumber, blockhash(block.number - 1)));
        return timeOfLastProof;
    }

    /**
     * @dev
     */
    function _adjustDifficulty() internal returns (uint256) {
        // Calculate time since last reward was given
        uint256 timeSinceLastProof = (block.timestamp - timeOfLastProof);
        // Adjusts the difficulty
        difficulty = difficulty * 10 minutes / (timeSinceLastProof + 1);
        return difficulty;
    }

    /**
     * @inheritdoc IERC918
     */
    function getChallengeNumber() external view returns (bytes32) {
        return challengeNumber;
    }

    /**
     * @inheritdoc IERC918
     */
    function getMiningDifficulty() external view returns (uint256) {
        return difficulty;
    }

    /**
     * @inheritdoc IERC918
     */
    function getMiningReward() external view returns (uint256) {
        return _reward();
    }
}
