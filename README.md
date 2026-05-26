# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

| Package    | Files                          | What it configures           |
|------------|--------------------------------|------------------------------|
| `zsh`      | `.zshrc`, `.zprofile`          | Shell options, prompt, aliases, PATH |
| `gh`       | `.config/gh/config.yml`        | GitHub CLI settings & aliases |

## Setup on a new machine

```bash
# 1. Install prerequisites
brew install stow eza bat

# 2. Clone and link
git clone git@github.com:shariqh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks each package into `~/` via Stow. Existing files are adopted into the repo, then restored to the repo version.

## Machine-specific config

Anything that shouldn't be shared across machines goes in `~/.zshrc.local`, which is sourced at the end of `.zshrc` but not tracked in this repo. Examples:

- Docker Desktop completions
- Paths to local dev tooling
- Work-specific env vars

## Managing dotfiles

```bash
# Edit a config (symlink means this edits the repo copy)
vim ~/.zshrc

# Add a new package (e.g. vim)
mkdir -p ~/dotfiles/vim
cp ~/.vimrc ~/dotfiles/vim/.vimrc
cd ~/dotfiles && stow vim

# Remove a package's symlinks
cd ~/dotfiles && stow -D gh

# Re-link everything
cd ~/dotfiles && ./install.sh
```
