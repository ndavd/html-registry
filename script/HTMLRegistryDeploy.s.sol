// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {HTMLRegistry} from "../src/HTMLRegistry.sol";

interface ICreateX {
    function deployCreate2(bytes32 salt, bytes memory initCode) external payable returns (address newContract);
}

contract HTMLRegistryDeployScript is Script {
    ICreateX public constant CREATEX = ICreateX(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed);
    bytes32 public constant SALT = bytes32(0x7d94e0fb1a40d702e8cc90000000000000000000000000000000000000000000);

    function run() public {
        bytes memory initCode = type(HTMLRegistry).creationCode;
        vm.startBroadcast();
        address registryAddr = CREATEX.deployCreate2(SALT, initCode);
        vm.stopBroadcast();
        require(registryAddr == 0xFa11bacCdc38022dbf8795cC94333304C9f22722);
    }
}
