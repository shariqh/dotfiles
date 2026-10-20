# Homebrew (also available in interactive shells, but ensures login shells get it)
eval "$(/opt/homebrew/bin/brew shellenv)"

# fnm (Fast Node Manager) — auto-switch on .nvmrc / .node-version
eval "$(fnm env --use-on-cd --shell zsh)"
