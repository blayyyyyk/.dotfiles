# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# >>> user-local Homebrew (~/.homebrew) >>>
# /opt/homebrew is owned by another account and is NOT writable by this user.
# ~/.homebrew is the personal prefix holding claude, direnv, fzf, zoxide, git, ...
# Kept early so later prepends (nvm, ~/Library/Python, venvs) keep their precedence.
typeset -U path PATH        # keep PATH entries unique; prevents dupes on re-source
if [ -x "$HOME/.homebrew/bin/brew" ]; then
  eval "$("$HOME/.homebrew/bin/brew" shellenv)"
fi

# Let OMO's tmux-compat bridge and OpenCode's CMUX hook find the cask CLI.
export CMUX_OMO_CMUX_BIN="$HOME/.homebrew/bin/cmux"
export CMUX_OPENCODE_CMUX_BIN="$HOME/.homebrew/bin/cmux"
export OPENCODE_CMUX_PROGRESS=true
export OPENCODE_CMUX_TRANSPORT=auto
export OPENCODE_CMUX_LOG_TODOS=true
export OPENCODE_CMUX_LOG_TOOLS=true
export OPENCODE_CMUX_LOG_SUBAGENTS=true
export OPENCODE_CMUX_GIT=true
export OPENCODE_CMUX_KEEP_DONE_STATUS=true

# rustup ships shims in ~/.cargo/bin that pick the right toolchain (rust-toolchain.toml,
# +nightly, per-dir overrides). Brew also installs rust, so re-promote rustup above it.
[ -d "$HOME/.cargo/bin" ] && path=("$HOME/.cargo/bin" $path)
# <<< user-local Homebrew <<<

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git direnv)

# NOTE: Everything below should always be at the end of this file
if [ ! -f $ZSH/oh-my-zsh.sh ]; then
    cp ~/.zshrc ~/.zshrc-tmp;
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc;
    cp ~/.zshrc-tmp ~/.zshrc;
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k";
    
fi
    
source $ZSH/oh-my-zsh.sh;

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# >>> my export init >>>
export iam="$(whoami)"
# <<< my export init <<<

# (conda init block removed: miniconda was uninstalled, and the block's else-branch
#  pushed the nonexistent /opt/homebrew/Caskroom/miniconda/base/bin onto PATH.
#  Re-run `conda init zsh` if you reinstall conda.)


export PATH="$PATH:$HOME/.local/bin"

# Claude Code has no tree-level folder-trust setting: it keys trust off each
# directory's git root, and its parent walk stops there, so a trusted ~/dev
# never covers the repos inside it. Pre-accept the key for anything under ~/dev
# so the trust dialog never appears. ~/.local/bin/claude-trust-dev does the work
# and is a no-op (no write, no config race) once a path is already trusted.
claude() {
  if [[ $PWD == $HOME/dev || $PWD/ == $HOME/dev/* ]]; then
    claude-trust-dev "$PWD" >/dev/null 2>&1
  fi
  command claude "$@"
}

eval "$(zoxide init zsh --cmd cd)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# export DYLD_FALLBACK_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_FALLBACK_LIBRARY_PATH"
# export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:$PKG_CONFIG_PATH"
[ -d "$HOME/.spicetify" ] && export PATH="$PATH:$HOME/.spicetify"

[ -d "$HOME/Library/Python/3.9/bin" ] && export PATH="$HOME/Library/Python/3.9/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
