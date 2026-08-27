#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: ./scripts/save-day.sh \"Day 2: MVP scaffold\""
  exit 1
fi

message="$1"

git add .
git commit -m "$message"

echo "Committed: $message"
echo "If origin is configured, run: git push"
