# ─── General Settings ────────────────────────────────────────────────
# Default directory — only auto-cd when shell starts at $HOME
# (avoids clobbering cwd when launched from Solo, IDEs, etc.)
[[ "$PWD" == "$HOME" ]] && cd ~/dev

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY          # append instead of overwrite
setopt INC_APPEND_HISTORY      # write after each command, not at exit
setopt HIST_IGNORE_DUPS        # skip consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS    # remove older duplicate from history
setopt HIST_REDUCE_BLANKS      # trim extra whitespace
setopt HIST_IGNORE_SPACE       # don't save commands starting with space
setopt SHARE_HISTORY           # share history across sessions

# Directory navigation
setopt AUTO_CD                 # type a directory name to cd into it
setopt AUTO_PUSHD              # cd pushes old dir onto stack
setopt PUSHD_IGNORE_DUPS       # no duplicate dirs on stack
setopt PUSHD_SILENT            # don't print stack after pushd/popd

# Misc
setopt NO_BEEP                 # silence terminal bell
setopt INTERACTIVE_COMMENTS    # allow # comments in interactive shell
setopt CORRECT                 # suggest corrections for mistyped commands

# ─── Completion ──────────────────────────────────────────────────────
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit          # enables bash-style `complete` (terraform, vault, etc.)
zstyle ':completion:*' menu select                    # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # colored completions

# ─── Key Bindings ────────────────────────────────────────────────────
bindkey -e                     # emacs-style keybindings (default on macOS)
bindkey '^[[A' history-search-backward   # up arrow: search history
bindkey '^[[B' history-search-forward    # down arrow: search history

# ─── Prompt ──────────────────────────────────────────────────────────
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'   # show git branch

setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f %# '

# ─── Aliases ─────────────────────────────────────────────────────────
alias ll='eza -la --icons --git'
alias la='eza -a --icons'
alias lt='eza -la --icons --tree --level=2'
alias cat='bat --paging=never'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'

# Shortcuts
alias ubi='ssh shariq@shariq-dev.duckdns.org'
alias cyolo='claude --dangerously-skip-permissions'
# One-shot gcloud re-auth: refreshes both user creds and Application Default
# Credentials in a single browser tab. Use until org session-length policy
# is extended in Workspace Admin.
alias gauth='gcloud auth login --update-adc'

# ─── PATH ────────────────────────────────────────────────────────────
# Add Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"

# Add local bin
export PATH="$HOME/.local/bin:$PATH"

# ─── Tool integrations ───────────────────────────────────────────────
# Terraform autocomplete
command -v terraform &>/dev/null && complete -o nospace -C "$(command -v terraform)" terraform

# Google Cloud SDK (PATH + completion)
[ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ] && . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'
[ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ] && . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'

# Notion CLI (ntn) — per-workspace PAT wrappers backed by 1Password.
# `op read` resolves silently via the 1Password Service Account token set in
# ~/.zshenv. The in-shell token cache below is a minor perf win (saves the
# network round-trip); `ntn-flush` clears it (e.g. after rotating a PAT).
_ntn_with_pat() {
  local pat_path="$1" cache_var="$2"; shift 2
  local token="${(P)cache_var}"
  if [[ -z "$token" ]]; then
    token="$(op read "$pat_path")" || { echo "ntn: failed to read $pat_path from 1Password" >&2; return 1; }
    [[ -z "$token" ]] && { echo "ntn: $pat_path is empty — fill it in 1Password first" >&2; return 1; }
    typeset -g "$cache_var=$token"
  fi
  NOTION_API_TOKEN="$token" command ntn "$@"
}
ntn-personal()  { _ntn_with_pat 'op://dev-env-vars/notion/personal'        '_NTN_TOK_PERSONAL' "$@"; }
ntn-cwx-airn()  { _ntn_with_pat 'op://dev-env-vars/notion/shariq-pat-airn' '_NTN_TOK_AIRN'     "$@"; }
ntn-cwx-pp()    { _ntn_with_pat 'op://dev-env-vars/notion/shariq-pat-pp'   '_NTN_TOK_PP'       "$@"; }
ntn-flush()     { unset _NTN_TOK_PERSONAL _NTN_TOK_AIRN _NTN_TOK_PP; echo "ntn: token cache cleared"; }

# Quick todo: AI-categorized GitHub issue
todo() {
  if [ -z "$1" ]; then
    echo "Usage: todo <task> | todo repeat ... | todo ?"
    return 1
  fi
  WFDIR="$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/user.workflow.todo-github"
  OUTPUT=$("$WFDIR/todo.sh" "$*")
  echo "$OUTPUT"
}

# Show todo help
function 'todo?' {
  bash "$HOME/Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/user.workflow.todo-github/help.sh"
}
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/shariqhirani/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# dev-setup (no-op if the directory isn't present; (N) prevents an unmatched-glob error)
for f in /Users/shariqhirani/dev/dev-setup/home/.zshrc.d/*.zsh(N); do [[ -r "$f" ]] && source "$f"; done

# ─── Local overrides ─────────────────────────────────────────────────
# Machine-specific config (secrets, personal paths, host-only aliases).
# Not tracked in the dotfiles repo; sourced last so it can override anything above.
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
