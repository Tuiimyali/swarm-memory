# Gas Benchmark: Initial Build — 142-Test Suite

**Date:** 2026-03-25
**Network:** Anvil Local Fork (Base Sepolia fork)
**Compiler:** Solidity 0.8.24 (pragma), compiled with 0.8.34
**Optimizer:** 200 runs
**EVM Version:** cancun

## Summary

This is the baseline gas report from the initial 5-contract build. All 142 tests
passed. All future gas optimizations are measured against these numbers.

| Contract | Deployment Gas | Notes |
|----------|---------------|-------|
| MemToken (impl) | ~1,800,000 | ERC-20 + demurrage + exemptions |
| MemToken (proxy) | ~500,000 | ERC1967 UUPS proxy |
| MempucToken | ~1,500,000 | ERC-721 + ERC-5192 soulbound |
| RestorationMilestoneRegistry | ~1,200,000 | Oracle consensus + cooldowns |
| ExternalBountyRegistry | ~800,000 | Bounty management + reputation |
| AgentWallet | ~600,000 | ERC-4337 + kill switch |
| **Total deployment** | **~7,760,517** | Including 19 config transactions |

## Key Function Gas Costs

| Contract | Function | Gas | Notes |
|----------|----------|-----|-------|
| MemToken | transfer() | ~65,000 | Includes decay materialization |
| MemToken | balanceOf() | ~8,000 | View function with decay computation |
| MemToken | mint() | ~52,000 | Authorized minter only |
| MempucToken | mintMempuc() | ~120,000 | Includes metadata storage |
| MempucToken | locked() | ~3,000 | Simple view |
| Registry | submitClaim() | ~80,000 | Claim creation |
| Registry | confirmClaim() | ~45,000 | Per validator vote |
| Registry | confirmClaim() (quorum) | ~95,000 | Quorum + auto-execute reward |
| Bounty | postBounty() | ~70,000 | Bounty creation |
| Bounty | claimBounty() | ~60,000 | Claim + reputation check |
| AgentWallet | executeX402Payment() | ~55,000 | USDC transfer + logging |
| AgentWallet | freeze() | ~25,000 | Emergency halt |

## Deployment Health

| Metric | Value |
|--------|-------|
| Contracts deployed | 5/5 |
| Configuration transactions | 19/19 |
| Test transactions | 6/6 passed |
| Estimated mainnet cost | ~0.00008 ETH (~$0.25 at $3,000/ETH) |
| Bugs found | 1 (cooldown first-claim, fixed) |

## Notes

- Gas costs are approximate and will vary with contract state (storage slots
  written vs. updated).
- `confirmClaim()` at quorum is significantly more expensive because it triggers
  `_executeReward()` which mints MemToken and MempucToken.
- `transfer()` gas includes decay materialization (burn + transfer). If no decay
  has accumulated, actual gas will be lower.
- The optimizer at 200 runs is a balanced setting. Higher runs (10,000+) would
  reduce function call gas but increase deployment gas.

## Related

- [Decision: ADR-001 Lazy Demurrage](../decisions/ADR-001-lazy-demurrage.md) — explains why balanceOf() has computation overhead
- [Post-Mortem: PM-001 Cooldown Bug](../post-mortems/2026-03-25-PM001-cooldown-bug.md) — the 1 bug found during deployment
