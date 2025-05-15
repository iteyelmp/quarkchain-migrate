// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";
import {TokenConversion} from "../src/TokenConversion.sol";

// OpenZeppelin Proxy Contracts
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TokenConversionScript is Script {
    address constant OLD_QKC = 0x1234567890123456789012345678901234567890;
    address constant NEW_QKC = 0xABcdEFABcdEFabcdEfAbCdefabcdeFABcDEFabCD;
    uint256 constant START_TIME = 1_713_000_000;
    uint256 constant END_TIME = 1_723_000_000;

    function run() public {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY_DEPLOYER");
        address deployer = vm.addr(deployerKey);
        vm.startBroadcast(deployerKey);

        // impl
        TokenConversion impl = new TokenConversion();
        // ProxyAdmin
        ProxyAdmin admin = new ProxyAdmin(deployer);
        // init data
        bytes memory initData = abi.encodeWithSelector(
            TokenConversion.initialize.selector,
            OLD_QKC,
            NEW_QKC,
            START_TIME,
            END_TIME,
            deployer // defaultAdmin
        );
        // Transparent Proxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(impl),
            address(admin),
            initData
        );

        console.log("Implementation:", address(impl));
        console.log("ProxyAdmin:", address(admin));
        console.log("Proxy:", address(proxy));

        vm.stopBroadcast();
    }
}
