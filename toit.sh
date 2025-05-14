#!/bin/bash
# HowTo-IT Managed Command

REPO_URL="https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="$(basename "$0")"
IDENTIFIER="# HowTo-IT Managed Command"

function info() { echo -e "ℹ️  $1"; }
function success() { echo -e "✅ $1"; }
function warning() { echo -e "⚠️  $1"; }
function error() { echo -e "❌ $1"; exit 1; }

# Ensure script is run as root (for install/remove ops)
function check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "You must run this script as root or with sudo."
    fi
}

# Check if the current script is our managed version
function is_our_script() {
    grep -q "$IDENTIFIER" "$0" 2>/dev/null
}

# Install a script from the repo
function install_script() {
    local script="$1"
    local tmpfile="/tmp/$script"

    info "Downloading $script..."
    curl -sSL "$REPO_URL/$script" -o "$tmpfile" || error "Download failed for $script"

    chmod +x "$tmpfile"
    bash "$tmpfile"
    rm -f "$tmpfile"
    success "$script ran successfully."
}

# Self-removal
function remove_self() {
    check_root
    echo "🗑️  Removing '$SCRIPT_NAME' from $INSTALL_DIR..."
    rm -f "$INSTALL_DIR/$SCRIPT_NAME"

    # Remove bashrc entry
    sed -i "/function $SCRIPT_NAME()/,/^}/d" "$HOME/.bashrc"
    success "'$SCRIPT_NAME' and related config have been removed."
    exit 0
}

# Self-update
function update_self() {
    check_root
    echo "🔄 Updating '$SCRIPT_NAME'..."

    curl -sSL "$REPO_URL/toit.sh" -o "/tmp/$SCRIPT_NAME" || error "Failed to download update."
    sed -i "1s|^|$IDENTIFIER\n|" "/tmp/$SCRIPT_NAME"
    mv "/tmp/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    success "Update complete."
    exit 0
}

# Check for existing conflict
if [ "$SCRIPT_NAME" = "toit" ] && ! is_our_script; then
    warning "The command 'toit' is already in use on your system."
    echo "Switching to 'h2it' instead to avoid conflicts."

    # Move to h2it instead
    curl -sSL "$REPO_URL/toit.sh" -o "/tmp/h2it" || error "Download failed."
    sed -i "1s|^|$IDENTIFIER\n|" /tmp/h2it
    sudo mv /tmp/h2it "$INSTALL_DIR/h2it"
    sudo chmod +x "$INSTALL_DIR/h2it"

    # Add function to .bashrc
    if ! grep -q "function h2it()" "$HOME/.bashrc"; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
        echo "🔄 Added h2it function to $HOME/.bashrc."
        echo -e "\nfunction h2it() {\n  bash $INSTALL_DIR/h2it \"\$@\"\n}" >> "$HOME/.bashrc"
    fi

    success "The 'h2it' command is now installed. You can use it like this:\n  h2it <script-name>"
    echo "Please run 'source ~/.bashrc' or restart your terminal to apply changes."
    exit 0
fi

# Main logic
case "$1" in
    "")
        warning "No script name provided."
        echo "Usage: $SCRIPT_NAME <script.sh> | update | removeyourself"
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
