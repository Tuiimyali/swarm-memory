# Ecosystem State: Base L2

**Last Updated:** 2026-03-25

## Current State

| Property | Value |
|----------|-------|
| Network | Base Mainnet (Ethereum L2, Optimism stack) |
| EVM Version | Prague (default since Solidity 0.8.30) |
| Our foundry.toml | `evm_version = "cancun"` |
| Gas costs | Sub-cent for most transactions |
| USDC | Native, EIP-3009 supported |
| Testnet | Base Sepolia (operational) |

## Key Notes

- **Prague EVM:** Base supports Prague (Pectra upgrade). Our `foundry.toml` still
  uses `cancun` — functional but consider updating for EIP-7702 features.
- **EIP-7702 (EOA delegation):** Allows EOAs to delegate to smart contracts.
  Could simplify agent onboarding in Phase 4. Available with Prague EVM.
- **Sub-cent fees:** Makes micropayments and frequent transactions viable.
  Critical for agent-to-agent x402 settlement.
- **Deployment verified:** All 5 contracts deployed successfully to forked
  Base Sepolia (2026-03-25). Total deployment gas: ~7.7M.

## Our Deployment

| Item | Status |
|------|--------|
| Base Sepolia fork test | Passed (2026-03-25) |
| Base Sepolia testnet | Not yet deployed |
| Base Mainnet | Phase 2 target |

## Sources

- https://docs.base.org
- https://base.org/blog
