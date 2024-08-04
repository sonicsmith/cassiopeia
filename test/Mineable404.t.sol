// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Mineable404} from "../src/Mineable404.sol";

contract Mineable404Test is Test {
    Mineable404 public token;

    address owner = address(1);

    function setUp() public {
        token = new Mineable404(owner);
    }

    function test_deployment() public view {
        assertEq(token.name(), "Mineable404");
        assertEq(token.symbol(), "M404");
        assertEq(token.decimals(), 18);
        assertEq(token.owner(), owner);
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(owner), 0);
    }
}
