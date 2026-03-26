# Ecosystem State: Solidity Compiler

**Last Updated:** 2026-03-25

## Current Version

| Property | Value |
|----------|-------|
| Latest stable | 0.8.34 (released 2026-02-18) |
| Our pragma | `^0.8.24` |
| Compatible | Yes — 0.8.34 satisfies ^0.8.24 |

## Key Notes

- 0.8.34 is a bugfix release: fixes IR pipeline transient storage clearing.
  We don't use transient storage or `--via-ir` — not affected.
- 0.8.30+ changed EVM default to Prague (Pectra upgrade). Our `foundry.toml`
  uses `cancun` — consider updating to `prague` for EIP-7702 features in Phase 4.
- 0.8.31 began deprecation warnings for: ABI coder v1, virtual modifiers,
  `address.send/transfer`, contract type comparisons. None of these affect our
  contracts (we use custom errors, not send/transfer).

## Upcoming

- **Solidity 0.9.0:** Breaking release expected. Plan migration path when
  timeline is announced. Key changes: removal of deprecated features from 0.8.31+.
- **0.8.35:** In nightly builds. Watch for release.

## Sources

- https://soliditylang.org/blog/category/releases/
- https://github.com/ethereum/solidity/releases
