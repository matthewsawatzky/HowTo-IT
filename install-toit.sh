#!/bin/bash

SCRIPT_NAME="toit"
ALT_NAME="h2it"
REPO_URL="https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main"
INSTALL_PATH="/usr/local/bin"
IDENTIFIER="# HowTo-IT Managed Command"

# Check if current command is already taken by something else
function is_our_script() {
    grep -q "$IDENTIFIER" "$1" 2>/dev/null
}

if command -v $SCRIPT_NAME >/dev/null && ! is_our_script "$(command -v $SCRIPT_NAME)"; then
    echo "⚠️ The command '$SCRIPT_NAME' is already in use by another program."
    CMD=$ALT_NAME
else
    CMD=$SCRIPT_NAME
fi

DEST="$INSTALL_PATH/$CMD"

echo "⬇️ Installing '$CMD'..."

curl -sSL "$REPO_URL/toit.sh" -o /tmp/$CMD.sh || {
    echo "❌ Failed to download script."
    exit 1
}

# Add identifier to detect our own script later
sed -i "1s|^|$IDENTIFIER\n|" /tmp/$CMD.sh

sudo mv /tmp/$CMD.sh "$DEST"
sudo chmod +x "$DEST"

# Add function to .bashrc
if ! grep -q "function $CMD()" ~/.bashrc; then
    echo "🔧 Adding '$CMD' function to ~/.bashrc..."
    echo -e "\n# $CMD command function\nfunction $CMD() {\n  bash $DEST \"\$@\"\n}" >> ~/.bashrc
    echo "🌀 Run 'source ~/.bashrc' or restart your terminal to activate."
else
    echo "ℹ️ '$CMD' function already exists in ~/.bashrc"
fi

echo "✅ '$CMD' installed and ready!"
