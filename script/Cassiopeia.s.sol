// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Cassiopeia} from "../src/Cassiopeia.sol";

contract CassiopeiaScript is Script {
    Cassiopeia public token;

    function setUp() public {}

    function run() public {
        address owner = vm.envAddress("OWNER");
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        token = new Cassiopeia(owner);

        vm.stopBroadcast();
    }
}
