# Ecosystem State: Base Sepolia Deployment

**Last Updated:** 2026-04-03

## Deployment Info

| Property | Value |
|----------|-------|
| Last deployed | 2026-04-03 |
| Deployer | `0x6d0e73341F2C31e151178b47D3527421C7dd9d3c` |
| Deployer balance remaining | 0.009945 ETH |
| Chain | Base Sepolia (Chain ID: 84532) |
| Total cost | 0.000055 ETH |

## Contract Addresses

| Contract | Address |
|----------|---------|
| MemToken | `0x56a176A57757010F5ed0fC5AC900934Afef1BA70` |
| MempucToken | `0xfeCFBCa92776A9aed611dbB01667392FF090B6A3` |
| RestorationMilestoneRegistry | `0x4c045c4dB5748dD2c2D5b84bf4a0B6e9CC90E888` |
| ExternalBountyRegistry | `0xcB3706bA2B8e7a56851245583f08EBd4BCC1669a` |
| AgentWallet | `0x9de0a9A0eD50A9E2c7Ed9731B8003beAd4066e8E` |

## On-Chain State

| Metric | Value |
|--------|-------|
| MEM in circulation | 600 |
| Mempuc minted | 1 (Cultural) |
| Validators registered | 3 (1 real, 2 deterministic) |
| Claims | 2 (1 Pending ecological, 1 Approved cultural) |
| Agent wallet | Operational, unfrozen, $1000/day budget |

## Verification Status

**UNKNOWN** — need to confirm source code is verified on Basescan.

## Notes

- Bytecode is PRE-LINTING (deployed before Pike's Rules audit)
- Will need redeployment after quality pass if bytecode changes
- Deterministic validator addresses cannot vote — oracle quorum untestable on
  live chain with current setup (see [anti-pattern](../anti-patterns/deterministic-validators.md))
