//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC918} from "./../interfaces/IERC918.sol";

/**
 * @dev Keeping superfluous SafeMath
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

/**
 * @dev Keeping superfluous ExtendedMath
 */
library ExtendedMath {
    //return the smaller of the two inputs (a or b)
    function limitLessThan(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a > b) return b;
        return a;
    }
}

abstract contract _0xBitcoinToken is IERC918 {
    using SafeMath for uint256;
    using ExtendedMath for uint256;

    uint256 public latestDifficultyPeriodStarted;

    uint256 public epochCount; //number of 'blocks' mined

    uint256 public _BLOCKS_PER_READJUSTMENT = 1024;

    //a little number
    uint256 public _MINIMUM_TARGET = 2 ** 16;

    //a big number is easier ; just find a solution that is smaller
    //uint public  _MAXIMUM_TARGET = 2**224;  bitcoin uses 224
    uint256 public _MAXIMUM_TARGET = 2 ** 234;

    uint256 public miningTarget;

    //generate a new one when a new reward is minted
    bytes32 public challengeNumber;

    address public lastRewardTo;
    uint256 public lastRewardAmount;
    uint256 public lastRewardEthBlockNumber;

    uint256 _totalMineable;

    mapping(bytes32 => bytes32) solutionForChallenge;

    uint256 public tokensMinted;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    function mint(uint256 nonce, bytes32 challengeDigest) public virtual returns (bool success);

    // A new Orb to be mined
    function _startNewMiningEpoch() internal {
        epochCount++;
        //every so often, readjust difficulty. Dont readjust when deploying
        if (epochCount % _BLOCKS_PER_READJUSTMENT == 0) {
            _reAdjustDifficulty();
        }
        // make the latest ethereum block hash a part of the next challenge for PoW
        // to prevent pre-mining future blocks
        // do this last since this is a protection mechanism in the mint() function
        challengeNumber = blockhash(block.number - 1);
    }

    //https://en.bitcoin.it/wiki/Difficulty#What_is_the_formula_for_difficulty.3F
    //as of 2017 the bitcoin difficulty was up to 17 zeroes, it was only 8 in the early days
    //readjust the target by 5 percent
    function _reAdjustDifficulty() internal {
        uint256 blocksSinceLastDifficulty = block.number - latestDifficultyPeriodStarted;

        // blocks = one 0xbitcoin epoch
        uint256 epochsMined = _BLOCKS_PER_READJUSTMENT;

        // Orb blocktime = 1800s (30min)
        // Eth blocktime = 12s
        // 1800 / 12 = 150 times slower than eth
        uint256 targetEthBlocksPerDiffPeriod = epochsMined * 150;

        //if there were less eth blocks passed in time than expected
        if (blocksSinceLastDifficulty < targetEthBlocksPerDiffPeriod) {
            uint256 excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(100)).div(blocksSinceLastDifficulty);
            uint256 excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000);
            // If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined
            // than expected then this is 100.
            // make it harder
            miningTarget = miningTarget.sub(miningTarget.div(2000).mul(excess_block_pct_extra)); //by up to 50 %
        } else {
            uint256 shortage_block_pct = (blocksSinceLastDifficulty.mul(100)).div(targetEthBlocksPerDiffPeriod);
            //always between 0 and 1000
            uint256 shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000);
            //make it easier
            miningTarget = miningTarget.add(miningTarget.div(2000).mul(shortage_block_pct_extra)); //by up to 50 %
        }
        latestDifficultyPeriodStarted = block.number;

        // Difficult
        if (miningTarget < _MINIMUM_TARGET) {
            miningTarget = _MINIMUM_TARGET;
        }
        // Easy
        if (miningTarget > _MAXIMUM_TARGET) {
            miningTarget = _MAXIMUM_TARGET;
        }
    }

    //this is a recent ethereum block hash, used to prevent pre-mining future blocks
    function getChallengeNumber() public view returns (bytes32) {
        return challengeNumber;
    }

    //the number of zeroes the digest of the PoW solution requires.  Auto adjusts
    function getMiningDifficulty() public view returns (uint256) {
        return _MAXIMUM_TARGET.div(miningTarget);
    }

    function getMiningTarget() public view returns (uint256) {
        return miningTarget;
    }

    //reward begins at 50 and is cut in half every reward era (as tokens are mined)
    function getMiningReward() public pure returns (uint256) {
        // Hardcode 1 token every block
        return 1 * 10 ** 18;
    }

    //help debug mining software
    function getMintDigest(uint256 nonce, bytes32, bytes32 challenge_number) public view returns (bytes32) {
        return keccak256(abi.encode(challenge_number, msg.sender, nonce));
    }

    //help debug mining software
    function checkMintSolution(
        uint256 nonce,
        bytes32 challenge_digest,
        bytes32 challenge_number,
        uint256 testTarget
    ) public view returns (bool success) {
        bytes32 digest = keccak256(abi.encode(challenge_number, msg.sender, nonce));
        if (uint256(digest) > testTarget) revert();
        return (digest == challenge_digest);
    }
}
