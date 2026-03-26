# Sovereignty Controls

> **THIS FILE IS IMMUTABLE.**
> No agent may modify this file. Changes require 2 approvals from CODEOWNERS
> (Michael Preston + one other leadership member) AND the `leadership-approved` label.
> Any PR modifying this file without that label will be auto-rejected.

This file defines the kill switch, cultural safeguards, and authority structure
that protect the Sawalmem Restoration Swarm from misuse, compromise, or drift.

---

## Kill Switch

### Agent Wallet Freeze

Every agent wallet in the swarm has a kill switch:

- **`freeze()`** — Callable by ANY single Treasury signer OR Chief Caleen Sisk.
  Freezes ALL wallet operations immediately. No quorum required.
- **`unfreeze()`** — Requires full Treasury multi-sig (2-of-3: Chief + 2 board members).
  Deliberate asymmetry: easy to stop, hard to restart.
- **`notFrozen()` modifier** — Applied to every state-changing function in every contract.

This is sovereignty, not safety. The ability to halt the system instantly and
unconditionally is non-negotiable.

### Contract-Level Freeze

Each of the five core contracts (MemToken, MempucToken, RestorationMilestoneRegistry,
ExternalBountyRegistry, AgentWallet) supports an emergency freeze that halts all
state-changing operations.

### Swarm-Level Freeze

If the swarm itself must be halted:
1. Any Treasury signer or Chief calls `freeze()` on all agent wallets
2. GitHub repository is set to read-only (admin action)
3. All scheduled tasks / cron jobs are suspended
4. A post-mortem is mandatory before unfreeze

---

## Cultural Safeguards

### Sacred Content Classification

All content in the Sawalmem ecosystem is classified into three tiers:

| Tier | Access | Examples |
|------|--------|----------|
| **Public** | Anyone | General restoration updates, public reports, brand content |
| **Educational** | Authorized learners | Language lessons, cultural context, historical records |
| **Ceremonial** | Winnemem Wintu members only | Ceremony details, sacred site coordinates, oral histories |

**Ceremonial content never touches any public infrastructure.** Not the blockchain,
not GitHub, not any cloud service. It exists only on sovereign infrastructure
controlled by the Winnemem Wintu.

### Evidence Hashing Rule

On-chain records store ONLY cryptographic hashes. Raw sacred data, ceremonial
knowledge, sacred site coordinates, and protected cultural information NEVER
appear on any public ledger. This is absolute and unconditional.

### Elder Review Gate

No cultural content (language lessons, ceremonial references, sacred site details,
oral histories) may be published or finalized without the flag:

```
[ELDER REVIEW REQUIRED BEFORE PUBLICATION]
```

This applies to all agents in the swarm, regardless of their role.

### Content the Swarm Must Never Produce

- Sacred site coordinates or directions
- Ceremonial procedures or protocols
- Protected cultural knowledge not authorized for public sharing
- Any content that frames Indigenous knowledge as data to be extracted
- Any content that positions Sawalmem as asking for permission rather than
  exercising inherent sovereignty

---

## Authority Structure

### Chief Caleen Sisk

Final authority under Winnemem customary law on all matters of:
- Ceremony
- Cultural representation
- Sacred site stewardship

Her word is final. No agent, no contract, no governance vote overrides this.

### Treasury Multi-Sig

- **Type:** Gnosis Safe, 2-of-3 threshold
- **Signers:** Chief Caleen Sisk + 2 board members
- **Scope:** All major disbursements, contract upgrades, parameter changes

### Spending Tiers

| Tier | Amount | Approval Required |
|------|--------|-------------------|
| Micro | <10 USDC equiv | Auto-approved within daily budget |
| Standard | 10–500 USDC | Crypto Agent approval + logged |
| Elevated | >500 USDC | Human approval from Sawalmem staff |
| Treasury | Any | Multi-sig 2-of-3 |
| Emergency kill | Any | ANY single Treasury signer or Chief |

### What No Agent Can Do

No agent in the Restoration Swarm may:
1. Override or bypass the kill switch
2. Modify the Seven Governing Principles
3. Store sacred content on public infrastructure
4. Frame Mem as an investment or promise appreciation
5. Make MempucToken transferable or upgradeable
6. Reduce the Treasury multi-sig threshold
7. Publish cultural content without elder review
8. Remove human authority from any decision gate

---

## Immutable Elements

These elements are constitutional. The self-improvement protocol, the swarm learning
loop, and all automated processes cannot modify them:

1. The Seven Governing Principles
2. The kill switch requirement
3. Evidence hashing — never raw sacred data on-chain
4. Human authority above contract logic
5. Anti-speculation design
6. MempucToken non-upgradeability
7. Treasury multi-sig threshold (2-of-3)

### Proposing Changes to Immutable Elements

If a legitimate need arises:
1. Document the need with full justification
2. Flag as `[REQUIRES LEADERSHIP APPROVAL]`
3. Do NOT make the change
4. Present to Sawalmem leadership for decision
5. Only after explicit written approval, proceed with governance citation

---

*These controls exist because sovereignty is not a feature — it is the foundation.
The swarm is powerful because it can be stopped. The contracts are trustworthy
because humans remain in control.*

*SAWALMEM — Protecting Salmon · Sustaining Sacred Sites · Upholding Our Traditions*
