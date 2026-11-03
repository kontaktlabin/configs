# =====================================================================
# .zshrc - Unified Shell Configuration (macOS & Arch Linux)
# =====================================================================

[[ $- != *i* ]] && return

# ---------------------------------------------------------------------
# 1. PATH CONFIGURATION & TOOLCHAIN SETUP
# ---------------------------------------------------------------------


# ---------------------------------------------------------------------
# 3. HISTORY & SHELL BEHAVIOR OPTIONS
# ---------------------------------------------------------------------
export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=500
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS


if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
  fi

# ---------------------------------------------------------------------
# 4. FILE MANAGEMENT & NAVIGATION ALIASES
# ---------------------------------------------------------------------
alias cat='bat'
alias ls='eza -h --color=always --group-directories-first --icons=always'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias tree='eza --tree'

alias cp='cp -riv'
alias mkdir='mkdir -vp'
alias mv='mv -iv'
alias rm='rm -riv'
alias rs='rsync -r --info=progress2'

alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -m'
alias topdisk='du -a . | sort -n -r | head -n 10'
alias ip='ip -color=auto'

# ---------------------------------------------------------------------
# 5. SYSTEM UTILITIES & PACKAGE MANAGEMENT
# ---------------------------------------------------------------------
alias pmrefresh='sudo reflector --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'

# ---------------------------------------------------------------------
# 6. THIRD-PARTY TOOLS & INTEGRATIONS
# ---------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# ---------------------------------------------------------------------
# SESSION ENVIRONMENT
# ---------------------------------------------------------------------
if [[ -f "$HOME/.config/environment.d/session.conf" ]]; then
    set -a
    source "$HOME/.config/environment.d/session.conf"
    set +a
fi

