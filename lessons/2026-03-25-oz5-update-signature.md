# Lesson: OpenZeppelin 5.x Changed ERC721._update() Signature

**Date:** 2026-03-25
**Agent:** Solidity Dev Team
**Category:** solidity
**Severity:** important

## What Happened

During the initial build of MempucToken (soulbound ERC-721), the override of
`_update()` used the OpenZeppelin 4.x signature:

```solidity
// OZ 4.x signature (WRONG for our stack)
function _update(address from, address to, uint256 tokenId) internal override { ... }
```

This failed to compile because our stack uses OpenZeppelin 5.x, which changed the
signature to:

```solidity
// OZ 5.x signature (CORRECT)
function _update(address to, uint256 tokenId, address auth) internal override returns (address) { ... }
```

In OZ 5.x, the `from` address is retrieved internally via `_ownerOf(tokenId)` inside
`_update()`. The function also returns the previous owner address.

## What We Learned

**Always check the installed OpenZeppelin version before overriding internal hooks.**

The OZ 4.x → 5.x migration changed several internal function signatures. This is
not a deprecated function — it is a complete signature change that will cause
compilation failure, not a runtime bug. The compiler will catch it, but it wastes
time and signals that the agent is working from stale knowledge.

Key differences in OZ 5.x:
- `_update(address to, uint256 tokenId, address auth)` replaces `_beforeTokenTransfer`
- `_update()` returns `address` (previous owner)
- `from` is no longer a parameter — use `_ownerOf(tokenId)` inside the function

## Applied To

- `MempucToken.sol` — uses correct OZ 5.x `_update()` signature
- `sawalmem-solidity` skill contract-specs.md — pseudocode corrected
- Skill v1.2 changelog documents the fix

## Test Added

N/A — this is a compile-time error, caught automatically by the compiler.

## Related

- [Anti-Pattern: OZ5 Update Signature](../anti-patterns/oz5-update-signature.md)
