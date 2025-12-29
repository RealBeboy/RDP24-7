#!/bin/bash

# --- CONFIGURATION ---
PORT=8114
VS_PASSWORD="beboy123"  # <--- CHANGE THIS PASSWORD!
INSTALL_DIR="$HOME/bin"
VS_DIR="$INSTALL_DIR/code-server"

# --- 1. CLEANUP (Start Fresh) ---
echo "Cleaning up old installations..."
pkill -f code-server  # Stop any running instances
rm -rf "$VS_DIR"      # Remove old folder

# --- 2. DOWNLOAD & EXTRACT ---
echo "Downloading code-server..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download the latest stable release (Linux AMD64)
curl -fL https://github.com/coder/code-server/releases/download/v4.92.2/code-server-4.92.2-linux-amd64.tar.gz \
  | tar -xz

# Rename the messy folder name to just 'code-server'
mv code-server-*-linux-amd64 "$VS_DIR"

# --- 3. CREATE LAUNCH SCRIPT ---
echo "Creating launch script..."
cat > $HOME/start_vscode.sh <<EOF
#!/bin/bash
export PASSWORD="$VS_PASSWORD"
echo "Starting VS Code Server on port $PORT..."
echo "Access it at: http://YOUR_SERVER_IP:$PORT"
$VS_DIR/bin/code-server --bind-addr 0.0.0.0:$PORT --auth password
EOF

chmod +x $HOME/start_vscode.sh

# --- 4. START SERVER ---
echo "Setup complete!"
echo "Starting server now..."
$HOME/start_vscode.sh
