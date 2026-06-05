# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

> **Assumes macOS on Apple Silicon** — Homebrew at `/opt/homebrew`. On Intel macs the
> hardcoded `/opt/homebrew/...` paths (Homebrew shellenv, gcloud, the zsh plugins) silently
> no-op; swap them to `/usr/local` if you ever run there.

## What's included

| Package | Files                   | What it configures |
|---------|-------------------------|--------------------|
| `zsh`   | `.zshrc`, `.zprofile`   | Shell options, prompt, aliases, PATH, completion, interactive enhancements |
| `gh`    | `.config/gh/config.yml` | GitHub CLI settings & aliases |

### Shell experience (zsh)

- **History prefix search** — type any prefix, then ↑/↓ cycles only matching history
  (e.g. `claude --resume`↑ matches the whole line, not just `claude`).
- **Inline autosuggestions** ([zsh-autosuggestions]) — greyed completion from history;
  **→**/**End** accepts the whole thing, **Tab** accepts one shell-word (a quoted arg comes
  in whole), Space stays a literal space.
- **Fuzzy history** ([fzf]) — **Ctrl-R** fuzzy history overlay, **Ctrl-T** file picker, **Alt-C** cd.
- **Syntax highlighting** ([zsh-syntax-highlighting]) — valid commands green, unknown red.
- **gh completion** — commands/subcommands/flags, **plus repo-name completion** for `--repo`/`-R`
  (gh has none natively): your own repos + any orgs you configure, cached daily.

[zsh-autosuggestions]: https://github.com/zsh-users/zsh-autosuggestions
[zsh-syntax-highlighting]: https://github.com/zsh-users/zsh-syntax-highlighting
[fzf]: https://github.com/junegunn/fzf

## Setup on a new machine

```bash
# 1. Install prerequisites
brew install stow eza bat fnm fzf gh \
  zsh-autosuggestions zsh-syntax-highlighting

# 2. Clone and link
git clone git@github.com:shariqh/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh

# 3. Authenticate gh (needed for --repo completion to fetch your repo list)
gh auth login
```

`install.sh` symlinks each package into `~/` via Stow. Existing files are adopted into the repo,
then restored to the repo version. It refuses to run with a dirty working tree (the post-adopt
`git checkout` would otherwise wipe uncommitted edits).

## Machine-specific config (`~/.zshrc.local`, untracked)

Anything that shouldn't be shared across machines goes in `~/.zshrc.local`, sourced at the end of
`.zshrc` (so it overrides the tracked config) but not committed. Examples:

- Paths to local dev tooling, host-only aliases, work-specific env vars
- Docker Desktop completions
- **`GH_REPO_COMPLETE_ORGS`** — orgs to include in `gh --repo` completion besides your own:
  ```zsh
  GH_REPO_COMPLETE_ORGS=(Coreworx-LLC bundlellc)
  ```

Secrets (e.g. the 1Password service-account token used by the `ntn` wrappers) live in `~/.zshenv` —
also untracked, `chmod 600`.

## Optional runtime dependencies

The tracked `.zshrc` registers integrations only when the tool is present, so missing tools degrade
silently. Install on demand:

- `gh` — GitHub CLI, drives the repo completion above (`brew install gh`, then `gh auth login`)
- `gcloud` — Google Cloud SDK (`brew install --cask google-cloud-sdk`)
- `terraform` — `brew install terraform`
- `op` — 1Password CLI, required by the `ntn-*` Notion wrappers (`brew install --cask 1password-cli`)

## Personal / host-specific bits (won't carry over)

A few things in the tracked `.zshrc` are tied to this account/host. They degrade quietly (only fail
if invoked or no-op when absent), but they **won't do anything useful on another machine or for
anyone else** — they're documented here rather than parameterized:

- `ntn-*` Notion wrappers → reference a personal **1Password vault** (`op://dev-env-vars/...`)
- `todo` / `todo?` → call a specific **Alfred workflow** at a hardcoded path
- `dev-setup` source + Docker completion `fpath` → personal absolute paths (your username baked in)
- `ubi` alias → a personal SSH host

## Upgrading / maintenance

**Refresh the gh repo-completion cache** (e.g. after creating a repo):
```bash
rm ~/.cache/gh-repo-list      # rebuilds on the next `--repo <Tab>`; auto-refreshes when >24h old
```

**Add / remove orgs in repo completion:** edit `GH_REPO_COMPLETE_ORGS` in `~/.zshrc.local`, then
`rm ~/.cache/gh-repo-list`. (List your orgs with `gh api user/orgs --jq '.[].login'`.)

**Upgrade the shell tools:**
```bash
brew upgrade        # or target them: brew upgrade fzf gh eza bat zsh-autosuggestions zsh-syntax-highlighting
```
`gh`'s completion script is regenerated on every shell start (`eval "$(gh completion -s zsh)"`), so
upgrading `gh` needs no extra step.

**After editing a config** (symlinks mean editing `~/.zshrc` edits the repo copy):
```bash
cd ~/dotfiles && git add -A && git commit -m "..." && git push
```

**Pull updates on another machine:**
```bash
git -C ~/dotfiles pull && exec zsh      # exec zsh reloads the shell
```

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
