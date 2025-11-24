#!/bin/bash

DOTFILES_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
TARGET_DIR="$HOME"

cd "$DOTFILES_DIR" || exit

echo "📂 Mirroring directory structure..."

fd --type d --hidden --exclude .git --exec mkdir -p "$TARGET_DIR/{}"

echo "🔗 Stowing files..."

stow --verbose -d "$DOTFILES_DIR" -t "$TARGET_DIR" .

echo "✅ Done!"
