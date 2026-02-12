# shellcheck shell=bash
# ═══════════════════════════════════════════════════════════════════
# Shell Aliases
# ═══════════════════════════════════════════════════════════════════

# ── Navigation ───────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ── Modern replacements ──────────────────────────────────────────
# These only activate if the tool is installed
command -v eza  &>/dev/null && alias ls='eza --icons --group-directories-first'
command -v eza  &>/dev/null && alias ll='eza -la --icons --group-directories-first'
command -v eza  &>/dev/null && alias lt='eza -la --icons --tree --level=2'
command -v bat  &>/dev/null && alias cat='bat --paging=never --style=plain'
command -v rg   &>/dev/null && alias grep='rg'
command -v fd   &>/dev/null && alias find='fd'
command -v btm  &>/dev/null && alias top='btm'

# ── Git ──────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -20'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
command -v lazygit &>/dev/null && alias lg='lazygit'

# ── Distrobox ────────────────────────────────────────────────────
alias db='distrobox enter dev'
alias dbs='distrobox stop dev'
alias dbl='distrobox list'

# ── System ───────────────────────────────────────────────────────
alias update='sudo apt update && sudo apt upgrade -y && flatpak update -y && distrobox enter dev -- sudo pacman -Syu --noconfirm'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'
alias reboot='sudo systemctl reboot'
alias poweroff='sudo systemctl poweroff'

# ── Misc ─────────────────────────────────────────────────────────
alias c='clear'
alias e='$EDITOR'
alias v='nvim'
alias py='python3'
alias mkdir='mkdir -pv'
alias df='df -h'
alias du='du -sh'
alias wget='wget -c'
alias myip='curl -s ifconfig.me'
