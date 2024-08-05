//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC404U16} from "erc404/ERC404U16.sol";
import {_0xBitcoinToken} from "./abstracts/_0xBitcoinToken.sol";

/**
 * @title Mineable404
 * @notice Mineable404 blah blah
 */
contract Mineable404 is Ownable, ERC404U16, _0xBitcoinToken {
    string private _baseUri = "";

    constructor(address initialOwner_) ERC404U16("Mineable404", "M404", 18) Ownable(initialOwner_) {
        tokensMinted = 0;
        rewardEra = 0;
        // _totalMineable = 65_535 * 10 ** 18; // (2 ** 16) - 1 tokens can ever be mined
        maxSupplyForEra = _totalMineable / 2;
        miningTarget = _MAXIMUM_TARGET;
        latestDifficultyPeriodStarted = block.number;
        _startNewMiningEpoch();
    }

    function setBaseURI(string memory baseUri_) external onlyOwner {
        _baseUri = baseUri_;
    }

    function tokenURI(uint256) public view override returns (string memory) {
        return _baseUri;
    }

    function setERC721TransferExempt(address account_, bool value_) external onlyOwner {
        _setERC721TransferExempt(account_, value_);
    }

    function mint(uint256 nonce, bytes32 challengeDigest) public override returns (bool success) {
        // the PoW must contain work that includes a recent ethereum block hash (challenge number)
        // and the msg.sender's address to prevent MITM attacks
        bytes32 digest = keccak256(abi.encode(challengeNumber, msg.sender, nonce));

        //the challenge digest must match the expected
        if (digest != challengeDigest) revert("Challenge digest mismatch");

        //the digest must be smaller than the target
        if (uint256(digest) > miningTarget) revert("Digest too large");

        //only allow one reward for each challenge
        bytes32 solution = solutionForChallenge[challengeNumber];
        solutionForChallenge[challengeNumber] = digest;
        if (solution != 0x0) revert("Solution already used");

        uint256 rewardAmount = getMiningReward();

        _mintERC20(msg.sender, rewardAmount);

        tokensMinted = tokensMinted + rewardAmount;

        //Cannot mint more tokens than there are
        assert(tokensMinted <= maxSupplyForEra);

        //set readonly diagnostics data
        lastRewardTo = msg.sender;
        lastRewardAmount = rewardAmount;
        lastRewardEthBlockNumber = block.number;

        _startNewMiningEpoch();

        emit Mint(msg.sender, rewardAmount, epochCount, challengeNumber);

        return true;
    }
}
