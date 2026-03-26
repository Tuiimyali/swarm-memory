#!/bin/bash
# =============================================================================
# Swarm Ecosystem Check: Verify dependency versions and freshness
# =============================================================================
# Checks ecosystem-state/ files for staleness and known version mismatches.
# Run periodically (weekly) or before any major development task.
#
# Usage: ./scripts/check-ecosystem.sh
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

STALE_DAYS=30
TODAY=$(date -u '+%Y-%m-%d')
WARNINGS=0

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         SWARM ECOSYSTEM CHECK                                ║"
echo "║  Date: $TODAY"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# --- Check each ecosystem state file ---
echo "── Dependency Freshness ──"
for f in ecosystem-state/*.md; do
    [ ! -f "$f" ] && continue
    NAME=$(basename "$f" .md)

    # Extract last updated date
    LAST_UPDATED=$(grep -m1 '^\*\*Last Updated:\*\*' "$f" | grep -oP '\d{4}-\d{2}-\d{2}' || echo "unknown")

    if [ "$LAST_UPDATED" = "unknown" ]; then
        echo "  ⚠️  $NAME: no update date found"
        WARNINGS=$((WARNINGS + 1))
        continue
    fi

    # Calculate days since last update (cross-platform)
    if command -v python3 &> /dev/null; then
        DAYS_AGO=$(python3 -c "
from datetime import datetime
d1 = datetime.strptime('$LAST_UPDATED', '%Y-%m-%d')
d2 = datetime.strptime('$TODAY', '%Y-%m-%d')
print((d2 - d1).days)
" 2>/dev/null || echo "?")
    else
        DAYS_AGO="?"
    fi

    if [ "$DAYS_AGO" != "?" ] && [ "$DAYS_AGO" -gt "$STALE_DAYS" ]; then
        echo "  ⚠️  $NAME: last updated $LAST_UPDATED ($DAYS_AGO days ago — STALE)"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "  ✓  $NAME: last updated $LAST_UPDATED ($DAYS_AGO days ago)"
    fi
done
echo ""

# --- Check for known version mismatches ---
echo "── Version Mismatch Check ──"

# Check OZ version gap
OZ_FILE="ecosystem-state/openzeppelin.md"
if [ -f "$OZ_FILE" ]; then
    INSTALLED=$(grep -oP 'installed version.*?(\d+\.\d+\.\d+)' "$OZ_FILE" | grep -oP '\d+\.\d+\.\d+' || echo "unknown")
    LATEST=$(grep -oP 'Latest stable.*?(\d+\.\d+\.\d+)' "$OZ_FILE" | grep -oP '\d+\.\d+\.\d+' || echo "unknown")
    if [ "$INSTALLED" != "unknown" ] && [ "$LATEST" != "unknown" ] && [ "$INSTALLED" != "$LATEST" ]; then
        echo "  ⚠️  OpenZeppelin: installed $INSTALLED, latest $LATEST — UPGRADE AVAILABLE"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "  ✓  OpenZeppelin: version check passed"
    fi
fi

# Check EVM version alignment
BASE_FILE="ecosystem-state/base-l2.md"
if [ -f "$BASE_FILE" ]; then
    if grep -q 'cancun' "$BASE_FILE" && grep -q 'Prague' "$BASE_FILE"; then
        echo "  ⚠️  Base L2: network is Prague, but foundry.toml may still use cancun"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "  ✓  Base L2: EVM version check passed"
    fi
fi

echo ""

# --- Check regulatory freshness ---
echo "── Regulatory Check ──"
REG_FILE="ecosystem-state/regulatory.md"
if [ -f "$REG_FILE" ]; then
    REG_DATE=$(grep -m1 '^\*\*Last Updated:\*\*' "$REG_FILE" | grep -oP '\d{4}-\d{2}-\d{2}' || echo "unknown")
    if [ "$REG_DATE" != "unknown" ]; then
        if command -v python3 &> /dev/null; then
            REG_DAYS=$(python3 -c "
from datetime import datetime
d1 = datetime.strptime('$REG_DATE', '%Y-%m-%d')
d2 = datetime.strptime('$TODAY', '%Y-%m-%d')
print((d2 - d1).days)
" 2>/dev/null || echo "?")
        else
            REG_DAYS="?"
        fi

        if [ "$REG_DAYS" != "?" ] && [ "$REG_DAYS" -gt 90 ]; then
            echo "  ⚠️  Regulatory: last checked $REG_DATE ($REG_DAYS days — QUARTERLY REVIEW DUE)"
            WARNINGS=$((WARNINGS + 1))
        else
            echo "  ✓  Regulatory: last checked $REG_DATE ($REG_DAYS days ago)"
        fi
    fi
fi
echo ""

# --- Summary ---
echo "╔══════════════════════════════════════════════════════════════╗"
if [ "$WARNINGS" -gt 0 ]; then
    echo "║  ⚠️  $WARNINGS warning(s) found — review before proceeding         ║"
else
    echo "║  ✓  All ecosystem checks passed                              ║"
fi
echo "╚══════════════════════════════════════════════════════════════╝"

exit "$WARNINGS"
