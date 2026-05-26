#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install stow if missing
if ! command -v stow &>/dev/null; then
  echo "Installing GNU Stow..."
  brew install stow
fi

# Stow each package (--adopt pulls existing files into the repo, then git restore)
echo "Linking dotfiles..."
for pkg in zsh ghostty gh; do
  echo "  $pkg"
  stow -d "$DOTFILES_DIR" -t "$HOME" --adopt "$pkg" 2>&1 || true
done

# Restore repo versions (--adopt may have pulled in local diffs)
cd "$DOTFILES_DIR"
git checkout -- . 2>/dev/null || true

echo ""
echo "Done. Dotfiles are symlinked into ~/"
echo ""
echo "Optional: create ~/.zshrc.local for machine-specific config"
echo "  (Docker completions, dev-setup sourcing, etc.)"
