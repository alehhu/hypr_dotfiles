# ==========================================================
# UNIFIED ZSH CONFIGURATION (Clean Style)
# ==========================================================

# --- 1. Environment & Paths ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH="$ZDOTDIR/ohmyzsh"
export EDITOR=vim 
export PATH=$PATH:$HOME/go/bin

# --- 2. History Configuration ---
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS

# --- 3. Plugin Manager (Zinit) ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Essential Plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light hlissner/zsh-autopair
zinit light Aloxaf/fzf-tab
zinit light rupa/z
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# --- 4. Theme (Original robbyrussell) ---
# We disable Starship and use the classic Oh My Zsh theme
ZSH_THEME="robbyrussell"

# Load Oh My Zsh
if [[ -f $ZSH/oh-my-zsh.sh ]]; then
    source $ZSH/oh-my-zsh.sh
fi

# --- 5. Custom Aliases ---

# Docker & Kubernetes
alias lab-up='sudo systemctl start docker && minikube start && echo "⚡ Lab Online!"'
alias lab-down='minikube stop && sudo systemctl stop docker && echo "💤 Lab Offline."'

# Power Management (TLP)
alias power-save='sudo systemctl start tlp && echo "🍃 Power Save ON"'
alias power-max='sudo systemctl stop tlp && echo "🔥 Max Performance ON"'

# Display & Boot Targets
alias gui-start='sudo systemctl isolate graphical.target'
alias gui-stop='sudo systemctl isolate multi-user.target'
alias boot-cli='sudo systemctl set-default multi-user.target'
alias boot-gui='sudo systemctl set-default graphical.target'

# Radio Controls
alias radio-off='sudo rfkill block bluetooth wifi'
alias radio-on='sudo rfkill unblock bluetooth wifi'

# System Modes
alias server-mode='gui-stop; radio-off; lab-down; power-save; echo "🦇 Server Mode Active"'
alias desktop-mode='power-max; radio-on; gui-start; echo "🚀 Desktop Mode Active"'

# Utils
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'
alias book="libgen-downloader -s"
alias paper='scidownl'
alias fastfetch='fastfetch --logo-type kitty'

# --- 6. Custom Functions ---
function vivado() {
    mkdir -p ~/.cache/vivado
    [ -f /opt/2025.2/Vivado/settings64.sh ] && source /opt/2025.2/Vivado/settings64.sh
    command vivado -log ~/.cache/vivado/vivado.log -journal ~/.cache/vivado/vivado.jou "$@"
}

# --- 7. Startup Art (Single Fastfetch) ---
if [[ $- == *i* ]]; then
    if command -v pokego >/dev/null; then
        pokego --no-title -r 1,3,6
    elif command -v pokemon-colorscripts >/dev/null; then
        pokemon-colorscripts --no-title -r 1,3,6
    elif command -v fastfetch >/dev/null; then
        fastfetch --logo-type kitty
    fi
fi

# --- 8. Final Polishing ---
fpath=($ZDOTDIR/completions "${fpath[@]}")
autoload -Uz compinit && compinit -C

# Keybinds
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
