#!/bin/bash
# Auto daily commit script for daily-dev-log
# Generates a daily log entry and pushes to GitHub

REPO_DIR="/home/ubuntu/daily-dev-log"
LOG_FILE="$REPO_DIR/log.md"
DATE=$(date +"%Y-%m-%d")
DAY=$(date +"%A")
TIME=$(date +"%H:%M:%S %Z")

cd "$REPO_DIR" || exit 1

# Pull latest (in case of remote changes)
git pull --rebase 2>/dev/null

# Generate daily entry
cat >> "$LOG_FILE" << EOF

## $DATE — $DAY

- Session started at $TIME
- Automated commit #$(wc -l < "$LOG_FILE" 2>/dev/null || echo 1)
- System uptime: $(uptime -p 2>/dev/null || echo 'N/A')
- Active services: $(pm2 list 2>/dev/null | grep -c online || echo 'N/A')

> $(curl -s "https://zenquotes.io/api/today" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['q'])" 2>/dev/null || echo "Keep building.")

---
EOF

# Also update README with last updated
cat > "$REPO_DIR/README.md" << EOF
# daily-dev-log

Automated daily development log. Updated daily via cron.

**Last updated:** $DATE $TIME

**Total entries:** $(grep -c "^## " "$LOG_FILE" 2>/dev/null || echo 0)
EOF

# Git operations
git add -A
git commit -m "daily: $DATE" --quiet
git push origin main 2>&1

echo "[$DATE $TIME] Commit pushed successfully"
