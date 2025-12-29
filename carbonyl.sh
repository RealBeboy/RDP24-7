#!/bin/bash

# Stop the script if any critical command fails
set -e

# --- Configuration ---
CARBONYL_VERSION="0.0.3"
CARBONYL_URL="https://github.com/fathyb/carbonyl/releases/download/v${CARBONYL_VERSION}/carbonyl.linux-amd64.zip"
LIB_DIR="$HOME/libs"
INSTALL_DIR="$HOME/carbonyl-${CARBONYL_VERSION}"
BUSYBOX_URL="https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64"

echo "=== 🚀 Starting Carbonyl Setup (Minimal OS Fix) ==="

# 1. Setup Directories
echo "📂 Creating directories..."
mkdir -p "$LIB_DIR"
mkdir -p "$HOME/bin"
cd "$HOME"

# 2. Install BusyBox (The Unzipper)
if [ ! -f "$HOME/bin/busybox" ]; then
    echo "⬇️  System lacks unzip/python. Downloading BusyBox..."
    curl -L -o "$HOME/bin/busybox" "$BUSYBOX_URL"
    chmod +x "$HOME/bin/busybox"
    echo "✅ BusyBox installed."
else
    echo "✅ BusyBox already present."
fi

# 3. Install Carbonyl
if [ ! -f "$INSTALL_DIR/carbonyl" ]; then
    echo "⬇️  Downloading Carbonyl..."
    curl -L -o carbonyl.zip "$CARBONYL_URL"
    
    echo "📦 Extracting Carbonyl using BusyBox..."
    # Use busybox to unzip
    "$HOME/bin/busybox" unzip -o carbonyl.zip
    
    rm carbonyl.zip
    chmod +x "$INSTALL_DIR/carbonyl"
    echo "✅ Carbonyl extracted successfully."
else
    echo "✅ Carbonyl already installed."
fi

# 4. Download & Extract Missing Libraries
echo "🔍 Checking System Dependencies..."

# List of packages. 
# Note: libcups is often optional for headless browsers, but we will try to get it.
packages=(
    "libnspr4"
    "libnss3"
    "libdrm2"
    "libexpat1"
    "libxkbcommon0"
    "libxcomposite1"
    "libxdamage1"
    "libxfixes3"
    "libxrandr2"
    "libgbm1"
    "libpango-1.0-0"
    "libcairo2"
    "libasound2t64"
    "libatk1.0-0t64"
    "libatk-bridge2.0-0t64"
)

# Switch to a temporary directory for downloading debs so we don't clutter Home
mkdir -p "$HOME/temp_debs"
cd "$HOME/temp_debs"

# Disable 'set -e' for the loop because apt download might fail on some, and we want to keep going
set +e 

for pkg in "${packages[@]}"; do
    echo "   ⬇️  Fetching $pkg..."
    
    # Try to download. If apt fails (404), we ignore it for now.
    apt download "$pkg" 2>/dev/null
    
    # Find the downloaded .deb file
    deb_file=$(ls ${pkg}*.deb 2>/dev/null | head -n 1)
    
    if [ ! -z "$deb_file" ]; then
        echo "      📦 Extracting $pkg..."
        dpkg -x "$deb_file" extracted_temp
        
        # Move libraries to local lib folder
        cp -rn extracted_temp/usr/lib/x86_64-linux-gnu/*.so* "$LIB_DIR/" 2>/dev/null
        cp -rn extracted_temp/lib/x86_64-linux-gnu/*.so* "$LIB_DIR/" 2>/dev/null
        
        # Cleanup
        rm "$deb_file"
        rm -rf extracted_temp
    else
        echo "      ⚠️  Failed to download $pkg (Repo version mismatch or not found)."
    fi
done

# Clean up temp folder
cd "$HOME"
rm -rf "$HOME/temp_debs"

echo "✅ Dependencies Setup Complete."

# 5. Create the Launcher
echo "📝 Creating Launcher Script..."
cat > "$HOME/carbonyl-launcher.sh" <<EOL
#!/bin/bash
export LD_LIBRARY_PATH=$LIB_DIR:\$LD_LIBRARY_PATH
export FONCONFIG_PATH=$LIB_DIR
# Force software rendering just in case
$INSTALL_DIR/carbonyl --no-sandbox --disable-gpu "\$@"
EOL

chmod +x "$HOME/carbonyl-launcher.sh"

echo "==============================================="
echo "🎉 Setup Finished!"
echo "Run it with:"
echo "./carbonyl-launcher.sh https://google.com"
echo "==============================================="
