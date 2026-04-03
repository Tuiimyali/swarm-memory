# Gas Benchmark: Live Base Sepolia Deployment

**Date:** 2026-04-03
**Network:** Base Sepolia (Chain ID: 84532)
**Compiler:** Solidity 0.8.24 (pragma)
**Optimizer:** 200 runs
**EVM Version:** cancun

## Summary

| Contract | Deployment Gas |
|----------|---------------|
| MemToken | ~1,287,482 |
| MempucToken | ~1,781,084 |
| RestorationMilestoneRegistry | ~1,472,382 |
| ExternalBountyRegistry | ~1,379,369 |
| AgentWallet | ~941,925 |
| **Total (5 contracts)** | **~6,862,242** |

## Configuration Gas

19 configuration transactions: ~893,756 gas

**Total deployment + config:** ~7,755,998 gas

## Test Transaction Gas

Negligible — read calls are free, write calls <100k each.

## Total Cost

**0.000055 ETH** for entire deployment + config + 6 live tests.

At Base Sepolia gas price of ~0.01 gwei, the L2 cost is effectively zero.

## Comparison to Fork Deployment (2026-03-25)

| Metric | Fork (Mar 25) | Live (Apr 3) | Delta |
|--------|--------------|--------------|-------|
| Total deployment gas | ~7,760,517 | ~7,755,998 | -4,519 (negligible) |
| Contracts deployed | 5/5 | 5/5 | — |
| Config transactions | 19/19 | 19/19 | — |
| Test transactions | 6/6 passed | 6/6 passed | — |
| Bugs found | 1 (cooldown) | 0 | Fixed |

Gas numbers are consistent between fork and live deployment. This is the
**live chain baseline**. Compare all future deployments against these numbers.
If a contract gets significantly more expensive, investigate (Pike's Rule 2).

## Notes

- Gas price on Base Sepolia is not representative of mainnet pricing
- Mainnet gas will be higher but still sub-cent for most operations
- The ~5k gas difference between fork and live is within normal variance

## Related

- [Gas Benchmark: Initial Build](2026-03-25-initial-build.md) — fork deployment baseline
- [Lesson: Live Testnet Deployment](../lessons/2026-04-03-live-testnet-deployment.md)
