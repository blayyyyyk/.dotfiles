# Create symlink
ln -s ~/.dotfiles/config/.config ~/.config

# Install pyright
# 1. Install nvm+npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
source "$NVM_DIR/nvm.sh"
nvm install 16.10.0
# 2. Install pyright


