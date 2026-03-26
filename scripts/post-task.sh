#!/bin/bash
# =============================================================================
# Swarm Post-Task: Write lessons to shared memory after completing work
# =============================================================================
# Run this after ANY task in the Restoration Swarm.
# It captures what the agent learned and feeds it back into shared memory.
#
# Usage: ./scripts/post-task.sh
#
# Interactive prompts will guide the agent through lesson capture.
# Gas benchmarks and ecosystem state updates are auto-committed.
# Skill patches are routed to pending/ for human review.
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

DATE=$(date -u '+%Y-%m-%d')

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              SWARM MEMORY: Post-Task                         ║"
echo "║  Time: $(date -u '+%Y-%m-%d %H:%M UTC')"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# --- Prompt for lessons ---
echo "Did you learn anything during this task?"
echo ""
echo "Categories:"
echo "  1) lesson          — A new insight or gotcha"
echo "  2) anti-pattern    — Something that breaks (never repeat)"
echo "  3) pattern         — A proven code or process pattern"
echo "  4) post-mortem     — Something went wrong (incident analysis)"
echo "  5) gas-benchmark   — New gas measurements"
echo "  6) decision        — An architecture decision (ADR)"
echo "  7) skill-patch     — Proposed update to an agent skill"
echo "  8) ecosystem-state — Dependency version or regulatory update"
echo "  9) none            — Nothing to report"
echo ""
echo -n "Enter number (or 'none' to skip): "
read -r CHOICE

case "$CHOICE" in
    1|lesson)       CATEGORY="lessons" ;;
    2|anti-pattern) CATEGORY="anti-patterns" ;;
    3|pattern)      CATEGORY="patterns" ;;
    4|post-mortem)  CATEGORY="post-mortems" ;;
    5|gas-benchmark) CATEGORY="gas-benchmarks" ;;
    6|decision)     CATEGORY="decisions" ;;
    7|skill-patch)  CATEGORY="skill-patches" ;;
    8|ecosystem-state) CATEGORY="ecosystem-state" ;;
    9|none)
        echo ""
        echo "No lessons to report. Post-task complete."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo -n "Enter a short title (kebab-case, e.g., lazy-demurrage-edge-case): "
read -r TITLE

if [ -z "$TITLE" ]; then
    echo "Title cannot be empty. Exiting."
    exit 1
fi

# --- Create the file ---
if [ "$CATEGORY" = "skill-patches" ]; then
    FILEPATH="skill-patches/pending/${DATE}-${TITLE}.md"
elif [ "$CATEGORY" = "ecosystem-state" ]; then
    FILEPATH="ecosystem-state/${TITLE}.md"
else
    FILEPATH="${CATEGORY}/${DATE}-${TITLE}.md"
fi

# Copy template if available
TEMPLATE="${CATEGORY}/_template.md"
if [ -f "$TEMPLATE" ]; then
    cp "$TEMPLATE" "$FILEPATH"
    echo ""
    echo "Created: $FILEPATH (from template)"
else
    touch "$FILEPATH"
    echo ""
    echo "Created: $FILEPATH (no template found — write from scratch)"
fi

echo "Edit the file now, then continue."
echo ""

# --- Determine auto-commit eligibility ---
AUTO_COMMIT=false
NEEDS_HUMAN_REVIEW=false

case "$CATEGORY" in
    gas-benchmarks)
        AUTO_COMMIT=true
        echo "This is a gas benchmark — will be auto-committed."
        ;;
    ecosystem-state)
        AUTO_COMMIT=true
        echo "This is an ecosystem state update — will be auto-committed."
        ;;
    skill-patches)
        NEEDS_HUMAN_REVIEW=true
        echo "⚠️  This is a skill patch — requires HUMAN REVIEW before merge."
        echo "   File placed in: skill-patches/pending/"
        echo "   Create a PR with the 'human-review' label."
        ;;
    decisions)
        NEEDS_HUMAN_REVIEW=true
        echo "⚠️  This is an architecture decision — requires HUMAN REVIEW."
        ;;
    *)
        # Lessons, patterns, anti-patterns, post-mortems
        # Check severity for auto-commit eligibility
        echo -n "Is this severity 'critical'? (y/n): "
        read -r IS_CRITICAL
        if [ "$IS_CRITICAL" = "y" ] || [ "$IS_CRITICAL" = "yes" ]; then
            NEEDS_HUMAN_REVIEW=true
            echo "⚠️  Critical severity — requires HUMAN REVIEW."
        else
            AUTO_COMMIT=true
            echo "Non-critical — eligible for auto-commit."
        fi
        ;;
esac

echo ""

# --- Commit and push ---
if [ "$AUTO_COMMIT" = true ]; then
    echo -n "Auto-commit and push? (y/n): "
    read -r CONFIRM
    if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "yes" ]; then
        git add "$FILEPATH"
        git commit -m "swarm: add $CATEGORY — $TITLE [$DATE]"
        git push
        echo ""
        echo "Committed and pushed to shared memory."
    else
        echo "Saved locally. Run the following to share with the swarm:"
        echo "  git add $FILEPATH"
        echo "  git commit -m 'swarm: add $CATEGORY — $TITLE'"
        echo "  git push"
    fi
elif [ "$NEEDS_HUMAN_REVIEW" = true ]; then
    echo "Saved locally. To submit for human review:"
    echo ""
    echo "  git checkout -b swarm/$CATEGORY/$TITLE"
    echo "  git add $FILEPATH"
    echo "  git commit -m 'swarm: propose $CATEGORY — $TITLE'"
    echo "  git push -u origin swarm/$CATEGORY/$TITLE"
    echo "  gh pr create --title 'Swarm: $TITLE' --label human-review"
    echo ""
    echo "The PR will be flagged for human review before merge."
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Post-Task Complete                                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
