#!/bin/bash
# =============================================================================
# Swarm Summary Generator: Create a human-readable digest for review
# =============================================================================
# Generates a summary of recent swarm memory activity for human review.
# Output is written to stdout and optionally saved to a file.
#
# Usage: ./scripts/generate-summary.sh [--since YYYY-MM-DD] [--output FILE]
#
# Options:
#   --since    Only include entries after this date (default: 7 days ago)
#   --output   Save summary to file (default: stdout only)
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Parse arguments
SINCE=""
OUTPUT=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --since) SINCE="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Default to 7 days ago
if [ -z "$SINCE" ]; then
    SINCE=$(date -d '7 days ago' '+%Y-%m-%d' 2>/dev/null || date -v-7d '+%Y-%m-%d' 2>/dev/null || echo "2026-03-18")
fi

TODAY=$(date -u '+%Y-%m-%d')

# Start building summary
SUMMARY=""
append() {
    SUMMARY="${SUMMARY}${1}\n"
}

append "# Swarm Memory Digest"
append ""
append "**Period:** $SINCE to $TODAY"
append "**Generated:** $(date -u '+%Y-%m-%d %H:%M UTC')"
append ""

# --- New Lessons ---
append "## New Lessons"
append ""
FOUND=0
for f in lessons/*.md; do
    [ "$f" = "lessons/_template.md" ] && continue
    [ ! -f "$f" ] && continue
    FILE_DATE=$(basename "$f" | grep -oP '^\d{4}-\d{2}-\d{2}' 2>/dev/null || echo "")
    if [ -n "$FILE_DATE" ] && [[ "$FILE_DATE" > "$SINCE" || "$FILE_DATE" == "$SINCE" ]]; then
        FOUND=1
        TITLE=$(grep -m1 '^# Lesson:' "$f" | sed 's/^# Lesson: //' || basename "$f" .md)
        SEVERITY=$(grep -m1 '^\*\*Severity:\*\*' "$f" | sed 's/\*\*Severity:\*\* //' || echo "?")
        CATEGORY=$(grep -m1 '^\*\*Category:\*\*' "$f" | sed 's/\*\*Category:\*\* //' || echo "?")
        append "- **[$SEVERITY]** $TITLE ($CATEGORY) — $FILE_DATE"
    fi
done
[ "$FOUND" -eq 0 ] && append "_(none)_"
append ""

# --- New Post-Mortems ---
append "## New Post-Mortems"
append ""
FOUND=0
for f in post-mortems/*.md; do
    [ "$f" = "post-mortems/_template.md" ] && continue
    [ ! -f "$f" ] && continue
    FILE_DATE=$(basename "$f" | grep -oP '^\d{4}-\d{2}-\d{2}' 2>/dev/null || echo "")
    if [ -n "$FILE_DATE" ] && [[ "$FILE_DATE" > "$SINCE" || "$FILE_DATE" == "$SINCE" ]]; then
        FOUND=1
        TITLE=$(grep -m1 '^# Post-Mortem:' "$f" | sed 's/^# Post-Mortem: //' || basename "$f" .md)
        SEVERITY=$(grep -m1 '^\*\*Severity:\*\*' "$f" | sed 's/\*\*Severity:\*\* //' || echo "?")
        append "- **[$SEVERITY]** $TITLE — $FILE_DATE"
    fi
done
[ "$FOUND" -eq 0 ] && append "_(none)_"
append ""

# --- New Anti-Patterns ---
append "## Anti-Patterns (All Active)"
append ""
FOUND=0
for f in anti-patterns/*.md; do
    [ "$f" = "anti-patterns/_template.md" ] && continue
    [ ! -f "$f" ] && continue
    FOUND=1
    TITLE=$(grep -m1 '^# Anti-Pattern:' "$f" | sed 's/^# Anti-Pattern: //' || basename "$f" .md)
    SEVERITY=$(grep -m1 '^\*\*Severity:\*\*' "$f" | sed 's/\*\*Severity:\*\* //' || echo "?")
    append "- **[$SEVERITY]** $TITLE"
done
[ "$FOUND" -eq 0 ] && append "_(none)_"
append ""

# --- Pending Skill Patches ---
append "## Pending Skill Patches (REQUIRES REVIEW)"
append ""
FOUND=0
if [ -d "skill-patches/pending" ]; then
    for f in skill-patches/pending/*.md; do
        [ ! -f "$f" ] && continue
        FOUND=1
        TITLE=$(grep -m1 '^# Skill Patch:' "$f" | sed 's/^# Skill Patch: //' || basename "$f" .md)
        PRIORITY=$(grep -m1 '^\*\*Priority:\*\*' "$f" | sed 's/\*\*Priority:\*\* //' || echo "?")
        append "- **[$PRIORITY]** $TITLE — AWAITING HUMAN REVIEW"
    done
fi
[ "$FOUND" -eq 0 ] && append "_(none pending)_"
append ""

# --- Ecosystem State ---
append "## Ecosystem State"
append ""
for f in ecosystem-state/*.md; do
    [ ! -f "$f" ] && continue
    NAME=$(basename "$f" .md)
    LAST_UPDATED=$(grep -m1 '^\*\*Last Updated:\*\*' "$f" | grep -oP '\d{4}-\d{2}-\d{2}' || echo "unknown")
    append "- **$NAME:** last updated $LAST_UPDATED"
done
append ""

# --- Statistics ---
TOTAL_LESSONS=$(find lessons/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)
TOTAL_AP=$(find anti-patterns/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)
TOTAL_PATTERNS=$(find patterns/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)
TOTAL_DECISIONS=$(find decisions/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)
TOTAL_PM=$(find post-mortems/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)
TOTAL_GAS=$(find gas-benchmarks/ -name "*.md" ! -name "_template*" 2>/dev/null | wc -l)

append "## Swarm Memory Statistics"
append ""
append "| Category | Count |"
append "|----------|-------|"
append "| Lessons | $TOTAL_LESSONS |"
append "| Post-Mortems | $TOTAL_PM |"
append "| Patterns | $TOTAL_PATTERNS |"
append "| Anti-Patterns | $TOTAL_AP |"
append "| Decisions | $TOTAL_DECISIONS |"
append "| Gas Benchmarks | $TOTAL_GAS |"
append ""
append "---"
append "*Generated by swarm-memory/scripts/generate-summary.sh*"

# --- Output ---
echo -e "$SUMMARY"

if [ -n "$OUTPUT" ]; then
    echo -e "$SUMMARY" > "$OUTPUT"
    echo ""
    echo "(Summary saved to $OUTPUT)"
fi
