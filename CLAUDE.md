# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

GNU Stow-managed dotfiles. Each top-level directory is a "stow package" — its contents mirror the target directory structure rooted at `$HOME`. Stow creates symlinks from `~/` into this repo.

## Commands

- **Link all packages:** `./install.sh` (installs stow if missing, then stows each package with `--adopt`)
- **Add a new package:** `mkdir -p <pkg>/<path>`, place the file, then `stow <pkg>`
- **Remove a package:** `stow -D <pkg>` (removes symlinks, leaves files in repo)
- **No tests, linter, or CI.** Changes are verified by opening a new shell.

## Structure

- `zsh/` — `.zshrc` and `.zprofile`, symlinked to `~/`. Machine-specific config goes in `~/.zshrc.local` (not tracked).
- `gh/` — GitHub CLI config, symlinked to `~/.config/gh/`.
- `install.sh` — bootstrap script; loops over package dirs and stows them.

## Key conventions

- Never put secrets, tokens, or machine-specific paths in tracked files. Those belong in `~/.zshrc.local`.
- When adding a package, update the loop in `install.sh` and the table in `README.md`.
