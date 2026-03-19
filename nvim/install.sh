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
SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
NVIM_CONFIG_SRC="$SCRIPT_DIR"
NVIM_CONFIG_DEST="$HOME/.config/nvim"

# Install NeoVim binary if not already present
if [ -x "$NVIM_BIN" ]; then
    echo "[INFO] NeoVim is already installed at $NVIM_BIN, skipping download."
    "$NVIM_BIN" --version | head -1
else
    echo "[INFO] Downloading NeoVim ${NVIM_VERSION}..."
    wget "$NVIM_URL" -O "$HOME/$NVIM_ARCHIVE"

    echo "[INFO] Extracting..."
    tar xzvf "$HOME/$NVIM_ARCHIVE" -C "$HOME"
    rm "$HOME/$NVIM_ARCHIVE"

    echo "[INFO] NeoVim installed at $NVIM_BIN"
fi

# Add alias to ~/.zshrc if not already present
if [ -f "$HOME/.zshrc" ] && ! grep -qF 'nvim-linux-x86_64/bin/nvim' "$HOME/.zshrc"; then
    echo "" >> "$HOME/.zshrc"
    echo "# NeoVim alias" >> "$HOME/.zshrc"
    echo "$ALIAS_LINE" >> "$HOME/.zshrc"
    echo "[INFO] Added nvim alias to ~/.zshrc"
fi

# Symlink nvim config if not already present
if [ -e "$NVIM_CONFIG_DEST" ] || [ -L "$NVIM_CONFIG_DEST" ]; then
    echo "[INFO] NeoVim config already exists at $NVIM_CONFIG_DEST, skipping symlink."
else
    mkdir -p "$HOME/.config"
    ln -s "$NVIM_CONFIG_SRC" "$NVIM_CONFIG_DEST"
    echo "[INFO] Linked $NVIM_CONFIG_SRC -> $NVIM_CONFIG_DEST"
fi

echo "[SUCCESS] NeoVim ${NVIM_VERSION} setup complete!"
echo "[INFO] Run 'source ~/.zshrc' or open a new terminal, then run 'nvim' to start."
