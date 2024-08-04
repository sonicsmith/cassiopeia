//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC404U16} from "erc404/ERC404U16.sol";
import {AbstractERC918} from "./abstracts/AbstractERC918.sol";

/**
 * @title Mineable404
 * @notice Mineable404 blah blah
 */
contract Mineable404 is Ownable, ERC404U16, AbstractERC918 {
    string private _baseUri = "";

    constructor(address initialOwner_) ERC404U16("Mineable404", "M404", 18) Ownable(initialOwner_) {
        // No Premint
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
        // perform the hash function validation
        _hash(nonce, challengeDigest);

        // calculate the current reward
        uint256 rewardAmount = _reward();

        // increment the minted tokens amount
        tokensMinted += rewardAmount;

        uint256 epochCount = _newEpoch(nonce);

        _adjustDifficulty();

        //populate read only diagnostics data
        statistics = Statistics(msg.sender, rewardAmount, block.number, block.timestamp);

        // send Mint event indicating a successful implementation
        emit Mint(msg.sender, rewardAmount, epochCount, challengeNumber);

        _mintERC20(msg.sender, _reward());

        return true;
    }
}
