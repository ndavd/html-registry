// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {HTMLRegistry} from "../src/HTMLRegistry.sol";

contract HTMLRegistryDeployScript is Script {
    HTMLRegistry public registry;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        registry = new HTMLRegistry();
        vm.stopBroadcast();
    }
}
