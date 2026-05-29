#!/usr/bin/env bash
# Auto-deploy script for docs.sentrixchain.com.
# Triggered by sentrix-labs/docs GitHub Action on push to main.
# Idempotent — safe to re-run.

set -euo pipefail

REPO_DIR="/home/sentriscloud/docs"
WWW_DIR="/var/www/docs-sentrixchain"
LOG_DIR="$HOME/.docs-deploy-logs"

mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/$(date +%Y%m%d-%H%M%S).log"

{
    echo "=== docs deploy $(date -Iseconds) ==="
    cd "$REPO_DIR"

    echo "[1/3] git pull"
    git fetch origin main
    git reset --hard origin/main
    HEAD_SHA=$(git rev-parse --short HEAD)
    echo "    head: $HEAD_SHA"

    echo "[2/3] npm run build"
    npm ci --silent 2>&1 | tail -3
    npm run build 2>&1 | tail -5

    echo "[3/3] rsync to /var/www"
    rsync -a --delete "$REPO_DIR/build/" "$WWW_DIR/"
    BUILT_AT=$(stat -c %y "$WWW_DIR" | awk '{print $1" "$2}')
    echo "    served from: $WWW_DIR (mtime: $BUILT_AT, head: $HEAD_SHA)"

    echo "=== deploy OK ==="
} 2>&1 | tee "$LOG"
