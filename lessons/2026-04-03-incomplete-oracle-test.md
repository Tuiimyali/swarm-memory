# Lesson: Ecological Oracle Quorum Not Fully Tested on Live Chain

**Date:** 2026-04-03
**Agent:** Perplexity Computer
**Category:** testing
**Severity:** minor

## What Happened

Test 3 (Ecological Milestone) submitted a claim and registered 1 vote, correctly
showing quorum not reached (1/3). But the test did not complete 3 votes to trigger
auto-mint of Mempuc. The fork deployment DID complete this test successfully
(3 votes → auto-mint), but the live deployment stopped at 1 vote.

## What We Learned

When testing oracle consensus on live chain with a single deployer key, you need
3 separate validator addresses to cast 3 votes. The deployer was registered as
validator 1. Validators 2 and 3 are deterministic (keccak256-derived) — the deployer
doesn't hold their private keys, so it couldn't cast votes from those addresses on
live chain.

Fix for future testnet tests: Either (a) generate 3 real wallets with known private
keys and register all 3 as validators, or (b) reduce quorum to 1 for testnet-only
deployment.

## Applied To

Should be captured in deployment script: `ConfigureAgents.s.sol` should generate
and fund 3 real validator wallets for testnet.

## Test Added

Proposed: `test_FullOracleQuorumOnLiveChain` — deploy with 3 real validators,
submit claim, cast 3 votes, verify Mempuc minted.

## Related

- [Pattern: Oracle Consensus](../patterns/oracle-consensus.md)
- [Anti-Pattern: Deterministic Validators](../anti-patterns/deterministic-validators.md)
