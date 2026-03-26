# Pattern: Soulbound Transfer Enforcement (ERC-5192)

**Status:** proven
**First Used:** 2026-03-25
**Contracts:** MempucToken

## Intent

Make ERC-721 tokens non-transferable (soulbound) while still allowing minting
(from = address(0)) and governance-gated burning (to = address(0)).

## Structure

```solidity
// ERC-5192: locked() always returns true for all tokens
function locked(uint256 tokenId) external view returns (bool) {
    _requireOwned(tokenId); // Revert if token doesn't exist
    return true; // All Mempuc tokens are permanently locked
}

// Override _update to block transfers (OZ 5.x signature)
function _update(
    address to,
    uint256 tokenId,
    address auth
) internal override returns (address) {
    address from = _ownerOf(tokenId);

    // Allow: mint (from == 0), burn (to == 0)
    // Block: transfer (from != 0 && to != 0)
    if (from != address(0) && to != address(0)) {
        revert SoulboundTransferBlocked();
    }

    return super._update(to, tokenId, auth);
}

// Emit Locked event on every mint per ERC-5192 spec
function _mintMempuc(address to, ...) internal {
    uint256 tokenId = _nextTokenId++;
    _safeMint(to, tokenId);
    emit Locked(tokenId); // ERC-5192 requirement
}
```

## When to Use

- Achievement records that must be permanent and non-tradeable
- Reputation tokens tied to verified work
- Any token where transferability would undermine the system's integrity

## When NOT to Use

- Tokens that need to be tradeable (use standard ERC-721)
- Tokens that might need to change ownership (consider approval-gated transfer)

## Trade-offs

| Pro | Con |
|-----|-----|
| Impossible to trade or sell | Cannot correct minting errors without burn + re-mint |
| Clean ERC-5192 compliance | Marketplaces may not understand `locked()` |
| Simple implementation | Must handle revocation separately (governance-gated burn) |

## Governing Principle Alignment

- **Principle 3 (Value Tracks Real Contribution):** Mempuc records cannot be
  bought or sold — they can only be earned through verified work.
- **Principle 7 (Sovereignty Over Convenience):** Sacred records are permanent.
  MempucToken is deliberately non-upgradeable (ADR-002).

## Tests

- `test_TransferBetweenUsersReverts`
- `test_MintSucceeds`
- `test_GovernanceBurnSucceeds`
- `test_LockedReturnsTrue`
- `test_LockedEmittedOnMint`

## Related

- [Decision: ADR-002 Soulbound Not Upgradeable](../decisions/ADR-002-soulbound-not-upgradeable.md)
- [Anti-Pattern: OZ5 Update Signature](../anti-patterns/oz5-update-signature.md)
