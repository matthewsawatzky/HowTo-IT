#!/bin/bash

set -e

INSTALL_PATH="/usr/local/bin"
REPO_URL="https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main"
IDENTIFIER="# HowTo-IT Managed Command"

echo "⬇️ Installing 'toit'..."

# Detect if 'toit' is already in use by another tool
if command -v toit >/dev/null && ! grep -q "$IDENTIFIER" "$(command -v toit)"; then
    echo "⚠️  'toit' command already exists and is not ours. Installing as 'h2it' instead."
    TARGET="h2it"
else
    TARGET="toit"
fi

# Download and install the actual dispatcher script
curl -sSL "$REPO_URL/toit.sh" -o "/tmp/$TARGET"
sed -i "1s|^|$IDENTIFIER\n|" "/tmp/$TARGET"
sudo mv "/tmp/$TARGET" "$INSTALL_PATH/$TARGET"
sudo chmod +x "$INSTALL_PATH/$TARGET"

echo "🔧 Adding '$TARGET' function to ~/.bashrc..."

if ! grep -q "function $TARGET()" "$HOME/.bashrc"; then
  echo -e "\nfunction $TARGET() {\n  $INSTALL_PATH/$TARGET \"\$@\"\n}" >> "$HOME/.bashrc"
fi

echo "🌀 Run 'source ~/.bashrc' or restart your terminal to activate."
echo "✅ '$TARGET' installed and ready!"
