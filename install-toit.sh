#!/bin/bash

# ---------------------------
# HowTo-IT: install-toit.sh
# Safe installer for `toit` command
# ---------------------------

set -e

TOIT_MARKER="# TOIT_MARKER: HowTo-IT"
TOIT_URL="https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main/toit.sh"
BIN_DIR="/usr/local/bin"
DEFAULT_CMD="toit"
ALT_CMD="h2it"

# Check if a command is one of ours
is_our_script() {
    local cmd_path="$1"
    [[ -f "$cmd_path" ]] && grep -q "$TOIT_MARKER" "$cmd_path"
}

# Install the toit command (or h2it fallback)
install_command() {
    local cmd="$1"
    local dest="$BIN_DIR/$cmd"

    echo "⬇️ Installing or updating '$cmd'..."
    curl -fsSL "$TOIT_URL" -o "/tmp/$cmd.sh"

    if [[ ! -s "/tmp/$cmd.sh" ]]; then
        echo "❌ Failed to download script. Aborting."
        exit 1
    fi

    sudo mv "/tmp/$cmd.sh" "$dest"
    sudo chmod +x "$dest"

    echo "✅ '$cmd' installed to $dest"
}

# Add bash function for fallback if needed
add_function_to_bashrc() {
    local cmd="$1"
    local bin_path="$BIN_DIR/$cmd"
    local bashrc="$HOME/.bashrc"

    if ! grep -q "command -v $cmd" "$bashrc"; then
        echo "🔧 Adding '$cmd' function to ~/.bashrc..."
        echo "" >> "$bashrc"
        echo "# Added by HowTo-IT installer" >> "$bashrc"
        echo "if ! command -v $cmd >/dev/null; then" >> "$bashrc"
        echo "  $cmd() { bash $bin_path \"\$@\"; }" >> "$bashrc"
        echo "fi" >> "$bashrc"
    else
        echo "ℹ️  '$cmd' function already in ~/.bashrc"
    fi

    echo "🌀 Run 'source ~/.bashrc' or restart your terminal to activate."
}

# Start
cmd_to_use="$DEFAULT_CMD"

if command -v "$DEFAULT_CMD" >/dev/null; then
    if ! is_our_script "$(command -v $DEFAULT_CMD)"; then
        echo "⚠️  Another tool already uses '$DEFAULT_CMD'. Switching to '$ALT_CMD'..."
        cmd_to_use="$ALT_CMD"
    else
        echo "🔁 Updating existing HowTo-IT '$DEFAULT_CMD'..."
    fi
fi

install_command "$cmd_to_use"
add_function_to_bashrc "$cmd_to_use"

echo "✅ '$cmd_to_use' is ready to use! Try: $cmd_to_use <script-name>"
