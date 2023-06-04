// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract HolidayToken is ERC20Upgradeable, AccessControlUpgradeable, PausableUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping (address => bool) private _blacklisted;

    function initialize() initializer public {
        __ERC20_init("HolidayToken", "HDT");
        __AccessControl_init();
        __Pausable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());

        _mint(_msgSender(), 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(MINTER_ROLE) {
        _burn(from, amount);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function blacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _blacklisted[account] = true;
    }

    function unBlacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _blacklisted[account] = false;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisted[account];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        require(!_blacklisted[from] && !_blacklisted[to], "ERC20: account is blacklisted");
        super._beforeTokenTransfer(from, to, amount);
    }

    uint256[49] private __gap;
}
