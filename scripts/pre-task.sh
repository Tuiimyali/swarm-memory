#!/bin/bash
# =============================================================================
# Swarm Pre-Task: Read shared memory before starting work
# =============================================================================
# Run this before ANY task in the Restoration Swarm.
# It ensures the agent has the latest lessons, anti-patterns, and ecosystem state.
#
# Usage: ./scripts/pre-task.sh [--agent AGENT_NAME] [--category CATEGORY]
#
# Options:
#   --agent      Name of the agent running the task (e.g., solidity, ledger, grants)
#   --category   Filter lessons by category (e.g., solidity, deployment, security)
# =============================================================================

set -euo pipefail

AGENT_NAME="${1:-unknown}"
CATEGORY="${2:-all}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              SWARM MEMORY: Pre-Task Check                    ║"
echo "║  Agent: $AGENT_NAME"
echo "║  Time:  $(date -u '+%Y-%m-%d %H:%M UTC')"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# --- Pull latest shared memory ---
cd "$REPO_ROOT"
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Pulling latest swarm memory..."
    git pull --quiet --rebase 2>/dev/null || echo "  (offline or no remote — using local state)"
    echo ""
fi

# --- Check immutable layer integrity ---
echo "── Immutable Layer ──"
if [ -f "PRINCIPLES.md" ] && [ -f "SOVEREIGNTY.md" ]; then
    echo "  PRINCIPLES.md: present ($(wc -l < PRINCIPLES.md) lines)"
    echo "  SOVEREIGNTY.md: present ($(wc -l < SOVEREIGNTY.md) lines)"
else
    echo "  ⚠️  IMMUTABLE FILES MISSING — DO NOT PROCEED"
    echo "  Pull the repository or restore from backup."
    exit 1
fi
echo ""

# --- Recent lessons (last 7 days) ---
echo "── Recent Lessons (last 7 days) ──"
CUTOFF=$(date -d '7 days ago' '+%Y-%m-%d' 2>/dev/null || date -v-7d '+%Y-%m-%d' 2>/dev/null || echo "2026-03-18")
LESSON_COUNT=0
for f in lessons/*.md; do
    [ "$f" = "lessons/_template.md" ] && continue
    [ ! -f "$f" ] && continue
    # Extract date from filename (YYYY-MM-DD prefix)
    FILE_DATE=$(basename "$f" | grep -oP '^\d{4}-\d{2}-\d{2}' 2>/dev/null || echo "")
    if [ -n "$FILE_DATE" ] && [[ "$FILE_DATE" > "$CUTOFF" || "$FILE_DATE" == "$CUTOFF" ]]; then
        LESSON_COUNT=$((LESSON_COUNT + 1))
        # Extract title and severity
        TITLE=$(grep -m1 '^# Lesson:' "$f" | sed 's/^# Lesson: //' || basename "$f" .md)
        SEVERITY=$(grep -m1 '^\*\*Severity:\*\*' "$f" | sed 's/\*\*Severity:\*\* //' || echo "unknown")
        echo "  [$SEVERITY] $TITLE"
    fi
done
if [ "$LESSON_COUNT" -eq 0 ]; then
    echo "  (no lessons in the last 7 days)"
fi
echo ""

# --- Active anti-patterns ---
echo "── Active Anti-Patterns ──"
AP_COUNT=0
for f in anti-patterns/*.md; do
    [ "$f" = "anti-patterns/_template.md" ] && continue
    [ ! -f "$f" ] && continue
    AP_COUNT=$((AP_COUNT + 1))
    TITLE=$(grep -m1 '^# Anti-Pattern:' "$f" | sed 's/^# Anti-Pattern: //' || basename "$f" .md)
    SEVERITY=$(grep -m1 '^\*\*Severity:\*\*' "$f" | sed 's/\*\*Severity:\*\* //' || echo "unknown")
    echo "  [$SEVERITY] $TITLE"
done
if [ "$AP_COUNT" -eq 0 ]; then
    echo "  (none recorded)"
fi
echo ""

# --- Ecosystem state summary ---
echo "── Ecosystem State ──"
for f in ecosystem-state/*.md; do
    [ ! -f "$f" ] && continue
    NAME=$(basename "$f" .md)
    # Extract the first table row with version info
    VERSION=$(grep -m1 'Latest stable\|Current Version\|Protocol version\|EVM Version\|Token Taxonomy' "$f" | sed 's/.*| //' | sed 's/ |.*//' || echo "see file")
    echo "  $NAME: $(head -3 "$f" | grep -oP '(?<=\*\*Last Updated:\*\* ).*' || echo 'check file')"
done
echo ""

# --- Proven patterns ---
echo "── Proven Patterns ──"
for f in patterns/*.md; do
    [ "$f" = "patterns/_template.md" ] && continue
    [ ! -f "$f" ] && continue
    TITLE=$(grep -m1 '^# Pattern:' "$f" | sed 's/^# Pattern: //' || basename "$f" .md)
    STATUS=$(grep -m1 '^\*\*Status:\*\*' "$f" | sed 's/\*\*Status:\*\* //' || echo "unknown")
    echo "  [$STATUS] $TITLE"
done
echo ""

# --- Architecture decisions ---
echo "── Architecture Decisions ──"
for f in decisions/*.md; do
    [ "$f" = "decisions/_template.md" ] && continue
    [ ! -f "$f" ] && continue
    TITLE=$(grep -m1 '^# ADR-' "$f" | sed 's/^# //' || basename "$f" .md)
    STATUS=$(grep -m1 '^\*\*Status:\*\*' "$f" | sed 's/\*\*Status:\*\* //' || echo "unknown")
    echo "  [$STATUS] $TITLE"
done
echo ""

# --- Pending skill patches ---
echo "── Pending Skill Patches ──"
PATCH_COUNT=0
if [ -d "skill-patches/pending" ]; then
    for f in skill-patches/pending/*.md; do
        [ ! -f "$f" ] && continue
        PATCH_COUNT=$((PATCH_COUNT + 1))
        TITLE=$(grep -m1 '^# Skill Patch:' "$f" | sed 's/^# Skill Patch: //' || basename "$f" .md)
        echo "  ⏳ $TITLE"
    done
fi
if [ "$PATCH_COUNT" -eq 0 ]; then
    echo "  (none pending)"
fi
echo ""

# --- Summary ---
TOTAL_LESSONS=$(find lessons/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)
TOTAL_AP=$(find anti-patterns/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)
TOTAL_PATTERNS=$(find patterns/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)
TOTAL_DECISIONS=$(find decisions/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)
TOTAL_PM=$(find post-mortems/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Swarm Memory Summary                                        ║"
echo "║  Lessons: $TOTAL_LESSONS  |  Anti-Patterns: $TOTAL_AP  |  Patterns: $TOTAL_PATTERNS"
echo "║  Decisions: $TOTAL_DECISIONS  |  Post-Mortems: $TOTAL_PM  |  Patches Pending: $PATCH_COUNT"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Pre-task check complete. Proceed with work."
