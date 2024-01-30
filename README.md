# Gas Bad NFT Marketplace 

We are building a "gas bad" marketplace. An NFT marketplace, but we are going for a gas optimized version. 

To do this, we are writing 2 types of smart contracts:

1. Reference contracts in solidity 
2. Optimized contracts in solidity / assembly 

We will be deploying `GasBadNftMarketplace.sol` to the Ethereum mainnet, but are using `NftMarketplace.sol` as a reference point. 

## Notes:
- At this time, Certora uses `remappings.txt` to know remappings instead of `foundry.toml`. 
- If we change `basic` in `NftMock.conf` -> `none`, we skip the trivial invariant check 

## Learnings 

- Parametric rules 
- Invariants 
- Ghosts 
- Hooks 
- Imports & Multi-contracts 
- Dispatches & Summaries 
- Sanity 