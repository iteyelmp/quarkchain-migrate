// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/mock/MockToken.sol";

contract TokenTransferScript is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY_DEPLOYER");
        address proxyAddress = vm.envAddress("CONVERSION_PROXY");
        address tokenAddress = vm.envAddress("NEW_QKC_ADDRESS");

        vm.startBroadcast(deployerKey);
        MockToken token = MockToken(tokenAddress);
        token.transfer(proxyAddress, 1_000_000 * 1e18);
        console.log("Transferred 1,000,000 nQKC to:", proxyAddress);
        vm.stopBroadcast();
    }
}
