#!/bin/bash
set -e

echo "🛑 Checking for stuck GitHub Actions jobs..."

if ! gh auth status &>/dev/null; then
    echo "❌ Error: Not authenticated with GitHub CLI. Run 'gh auth login' first."
    exit 1
fi

# Updated to use strictly valid GitHub CLI API statuses
for STATUS in queued requested waiting in_progress; do
    echo "Scanning for $STATUS runs..."
    
    # Check if there are any runs in this status first
    RUNS=$(gh run list --status $STATUS --json databaseId -q '.[].databaseId')
    
    if [ -z "$RUNS" ]; then
        echo "   No $STATUS runs found."
        continue
    fi

    for RUN_ID in $RUNS; do 
        echo "   Canceling Run: $RUN_ID"
        gh run cancel $RUN_ID || echo "   ⚠️ Failed to cancel $RUN_ID"
    done
done

echo "✅ All stuck jobs canceled."
