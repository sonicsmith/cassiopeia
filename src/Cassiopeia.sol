//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*

 ██████  █████  ███████ ███████ ██  ██████  ██████  ███████ ██  █████  
██      ██   ██ ██      ██      ██ ██    ██ ██   ██ ██      ██ ██   ██ 
██      ███████ ███████ ███████ ██ ██    ██ ██████  █████   ██ ███████ 
██      ██   ██      ██      ██ ██ ██    ██ ██      ██      ██ ██   ██ 
 ██████ ██   ██ ███████ ███████ ██  ██████  ██      ███████ ██ ██   ██ 
                                                                       
                                                                       
    The worlds first mineable ERC404 token.

    https://github.com/sonicsmith/cassiopeia

*/

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC404U16} from "erc404/ERC404U16.sol";
import {_0xBitcoinToken} from "./abstracts/_0xBitcoinToken.sol";
import {IERC4906} from "./interfaces/IERC4906.sol";

/**
 * @title Cassiopeia
 * @notice The worlds first mineable ERC404 token
 */
contract Cassiopeia is Ownable, ERC404U16, _0xBitcoinToken, IERC4906 {
    string private _baseUri = "ipfs://QmUiTFJQdm2RP84xKbfRgEMbvojCQakEjkSTPkrWx1iEoL";

    error ChallengeDigestMismatch();
    error DigestTooLarge();
    error SolutionAlreadyUsed();
    error BlockAlreadyMined();

    constructor(address initialOwner_) ERC404U16("cTest", "cTest", 18) Ownable(initialOwner_) {
        tokensMinted = 0;
        // (2 ** 16) - 1 = Max tokens can ever be mined
        _totalMineable = 65_535 * 10 ** 18;
        miningTarget = _MAXIMUM_TARGET;
        latestDifficultyPeriodStarted = block.number;
        _startNewMiningEpoch();
    }

    function setBaseURI(string memory baseUri_) external onlyOwner {
        _baseUri = baseUri_;
        emit BatchMetadataUpdate(1, _totalMineable);
    }

    function tokenURI(uint256) public view override returns (string memory) {
        return _baseUri;
    }

    function setERC721TransferExempt(address account_, bool value_) external onlyOwner {
        _setERC721TransferExempt(account_, value_);
    }

    function mint(uint256 nonce, bytes32 challengeDigest) public override returns (bool success) {
        // The PoW must contain work that includes a recent ethereum block hash (challenge number)
        // and the msg.sender's address to prevent MITM attacks
        bytes32 digest = keccak256(abi.encode(challengeNumber, msg.sender, nonce));

        // Challenge digest must match the expected
        if (digest != challengeDigest) {
            revert ChallengeDigestMismatch();
        }

        // Digest must be smaller than the target
        if (uint256(digest) > miningTarget) {
            revert DigestTooLarge();
        }

        // Solution can only be used once
        bytes32 solution = solutionForChallenge[challengeNumber];
        solutionForChallenge[challengeNumber] = digest;
        if (solution != 0x0) {
            revert SolutionAlreadyUsed();
        }

        // One mined block per Ethereum block
        if (lastRewardEthBlockNumber == block.number) {
            revert BlockAlreadyMined();
        }
        lastRewardEthBlockNumber = block.number;

        uint256 rewardAmount = getMiningReward();

        _mintERC20(msg.sender, rewardAmount);

        tokensMinted = tokensMinted + rewardAmount;

        // Cannot mint more tokens than there are
        assert(tokensMinted <= _totalMineable);

        // Set readonly diagnostics data
        lastRewardTo = msg.sender;
        lastRewardAmount = rewardAmount;
        lastRewardEthBlockNumber = block.number;

        _startNewMiningEpoch();

        emit Mint(msg.sender, rewardAmount, epochCount, challengeNumber);

        return true;
    }
}
