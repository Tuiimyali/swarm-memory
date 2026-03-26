# ADR-001: Lazy Demurrage Over Active Decay

**Date:** 2026-03-25
**Status:** accepted
**Deciders:** Solidity Dev Team, Michael Preston (CVO)

## Context

MemToken requires a 2% per 30-day epoch decay on idle balances to incentivize
circulation and prevent hoarding. Two approaches were evaluated:

1. **Active decay:** A keeper or automated process burns decayed tokens periodically
   for every holder.
2. **Lazy decay:** Decay is computed at the point of `balanceOf()` query or transfer,
   using the `_lastActivity` timestamp and compound decay formula.

## Decision

Lazy demurrage. Compute decay at point of balance query, not continuously.

Use `_lastActivity` timestamp per account. Apply formula:
`effectiveBalance = B * (0.98 ^ floor((t - gracePeriod) / epochLength))`

Materialize (burn the difference between nominal and effective) in `_update()`
before any transfer executes.

## Consequences

**Good:**
- Zero gas cost when no queries or transfers occur
- Scales to unlimited holders without per-holder gas costs
- No keeper infrastructure needed
- 7-day grace period resets on ANY transaction (inbound or outbound)

**Bad:**
- `balanceOf()` is more expensive than a standard ERC-20 (computation in view function)
- External tools reading raw storage slots see nominal balance, not effective
- Decay must be materialized before every transfer (extra burn step in `_update()`)
- DecayMath library needed for fixed-point exponentiation by squaring

## Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| Active decay (per-block) | Gas-prohibitive. Would cost gas on every block for every holder. Not viable on any chain. |
| Active decay (periodic keeper) | Requires off-chain infrastructure, adds trust assumption, operational overhead. |
| Snapshot-based decay | Complex to implement, harder to audit, doesn't align with real-time balance queries. |
| No demurrage | Fails Principle 4 (Speculation Impossible). Idle hoarding becomes rational. |

## Governing Principle Alignment

- **Principle 1 (Restoration First):** Demurrage directs Mem toward active use.
- **Principle 4 (Speculation Impossible):** Idle balances lose value.
- **Principle 5 (Legibility):** The formula is one line of math.

## Related

- [Pattern: Lazy Demurrage](../patterns/lazy-demurrage.md)
