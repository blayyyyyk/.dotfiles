
# nvm
echo "Installing NVM..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
echo "NVM Version: $(nvm --version)"

# node
echo "Installing Node.js..."
nvm install --lts
nvm alias default --lts
nvm use default

# pyright
echo "Installing Pyright..."
npm i -g pyright

# lazygit
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="darwin"
else
    PLATFORM="linux"
fi
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    BINARY_ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    BINARY_ARCH="arm64"
else
    BINARY_ARCH="x86_64" # Fallback
fi

curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_0.58.1_${PLATFORM}_${BINARY_ARCH}.tar.gz"
echo "$BINARY_ARCH$PLATFORM"
tar xf lazygit.tar.gz lazygit
mv lazygit ~/.local/bin/
rm lazygit.tar.gz # cleanup
export PATH="$HOME/.local/bin:$PATH" # add to path

# Strip the 'com.apple.quarantine' attribute (macOS only)
if [ "$(uname -s)" = "Darwin" ]; then
    xattr -d com.apple.quarantine ~/.local/bin/lazygit 2>/dev/null
fi

echo "Installation Complete!"
echo "NVM: $(nvm --version)"
echo "Node: $(node -v)"
echo "Lazygit: $(lazygit --version)"