# ADR-004: Adoption of Rob Pike's 5 Rules of Programming

**Date:** 2026-03-25
**Status:** accepted
**Deciders:** Solidity Dev Team, Michael Preston (CVO)

## Context

The Sawalmem contract suite needed explicit engineering standards beyond the
Seven Governing Principles. The principles govern WHAT to build and WHY; we
needed rules for HOW to write the code. Rob Pike's 5 Rules align with our
principles and provide concrete, memorable guidance.

## Decision

Adopted Rob Pike's 5 Rules of Programming as engineering standards for all
Sawalmem Solidity development, with explicit mappings to Governing Principles.

### The Rules

**Rule 1: You can't tell where a program is going to spend its time.**
Don't add speed hacks until you've proven the bottleneck. In Solidity: no
`unchecked` blocks, assembly, or custom storage layouts until `forge test --gas-report`
proves they're needed.

**Rule 2: Measure. Don't tune for speed until you've measured.**
Run `forge test --gas-report` before and after every optimization. The cooldown
bug was found by testing, not by guessing. Always measure.

**Rule 3: Fancy algorithms are slow when n is small, and n is usually small.**
Validator count = 5. Stewardship tiers = 9. Milestone categories = 6. Use simple
loops, simple mappings, simple comparisons.

**Rule 4: Fancy algorithms are buggier than simple ones.**
Simple code can be explained to tribal elders. Fancy code cannot. This is
Governing Principle 5 (Legibility) expressed as engineering practice.

**Rule 5: Data dominates.**
`mapping(address => uint256) _lastActivity` makes lazy demurrage obvious.
`enum ClaimStatus { Pending, Approved, Rejected, Disputed }` makes the state
machine self-documenting. Get the structs right and the functions write themselves.

### Code Review Application

| Situation | Question to Ask |
|-----------|----------------|
| Someone adds an optimization | "Did you measure?" (Rules 1-2) |
| Someone adds a complex algorithm | "How big is n?" (Rule 3) |
| Someone adds clever code | "Can an elder understand this?" (Rule 4 + Principle 5) |
| Someone struggles with logic | "Are the data structures right?" (Rule 5) |

## Consequences

**Good:**
- Every code review has concrete, memorable criteria
- Rules are language-agnostic but map cleanly to Solidity patterns
- Aligns engineering culture with restoration culture (simplicity, measurement, data)

**Bad:**
- May initially slow development as team internalizes the rules
- "Can an elder understand this?" is subjective (but that's intentional)

## Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| No explicit engineering rules | Principles are too high-level for code review. Need concrete rules. |
| Google/Airbnb style guides | Too generic. Don't align with our cultural context. |
| Custom rules from scratch | Why reinvent? Pike's rules are proven and align naturally. |

## Governing Principle Alignment

- **Rule 4 (simplicity)** = **Principle 5 (Legibility)**
- **Rule 2 (measure)** = **Principle 1 (Restoration First — don't waste effort)**
- **Rule 5 (data dominates)** = **Principle 6 (Ecology IS Economy — get the foundation right)**

## Related

- All patterns and anti-patterns implicitly follow these rules
