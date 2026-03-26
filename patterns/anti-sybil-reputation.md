# Pattern: Anti-Sybil Reputation Gating

**Status:** proven
**First Used:** 2026-03-25
**Contracts:** ExternalBountyRegistry

## Intent

Prevent Sybil attacks (multiple fake identities claiming bounties) by gating
bounty access based on earned reputation. New agents start with low-value bounties
and must build a track record before accessing higher-value work.

## Structure

```solidity
struct AgentReputation {
    uint256 completedBounties;
    uint256 totalEarned;
    uint256 qualityScore;      // Validator-assessed, 0-100
    uint256 firstActiveTime;
    bool banned;
}

mapping(address => AgentReputation) public reputation;

// Reputation tiers determine max bounty value accessible
function getMaxBountyValue(address agent) public view returns (uint256) {
    AgentReputation storage rep = reputation[agent];
    if (rep.banned) return 0;
    if (rep.completedBounties == 0) return LOW_VALUE_THRESHOLD;   // New agents: small bounties only
    if (rep.qualityScore < 50) return LOW_VALUE_THRESHOLD;
    if (rep.completedBounties < 5) return MEDIUM_VALUE_THRESHOLD;
    return HIGH_VALUE_THRESHOLD; // Proven agents: full access
}

function claimBounty(uint256 bountyId, bytes32 evidenceHash) external notFrozen {
    Bounty storage bounty = bounties[bountyId];
    require(bounty.memReward <= getMaxBountyValue(msg.sender), "Reputation too low");
    // ... claim logic
}

// Permanent ban for fraudulent evidence
function banAgent(address agent) external onlyGovernance {
    reputation[agent].banned = true;
    emit AgentBanned(agent, block.timestamp);
}
```

## When to Use

- Open bounty systems where any agent can participate
- When the cost of fraudulent claims exceeds the cost of reputation gating
- Phase 4: when external AI agents join the ecosystem

## When NOT to Use

- Internal-only bounties where all participants are known
- When reputation requirements would block legitimate first-time contributors
  (ensure LOW_VALUE_THRESHOLD bounties are always available)

## Trade-offs

| Pro | Con |
|-----|-----|
| Prevents low-effort Sybil attacks | Legitimate new agents start restricted |
| Quality incentive (validators assess quality) | Requires validator overhead for quality scoring |
| Permanent ban deters fraud | Bans may be too harsh (no appeal path yet) |

## Governing Principle Alignment

- **Principle 3 (Value Tracks Real Contribution):** Reputation is earned through
  work, not purchased or transferred.
- **Principle 1 (Restoration First):** Sybil prevention ensures Mem flows to
  actual restoration work, not gaming.

## Tests

- `test_NewAgentRestrictedToLowValueBounties`
- `test_ProvenAgentAccessesHighValueBounties`
- `test_BannedAgentCannotClaim`
- `test_ReputationIncreasesOnCompletion`

## Related

- [Decision: ADR-004 Pike Rules Adoption](../decisions/ADR-004-pike-rules-adoption.md) — Rule 5 (data dominates): the reputation struct IS the anti-Sybil mechanism
