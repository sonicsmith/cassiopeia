// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Mineable404} from "../src/Mineable404.sol";

contract Mineable404Script is Script {
    Mineable404 public token;

    function setUp() public {}

    function run() public {
        address owner = vm.envAddress("OWNER");
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        token = new Mineable404(owner);

        vm.stopBroadcast();
    }
}
