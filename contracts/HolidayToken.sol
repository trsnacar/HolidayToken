// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

/// @title HolidayToken
/// @notice ERC-20 token for the holiday industry with role-based minting/burning,
///         pausability and an admin-controlled blacklist.
/// @dev Built on OpenZeppelin's upgradeable contracts. This contract uses the
///      `initializer` pattern; whoever deploys it MUST call `initialize()` in the
///      same transaction (or immediately after) as deployment, otherwise a third
///      party could front-run the call and claim the admin/minter/pauser roles.
contract HolidayToken is ERC20Upgradeable, AccessControlUpgradeable, PausableUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping (address => bool) private _blacklisted;

    /// @notice Emitted when an account is added to the blacklist.
    event Blacklisted(address indexed account, address indexed by);

    /// @notice Emitted when an account is removed from the blacklist.
    event UnBlacklisted(address indexed account, address indexed by);

    /// @notice Initializes the token, grants the deployer all administrative
    ///         roles and mints the initial supply to the deployer.
    /// @dev Can only be called once, guarded by the `initializer` modifier.
    function initialize() initializer public {
        __ERC20_init("HolidayToken", "HDT");
        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(PAUSER_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());

        _mint(_msgSender(), 1000000 * 10 ** decimals());
    }

    /// @notice Mints `amount` tokens to `to`.
    /// @dev Restricted to accounts holding `MINTER_ROLE`. Reverts on the
    ///      zero address via the underlying `ERC20Upgradeable._mint` check.
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @notice Burns `amount` tokens from `from`.
    /// @dev Restricted to accounts holding `MINTER_ROLE`.
    function burn(address from, uint256 amount) public onlyRole(MINTER_ROLE) {
        _burn(from, amount);
    }

    /// @notice Pauses all token transfers.
    /// @dev Restricted to accounts holding `PAUSER_ROLE`.
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Resumes token transfers.
    /// @dev Restricted to accounts holding `PAUSER_ROLE`.
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice Adds `account` to the blacklist, preventing it from sending or
    ///         receiving tokens.
    /// @dev Restricted to accounts holding `DEFAULT_ADMIN_ROLE`.
    function blacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "HolidayToken: zero address");
        _blacklisted[account] = true;
        emit Blacklisted(account, _msgSender());
    }

    /// @notice Removes `account` from the blacklist.
    /// @dev Restricted to accounts holding `DEFAULT_ADMIN_ROLE`.
    function unBlacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _blacklisted[account] = false;
        emit UnBlacklisted(account, _msgSender());
    }

    /// @notice Returns whether `account` is currently blacklisted.
    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisted[account];
    }

    /// @dev Blocks transfers while paused and blocks any transfer involving a
    ///      blacklisted sender or recipient.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        require(!_blacklisted[from] && !_blacklisted[to], "ERC20: account is blacklisted");
        super._beforeTokenTransfer(from, to, amount);
    }

    uint256[49] private __gap;
}
