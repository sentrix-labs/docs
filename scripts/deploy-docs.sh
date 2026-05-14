#!/usr/bin/env bash
# deploy-docs.sh — rebuild + deploy docs.sentrixchain.com from latest main.
#
# Run after merging changes to this repo on main. Pulls latest, builds
# Docusaurus, rsyncs to /var/www/docs-sentrixchain/ (Caddy file-serves).
# Idempotent — safe to re-run. ~30s on warm caches.
#
# Repo split out of sentrix-labs/sentrix on 2026-05-14 — used to live at
# sentrix/docs-site/. Caddy/Cloudflare config unchanged.
set -euo pipefail

REPO="${REPO:-$HOME/docs}"
WEB_ROOT="${WEB_ROOT:-/var/www/docs-sentrixchain}"

echo "==> deploy-docs.sh — $(date -Iseconds)"

cd "$REPO"
git fetch origin main
local_head=$(git rev-parse HEAD)
remote_head=$(git rev-parse origin/main)
if [ "$local_head" != "$remote_head" ]; then
    echo "    fast-forwarding $local_head → $remote_head"
    git checkout main
    git pull --ff-only origin main
else
    echo "    already at main HEAD ($local_head)"
fi

if [ ! -d node_modules ] || [ "package-lock.json" -nt "node_modules/.package-lock.json" ]; then
    echo "==> npm install"
    npm install
fi

echo "==> npm run build"
npm run build

echo "==> rsync build/ → $WEB_ROOT/"
sudo rsync -a --delete build/ "$WEB_ROOT/"

echo "==> done. Caddy auto-serves new files."
