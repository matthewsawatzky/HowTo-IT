#!/bin/bash

# ----- CONFIG -----
SCRIPT_NAME="toit"
ALT_NAME="h2it"
REPO_URL="https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main"
INSTALL_PATH="/usr/local/bin"
IDENTIFIER="# HowTo-IT Managed Command"

# ----- DETECTION -----
function is_our_script() {
    grep -q "$IDENTIFIER" "$1" 2>/dev/null
}

# ----- CHOOSE COMMAND NAME -----
if command -v $SCRIPT_NAME >/dev/null && ! is_our_script "$(command -v $SCRIPT_NAME)"; then
    echo "⚠️ The command '$SCRIPT_NAME' is already in use by another program."
    CMD=$ALT_NAME
else
    CMD=$SCRIPT_NAME
fi

DEST="$INSTALL_PATH/$CMD"

# ----- INSTALL OR UPDATE SCRIPT -----
echo "⬇️ Installing or updating '$CMD'..."

curl -sSL "$REPO_URL/toit.sh" -o /tmp/$CMD.sh || {
    echo "❌ Failed to download script."
    exit 1
}

# Add identifier at the top of the script
sed -i "1s|^|$IDENTIFIER\n|" /tmp/$CMD.sh

sudo mv /tmp/$CMD.sh "$DEST"
sudo chmod +x "$DEST"

# ----- ADD TO .bashrc -----
if ! grep -q "function $CMD()" ~/.bashrc; then
    echo "🔧 Adding '$CMD' function to ~/.bashrc..."
    echo -e "\n# $CMD command function\nfunction $CMD() {\n  bash $DEST \"\$@\"\n}" >> ~/.bashrc
    echo "🌀 Run 'source ~/.bashrc' or restart your terminal to activate."
else
    echo "ℹ️ '$CMD' function already in ~/.bashrc"
fi

echo "✅ '$CMD' is ready to use."
exit 0

# ---------- RUNTIME LOGIC (when user runs `toit <arg>`) ----------

if [[ "$0" == "$BASH_SOURCE" ]]; then
    case "$1" in
        removeyourself)
            echo "🧹 Removing '$CMD' and cleaning up..."
            sudo rm -f "$DEST"
            sed -i "/function $CMD()/,/^}/d" ~/.bashrc
            echo "✅ '$CMD' removed. Run 'source ~/.bashrc' or restart your terminal."
            exit 0
            ;;
        "")
            echo "❓ Please provide a setup script name, like:"
            echo "   $CMD xmrig-setup.sh"
            echo "   $CMD removeyourself"
            exit 1
            ;;
        *)
            SCRIPT="$1"
            echo "📥 Fetching and running '$SCRIPT'..."
            curl -sSL "$REPO_URL/$SCRIPT" -o /tmp/$SCRIPT || {
                echo "❌ Failed to download $SCRIPT"
                exit 1
            }
            chmod +x /tmp/$SCRIPT
            bash /tmp/$SCRIPT
            ;;
    esac
fi
