# Lesson: Cooldown Check Blocks First-Ever Claims

**Date:** 2026-03-25
**Agent:** Solidity Dev Team
**Category:** solidity
**Severity:** important

## What Happened

During Base Sepolia fork deployment, the first-ever milestone claim for any
site/type combination was blocked by the cooldown check in
`RestorationMilestoneRegistry.submitClaim()`.

The cooldown logic checked `block.timestamp < lastClaimed[key] + cooldownPeriods[type]`.
When `lastClaimed[key] == 0` (no prior claim) and `cooldownPeriods[type] > 0`, the
expression `0 + cooldownPeriod` was always greater than the current timestamp, so
the first claim always reverted.

## What We Learned

Solidity mappings return 0 for unset keys. Any arithmetic on a mapping value that
might be uninitialized must guard with `value > 0 &&` before the comparison.

This is a general Solidity gotcha, not specific to cooldowns. Any time you use a
mapping value in a comparison where zero has semantic meaning (like "never set"),
you must explicitly check for the zero case.

**Concrete rule:** Always guard with `lastClaimedTs > 0 &&` before any cooldown
arithmetic on mapping values.

## Applied To

- `RestorationMilestoneRegistry.submitClaim()` — added `lastClaimedTs > 0` guard
- Pseudocode in `contract-specs.md` Section 4 updated
- `sawalmem-solidity` skill v1.2 updated

## Test Added

- `test_FirstClaimAlwaysPassesDespiteCooldown`
- `test_SecondClaimBlockedByCooldown`

## Related

- [Post-Mortem: PM-001 Cooldown Bug](../post-mortems/2026-03-25-PM001-cooldown-bug.md)
- [Anti-Pattern: Zero Default Comparison](../anti-patterns/zero-default-comparison.md)
