# Post-Mortem: First-Claim Cooldown Bug

**Date:** 2026-03-25
**ID:** PM-001
**Severity:** medium
**Agent:** Solidity Dev Team

## What Happened

During Base Sepolia fork deployment, the first-ever milestone claim for any
site/type combination was blocked by the cooldown check in
`RestorationMilestoneRegistry.submitClaim()`. The deployment test attempted to
submit the first ecological milestone claim, which reverted unexpectedly.

## Root Cause

`submitClaim()` checked:
```solidity
if (block.timestamp < lastClaimed[key] + cooldownPeriods[type]) revert CooldownActive();
```

When `lastClaimed[key] == 0` (no prior claim exists) and `cooldownPeriods[type] > 0`,
the expression evaluates to `0 + cooldownPeriod`, which is always greater than
`block.timestamp` for any reasonable cooldown value. The first claim at any
milestone/site combination always reverted.

This is a known Solidity gotcha: mappings return 0 for unset keys, and 0 can have
unintended semantic meaning in arithmetic comparisons.

## How It Was Detected

Live deployment testing on forked Base Sepolia. The testnet deployment sequence
attempted to submit the first ecological milestone claim, which reverted.

## Impact

- No funds at risk (testnet deployment)
- No sacred data exposed
- Deployment delay while fix was applied
- All 142 unit tests still passed — the bug was only visible in integration testing
  with a fresh deployment (no pre-existing claims)

## Timeline

| Time | Event |
|------|-------|
| Build phase | 142 unit/fuzz tests pass, including cooldown tests |
| Deploy phase | 5 contracts deployed successfully to forked Base Sepolia |
| Test tx 4 | `submitClaim()` for first ecological milestone — REVERTED |
| Investigation | Root cause identified: zero-default mapping + cooldown arithmetic |
| Fix | Added `lastClaimedTs > 0 &&` guard to cooldown check |
| Re-test | All deployment tests pass, including first-claim scenario |

## Fix Applied

Added a guard to the cooldown check:
```solidity
uint256 lastClaimedTs = lastClaimed[key];
if (lastClaimedTs > 0 && block.timestamp < lastClaimedTs + cooldownPeriods[type]) {
    revert CooldownActive();
}
```

First claims (where `lastClaimedTs == 0`) now bypass the cooldown check entirely.
Subsequent claims enforce cooldown normally.

## Skill Update

- Fixed pseudocode in `contract-specs.md` Section 4
- Added `test_FirstClaimAlwaysPassesDespiteCooldown` to required test patterns
- Added `test_SecondClaimBlockedByCooldown` to required test patterns
- Added deployment integration lessons section
- Skill version bumped to v1.2

## Contracts Affected

- RestorationMilestoneRegistry

## Could This Happen in Other Contracts?

The specific cooldown logic is unique to RestorationMilestoneRegistry. However, the
underlying pattern — performing arithmetic on mapping values that might be
uninitialized (zero) — could occur in any contract using mappings for timestamps
or counters.

Checked:
- MemToken: `_lastActivity` mapping — safe because `balanceOf()` handles the
  zero case (no activity = no decay needed)
- ExternalBountyRegistry: `claimCount` — safe because it's incremented, not
  compared with arithmetic
- AgentWallet: `dailySpent` — safe because it resets on new day, always compared
  against limit

## Lessons for the Swarm

1. Unit tests can miss deployment-state edge cases. Always test against a fresh
   deployment with no pre-existing state.
2. When a mapping value participates in arithmetic that affects control flow,
   always handle the zero/uninitialized case explicitly.
3. The fix is simple: `if (value > 0 && ...)` — but you have to know to look for it.

## Related

- [Lesson: Cooldown First Claim](../lessons/2026-03-25-cooldown-first-claim.md)
- [Anti-Pattern: Zero Default Comparison](../anti-patterns/zero-default-comparison.md)
