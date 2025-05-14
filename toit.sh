#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "You must run this script as root or with sudo."
  exit 1
fi

# Path to the current 'toit' executable
TOIT_PATH="/usr/local/bin/toit"

# Function to update the script if it's ours
update_toit_script() {
  echo "Updating to the latest version of our 'toit' command..."
  curl -sSL https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main/toit.sh -o /tmp/toit.sh
  sudo mv /tmp/toit.sh /usr/local/bin/toit
  sudo chmod +x /usr/local/bin/toit
}

# Check if 'toit' exists and is our custom version
if [ -f "$TOIT_PATH" ]; then
  if grep -q "Our custom toit script" "$TOIT_PATH"; then
    echo "Our custom 'toit' command is already installed."
    # Optionally update the script if needed
    # update_toit_script
    exit 0
  else
    echo "Found another program using the 'toit' command. Replacing it with 'h2it'..."
    sudo rm -f "$TOIT_PATH"
  fi
else
  echo "'toit' command not found. Installing our custom version as 'toit'..."
fi

# Download and install the correct version of 'toit'
curl -sSL https://raw.githubusercontent.com/matthewsawatzky/HowTo-IT/main/toit.sh -o /tmp/toit.sh

# Move the script to /usr/local/bin/ and rename it to 'toit'
sudo mv /tmp/toit.sh /usr/local/bin/toit

# Make the script executable
sudo chmod +x /usr/local/bin/toit

# Check if another program uses 'toit', and if so, rename it to 'h2it'
if command -v toit &>/dev/null && ! grep -q "Our custom toit script" "$TOIT_PATH"; then
  echo "Renaming 'toit' to 'h2it' to avoid conflicts with another program."
  sudo mv /usr/local/bin/toit /usr/local/bin/h2it

  # Modify .bashrc to add the 'h2it' function (if not already added)
  if ! grep -q "h2it()" ~/.bashrc; then
    echo "Adding 'h2it' function to ~/.bashrc..."
    echo -e "\n# h2it function\nfunction h2it() {\n  bash /usr/local/bin/h2it \$1;\n}" >> ~/.bashrc
    # Backup and apply changes to .bashrc
    cp ~/.bashrc ~/.bashrc.backup
    source ~/.bashrc
  fi

  echo "✅ The 'h2it' command is now installed. You can use it like this:\n  h2it <script-name>"
else
  # If it's our custom version, it’s already correct
  echo "Our custom 'toit' command is installed and ready to use."
  echo "✅ The 'toit' command is now installed. You can use it like this:\n  toit <script-name>"
fi
