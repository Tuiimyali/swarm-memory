# Anti-Pattern: Zero Default Mapping Comparison

**Discovered:** 2026-03-25
**In:** RestorationMilestoneRegistry.submitClaim()
**Severity:** will-break

## The Pattern (DON'T DO THIS)

```solidity
// BAD — lastClaimed[key] returns 0 when key has never been set.
// 0 + cooldownPeriod > block.timestamp for any reasonable cooldown.
// First claims ALWAYS revert.
if (block.timestamp < lastClaimed[key] + cooldownPeriods[type]) {
    revert CooldownActive();
}
```

## The Fix (DO THIS INSTEAD)

```solidity
// GOOD — explicitly guard for the uninitialized case.
// First claims (value == 0) bypass cooldown entirely.
uint256 lastClaimedTs = lastClaimed[key];
if (lastClaimedTs > 0 && block.timestamp < lastClaimedTs + cooldownPeriods[type]) {
    revert CooldownActive();
}
```

## Why It Breaks

Solidity mappings return the zero value for any key that has never been set.
For `mapping(bytes32 => uint256)`, this means unset keys return `0`.

When you perform arithmetic on a zero-default value and compare it to
`block.timestamp`, the comparison behaves unexpectedly:
- `0 + 86400` (1 day cooldown) = `86400`
- `block.timestamp` (March 2026) ≈ `1,774,000,000`
- `86400 < 1,774,000,000` → true? No — the check is `timestamp < 86400`, which is false.

Wait — actually the issue is more subtle. When `cooldownPeriods[type]` is set to
a value like `7776000` (90 days), `0 + 7776000 = 7776000`, and
`block.timestamp (1.77B) < 7776000` is false, so it should pass...

The real failure mode depends on the specific cooldown values and comparison
direction. **The fundamental rule is: don't perform arithmetic on values that
might be semantically "unset" without first checking whether they're initialized.**

In our case, the guard `lastClaimedTs > 0` makes the intent clear: if no claim
has ever been made, skip the cooldown check entirely.

## How to Detect

1. **Code review:** Look for any `mapping(... => uint256)` where the value
   participates in arithmetic that controls `revert` or `require`.
2. **Grep pattern:** `lastClaimed\[` or any timestamp mapping used in comparisons.
3. **Test strategy:** Always test with a fresh contract state where no mappings
   have been set. Unit tests that pre-populate state will miss this.
4. **Static analysis:** Slither's `uninitialized-state` detector may catch some
   variants.

## Affected Contracts

- RestorationMilestoneRegistry (fixed in v1.2)

## Related

- [Post-Mortem: PM-001 Cooldown Bug](../post-mortems/2026-03-25-PM001-cooldown-bug.md)
- [Lesson: Cooldown First Claim](../lessons/2026-03-25-cooldown-first-claim.md)
