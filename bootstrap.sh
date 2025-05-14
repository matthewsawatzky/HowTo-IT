#!/bin/bash

SCRIPT_NAME="${1}-setup.sh"
REPO_URL="https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main"

if [[ -z "$1" ]]; then
  echo "❌ Usage: $0 <script-name> (e.g., xmrig, pihole)"
  exit 1
fi

echo "📦 Fetching and running $SCRIPT_NAME from HowTo-IT..."

curl -sS "$REPO_URL/$SCRIPT_NAME" -o "/tmp/$SCRIPT_NAME"

if [[ ! -s "/tmp/$SCRIPT_NAME" ]]; then
  echo "❌ Could not fetch script. Check name or repo."
  exit 2
fi

chmod +x "/tmp/$SCRIPT_NAME"
exec "/tmp/$SCRIPT_NAME"
