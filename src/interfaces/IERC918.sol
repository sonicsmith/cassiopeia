//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC918 {
    /**
     * @dev Upon successful verification and reward the mint method dispatches
     * a Mint Event indicating the reward address,
     * @param from: The address of the reward token
     * @param rewardAmount: The number of tokens minted
     * @param epochCount: The number of the epoch
     * @param newChallengeNumber: The new challenge number
     */
    event Mint(address indexed from, uint256 rewardAmount, uint256 epochCount, bytes32 newChallengeNumber);

    /**
     * @dev Externally facing mint function that is called by miners to validate
     * challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as
     * required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     * @param nonce solution number
     * @param challengeDigest the digest of the solution
     * @return success if the solution is found
     */
    function mint(uint256 nonce, bytes32 challengeDigest) external returns (bool success);

    /**
     * @dev Recent ethereum block hash, used to prevent pre-mining future blocks.
     */
    function getChallengeNumber() external view returns (bytes32);

    /**
     * @dev The number of digits that the digest of the PoW solution requires which typically auto adjusts during
     * reward generation.
     */
    function getMiningDifficulty() external view returns (uint256);

    /**
     * @dev Return the current reward amount. Depending on the algorithm, typically rewards are divided every reward
     *  era as tokens are mined to provide scarcity.
     */
    function getMiningReward() external view returns (uint256);
}
