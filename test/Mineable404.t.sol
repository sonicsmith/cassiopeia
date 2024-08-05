// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Mineable404} from "../src/Mineable404.sol";

contract Mineable404Test is Test {
    Mineable404 public token;

    uint256 startTime;

    address owner = address(1);
    address miner = address(2);

    function setUp() public {
        token = new Mineable404(owner);
        startTime = block.timestamp;
    }

    function test_deployment() public view {
        assertEq(token.name(), "Mineable404");
        assertEq(token.symbol(), "M404");
        assertEq(token.decimals(), 18);
        assertEq(token.owner(), owner);
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(owner), 0);
    }

    function test_setBaseURI() public {
        vm.prank(owner);
        token.setBaseURI("https://example.com/");
        assertEq(token.tokenURI(0), "https://example.com/");
    }

    function test_mint() public {
        vm.warp(startTime + 10000 seconds);

        bytes32 challengeNumber = token.getChallengeNumber();

        vm.prank(miner);
        bool success = token.mint(0, challengeNumber);

        assertEq(success, true);
        assertEq(token.totalSupply(), 1 * token.units());
        assertEq(token.balanceOf(miner), 1 * token.units());
    }
}
