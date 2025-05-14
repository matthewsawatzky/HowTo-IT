#!/bin/bash
# HowTo-IT Managed Command

REPO_URL="https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main"
IDENTIFIER="# HowTo-IT Managed Command"

function info()    { echo -e "ℹ️  $1"; }
function success() { echo -e "✅ $1"; }
function warning() { echo -e "⚠️  $1"; }
function error()   { echo -e "❌ $1"; exit 1; }

SCRIPT_NAME="$(basename "$0")"
INSTALL_PATH="/usr/local/bin/$SCRIPT_NAME"

function is_our_script() {
    grep -q "$IDENTIFIER" "$INSTALL_PATH" 2>/dev/null
}

function install_script() {
    local script="$1"
    local temp="/tmp/$script"
    info "Fetching script: $script"
    curl -sSL "$REPO_URL/$script" -o "$temp" || error "Download failed for $script"
    chmod +x "$temp"
    bash "$temp"
    rm -f "$temp"
    success "$script completed."
}

function remove_self() {
    echo "🗑️  Removing $SCRIPT_NAME..."
    sudo rm -f "$INSTALL_PATH"
    sed -i "/function $SCRIPT_NAME()/,/^}/d" "$HOME/.bashrc"
    success "$SCRIPT_NAME removed. Please 'source ~/.bashrc' to finalize."
    exit 0
}

function update_self() {
    echo "🔄 Updating $SCRIPT_NAME..."
    curl -sSL "$REPO_URL/toit.sh" -o "/tmp/$SCRIPT_NAME" || error "Download failed."
    sed -i "1s|^|$IDENTIFIER\n|" "/tmp/$SCRIPT_NAME"
    sudo mv "/tmp/$SCRIPT_NAME" "$INSTALL_PATH"
    sudo chmod +x "$INSTALL_PATH"
    success "$SCRIPT_NAME updated!"
    exit 0
}

# Main Logic
case "$1" in
    "")
        warning "No script specified. Usage: $SCRIPT_NAME <setup.sh>|update|removeyourself"
        ;;
    removeyourself)
        remove_self
        ;;
    update)
        update_self
        ;;
    *)
        install_script "$1"
        ;;
esac
