# ─── General Settings ────────────────────────────────────────────────
# Default directory — only auto-cd when shell starts at $HOME
# (avoids clobbering cwd when launched from Solo, IDEs, etc.)
[[ "$PWD" == "$HOME" && -d ~/dev ]] && cd ~/dev

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
# Up/down: search history by the WHOLE text typed before the cursor (not just
# the first word). So `claude --resume`<Up> cycles only `claude --resume …`
# entries. Falls back to normal line motion inside multi-line buffers.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # up arrow
bindkey '^[[B' down-line-or-beginning-search  # down arrow
bindkey '^[OA' up-line-or-beginning-search    # up arrow (application cursor mode)
bindkey '^[OB' down-line-or-beginning-search  # down arrow (application cursor mode)

# Word-by-word cursor movement. Esc-f / Esc-b (^[f/^[b) are already bound by
# emacs mode; these add the CSI sequences iTerm sends when Option/Control report
# as a modifier (rather than Esc+), so Option+←/→ and Ctrl+←/→ jump by word.
bindkey '^[[1;3C' forward-word  '^[[1;3D' backward-word   # Option + → / ←
bindkey '^[[1;5C' forward-word  '^[[1;5D' backward-word   # Control + → / ←

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

# GitHub CLI completion (commands, subcommands, flag names).
# Note: gh does NOT natively complete repo names for --repo/-R.
command -v gh &>/dev/null && eval "$(gh completion -s zsh)"

# Add repo-name completion after --repo/-R (gh has no native support). Serves
# your own repos plus those of any orgs in $GH_REPO_COMPLETE_ORGS, cached daily
# so Tab stays instant; force a refresh with `rm ~/.cache/gh-repo-list`.
# Delegates everything else to gh's own completer (_gh) so it survives gh
# upgrades. Set the org list (work-specific) in ~/.zshrc.local, e.g.:
#   GH_REPO_COMPLETE_ORGS=(Some-Org Another-Org)
typeset -ga GH_REPO_COMPLETE_ORGS
if command -v gh &>/dev/null; then
  _gh_with_repos() {
    if [[ ${words[CURRENT-1]} == (--repo|-R) ]]; then
      local cache="${XDG_CACHE_HOME:-$HOME/.cache}/gh-repo-list"
      [[ -d ${cache:h} ]] || mkdir -p ${cache:h}
      local -a fresh=( $cache(Nmh-24) )          # exists & <24h old?
      if (( ! ${#fresh} )); then
        { gh repo list --limit 300 --json nameWithOwner -q '.[].nameWithOwner'
          local org
          for org in $GH_REPO_COMPLETE_ORGS; do
            gh repo list "$org" --limit 300 --json nameWithOwner -q '.[].nameWithOwner'
          done
        } >| $cache 2>/dev/null
      fi
      compadd -- "${(@f)$(<$cache 2>/dev/null)}"
      return
    fi
    _gh
  }
  compdef _gh_with_repos gh
fi

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
ntn-personal()  { _ntn_with_pat 'op://dev-env-vars/notion-personal/Claude Code MCP Access Token' '_NTN_TOK_PERSONAL' "$@"; }
ntn-cwx-airn()  { _ntn_with_pat 'op://dev-env-vars/5pqlb26twvdfmlr3vviuxps2i4/shariq-pat-airn' '_NTN_TOK_AIRN'     "$@"; }
ntn-cwx-pp()    { _ntn_with_pat 'op://dev-env-vars/5pqlb26twvdfmlr3vviuxps2i4/shariq-pat-pp'   '_NTN_TOK_PP'       "$@"; }
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

# ─── Autocomplete & interactive enhancements ─────────────────────────
# Fish-style inline suggestions from history — the greyed-out completion
# appears as you type; accept the whole thing with → (or End), or accept
# one word with Ctrl-→. Just keep typing to ignore it.
[[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf: fuzzy Ctrl-R history search overlay, Ctrl-T file picker, Alt-C cd.
# `fzf --zsh` emits the key-bindings + completion setup (fzf ≥ 0.48).
command -v fzf &>/dev/null && eval "$(fzf --zsh)"

# Move the cursor over the next *shell word*: treats a quoted string like
# "foo bar" (or 'foo bar') as ONE token instead of stranding on the opening
# quote. Registered with the autosuggestions plugin so its partial-accept
# logic accepts exactly this much of the suggestion.
_forward-shell-word() {
  emulate -L zsh
  local rest=${BUFFER[CURSOR+1,-1]}
  local pat='^[[:space:]]*("[^"]*"?|'\''[^'\'']*'\''?|[^[:space:]]+)'
  if [[ $rest =~ $pat ]]; then (( CURSOR += ${#MATCH} )); else zle forward-word; fi
}
zle -N _forward-shell-word
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(_forward-shell-word)

# Tab: if an inline suggestion is showing, accept its next shell word (so a
# quoted arg comes in whole); otherwise fall through to normal completion
# (fzf's if present). Space always stays a literal space. Bound AFTER fzf.
_accept_suggested_word_or_complete() {
  if [[ -n "$POSTDISPLAY" ]]; then
    zle _forward-shell-word
  elif (( ${+widgets[fzf-completion]} )); then
    zle fzf-completion
  else
    zle expand-or-complete
  fi
}
zle -N _accept_suggested_word_or_complete
bindkey '^I' _accept_suggested_word_or_complete   # ^I = Tab

# ─── Local overrides ─────────────────────────────────────────────────
# Machine-specific config (secrets, personal paths, host-only aliases).
# Not tracked in the dotfiles repo; sourced last so it can override anything above.
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# ─── Syntax highlighting ─────────────────────────────────────────────
# MUST be sourced last: it wraps every ZLE widget defined above (including
# our history-search bindings and autosuggestions) to colorize the command
# line as you type — valid commands green, unknown ones red.
[[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
