# Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
echo >> "$HOME/.bashrc";
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> "$HOME/.bashrc";
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)";

# Update & upgrade
brew update && brew upgrade;

# Core packages
brew bundle --file=Brewfile

# Stow .dotfiles
cd ~/.dotfiles
stow \
    config \
    zsh \
    vscode
    
exec zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc; && \
    /home/linuxbrew/.linuxbrew/bin/zsh
    
echo "✅ Setup complete!"