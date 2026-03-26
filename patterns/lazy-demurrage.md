# Pattern: Lazy Demurrage

**Status:** proven
**First Used:** 2026-03-25
**Contracts:** MemToken

## Intent

Implement 2% per 30-day epoch decay on idle Mem balances without incurring gas
costs on every block or every balance query across all holders.

## Structure

```solidity
// Store last activity timestamp per account
mapping(address => uint256) private _lastActivity;

// Compute decay lazily — only when balance is queried or transfer occurs
function balanceOf(address account) public view override returns (uint256) {
    uint256 nominal = super.balanceOf(account);
    if (nominal == 0) return 0;

    uint256 lastAct = _lastActivity[account];
    if (lastAct == 0) return nominal; // Never transacted — no decay

    uint256 elapsed = block.timestamp - lastAct;
    if (elapsed <= GRACE_PERIOD) return nominal; // Within 7-day grace

    uint256 epochs = (elapsed - GRACE_PERIOD) / EPOCH_LENGTH;
    if (epochs == 0) return nominal;

    // effectiveBalance = nominal * (0.98 ^ epochs)
    // Use DecayMath library for fixed-point exponentiation
    return DecayMath.applyDecay(nominal, epochs, DECAY_RATE_BPS);
}

// Materialize decay (burn difference) before any transfer
function _update(address from, address to, uint256 amount) internal override {
    if (from != address(0)) {
        _materializeDecay(from); // Burn decayed amount before transfer
    }
    super._update(from, to, amount);
    // Reset activity timestamps
    if (from != address(0)) _lastActivity[from] = block.timestamp;
    if (to != address(0)) _lastActivity[to] = block.timestamp;
}
```

## When to Use

- Demurrage / decay on ERC-20 balances
- Any system where idle balances should decrease over time
- When the number of holders is large and active decay would be gas-prohibitive

## When NOT to Use

- When real-time balance accuracy is critical for external integrations that
  don't call `balanceOf()` (e.g., some DEX AMMs read storage slots directly)
- When the decay formula is too complex for a `view` function (gas limit on reads)

## Trade-offs

| Pro | Con |
|-----|-----|
| Zero gas cost when no one queries | `balanceOf()` is slightly more expensive (computation) |
| No per-block transactions needed | Decay must be materialized before transfers (extra burn step) |
| Scales to unlimited holders | External tools reading raw storage slots see nominal, not effective balance |
| Grace period resets on ANY transaction | Slightly more complex `_update()` override |

## Governing Principle Alignment

- **Principle 1 (Restoration First):** Demurrage incentivizes circulation over hoarding,
  directing Mem toward active restoration work.
- **Principle 4 (Speculation Impossible):** Idle balances decay, making Mem a poor
  vehicle for speculation.
- **Principle 5 (Legibility):** The formula `B * (0.98 ^ epochs)` is simple to explain.

## Tests

- `test_BalanceDecaysAfterGracePeriod`
- `test_NoDecayWithinGracePeriod`
- `test_TransferMaterializesDecay`
- `test_ZeroBalanceNoDecay`
- `test_FuzzDecayMath`

## Related

- [Decision: ADR-001 Lazy Demurrage](../decisions/ADR-001-lazy-demurrage.md)
