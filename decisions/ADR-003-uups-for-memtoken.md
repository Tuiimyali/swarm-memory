# ADR-003: UUPS Proxy for MemToken

**Date:** 2026-03-25
**Status:** accepted
**Deciders:** Solidity Dev Team, Michael Preston (CVO)

## Context

MemToken is the core ERC-20 restoration currency. It has complex mechanics
(lazy demurrage, exemption mappings, bonus multipliers, campaign tranches) that
may need refinement as the ecosystem grows from Phase 1 through Phase 4. Unlike
MempucToken (sacred records), MemToken represents a circulating utility — its
behavior may legitimately need upgrading.

## Decision

Use UUPS (Universal Upgradeable Proxy Standard, EIP-1822) for MemToken. The
proxy owner is the Gnosis Safe multi-sig (2-of-3).

Also apply UUPS to RestorationMilestoneRegistry, as oracle consensus parameters
and verification pathways may evolve.

Do NOT apply UUPS to MempucToken (ADR-002), ExternalBountyRegistry (simple enough
to redeploy), or AgentWallet (each wallet is independently deployed).

## Consequences

**Good:**
- Can refine demurrage parameters without migrating all balances
- Can add new features (new exemption types, new earning multipliers) as phases progress
- Upgrade is governance-gated (multi-sig only)
- UUPS is gas-efficient (logic in implementation, not proxy)

**Bad:**
- Upgrade mechanism is an attack surface (compromised multi-sig could push malicious upgrade)
- More complex deployment (proxy + implementation)
- Must preserve storage layout across upgrades (no reordering state variables)
- Kill switch must work on BOTH proxy and implementation

## Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| No upgradeability | Too risky for a complex contract in Phase 1. Redeployment would require migrating all balances. |
| Transparent proxy | Higher gas per call (admin slot check on every call). UUPS is more efficient. |
| Diamond (EIP-2535) | Over-engineered. Fails Principle 5 (Legibility). |

## Governing Principle Alignment

- **Principle 2 (Human Authority):** Upgrade requires multi-sig. Kill switch
  stops upgrades if needed.
- **Principle 5 (Legibility):** UUPS is well-documented and widely understood.
- **Principle 7 (Sovereignty Over Convenience):** Upgradeability is a deliberate
  choice, not a default. Only applied where justified.

## Related

- [ADR-002: Soulbound Not Upgradeable](ADR-002-soulbound-not-upgradeable.md) — Contrasting decision
