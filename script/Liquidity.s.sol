// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

interface ICassiopeia {
    function setERC721TransferExempt(address account_, bool value_) external;
}

contract LiquidityScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        ICassiopeia token = ICassiopeia(0xB17c8A3fad09c1eC2759B480349e48BFfF37ADB7);

        // Calculated addressed from simulation
        address uniswapV2 = 0x7Da1435cee9933320dcB6aD51dDec548c5D79D3C;
        address uniswapV3_500 = 0x9136C9A43DF7820A07f6Aee1BE602461b20822af;
        address uniswapV3_3_000 = 0x84d35e5eeE0EDdE2bdE258257ce2c15dE15b259F;
        address uniswapV3_10_000 = 0x0DFcd523cA1dE6eA3a02D055a17be28cb52f46f3;

        token.setERC721TransferExempt(uniswapV2, true);
        token.setERC721TransferExempt(uniswapV3_500, true);
        token.setERC721TransferExempt(uniswapV3_3_000, true);
        token.setERC721TransferExempt(uniswapV3_10_000, true);

        vm.stopBroadcast();
    }
}
