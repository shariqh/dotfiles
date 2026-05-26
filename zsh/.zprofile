# Homebrew (also available in interactive shells, but ensures login shells get it)
eval "$(/opt/homebrew/bin/brew shellenv)"

# fnm (Fast Node Manager) — auto-switch on .nvmrc / .node-version
eval "$(fnm env --use-on-cd --shell zsh)"

# Copilot CLI: load global custom instructions from ~/.copilot/AGENTS.md
export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$HOME/.copilot"
