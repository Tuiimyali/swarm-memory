# Pattern: 3-of-5 Oracle Consensus with Auto-Execute

**Status:** proven
**First Used:** 2026-03-25
**Contracts:** RestorationMilestoneRegistry

## Intent

Verify ecological restoration milestones through multi-validator consensus,
auto-execute rewards on quorum, and auto-reject when quorum becomes impossible.

## Structure

```solidity
uint256 public constant VALIDATOR_COUNT = 5;
uint256 public constant QUORUM = 3;

struct Claim {
    bytes32 milestoneKey;
    address claimant;
    bytes32 evidenceHash;
    ClaimStatus status;
    uint256 approvalCount;
    uint256 rejectionCount;
    mapping(address => bool) hasVoted;
}

function confirmClaim(uint256 claimId) external onlyValidator notFrozen {
    Claim storage claim = claims[claimId];
    require(!claim.hasVoted[msg.sender], "Already voted");
    require(claim.status == ClaimStatus.Pending, "Not pending");

    // Validator rotation: cannot review same site 2+ consecutive periods
    require(!_isRotationBlocked(msg.sender, claim.milestoneKey), "Rotation block");

    claim.hasVoted[msg.sender] = true;
    claim.approvalCount++;

    if (claim.approvalCount >= QUORUM) {
        claim.status = ClaimStatus.Approved;
        _executeReward(claim);
    }
}

function rejectClaim(uint256 claimId) external onlyValidator notFrozen {
    Claim storage claim = claims[claimId];
    require(!claim.hasVoted[msg.sender], "Already voted");

    claim.hasVoted[msg.sender] = true;
    claim.rejectionCount++;

    // Auto-reject when quorum becomes impossible
    if (claim.rejectionCount > VALIDATOR_COUNT - QUORUM) {
        claim.status = ClaimStatus.Rejected;
    }
}
```

## When to Use

- Multi-party verification of real-world events
- When automatic execution on consensus is needed
- When validator collusion must be mitigated through rotation

## When NOT to Use

- When a single trusted authority is sufficient (e.g., Cultural milestones
  need Chief's sign-off, not oracle consensus)
- When the validator set is dynamic and frequently changing (requires different
  mechanism)

## Trade-offs

| Pro | Con |
|-----|-----|
| No single point of failure | 5 validators must be available |
| Auto-execute reduces latency | Validator rotation adds complexity |
| Auto-reject prevents limbo claims | Small validator set means each vote matters more |

## Governing Principle Alignment

- **Principle 2 (Human Authority):** Validators are humans (or human-supervised
  agents). The kill switch can halt the oracle at any time.
- **Principle 3 (Value Tracks Real Contribution):** Oracle verifies actual
  restoration work before rewards are issued.

## Tests

- `test_QuorumTriggersAutoApproval`
- `test_AutoRejectWhenQuorumImpossible`
- `test_ValidatorCannotVoteTwice`
- `test_ValidatorRotationEnforced`
- `test_FirstClaimAlwaysPassesDespiteCooldown`

## Related

- [Lesson: Cooldown First Claim](../lessons/2026-03-25-cooldown-first-claim.md)
- [Anti-Pattern: Zero Default Comparison](../anti-patterns/zero-default-comparison.md)
