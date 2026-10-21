#!/usr/bin/env bash
# Try setup.sh on a throwaway Linux machine: a fresh Ubuntu container with a
# sudo-capable user, a clean clone of this repo's committed HEAD, and an
# interactive zsh at the end to poke around.
#
#   ./setup_container.sh [image]      default ubuntu:24.04
#
# Needs docker, or Apple's `container` CLI.
set -euo pipefail

image="${1:-ubuntu:24.04}"
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v docker >/dev/null 2>&1; then
  runtime=docker
elif command -v container >/dev/null 2>&1; then
  runtime=container
else
  echo "needs docker or Apple's container CLI" >&2
  exit 1
fi

"$runtime" run --rm -it -v "$repo:/src:ro" "$image" bash -c '
  set -e
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sudo git ca-certificates >/dev/null
  useradd -m -s /bin/bash dev
  echo "dev ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/dev
  sudo -u dev git -c safe.directory="*" clone -q /src /home/dev/.dotfiles
  sudo -u dev -H bash -c "cd ~/.dotfiles && ./setup.sh" || true
  exec sudo -u dev -H zsh -l
'
