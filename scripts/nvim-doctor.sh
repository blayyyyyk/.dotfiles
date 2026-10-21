#!/usr/bin/env bash
# Install everything the Neovim config needs, then verify it actually works:
# every language server attaches and reports diagnostics, every formatter
# formats, every tree-sitter parser loads. Exits non-zero on any failure.
#
#   scripts/nvim-doctor.sh            install what's missing, then check
#   scripts/nvim-doctor.sh --restore  first reset plugins to lazy-lock.json
#   scripts/nvim-doctor.sh --check    check only, install nothing
set -euo pipefail

lock="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config/.config/nvim/lazy-lock.json"

restore() {
  # When lazy.nvim installs a missing plugin at startup it rewrites
  # lazy-lock.json from whatever is checked out locally, which on a machine
  # with older plugins would record those older commits. Keep the committed
  # lockfile, let startup install, put the lockfile back, then restore to it.
  local saved
  saved="$(mktemp)"
  cp "$lock" "$saved"
  nvim --headless +qall
  cp "$saved" "$lock"
  rm -f "$saved"
  nvim --headless "+ConfigSync!" +qall
}

case "${1:-}" in
  --restore) restore ;;
  --check) ;;
  "") nvim --headless +ConfigSync +qall ;;
  *) echo "usage: $0 [--restore|--check]" >&2; exit 2 ;;
esac

# A fresh process, so errors raised during startup are caught too.
nvim --headless +ConfigDoctor
