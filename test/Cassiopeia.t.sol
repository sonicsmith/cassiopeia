// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Cassiopeia} from "../src/Cassiopeia.sol";

contract CassiopeiaTest is Test {
    Cassiopeia public token;

    uint256 startTime;

    address owner = address(1);
    address miner = address(2);

    function setUp() public {
        token = new Cassiopeia(owner);
        startTime = block.timestamp;
    }

    function test_deployment() public view {
        assertEq(token.name(), "Cassiopeia");
        assertEq(token.symbol(), "PEIA");
        assertEq(token.decimals(), 18);
        assertEq(token.owner(), owner);
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(owner), 0);
        assertEq(token.tokenURI(0), "ipfs://");
    }

    function test_setBaseURI() public {
        vm.prank(owner);
        token.setBaseURI("theBaseUri");
        assertEq(token.tokenURI(0), "theBaseUri");
    }

    function test_mint() public {
        vm.warp(startTime + 10000 seconds);

        vm.prank(miner);
        // Use previously computed test hash
        bool success = token.mint(362085, 0x000000fe3a664beb9a776998b1cb016fb94cae88a00468c908ae9898627d1d71);

        assertEq(success, true);
        assertEq(token.totalSupply(), 1 * token.units());
        assertEq(token.balanceOf(miner), 1 * token.units());
    }
}
