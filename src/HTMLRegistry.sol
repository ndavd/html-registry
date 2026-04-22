// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SSTORE2} from "solady/utils/SSTORE2.sol";

interface IOwnable {
    function owner() external view returns (address);
}

/// @title HTMLRegistry
/// @notice On-chain registry for associating HTML content to protocols or accounts
contract HTMLRegistry {
    /// @dev author => target => version => content
    mapping(address => mapping(address => mapping(uint256 => address))) sPtrs;
    /// @dev author => target => latest version
    mapping(address => mapping(address => uint256)) sVersions;

    error HTMLRegistry__NotAuthorized();

    event HTMLRegistry__HtmlSet(address indexed author, address indexed target, uint256 version);

    function _checkAuthorized(address target) internal view {
        address sender = msg.sender;
        if (sender == target) return;
        if (target.code.length > 0) {
            try IOwnable(target).owner() returns (address owner) {
                if (sender == owner) return;
            } catch {}
        }
        revert HTMLRegistry__NotAuthorized();
    }

    modifier onlyAuthorized(address target) {
        _checkAuthorized(target);
        _;
    }

    function _write(address author, address target, string calldata htmlData) internal {
        uint256 version = ++sVersions[author][target];
        sPtrs[author][target][version] = SSTORE2.write(bytes(htmlData));
        emit HTMLRegistry__HtmlSet(author, target, version);
    }

    function _html(address author, address target, uint256 version) internal view returns (string memory) {
        address ptr = sPtrs[author][target][version];
        if (ptr == address(0)) return "";
        return string(SSTORE2.read(ptr));
    }

    function setHtml(address target, string calldata htmlData) external onlyAuthorized(target) {
        _write(msg.sender, target, htmlData);
    }

    function setHtmlAsTarget(address target, string calldata htmlData) external onlyAuthorized(target) {
        _write(target, target, htmlData);
    }

    function html(address author, address target, uint256 version) external view returns (string memory) {
        return _html(author, target, version);
    }

    function html(address author, address target) external view returns (string memory) {
        return _html(author, target, sVersions[author][target]);
    }

    function html(address addr, uint256 version) external view returns (string memory) {
        return _html(addr, addr, version);
    }

    function html(address addr) external view returns (string memory) {
        return _html(addr, addr, sVersions[addr][addr]);
    }

    function latestVersion(address author, address target) external view returns (uint256) {
        return sVersions[author][target];
    }
}
