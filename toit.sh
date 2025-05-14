#!/bin/bash

# Check if "toit" is already in use on the system
if command -v toit &> /dev/null; then
  echo "⚠️ The command 'toit' is already in use on your system."
  echo "Switching to 'h2it' instead to avoid conflicts."
  COMMAND_NAME="h2it"
else
  COMMAND_NAME="toit"
fi

# Check if ~/.bashrc or ~/.bash_profile exists
BASHRC_FILE="$HOME/.bashrc"
if [ ! -f "$BASHRC_FILE" ]; then
  BASHRC_FILE="$HOME/.bash_profile"
fi

# Backup .bashrc or .bash_profile before modifying
cp "$BASHRC_FILE" "$BASHRC_FILE-backup"
echo "🛠️ Backup of your $BASHRC_FILE created."

# Add the command to ~/.bashrc or ~/.bash_profile
cat <<EOF >> "$BASHRC_FILE"

# Custom command $COMMAND_NAME
$COMMAND_NAME() {
  if [ "\$1" == "removeyourself" ]; then
    echo "🚮 Removing $COMMAND_NAME and the bootstrap script..."

    # Remove the custom function
    sed -i '/$COMMAND_NAME()/,/^}/d' $BASHRC_FILE

    # Remove the backup and reload
    source $BASHRC_FILE
    echo "✅ Removed $COMMAND_NAME successfully!"
    return 0
  fi

  if [ -z "\$1" ]; then
    echo "Usage: $COMMAND_NAME <script-name> or $COMMAND_NAME removeyourself"
    return 1
  fi

  SCRIPT_NAME="\$1-setup.sh"
  REPO_URL="https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main"

  echo "📦 Fetching and running \$SCRIPT_NAME from HowTo-IT..."

  curl -sS "\$REPO_URL/\$SCRIPT_NAME" -o "/tmp/\$SCRIPT_NAME"

  if [ ! -s "/tmp/\$SCRIPT_NAME" ]; then
    echo "❌ Could not fetch script. Check name or repo."
    return 2
  fi

  chmod +x "/tmp/\$SCRIPT_NAME"
  exec "/tmp/\$SCRIPT_NAME"
}

EOF

# Inform user and reload the shell config
echo "🔄 Added $COMMAND_NAME function to $BASHRC_FILE."
echo "Please run 'source $BASHRC_FILE' or restart your terminal to apply changes."
source "$BASHRC_FILE"

# Let the user know about the success and the ability to use the new command
echo "✅ The '$COMMAND_NAME' command is now installed. You can use it like this:"
echo "$COMMAND_NAME <script-name>"
