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

# ─── PATH ────────────────────────────────────────────────────────────
# Add Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"

# Add local bin
export PATH="$HOME/.local/bin:$PATH"

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

# dev-setup
for f in /Users/shariqhirani/dev/dev-setup/home/.zshrc.d/*.zsh; do [[ -r "$f" ]] && source "$f"; done
