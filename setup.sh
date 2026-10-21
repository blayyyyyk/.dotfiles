#!/usr/bin/env bash
# Set up this machine from ~/.dotfiles on macOS or Linux.
#
# Safe to re-run: each step checks what's already there and only does the
# missing work. Files that would be replaced by a stowed symlink are moved to
# ~/.dotfiles-backup/<timestamp>/ first, never deleted.
#
#   ./setup.sh             full setup
#   ./setup.sh --dry-run   print what would run; change nothing
#   ./setup.sh --upgrade   also upgrade Homebrew packages that are already installed
#   ./setup.sh --no-brew   skip Homebrew and the Brewfile
#   ./setup.sh --no-nvim   skip the Neovim plugin/tool install and doctor
#   ./setup.sh --ci        what CI runs: no casks, no chsh, fail on any problem
#
# Written for bash 3.2 (macOS's /bin/bash) as well as current bash.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
UPGRADE=0
WITH_BREW=1
WITH_NVIM=1
CI_MODE=0
PROBLEMS=()

usage() {
  sed -n '2,/^set -euo/p' "$0" | sed -e '/^set -euo/d' -e 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --upgrade) UPGRADE=1 ;;
    --no-brew) WITH_BREW=0 ;;
    --no-nvim) WITH_NVIM=0 ;;
    --ci) CI_MODE=1 ;;
    -h | --help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

# --- helpers -----------------------------------------------------------------

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
# Record a problem and keep going; the summary lists them all at the end.
problem() {
  printf '\033[1;33m    ! %s\033[0m\n' "$*" >&2
  PROBLEMS+=("$*")
}
die() { printf '\033[1;31mError: %s\033[0m\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# Run a command, or only print it under --dry-run.
run() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '    + %s\n' "$*"
  else
    "$@"
  fi
}

# Run a command as root: directly when we are root, otherwise through sudo.
as_root() {
  if [ "$(id -u)" = 0 ]; then
    run "$@"
  elif have sudo; then
    run sudo "$@"
  else
    return 1
  fi
}

resolve() {
  if have realpath; then
    realpath "$1" 2>/dev/null
  elif have perl; then
    perl -MCwd=abs_path -e 'print abs_path(shift)' "$1"
  else
    python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
  fi
}

# Download a script and pipe it to a shell; fails loudly if the download does.
fetch() { curl --proto '=https' --tlsv1.2 -fsSL "$1"; }

# --- steps -------------------------------------------------------------------

preflight() {
  step "Checking the system"
  case "$OS" in
    Darwin) info "macOS $(sw_vers -productVersion) ($(uname -m))" ;;
    Linux) info "Linux $(uname -r) ($(uname -m))" ;;
    *) die "unsupported OS: $OS" ;;
  esac
  if [ "$OS" = Linux ] && [ "$(id -u)" = 0 ] && [ "$WITH_BREW" = 1 ]; then
    die "Homebrew refuses to run as root. Run setup.sh as a regular user with sudo access (or pass --no-brew)."
  fi
  if [ "$CI_MODE" = 1 ]; then
    export DOTFILES_NO_CASKS=1
  fi
}

install_prerequisites() {
  step "Installing system prerequisites"
  if [ "$OS" = Darwin ]; then
    if xcode-select -p >/dev/null 2>&1; then
      info "Xcode Command Line Tools: installed"
    else
      run xcode-select --install || true
      if [ "$DRY_RUN" = 0 ]; then
        info "Finish the Command Line Tools installer dialog; waiting for it..."
        until xcode-select -p >/dev/null 2>&1; do sleep 5; done
      fi
    fi
    return
  fi

  local missing=0 bin
  for bin in cc make curl git file unzip tar gzip zsh python3; do
    have "$bin" || missing=1
  done
  if [ "$missing" = 0 ]; then
    info "build tools, curl, git, unzip, zsh, python3: installed"
    return
  fi
  if have apt-get; then
    if ! { as_root apt-get update -qq &&
      as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        build-essential procps curl file git unzip tar gzip zsh python3 python3-venv ca-certificates locales; }; then
      problem "apt-get could not install the prerequisites"
    fi
  elif have dnf; then
    as_root dnf install -y gcc gcc-c++ make procps-ng curl file git unzip tar gzip zsh python3 ||
      problem "dnf could not install the prerequisites"
  elif have pacman; then
    as_root pacman -Sy --needed --noconfirm base-devel procps-ng curl file git unzip tar gzip zsh python ||
      problem "pacman could not install the prerequisites"
  else
    problem "no apt-get, dnf or pacman: install a C compiler, make, curl, git, unzip and zsh yourself"
  fi
}

find_brew() {
  local candidate
  for candidate in "$HOME/.homebrew/bin/brew" /opt/homebrew/bin/brew /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  have brew && command -v brew
}

can_sudo() {
  [ "$(id -u)" = 0 ] && return 0
  have sudo || return 1
  sudo -n true 2>/dev/null && return 0
  # Interactive runs may prompt for the password once; CI has no terminal.
  [ -t 0 ] && sudo -v
}

install_homebrew() {
  step "Homebrew"
  local brew
  brew="$(find_brew || true)"
  if [ -z "$brew" ]; then
    if [ "$DRY_RUN" = 1 ]; then
      info "+ install Homebrew"
      return
    fi
    if can_sudo; then
      NONINTERACTIVE=1 /bin/bash -c "$(fetch https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" ||
        die "the Homebrew installer failed"
    else
      # No admin rights (e.g. another account owns /opt/homebrew): use a
      # personal prefix. Works, but Homebrew builds more from source there.
      local prefix="$HOME/.homebrew"
      [ "$OS" = Linux ] && prefix="$HOME/.linuxbrew"
      problem "no sudo: installing Homebrew to $prefix (unsupported prefix; expect source builds)"
      git clone --depth=1 https://github.com/Homebrew/brew "$prefix"
    fi
    brew="$(find_brew)" || die "Homebrew installed but brew was not found"
  fi
  info "using $brew"
  eval "$("$brew" shellenv)"

  # zsh gets this from .zshrc; give bash the same PATH, once. (Not
  # .bash_profile: creating one would stop bash from reading ~/.profile.)
  local rc="$HOME/.bashrc"
  if ! grep -qs 'brew shellenv' "$rc"; then
    if [ "$DRY_RUN" = 1 ]; then
      info "+ add brew shellenv to $rc"
    else
      # shellcheck disable=SC2016 # the $(...) is meant for the rc file
      printf '\n# Homebrew (added by ~/.dotfiles/setup.sh)\neval "$(%s shellenv)"\n' "$brew" >>"$rc"
    fi
  fi
}

brew_bundle() {
  step "Installing the Brewfile"
  export HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_BUNDLE_NO_LOCK=1
  local args=(bundle --file="$DOTFILES/Brewfile")
  [ "$UPGRADE" = 1 ] || args+=(--no-upgrade)
  # One bad formula shouldn't stop the rest of setup; brew lists failures.
  run brew "${args[@]}" || problem "brew bundle reported failures (see above)"
}

install_toolchains() {
  step "Language toolchains"
  if have rustup || [ -x "$HOME/.cargo/bin/rustup" ]; then
    info "rustup: installed"
  elif [ "$DRY_RUN" = 1 ]; then
    info "+ install rustup"
  else
    # .zshrc puts ~/.cargo/bin on PATH, so don't let rustup edit shell files.
    fetch https://sh.rustup.rs | sh -s -- -y --no-modify-path || problem "rustup install failed"
  fi
  if have uv || [ -x "$HOME/.local/bin/uv" ]; then
    info "uv: installed"
  elif [ "$DRY_RUN" = 1 ]; then
    info "+ install uv"
  else
    fetch https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh || problem "uv install failed"
  fi
}

install_zsh_framework() {
  step "Oh My Zsh and powerlevel10k"
  local zsh_dir="$HOME/.oh-my-zsh"
  if [ -d "$zsh_dir" ]; then
    info "Oh My Zsh: installed"
  elif [ "$DRY_RUN" = 1 ]; then
    info "+ install Oh My Zsh"
  else
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(fetch https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc ||
      problem "Oh My Zsh install failed"
  fi
  local p10k="${ZSH_CUSTOM:-$zsh_dir/custom}/themes/powerlevel10k"
  if [ -d "$p10k" ]; then
    info "powerlevel10k: installed"
  else
    run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k" || problem "powerlevel10k clone failed"
  fi
}

# Directories the repo owns outright: each should be one link into the repo
# (so new files, like lazy-lock.json updates, land in Git). An existing real
# directory is backed up whole instead of being merged file by file.
OWNED_DIRS=" .config/nvim .config/kitty .config/tmux .config/prettier "

# Move aside whatever stow would refuse to replace, walking the package top
# down. Anything that already resolves to the repo (a linked file, or a linked
# directory such as ~/.config/nvim) is skipped without looking inside it.
backup_conflicts() {
  local pkg="$1" rel="$2"
  local src="$DOTFILES/$pkg${rel:+/$rel}" target="$HOME${rel:+/$rel}"
  if [ -n "$rel" ]; then
    [ -e "$target" ] || [ -L "$target" ] || return 0
    [ "$(resolve "$target")" = "$(resolve "$src")" ] && return 0
  fi
  if [ -d "$src" ] && [ ! -L "$src" ] && [ -d "$target" ] && [ ! -L "$target" ] &&
    [ "${OWNED_DIRS#* "$rel" }" = "$OWNED_DIRS" ]; then
    local child
    while IFS= read -r child; do
      backup_conflicts "$pkg" "${rel:+$rel/}$(basename "$child")"
    done < <(find "$src" -mindepth 1 -maxdepth 1 ! -name .DS_Store)
    return 0
  fi
  info "backing up ~/$rel"
  run mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  run mv "$target" "$BACKUP_DIR/$rel"
}

stow_packages() {
  step "Linking dotfiles"
  have stow || { problem "stow is not installed; skipping links"; return; }
  local packages=(config zsh git bin vscode)
  [ "$OS" = Darwin ] && packages+=(hammerspoon)

  # Stow links a whole directory when the target doesn't exist yet. That's
  # right for nvim, kitty or tmux, which this repo owns, but for these it
  # would route every other app's files (all of ~/.local/share, say) into
  # the repo. Making them real directories first keeps the links per-file.
  local dir
  for dir in .config .local .local/bin .local/share .config/git .config/zed \
    .config/cmux .config/opencode .config/iterm2 .hammerspoon; do
    [ -d "$HOME/$dir" ] || run mkdir -p "$HOME/$dir"
  done

  local pkg
  for pkg in "${packages[@]}"; do
    backup_conflicts "$pkg" ""
    if [ "$DRY_RUN" = 1 ]; then
      stow --no --restow --dir="$DOTFILES" --target="$HOME" "$pkg" || true
    else
      stow --restow --dir="$DOTFILES" --target="$HOME" "$pkg" || problem "stow $pkg failed"
    fi
  done
  [ -d "$BACKUP_DIR" ] && info "replaced files were moved to $BACKUP_DIR"
  return 0
}

configure_git() {
  step "Git"
  # Machine-specific: the gh path depends on the Homebrew prefix.
  local local_cfg="$HOME/.gitconfig.local"
  if [ -f "$local_cfg" ]; then
    info "$local_cfg: exists"
  elif have gh; then
    local helper host
    helper="!$(command -v gh) auth git-credential"
    for host in https://github.com https://gist.github.com; do
      run git config --file "$local_cfg" --add "credential.$host.helper" ""
      run git config --file "$local_cfg" --add "credential.$host.helper" "$helper"
    done
    info "wrote the gh credential helper to $local_cfg (run 'gh auth login' if you haven't)"
  else
    problem "gh not installed; skipped the git credential helper"
  fi
}

install_tmux_plugins() {
  step "tmux plugins"
  local plugins="$HOME/.config/tmux/plugins" tpm="$HOME/.config/tmux/plugins/tpm"
  # Older checkouts tracked the plugins as gitlinks, leaving empty directories
  # that TPM mistakes for installed plugins.
  if [ -d "$plugins" ]; then
    run find "$plugins" -mindepth 1 -maxdepth 1 -type d -empty -exec rmdir {} +
  fi
  if [ -x "$tpm/tpm" ]; then
    info "TPM: installed"
  else
    run git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm" || { problem "TPM clone failed"; return; }
  fi
  if have tmux; then
    run "$tpm/bin/install_plugins" >/dev/null || problem "TPM could not install the tmux plugins"
  fi
}

install_opencode_plugins() {
  have opencode || return 0
  step "OpenCode plugins"
  local style="$HOME/.config/opencode/local/opencode-claude-style"
  if [ -d "$style" ]; then
    info "opencode-claude-style: installed"
  else
    run git clone --depth=1 https://github.com/nicoponder/opencode-claude-style "$style" ||
      problem "opencode-claude-style clone failed"
  fi
}

setup_nvim() {
  step "Neovim plugins, language servers, formatters and parsers"
  have nvim || { problem "nvim is not installed"; return; }
  local ok
  ok="$(nvim --headless --clean -c 'lua io.stdout:write(vim.fn.has("nvim-0.12"))' +qall 2>/dev/null || true)"
  if [ "$ok" != 1 ]; then
    problem "nvim is older than 0.12 ($(nvim --version | head -1)); the config needs 0.12+"
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    info "+ $DOTFILES/scripts/nvim-doctor.sh --restore"
    return
  fi
  "$DOTFILES/scripts/nvim-doctor.sh" --restore || problem "the Neovim doctor found problems (see above)"
}

set_login_shell() {
  [ "$CI_MODE" = 1 ] && return 0
  [ "$(basename "${SHELL:-}")" = zsh ] && return 0
  step "Login shell"
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ]; then
    problem "zsh not found; login shell unchanged"
    return
  fi
  # chsh asks for a password, so only try it from a terminal.
  if [ ! -t 0 ]; then
    problem "login shell is $SHELL; run: chsh -s $zsh_path"
    return
  fi
  if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
    if [ "$DRY_RUN" = 1 ]; then
      info "+ add $zsh_path to /etc/shells"
    elif ! echo "$zsh_path" | as_root tee -a /etc/shells >/dev/null; then
      problem "could not add $zsh_path to /etc/shells; run: chsh -s $zsh_path"
      return
    fi
  fi
  run chsh -s "$zsh_path" || problem "chsh failed; run: chsh -s $zsh_path"
}

summary() {
  step "Done"
  if [ "${#PROBLEMS[@]}" -eq 0 ]; then
    info "Everything is set up. Open a new terminal to load the shell config."
    return 0
  fi
  printf '\033[1;33m%s problem(s):\033[0m\n' "${#PROBLEMS[@]}"
  local p
  for p in "${PROBLEMS[@]}"; do
    printf '  - %s\n' "$p"
  done
  info "Fix these and re-run ./setup.sh; finished steps are skipped."
  [ "$CI_MODE" = 1 ] && return 1
  return 0
}

preflight
install_prerequisites
if [ "$WITH_BREW" = 1 ]; then
  install_homebrew
  brew_bundle
fi
install_toolchains
install_zsh_framework
stow_packages
configure_git
install_tmux_plugins
install_opencode_plugins
[ "$WITH_NVIM" = 1 ] && setup_nvim
set_login_shell
summary
