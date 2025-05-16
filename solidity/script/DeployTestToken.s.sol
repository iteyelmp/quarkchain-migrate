// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";
import {TokenConversion} from "../src/TokenConversion.sol";

// OpenZeppelin Proxy Contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {

    constructor(string memory name_, string memory symbol_, bool _initialMint) ERC20(name_, symbol_) {
        if (_initialMint) {
            _mint(msg.sender, 10000_000_000 * 1e18);
        }
    }

    function mint() public {
        _mint(msg.sender, 1000 * 10 ** 18);
    }
}

contract TokenDeployScript is Script {

    function run() public {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY_DEPLOYER");
        vm.startBroadcast(deployerKey);

        // impl
        MockToken newQKC = new MockToken("QuarkChain New", "nQKC", true);
        MockToken oldQKC = new MockToken("QuarkChain Old", "oQKC", false);
        oldQKC.mint();

        console.log("newQKC:", address(newQKC));
        console.log("oldQKC:", address(oldQKC));

        vm.stopBroadcast();
    }
}
