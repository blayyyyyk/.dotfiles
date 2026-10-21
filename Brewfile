# Installed by setup.sh with `brew bundle`; works on macOS and Linux.
# Rust (rustup) and uv come from their own installers in setup.sh, so
# per-project toolchain pins keep working.

tap "anomalyco/tap"

# Shell and terminal
brew "zsh"
brew "tmux"
brew "stow"
brew "zoxide"
brew "fzf" # .zshrc key bindings
brew "direnv"

# Git
brew "git"
brew "git-crypt"
brew "git-lfs"
brew "gh" # also the git credential helper (~/.gitconfig.local)
brew "lazygit" # nvim <leader>gg
brew "gnupg"

# Editor
brew "neovim" # the nvim config needs 0.12+
brew "tree-sitter-cli" # compiles nvim-treesitter parsers (Mason has a fallback copy)
brew "ripgrep" # Telescope live grep
brew "fd" # Telescope find files
brew "jq" # cmux notification hook

# Languages
brew "node" # Copilot and npm-based language servers
brew "nvm"
brew "go"

# Build tools
brew "autoconf"
brew "automake"
brew "cmake"
brew "pkgconf"
brew "libtool"
brew "protobuf"

# Media and misc
brew "librsvg"
brew "imagemagick"
brew "ncspot"
brew "anomalyco/tap/opencode"

# macOS apps. CI sets DOTFILES_NO_CASKS to skip the large downloads.
if OS.mac? && !ENV["DOTFILES_NO_CASKS"]
  tap "theboredteam/boring-notch"

  cask "font-jetbrains-mono-nerd-font" # icons in nvim (set it as iTerm2's non-ASCII font)
  cask "iterm2"
  cask "cmux"
  cask "zed"
  cask "visual-studio-code"
  cask "cursor"
  cask "hammerspoon"
  cask "obsidian"
  cask "arc"
  cask "google-chrome"
  cask "spotify"
  cask "scroll-reverser"
  cask "dockdoor"
  cask "theboredteam/boring-notch/boring-notch"
  cask "gcloud-cli"
end
