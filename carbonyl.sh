#!/bin/bash

# --- Configuration ---
CARBONYL_VERSION="0.0.3"
CARBONYL_URL="https://github.com/fathyb/carbonyl/releases/download/v${CARBONYL_VERSION}/carbonyl.linux-amd64.zip"
LIB_DIR="$HOME/libs"
INSTALL_DIR="$HOME/carbonyl-${CARBONYL_VERSION}"

echo "=== 🚀 Starting Carbonyl Setup ==="

# 1. Setup Directories
mkdir -p "$LIB_DIR"
cd "$HOME"

# 2. Install Carbonyl (if not present)
if [ ! -f "$INSTALL_DIR/carbonyl" ]; then
    echo "⬇️  Downloading Carbonyl..."
    # Download zip using python if curl/wget fails, or just use curl
    curl -L -o carbonyl.zip "$CARBONYL_URL"
    
    echo "📦 Extracting Carbonyl..."
    # Unzip using Python (since unzip isn't installed)
    python3 -m zipfile -e carbonyl.zip .
    
    # Cleanup zip
    rm carbonyl.zip
    
    # Make executable
    chmod +x "$INSTALL_DIR/carbonyl"
    echo "✅ Carbonyl installed."
else
    echo "✅ Carbonyl already installed."
fi

# 3. Download & Extract Missing Libraries
echo "🔍 Downloading System Dependencies..."

# List of required packages for Chromium/Carbonyl
packages=(
    "libnspr4"
    "libnss3"
    "libcups2t64"
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
    "libat-spi2-0"
)

# Download loop using 'apt download' (No Root Needed)
for pkg in "${packages[@]}"; do
    # Only download if we don't have it (crude check, but faster)
    # Actually, let's just try to download to be safe
    apt download "$pkg" 2>/dev/null
    
    # Find the downloaded .deb file
    deb_file=$(ls ${pkg}*.deb 2>/dev/null | head -n 1)
    
    if [ ! -z "$deb_file" ]; then
        echo "   📦 Extracting $pkg..."
        dpkg -x "$deb_file" extracted_temp
        
        # Move libraries to our local lib folder (suppress errors)
        cp -n extracted_temp/usr/lib/x86_64-linux-gnu/*.so* "$LIB_DIR/" 2>/dev/null
        cp -n extracted_temp/lib/x86_64-linux-gnu/*.so* "$LIB_DIR/" 2>/dev/null
        
        # Cleanup
        rm "$deb_file"
        rm -rf extracted_temp
    else
        echo "   ⚠️  Could not download $pkg (might be installed or named differently)"
    fi
done

echo "✅ Dependencies Setup Complete."

# 4. Create a Launch Script (launcher.sh)
# This makes it easy to run Carbonyl later without typing the export command every time
cat > "$HOME/carbonyl-launcher.sh" <<EOL
#!/bin/bash
export LD_LIBRARY_PATH=$LIB_DIR:\$LD_LIBRARY_PATH
$INSTALL_DIR/carbonyl --no-sandbox "\$@"
EOL

chmod +x "$HOME/carbonyl-launcher.sh"

echo "==============================================="
echo "🎉 Setup Finished!"
echo "To run Carbonyl, use:"
echo "./carbonyl-launcher.sh https://google.com"
echo "==============================================="
