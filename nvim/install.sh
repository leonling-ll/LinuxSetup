#!/bin/bash

# NeoVim Auto-Install Script
# Installs nvim v0.11.5 from GitHub releases (latest stable)
# See nvim/README.md for details

set -e

NVIM_VERSION="v0.11.5"
NVIM_ARCHIVE="nvim-linux-x86_64.tar.gz"
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_ARCHIVE}"
NVIM_BIN="$HOME/nvim-linux-x86_64/bin/nvim"
ALIAS_LINE='alias nvim="$HOME/nvim-linux-x86_64/bin/nvim"'

if [ -x "$NVIM_BIN" ]; then
    echo "[INFO] NeoVim is already installed at $NVIM_BIN"
    "$NVIM_BIN" --version | head -1
    exit 0
fi

echo "[INFO] Downloading NeoVim ${NVIM_VERSION}..."
wget "$NVIM_URL" -O "$HOME/$NVIM_ARCHIVE"

echo "[INFO] Extracting..."
tar xzvf "$HOME/$NVIM_ARCHIVE" -C "$HOME"
rm "$HOME/$NVIM_ARCHIVE"

echo "[INFO] NeoVim installed at $NVIM_BIN"

# Add alias to ~/.zshrc if not already present
if [ -f "$HOME/.zshrc" ] && ! grep -qF 'nvim-linux-x86_64/bin/nvim' "$HOME/.zshrc"; then
    echo "" >> "$HOME/.zshrc"
    echo "# NeoVim alias" >> "$HOME/.zshrc"
    echo "$ALIAS_LINE" >> "$HOME/.zshrc"
    echo "[INFO] Added nvim alias to ~/.zshrc"
fi

echo "[SUCCESS] NeoVim ${NVIM_VERSION} installed successfully!"
echo "[INFO] Run 'source ~/.zshrc' or open a new terminal, then run 'nvim' to start."
