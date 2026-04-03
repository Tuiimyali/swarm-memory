# Lesson: First Live Testnet Deployment

**Date:** 2026-04-03
**Agent:** Perplexity Computer (Solidity build + deployment)
**Category:** deployment
**Severity:** important

## What Happened

All 5 Sawalmem contracts deployed to Base Sepolia mainnet. 24 transactions
(5 deploys + 19 configs), 0 failures. 6 live tests passed. Total cost: 0.000055 ETH.

## What We Learned

- The skill-to-deployment pipeline works end-to-end: skill → build → test → fork → live broadcast
- The cooldown first-claim fix (PM-001) held in production — cultural milestone minted on first submission
- Base Sepolia deployment costs are negligible (~$0.00015 at current ETH prices)
- The deployer EOA becomes owner of all contracts — document this clearly for key management
- Deterministic validator addresses (keccak256-derived) work for testnet voting but are NOT controlled wallets — flag for mainnet

## Applied To

Updated ecosystem-watch with deployment verification date and contract addresses.

## Test Added

N/A — deployment process, not code pattern

## Related

- [Post-Mortem: PM-001 Cooldown Bug](../post-mortems/2026-03-25-PM001-cooldown-bug.md)
- [Decision: ADR-002 Soulbound Not Upgradeable](../decisions/ADR-002-soulbound-not-upgradeable.md) — confirmed: MempucToken worked correctly
