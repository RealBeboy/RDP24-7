#!/bin/bash

# 1. Setup
mkdir -p "$HOME/bin"
cd "$HOME/bin"

echo "⬇️  Downloading Tmux (Static v3.6a)..."

# 2. Download the compressed binary
# We use the mjakob-gh repo which is the standard for static tmux builds
curl -L -o tmux.gz "https://github.com/mjakob-gh/build-static-tmux/releases/download/v3.6a/tmux.linux-amd64.gz"

# 3. Check if download worked (Size check)
filesize=$(wc -c < "tmux.gz")
if [ $filesize -lt 1000 ]; then
    echo "❌ Error: Download failed. File is too small."
    cat tmux.gz
    exit 1
fi

echo "📦 Extracting..."

# 4. Decompress
# We try 'gzip' first. If missing, we assume 'gunzip' or 'busybox' might be needed.
if command -v gzip >/dev/null 2>&1; then
    gzip -d -f tmux.gz
else
    echo "⚠️  'gzip' not found. Trying to run it as-is (unlikely to work) or use busybox if present..."
    # If you have the busybox from step 1, use: $HOME/bin/busybox gzip -d tmux.gz
    mv tmux.gz tmux
fi

# 5. Make executable
chmod +x tmux

echo "✅ Tmux installed to $HOME/bin/tmux"

# 6. Setup the PATH again (just to be safe)
export PATH=$HOME/bin:$PATH

echo "🎉 Setup Complete!"
echo "---------------------------------------------------"
echo "To start Tmux, run:"
echo "  ~/bin/tmux"
echo ""
echo "KEYBOARD SHORTCUTS (Since mouse won't work):"
echo "  Split Vertical:   Ctrl+b  then  %"
echo "  Split Horizontal: Ctrl+b  then  \""
echo "  Switch Pane:      Ctrl+b  then  Arrow Keys"
echo "---------------------------------------------------"
