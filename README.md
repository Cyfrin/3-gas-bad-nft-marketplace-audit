# Gas Bad NFT Marketplace 

We are building a "gas bad" marketplace. An NFT marketplace, but we are going for a gas optimized version. 

To do this, we are writing 2 types of smart contracts:

1. Reference contracts in solidity 
2. Optimized contracts in solidity / assembly 

We will be deploying `GasBadNftMarketplace.sol` to the Ethereum mainnet, but are using `NftMarketplace.sol` as a reference point. 

<!-- <p align="center">
<img src="./images/math-master.png" width="400" alt="gas bad nft marketplace">
<br/> -->

# Gas Bad NFT Marketplace

- [Gas Bad NFT Marketplace](#gas-bad-nft-marketplace)
- [Gas Bad NFT Marketplace](#gas-bad-nft-marketplace-1)
- [About](#about)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Certora](#certora)
    - [Certora Setup](#certora-setup)
    - [Running Certora](#running-certora)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
- [Audit Scope Details](#audit-scope-details)
  - [Compatibilities](#compatibilities)
- [Roles](#roles)
- [Known Issues](#known-issues)

# About

We are building a "gas bad" marketplace. An NFT marketplace, but we are going for a gas optimized version. 

To do this, we are writing 2 types of smart contracts:

1. Reference contracts in solidity 
2. Optimized contracts in solidity / assembly 

We will be deploying `GasBadNftMarketplace.sol` to the Ethereum mainnet, but are using `NftMarketplace.sol` as a reference point. 

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`
- [certoraRun cli](https://docs.certora.com/en/latest/docs/user-guide/getting-started/install.html)
  - You'll know you did it right if you can run `certoraRun --version` and you see a response like `certora-cli 6.1.4`
  - You'll also need a certora environment variable named `CERTORAKEY`
  - You may need python and `pip` installed to install the certora cli

## Quickstart

```
git clone https://github.com/Cyfrin/12-gas-bad-nft-marketplace-audit
cd 12-gas-bad-nft-marketplace-audit
make
```

# Usage

## Certora


### Certora Setup

After installing the [Certora CLI](https://docs.certora.com/en/latest/docs/user-guide/getting-started/install.html), you'll need to set up your environment variables. The instructions here only work for linux/macOs/windows WSL.

```bash
export CERTORAKEY=<personal_access_key>
```

or, you can ruh:

```
source .env.example
```

You can check if the environment variable is set by running:

```bash
echo $CERTORAKEY
```

### Running Certora 

In this repo, we will be heavily relying on Certora to make sure our codebase is good! We have the following specs:
- `GasBadNft.spec`: For formally verifying the `GasBadNftContract.sol`
- `NftMock.spec`: For showcasing some cool Certora functionality 😊 

The two main commands to run the specs, respectively are:

```
make certora
make certoraNft
```

See the `Makefile` for more details.

## Testing

```
forge test
```

### Test Coverage

```
forge coverage
```

and for coverage based testing:

```
forge coverage --report debug
```

# Audit Scope Details

- Commit Hash: 
- In Scope:

```

```

## Compatibilities

- Solc Version: 0.8.20
- Chain(s) to deploy contract to: 
  - Ethereum
- Tokens:
  - None

# Roles

- Buyer: Someone who buys an NFT from the marketplace
- Seller: Someone who sells and NFT on the marketplace

# Known Issues

- The seller can front-run a bought NFT and cancel the listing
- The seller can front-run a bought NFT and update the listing
- We should emit an event for withdrawing proceeds
