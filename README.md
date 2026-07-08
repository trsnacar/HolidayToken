# HolidayToken (HDT)

An ERC-20 token built with Solidity and OpenZeppelin's upgradeable contracts, designed around a holiday/travel-industry theme. It combines standard ERC-20 functionality with role-based access control, pausability, and an admin-managed blacklist.

## Overview

`HolidayToken` is implemented in `contracts/HolidayToken.sol` as an upgradeable contract (`ERC20Upgradeable`, `AccessControlUpgradeable`, `PausableUpgradeable` from `@openzeppelin/contracts-upgradeable`). Rather than a constructor, it exposes an `initialize()` function that sets up the token name/symbol (`HolidayToken` / `HDT`), grants the deployer all administrative roles, and mints the initial supply.

> **Note:** The contract uses OpenZeppelin's `initializer` pattern. If deployed without a proxy, `initialize()` must be called in the same transaction as deployment (or immediately after) to avoid a third party front-running it and claiming the admin roles.

## Key Features

- **ERC-20 compliant** token with an initial supply of 1,000,000 HDT (18 decimals) minted to the deployer.
- **Role-based access control** via OpenZeppelin `AccessControl`:
  - `DEFAULT_ADMIN_ROLE` — can manage the blacklist and grant/revoke roles.
  - `MINTER_ROLE` — can mint and burn tokens.
  - `PAUSER_ROLE` — can pause and unpause all token transfers.
- **Pausable transfers** — the admin can halt all transfers in an emergency via `pause()` / `unpause()`.
- **Blacklist** — accounts can be blocked from sending or receiving tokens via `blacklist()` / `unBlacklist()`, checked on every transfer via `_beforeTokenTransfer`.
- **Upgrade-safe storage** — includes a storage gap (`__gap`) for future upgrades.

## Tech Stack

- [Solidity](https://soliditylang.org/) `0.8.4`
- [Hardhat](https://hardhat.org/) development environment
- [OpenZeppelin Contracts Upgradeable](https://docs.openzeppelin.com/contracts/4.x/) `^4.9.0`
- [Ethers.js](https://docs.ethers.org/v5/) `v5` and [ethereum-waffle](https://www.npmjs.com/package/ethereum-waffle) for testing
- [Chai](https://www.chaijs.com/) for test assertions

## Prerequisites

- [Node.js](https://nodejs.org/) (v16 or later recommended)
- npm

## Installation

```bash
git clone https://github.com/trsnacar/HolidayToken.git
cd HolidayToken
npm install
```

## Usage

### Compile the contracts

```bash
npx hardhat compile
```

### Run the tests

The test suite (`test/HolidayToken.test.js`) covers deployment/role assignment, token transfers, blacklisting, and pausing:

```bash
npx hardhat test
```

### Local deployment

The project ships with the default Hardhat network configuration (`hardhat.config.js`, chain ID `1337`). You can deploy and initialize the contract from the Hardhat console or a script, e.g.:

```js
const HolidayToken = await ethers.getContractFactory("HolidayToken");
const holidayToken = await HolidayToken.deploy();
await holidayToken.deployed();
await holidayToken.initialize();
```

No deployment scripts or live network configuration are currently included in this repository, and no contract has been deployed to a public network yet.

## Project Structure

```
contracts/
  HolidayToken.sol      # Main ERC-20 token contract
test/
  HolidayToken.test.js  # Hardhat/Chai test suite
hardhat.config.js       # Hardhat configuration
```

## License

The contract source is marked `SPDX-License-Identifier: UNLICENSED`. No separate `LICENSE` file is currently included in this repository.

## Contributing

Contributions are welcome. Please open an issue or pull request to discuss changes before submitting significant work.
