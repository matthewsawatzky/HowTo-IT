#!/bin/bash
set -e

# === XMRig Installer for Homelab Setup ===
# By: [your GitHub username]

# === Defaults ===
REPO_URL="https://github.com/xmrig/xmrig.git"
DEFAULT_POOL="pool.supportxmr.com:3333"
CONFIG_FILE="config.json"
XMRIG_DIR="xmrig"

echo "🔧 Starting XMRig installer..."

# === Step 1: Dependencies ===
echo "📦 Installing build dependencies..."
sudo apt update -y
sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

# === Step 2: Clone if not exists ===
if [ ! -d "$XMRIG_DIR" ]; then
  echo "⬇️ Cloning XMRig..."
  git clone "$REPO_URL"
fi

# === Step 3: Build if needed ===
cd "$XMRIG_DIR"
mkdir -p build && cd build

if [ ! -f "./xmrig" ]; then
  echo "🔨 Building XMRig..."
  cmake .. && make -j$(nproc)
else
  echo "✅ XMRig binary already built."
fi

# === Step 4: Get config input ===
echo "🧾 Configuring..."

read -p "Enter Monero wallet address: " WALLET
read -p "Enter pool address (default: $DEFAULT_POOL): " POOL
POOL=${POOL:-$DEFAULT_POOL}
read -p "Enter worker name (optional): " WORKER
[[ -n "$WORKER" ]] && WORKER=".$WORKER"

cat > "$CONFIG_FILE" <<EOF
{
  "autosave": true,
  "background": false,
  "cpu": true,
  "opencl": false,
  "cuda": false,
  "pools": [
    {
      "url": "$POOL",
      "user": "$WALLET$WORKER",
      "pass": "x",
      "keepalive": true,
      "tls": false
    }
  ]
}
EOF

# === Step 5: Permissions ===
echo "🔐 Setting capabilities..."
sudo setcap cap_sys_nice=eip ./xmrig || echo "⚠️ Failed to set cap_sys_nice. You may need to run with sudo."

# === Step 6: Optional systemd ===
read -p "Install as a systemd service? (y/n): " INSTALL_SYSTEMD

if [[ "$INSTALL_SYSTEMD" == "y" ]]; then
  echo "🛠️ Creating systemd service..."
  SERVICE_PATH="/etc/systemd/system/xmrig.service"
  sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=XMRig Miner
After=network.target

[Service]
ExecStart=$(pwd)/xmrig -c $(pwd)/$CONFIG_FILE
Restart=always
Nice=10

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable xmrig
  echo "✅ Service installed. Start with: sudo systemctl start xmrig"
else
  echo "📌 Manual run: ./xmrig -c $CONFIG_FILE"
fi
echo "👉 To start mining, run:"
echo "./xmrig/build/xmrig -c config.json"
echo "----------------------------------"
echo "🎉 XMRig setup complete."
