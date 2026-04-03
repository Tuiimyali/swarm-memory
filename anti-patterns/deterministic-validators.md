# Anti-Pattern: Deterministic Validator Addresses on Live Chain

**Discovered:** 2026-04-03
**In:** Testnet deployment — validator registration
**Severity:** will-break (on mainnet if not replaced)

## The Pattern (DON'T DO THIS)

```solidity
// BAD — Deriving validator addresses from keccak256.
// Nobody holds these private keys. They can never vote.
address validator2 = address(uint160(uint256(keccak256("validator2"))));
address validator3 = address(uint160(uint256(keccak256("validator3"))));
registry.setValidator(validator2, true);
registry.setValidator(validator3, true);
```

## The Fix (DO THIS INSTEAD)

```solidity
// GOOD — Use real wallets with known private keys for testnet.
// Use real validator node addresses for mainnet.
address validator2 = vm.envAddress("VALIDATOR_2_ADDRESS");
address validator3 = vm.envAddress("VALIDATOR_3_ADDRESS");
registry.setValidator(validator2, true);
registry.setValidator(validator3, true);
```

## Why It Breaks

Deterministic addresses derived from `keccak256` are valid Ethereum addresses, but
nobody holds the private key. Transactions cannot be sent FROM these addresses. On
testnet, the deployer can register them as validators, but they can never actually
vote. Oracle quorum becomes unreachable.

## How to Detect

In any deployment script: if `setValidator()` is called with an address not sourced
from `.env` or a real wallet, flag it. Grep for:

```
keccak256("validator
```

Any address derived from a human-readable string hash is almost certainly not a
controlled wallet.

## Affected Contracts

- RestorationMilestoneRegistry (Base Sepolia deployment, 2026-04-03)

## Related

- [Lesson: Incomplete Oracle Test](../lessons/2026-04-03-incomplete-oracle-test.md)
- [Pattern: Oracle Consensus](../patterns/oracle-consensus.md)
