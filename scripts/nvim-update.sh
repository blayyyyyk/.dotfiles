#!/usr/bin/env bash
# Update Neovim plugins and parsers, and keep the update only if the doctor
# still passes. On failure lazy-lock.json and the plugins are rolled back, so
# an update can't leave the editor broken.
#
#   scripts/nvim-update.sh           update plugins + parsers
#   scripts/nvim-update.sh --tools   also update Mason servers/formatters
#                                    (Mason has no lockfile: not rolled back)
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
lock="$repo/config/.config/nvim/lazy-lock.json"
backup="$(mktemp)"
trap 'rm -f "$backup"' EXIT
cp "$lock" "$backup"

nvim --headless "+Lazy! update" +qall
if [[ "${1:-}" == "--tools" ]]; then
  nvim --headless +MasonToolsUpdateSync +qall
fi
nvim --headless +ConfigSync +qall

if nvim --headless +ConfigDoctor; then
  echo
  echo "Update passed. Review and commit it:"
  echo "  git -C $repo diff -- config/.config/nvim/lazy-lock.json"
else
  cp "$backup" "$lock"
  nvim --headless "+ConfigSync!" +qall
  echo "The update failed the doctor; restored the previous lazy-lock.json." >&2
  exit 1
fi
