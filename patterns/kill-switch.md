# Pattern: Asymmetric Kill Switch

**Status:** proven
**First Used:** 2026-03-25
**Contracts:** MemToken, MempucToken, RestorationMilestoneRegistry, ExternalBountyRegistry, AgentWallet

## Intent

Allow any single authorized party to halt all operations instantly, but require
full multi-sig consensus to resume. This asymmetry ensures the system can always
be stopped — sovereignty over convenience.

## Structure

```solidity
bool public frozen;

modifier notFrozen() {
    if (frozen) revert ContractFrozen();
    _;
}

/// @notice Freeze all operations. Callable by ANY Treasury signer or Chief.
/// @dev Easy to stop — sovereignty requires it.
function freeze() external {
    if (!isTreasurySigner(msg.sender) && msg.sender != chief) {
        revert NotAuthorized();
    }
    frozen = true;
    emit Frozen(msg.sender, block.timestamp);
}

/// @notice Unfreeze operations. Requires full Treasury multi-sig.
/// @dev Hard to restart — deliberate asymmetry.
function unfreeze() external onlyOwner {
    // onlyOwner = Gnosis Safe multi-sig (2-of-3)
    frozen = false;
    emit Unfrozen(msg.sender, block.timestamp);
}
```

Apply `notFrozen` to every state-changing function:

```solidity
function mint(address to, uint256 amount) external onlyMinter notFrozen { ... }
function transfer(address to, uint256 amount) public override notFrozen returns (bool) { ... }
function submitClaim(...) external onlyValidator notFrozen { ... }
function claimBounty(...) external notFrozen { ... }
function executeX402Payment(...) external notFrozen { ... }
```

## When to Use

- Every contract in the Sawalmem ecosystem (non-negotiable)
- Any system where human authority must supersede contract logic

## When NOT to Use

- Never. This pattern is constitutional. See SOVEREIGNTY.md.

## Trade-offs

| Pro | Con |
|-----|-----|
| Any single signer can halt everything | Freeze can be triggered accidentally |
| Full multi-sig required to resume (safety) | Unfreezing takes time (by design) |
| Simple to implement and audit | Every function needs the modifier |

## Governing Principle Alignment

- **Principle 2 (Human Authority Above Contract Logic):** This IS the principle
  made concrete. The kill switch is the most important pattern in the system.
- **Principle 7 (Sovereignty Over Convenience):** Easy to stop, hard to restart.
  This is sovereignty, not safety.

## Tests

- `test_FreezeByTreasurySigner`
- `test_FreezeByChief`
- `test_FreezeBlocksAllOperations`
- `test_UnfreezeRequiresMultiSig`
- `test_UnauthorizedCannotFreeze`
- `test_UnauthorizedCannotUnfreeze`

## Related

- [SOVEREIGNTY.md](../SOVEREIGNTY.md) — Kill switch specification
- [PRINCIPLES.md](../PRINCIPLES.md) — Principle 2
