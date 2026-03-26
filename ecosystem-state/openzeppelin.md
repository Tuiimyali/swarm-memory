# Ecosystem State: OpenZeppelin Contracts

**Last Updated:** 2026-03-25

## Current Version

| Property | Value |
|----------|-------|
| Latest stable | 5.4.0 |
| Our installed version | 5.1.0 (in initial build) |
| Our spec | 5.x |
| Compatible | Yes — but should upgrade to 5.4.0 for latest fixes |

## Key Notes

- **5.4.0 changes:** Min pragma ^0.8.24 for some contracts (matches our spec).
  Added ERC-7786 cross-chain messaging, ERC-6909 now final, SignerERC7702 renamed
  to SignerEIP7702.
- **Breaking change (4.x → 5.x):** `ERC721._update()` signature changed from
  `(address from, address to, uint256 tokenId)` to
  `(address to, uint256 tokenId, address auth)`. See anti-pattern: oz5-update-signature.
- **Version gap:** Our initial build installed 5.1.0 but the latest is 5.4.0.
  Should update for security fixes and new features.

## Upgrade Path

```bash
# In sawalmem-contracts/
forge update lib/openzeppelin-contracts
# Verify: cat lib/openzeppelin-contracts/package.json | grep version
```

After upgrade, re-run full test suite: `forge test --gas-report`

## Future Watch

- **OpenZeppelin 6.x:** No announcement yet. Monitor for breaking changes.
- **ERC-7786 cross-chain:** May be relevant for Phase 4 partner nation forks.
- **ERC-6909 multi-token:** Could represent multiple Mempuc tiers in single
  contract. Evaluate for MempucToken v2.

## Sources

- https://docs.openzeppelin.com/contracts/5.x
- https://github.com/OpenZeppelin/openzeppelin-contracts/releases
