#!/bin/bash



# 1. Create a safe folder for your apps

# We use $HOME/bin because it's the standard place for user programs

mkdir -p "$HOME/bin"



echo "⬇️  Downloading Zellij..."



# 2. Download and extract directly into that folder

# We use -C to tell tar to extract it straight into $HOME/bin

curl -L https://github.com/zellij-org/zellij/releases/download/v0.40.1/zellij-x86_64-unknown-linux-musl.tar.gz | tar -xz -C "$HOME/bin"



# 3. Make it executable (just in case)

chmod +x "$HOME/bin/zellij"



echo "✅ Zellij installed to $HOME/bin/zellij"



# 4. Add to PATH for this session so you can type 'zellij' immediately

export PATH=$HOME/bin:$PATH



# 5. Add to PATH permanently (for future restarts)

# This checks if the line exists in .bashrc, if not, it adds it.

if ! grep -q 'export PATH=$HOME/bin:$PATH' "$HOME/.bashrc"; then

  echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bashrc"

fi



echo "🎉 Setup Complete!"

echo "You can run it now by typing: ~/bin/zellij"

echo "zellij"
