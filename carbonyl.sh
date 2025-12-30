#!/bin/bash
# AIO Carbonyl Installer for Minimal/Containerized Linux
# Fixed for: NSS Errors, GLIBC mismatches, Missing Symbols, Dangling Symlinks

set -e # Exit immediately if a command fails

# --- Config ---
CARBONYL_VER="0.0.3"
CARBONYL_URL="https://github.com/fathyb/carbonyl/releases/download/v${CARBONYL_VER}/carbonyl.linux-amd64.zip"
LIB_DIR="$HOME/libs"
INSTALL_DIR="$HOME/carbonyl-${CARBONYL_VER}"
TEMP_DIR="$HOME/carbonyl_aio_temp"

echo "==================================================="
echo "🚀 Carbonyl AIO Installer (Final Fix Edition)"
echo "==================================================="

# 1. CLEAN SLATE
# We wipe everything to prevent "dangling symlink" errors from previous failed attempts.
echo "🧹 Wiping old installations and libraries..."
rm -rf "$LIB_DIR"
rm -rf "$INSTALL_DIR"
rm -rf "$TEMP_DIR"
rm -f "$HOME/carbonyl-launcher.sh"

mkdir -p "$LIB_DIR"
mkdir -p "$TEMP_DIR"
mkdir -p "$HOME/bin"
# Create the PKI DB folder to prevent NSS DB errors
mkdir -p "$HOME/.pki/nssdb"

cd "$TEMP_DIR"

# 2. INSTALL BUSYBOX (Essential Tool)
# We need this because the system 'grep' or 'unzip' might be missing or limited.
BB="$HOME/bin/busybox"
if [ ! -f "$BB" ]; then
    echo "⬇️  Downloading BusyBox..."
    curl -L -o "$BB" "https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64"
    chmod +x "$BB"
fi

# 3. INSTALL CARBONYL
echo "⬇️  Downloading Carbonyl v${CARBONYL_VER}..."
curl -L -o carbonyl.zip "$CARBONYL_URL"
echo "📦 Extracting Carbonyl..."
"$BB" unzip -q -o carbonyl.zip -d "$HOME"
chmod +x "$INSTALL_DIR/carbonyl"
rm carbonyl.zip

# 4. DEPENDENCY INJECTOR FUNCTION
# This function goes to the Ubuntu file server, finds the right version,
# extracts it, and "vacuums" all .so and .chk files into your lib folder.
inject_lib() {
    pkg=$1
    base_url=$2
    
    echo "🔍 Processing $pkg..."
    
    # 1. Scrape the file list
    # Regex Explanation: Match "pkgname_...amd64.deb" but stop at the first quote [^\"]
    grep_pattern="${pkg}_[^\"]*amd64.deb"
    
    html=$(curl -sL "$base_url")
    file_name=$(echo "$html" | "$BB" grep -o "$grep_pattern" | head -n 1)

    if [ -z "$file_name" ]; then
        echo "   ❌ CRITICAL: Could not find package $pkg on server!"
        return
    fi
    
    echo "   ⬇️  Downloading: $file_name"
    curl -L -o "$pkg.deb" "${base_url}${file_name}"

    # 2. Extract
    # We check if file is valid (>1kb)
    if [ -s "$pkg.deb" ] && [ $(wc -c < "$pkg.deb") -gt 1000 ]; then
        dpkg -x "$pkg.deb" extracted
        
        # 3. The "Vacuum" Copy
        # - Find all .so (libraries) AND .chk (security checksums)
        # - Use 'cp -L' to follow symlinks and copy the REAL file data
        # - Use '--remove-destination' to overwrite any broken links
        find extracted -type f \( -name "*.so*" -o -name "*.chk" \) -print0 | while IFS= read -r -d '' file; do
            cp -L --remove-destination "$file" "$LIB_DIR/"
        done
        
        # Cleanup for next loop
        rm -rf extracted "$pkg.deb"
        echo "   ✅ Installed."
    else
        echo "   ❌ Error: Download failed for $pkg"
        exit 1
    fi
}

echo "---------------------------------------------------"
echo "💉 Injecting System Libraries (Ubuntu 20.04 Base)..."
echo "---------------------------------------------------"

# --- THE LIST ---
# We use the Ubuntu 20.04 (Focal) repositories for maximum compatibility.

# Core NSS/Security (Fixes -8023 error)
inject_lib "libnspr4"       "http://archive.ubuntu.com/ubuntu/pool/main/n/nspr/"
inject_lib "libnss3"        "http://archive.ubuntu.com/ubuntu/pool/main/n/nss/"
inject_lib "libsqlite3-0"   "http://archive.ubuntu.com/ubuntu/pool/main/s/sqlite3/"

# Graphics & Rendering (Fixes missing symbol errors)
inject_lib "libgbm1"        "http://archive.ubuntu.com/ubuntu/pool/main/m/mesa/"
inject_lib "libdrm2"        "http://archive.ubuntu.com/ubuntu/pool/main/libd/libdrm/"
inject_lib "libexpat1"      "http://archive.ubuntu.com/ubuntu/pool/main/e/expat/"

# X11 Window System (Fixes startup crashes)
inject_lib "libxkbcommon0"  "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxkbcommon/"
inject_lib "libxcomposite1" "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxcomposite/"
inject_lib "libxdamage1"    "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxdamage/"
inject_lib "libxfixes3"     "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxfixes/"
inject_lib "libxrandr2"     "http://archive.ubuntu.com/ubuntu/pool/main/libx/libxrandr/"

# Text & UI (Fixes font rendering)
inject_lib "libpango-1.0-0" "http://archive.ubuntu.com/ubuntu/pool/main/p/pango1.0/"
inject_lib "libcairo2"      "http://archive.ubuntu.com/ubuntu/pool/main/c/cairo/"
inject_lib "libatk1.0-0"    "http://archive.ubuntu.com/ubuntu/pool/main/a/atk1.0/"
inject_lib "libatk-bridge2.0-0" "http://archive.ubuntu.com/ubuntu/pool/main/a/at-spi2-atk/"

# Audio (Fixes libasound errors)
inject_lib "libasound2"     "http://archive.ubuntu.com/ubuntu/pool/main/a/alsa-lib/"

# 5. CREATE LAUNCHER
echo "📝 Creating Launcher..."
cat > "$HOME/carbonyl-launcher.sh" <<EOL
#!/bin/bash
export LD_LIBRARY_PATH=$LIB_DIR:\$LD_LIBRARY_PATH
export FONCONFIG_PATH=$LIB_DIR

# Flags:
# --no-sandbox: Required for container usage
# --disable-gpu: Prevents GPU process crashes
# --disable-dev-shm-usage: Fixes memory issues in small containers
$INSTALL_DIR/carbonyl --no-sandbox --disable-gpu --disable-dev-shm-usage "\$@"
EOL

chmod +x "$HOME/carbonyl-launcher.sh"

# Cleanup Temp
cd "$HOME"
rm -rf "$TEMP_DIR"

echo "==================================================="
echo "🎉 Installation Complete!"
echo "---------------------------------------------------"
echo "To browse the web, run:"
echo "./carbonyl-launcher.sh https://google.com"
echo "==================================================="
