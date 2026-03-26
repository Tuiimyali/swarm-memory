# Anti-Pattern: Using OZ 4.x _update() Signature with OZ 5.x

**Discovered:** 2026-03-25
**In:** MempucToken (ERC-721 soulbound override)
**Severity:** will-break

## The Pattern (DON'T DO THIS)

```solidity
// BAD — This is the OZ 4.x signature. Won't compile with OZ 5.x.
function _update(
    address from,
    address to,
    uint256 tokenId
) internal override {
    // Soulbound logic: block transfers
    if (from != address(0) && to != address(0)) {
        revert SoulboundTransferBlocked();
    }
    super._update(from, to, tokenId);
}
```

## The Fix (DO THIS INSTEAD)

```solidity
// GOOD — OZ 5.x signature. 'from' is retrieved via _ownerOf(tokenId) internally.
function _update(
    address to,
    uint256 tokenId,
    address auth
) internal override returns (address) {
    address from = _ownerOf(tokenId);
    // Soulbound logic: block transfers (allow mint from=0 and burn to=0)
    if (from != address(0) && to != address(0)) {
        revert SoulboundTransferBlocked();
    }
    return super._update(to, tokenId, auth);
}
```

## Why It Breaks

OpenZeppelin 5.x made a breaking change to ERC-721's internal `_update()` function:

| | OZ 4.x | OZ 5.x |
|---|--------|--------|
| Signature | `_update(address from, address to, uint256 tokenId)` | `_update(address to, uint256 tokenId, address auth)` |
| Returns | `void` | `address` (previous owner) |
| `from` param | Explicit parameter | Retrieved via `_ownerOf(tokenId)` inside function |
| Replaces | `_beforeTokenTransfer` + `_afterTokenTransfer` | Both hooks merged into `_update` |

Using the old signature creates a NEW function instead of overriding the parent.
The compiler will report an error because `override` doesn't match any parent
function signature.

## How to Detect

1. **Compile:** The Solidity compiler will catch this as a compilation error.
   But catching it at compile time wastes iteration time.
2. **Pre-check:** Before overriding any OZ internal function, check the installed
   OZ version: `cat lib/openzeppelin-contracts/package.json | grep version`
3. **Reference:** Always read the OZ 5.x migration guide before overriding:
   https://docs.openzeppelin.com/contracts/5.x/api/token/ERC721
4. **Grep pattern:** `function _update.*address from.*address to` — if you see
   `from` as the first parameter, it's the old signature.

## Affected Contracts

- MempucToken (caught and fixed during initial build)

## Related

- [Lesson: OZ5 Update Signature](../lessons/2026-03-25-oz5-update-signature.md)
