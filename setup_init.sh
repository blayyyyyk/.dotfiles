#!/bin/bash

set -e

OS=$(uname -s)

if [[ "$OS" == "Darwin" ]]; then
  echo "🍏 Detected macOS"

  # Check for Xcode Command Line Tools
  if ! xcode-select -p &>/dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install;

    # Wait until installed
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
  fi

elif [[ "$OS" == "Linux" ]]; then
  echo "🐧 Detected Linux"
  # Add Linux-specific setup here if needed
  if ! command -v curl &> /dev/null; then
      apt update;
      apt install -y curl;
  fi

else
  echo "❌ Unsupported OS: $OS"
  exit 1
fi




