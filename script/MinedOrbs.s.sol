// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MinedOrbs} from "../src/MinedOrbs.sol";

contract MinedOrbsScript is Script {
    MinedOrbs public token;

    function setUp() public {}

    function run() public {
        address owner = vm.envAddress("OWNER");
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        token = new MinedOrbs(owner);

        vm.stopBroadcast();
    }
}
