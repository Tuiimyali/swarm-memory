# Swarm Memory

**The shared brain of the Sawalmem Restoration Swarm.**

Every agent reads this repository before starting work. Every agent writes to it
after completing work. The knowledge compounds. The restoration accelerates.

---

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    SHARED MEMORY                         │
│              (this repository)                           │
│                                                          │
│  lessons/           — What the swarm has learned         │
│  post-mortems/      — What went wrong and why            │
│  patterns/          — Proven code patterns               │
│  anti-patterns/     — Things that break (never repeat)   │
│  ecosystem-state/   — Current dependency versions        │
│  gas-benchmarks/    — Historical gas costs per function  │
│  decisions/         — Architecture decisions + rationale │
│  skill-patches/     — Proposed updates to agent skills   │
│                                                          │
│  [IMMUTABLE — cannot be modified by agents]              │
│  PRINCIPLES.md      — The 7 Governing Principles         │
│  SOVEREIGNTY.md     — Kill switch, cultural safeguards   │
└─────────────────┬───────────────────────────────────────┘
                  │
        ┌─────────┴──────────┐
        │   READ on start    │
        │   WRITE on finish  │
        ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Agent A    │    │   Agent B    │    │   Agent C    │
│  (Solidity)  │    │  (Ledger)    │    │  (Grants)    │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       └───────────┬───────┴───────────────────┘
                   ▼
         ┌─────────────────┐
         │  REVIEW GATE    │
         │  (Human-in-loop)│
         │                 │
         │ Auto-approved:  │
         │  - Gas data     │
         │  - Dep versions │
         │  - Non-critical │
         │    lessons      │
         │                 │
         │ Requires human: │
         │  - Skill patches│
         │  - New patterns │
         │  - Architecture │
         │    decisions    │
         │  - Anything     │
         │    touching     │
         │    principles   │
         └─────────────────┘
```

## The Cycle

1. **Before a task:** Agent runs `scripts/pre-task.sh`. Sees recent lessons,
   active anti-patterns, ecosystem state. This context prevents repeating known
   mistakes.

2. **During a task:** Agent encounters something new — a gas optimization, a
   deployment quirk, a regulatory update. Notes it for post-task.

3. **After a task:** Agent runs `scripts/post-task.sh`. Creates a lesson,
   anti-pattern, or gas benchmark. If it proposes a skill change, it goes to
   `skill-patches/pending/` for human review.

4. **Periodically:** A human reviews pending skill patches. Approved patches
   are merged and agent skills are updated with the new knowledge. The skill
   is re-uploaded to every agent platform.

The swarm gets smarter every cycle. Not by magic — by the disciplined
accumulation of verified lessons, the way the watershed gets healthier by the
disciplined accumulation of restored habitat.

---

## Repository Structure

```
swarm-memory/
├── README.md                    ← You are here
├── PRINCIPLES.md                ← IMMUTABLE: The 7 Governing Principles
├── SOVEREIGNTY.md               ← IMMUTABLE: Kill switch, cultural safeguards
├── lessons/                     ← What the swarm has learned
│   ├── _template.md
│   └── YYYY-MM-DD-title.md
├── post-mortems/                ← What went wrong and why
│   ├── _template.md
│   └── YYYY-MM-DD-PMNNN-title.md
├── patterns/                    ← Proven code and process patterns
│   ├── _template.md
│   └── pattern-name.md
├── anti-patterns/               ← Things that break (never repeat)
│   ├── _template.md
│   └── anti-pattern-name.md
├── ecosystem-state/             ← Current dependency versions
│   ├── solidity.md
│   ├── openzeppelin.md
│   ├── x402.md
│   ├── base-l2.md
│   └── regulatory.md
├── gas-benchmarks/              ← Historical gas costs
│   ├── _template.md
│   └── YYYY-MM-DD-title.md
├── decisions/                   ← Architecture Decision Records
│   ├── _template.md
│   └── ADR-NNN-title.md
├── skill-patches/               ← Proposed updates to agent skills
│   ├── _template.md
│   └── pending/                 ← Awaiting human review
├── scripts/
│   ├── pre-task.sh              ← Agent reads memory before work
│   ├── post-task.sh             ← Agent writes lesson after work
│   ├── check-ecosystem.sh       ← Checks dependency versions
│   └── generate-summary.sh      ← Creates digest for human review
└── .github/
    ├── CODEOWNERS               ← Protected file ownership
    └── workflows/
        ├── auto-approve.yml     ← Auto-merges gas data, dep checks
        └── human-review.yml     ← Flags skill patches for approval
```

---

## Review Gates

### Auto-Approved (No Human Required)

These changes are merged automatically because they carry low risk:

- **Gas benchmarks** — Measurement data, no logic changes
- **Ecosystem state updates** — Version numbers and compatibility notes
- **Non-critical lessons** — New insights that don't affect architecture
- **Post-mortems** — Incident analysis (informational)

### Human Review Required

These changes affect how agents think and build:

- **Skill patches** — Changes to agent skills (how the swarm builds contracts)
- **New patterns** — Proposed standard approaches
- **Architecture decisions** — ADRs that shape system design
- **New anti-patterns** — Patterns to avoid
- **Critical-severity lessons** — Lessons that may require architectural changes

### Auto-Rejected (Constitutional Protection)

These changes are blocked unless explicitly authorized:

- **PRINCIPLES.md** — The 7 Governing Principles. Requires `leadership-approved`
  label + 2 CODEOWNER approvals.
- **SOVEREIGNTY.md** — Kill switch and cultural safeguards. Same protection.

These files are constitutional. They define what the swarm is and what it cannot
become. No agent, no automation, no process can modify them without human
leadership authorization.

---

## Scripts

### `scripts/pre-task.sh`

Run before starting any work. Outputs:
- Recent lessons (last 7 days)
- All active anti-patterns
- Ecosystem state summary
- Proven patterns
- Architecture decisions
- Pending skill patches

```bash
./scripts/pre-task.sh solidity
```

### `scripts/post-task.sh`

Run after completing work. Interactive prompts guide lesson capture:
- Lessons, anti-patterns, patterns → routed by severity
- Gas benchmarks, ecosystem state → auto-committed
- Skill patches, decisions → routed to human review

```bash
./scripts/post-task.sh
```

### `scripts/check-ecosystem.sh`

Checks dependency freshness and version mismatches:

```bash
./scripts/check-ecosystem.sh
# Exit code = number of warnings (0 = all clear)
```

### `scripts/generate-summary.sh`

Creates a human-readable digest for review:

```bash
./scripts/generate-summary.sh --since 2026-03-20 --output digest.md
```

---

## For AI Agents

If you are an AI agent in the Sawalmem Restoration Swarm:

1. **Before every task:** Read this repository. At minimum:
   - All files in `anti-patterns/` (things that will break your work)
   - Recent files in `lessons/` (what the swarm recently learned)
   - The relevant `ecosystem-state/` files for your domain
   - Any `decisions/` that affect your task

2. **After every task:** Ask yourself:
   - Did I learn something the swarm should know?
   - Did something break that should be documented?
   - Did I discover a pattern that others should use?
   - Should an agent skill be updated?

3. **Never modify:**
   - `PRINCIPLES.md` — The 7 Governing Principles are constitutional
   - `SOVEREIGNTY.md` — Kill switch and cultural safeguards are constitutional

4. **Always remember:**
   - The living ecology is the economy. Your code serves the salmon, the springs,
     the mountains.
   - Human authority supersedes contract logic. The kill switch is always available.
   - Simple code that an elder can understand beats clever code that only you can.

---

## Immutable Principles

The 7 Governing Principles (see `PRINCIPLES.md`):

1. **Restoration First** — The contracts serve ecological recovery
2. **Human Authority Above Contract Logic** — Kill switch always available
3. **Value Tracks Real Contribution** — Rewards map to actual work
4. **Speculation Is Structurally Impossible** — Architecture prevents hoarding
5. **Legibility** — Code must be explainable to tribal elders
6. **The Living Ecology Is the Economy** — Salmon, springs, mountains = the real economy
7. **Sovereignty Over Convenience** — Permanence over speed

These are not guidelines. They are constitutional. They define what the swarm is
and what it will never become.

---

*SAWALMEM — Protecting Salmon · Sustaining Sacred Sites · Upholding Our Traditions*

*sawalmem.earth*
