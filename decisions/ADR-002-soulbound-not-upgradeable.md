# ADR-002: MempucToken Is Non-Upgradeable

**Date:** 2026-03-25
**Status:** accepted
**Deciders:** Sawalmem Leadership, Chief Caleen Sisk

## Context

Most Sawalmem contracts use the UUPS proxy pattern for upgradeability (MemToken,
RestorationMilestoneRegistry). The question was whether MempucToken — the sacred
stewardship record — should also be upgradeable.

## Decision

MempucToken is deliberately non-upgradeable. No proxy. No migration path built in.
Sacred records are permanent.

If a new version is needed, deploy a new contract. Old records persist on the
original contract forever. The on-chain record of verified restoration milestones
is immutable.

## Consequences

**Good:**
- Simpler contract (no proxy overhead)
- Smaller attack surface (no upgrade mechanism to exploit)
- Philosophical alignment: sacred records should not change
- Auditors can verify the contract is final
- Strongest possible guarantee to stewards that their records are permanent

**Bad:**
- Cannot fix bugs post-deployment (must deploy new contract)
- Cannot add features (new stewardship tiers, new metadata fields)
- If a critical vulnerability is found, old tokens are on a vulnerable contract
- Migration requires issuing new tokens on a new contract and deprecating the old

## Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| UUPS upgradeable | Introduces the possibility that sacred records could be altered. Even if governance-gated, the capability exists. Conflicts with Principle 7. |
| Beacon proxy | Same upgradeability concern, plus additional complexity. |
| Diamond pattern (EIP-2535) | Over-engineered for a soulbound token. Fails Principle 5 (Legibility). |

## Governing Principle Alignment

- **Principle 7 (Sovereignty Over Convenience):** Permanence over flexibility.
  The inconvenience of deploying a new contract is acceptable if it protects
  the integrity of sacred records.
- **Principle 5 (Legibility):** A non-upgradeable contract is simpler to audit
  and explain.

## Related

- [Pattern: Soulbound Enforcement](../patterns/soulbound-enforcement.md)
