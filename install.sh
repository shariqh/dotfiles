#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install stow if missing
if ! command -v stow &>/dev/null; then
  echo "Installing GNU Stow..."
  brew install stow
fi

# Refuse to run with uncommitted changes — the post-stow `git checkout` below
# would wipe them out. Commit or stash first.
cd "$DOTFILES_DIR"
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Error: working tree has uncommitted changes. Commit or stash before running install.sh."
  echo "       (otherwise the post-adopt 'git checkout' would discard them.)"
  exit 1
fi

# Stow each package (--adopt pulls existing files into the repo, then git restore)
echo "Linking dotfiles..."
for pkg in zsh gh; do
  echo "  $pkg"
  stow -d "$DOTFILES_DIR" -t "$HOME" --adopt "$pkg" 2>&1 || true
done

# Restore repo versions (--adopt may have pulled in local diffs)
git checkout -- . 2>/dev/null || true

echo ""
echo "Done. Dotfiles are symlinked into ~/"
echo ""
echo "Optional: create ~/.zshrc.local for machine-specific config"
echo "  (Docker completions, dev-setup sourcing, etc.)"
