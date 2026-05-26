# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

GNU Stow-managed dotfiles. Each top-level directory is a "stow package" — its contents mirror the target directory structure rooted at `$HOME`. Stow creates symlinks from `~/` into this repo.

## Commands

- **Link all packages:** `./install.sh` (installs stow if missing, then stows each package with `--adopt`)
- **Add a new package:** `mkdir -p <pkg>/<path>`, place the file, then `stow <pkg>`
- **Remove a package:** `stow -D <pkg>` (removes symlinks, leaves files in repo)
- **No tests, linter, or CI.** Changes are verified by opening a new shell.

⚠️ `install.sh` refuses to run with a dirty working tree. Its post-adopt `git checkout -- .` would otherwise discard uncommitted edits to tracked dotfiles. Commit or stash before re-running.

## Structure

- `zsh/` — `.zshrc` and `.zprofile`, symlinked to `~/`. `.zshrc` sources `~/.zshrc.local` last (untracked, machine-specific).
- `gh/` — GitHub CLI config, symlinked to `~/.config/gh/`.
- `install.sh` — bootstrap script; loops over package dirs and stows them.

## Key conventions

- Never put secrets, tokens, or machine-specific paths in tracked files. Those belong in `~/.zshrc.local` (or `~/.zshenv` for env vars / secrets that need to be set on every invocation).
- When adding a package, update the loop in `install.sh` and the table in `README.md`.
- The `ntn-*` functions in `zsh/.zshrc` depend on (a) the `op` 1Password CLI and (b) `OP_SERVICE_ACCOUNT_TOKEN` exported from the untracked `~/.zshenv`. If you touch them, keep the secret out of the repo.
- When sourcing globs from optional directories (like the `dev-setup` line), use the zsh `(N)` glob qualifier so unmatched globs no-op instead of aborting `.zshrc`.
