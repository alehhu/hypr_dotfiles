# ==========================================================
# UNIFIED ZSH CONFIGURATION (Complete & Self-Contained)
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

# --- 3. Startup Art (Pokemon Feature) ---
if [[ $- == *i* ]]; then
    # Prioritize fastfetch as it is configured to show the pokemon
    if command -v fastfetch >/dev/null; then
        fastfetch
    elif command -v pokemon-colorscripts-go >/dev/null; then
        pokemon-colorscripts-go --no-title -r 1-8
    elif command -v pokego >/dev/null; then
        pokego --no-title -r 1,3,6
    elif command -v pokemon-colorscripts >/dev/null; then
        pokemon-colorscripts --no-title -r 1,3,6
    fi
fi

# --- 4. Plugin Manager (Zinit) ---
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
zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-history-substring-search
zinit light djui/alias-tips

# Snippets (OMZ)
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# --- 5. Theme & Prompt ---
ZSH_THEME="robbyrussell"
if [[ -f $ZSH/oh-my-zsh.sh ]]; then
    source $ZSH/oh-my-zsh.sh
fi

# --- 6. Custom Aliases ---

# Docker & Kubernetes (Minikube)
alias lab-up='sudo systemctl start docker && minikube start && echo "⚡ Lab Online! (Docker e Minikube attivi)"'
alias lab-down='minikube stop && sudo systemctl stop docker && echo "💤 Lab Spento. Batteria salva!"'

# Gestione Energetica (TLP)
alias power-save='sudo systemctl start tlp && echo "🍃 Risparmio energetico TLP ATTIVATO"'
alias power-max='sudo systemctl stop tlp && echo "🔥 Risparmio energetico TLP DISATTIVATO (Prestazioni massime)"'

# Interfaccia Grafica (Headless vs GUI)
alias gui-start='sudo systemctl isolate graphical.target'
alias gui-stop='sudo systemctl isolate multi-user.target && echo "🖥️ Interfaccia grafica terminata."'
alias boot-cli='sudo systemctl set-default multi-user.target && echo "Al prossimo avvio: Solo Terminale (Headless)"'
alias boot-gui='sudo systemctl set-default graphical.target && echo "Al prossimo avvio: Interfaccia Grafica abilitata"'

# Radio e Antenne (Wi-Fi e Bluetooth)
alias radio-off='sudo rfkill block bluetooth wifi && echo "📡 Wi-Fi e Bluetooth SPENTI"'
alias radio-on='sudo rfkill unblock bluetooth wifi && echo "📡 Wi-Fi e Bluetooth ACCESI"'

# Modalità di Sistema (Tutto in uno)
alias server-mode='gui-stop; radio-off; lab-down; power-save; echo "🦇 Modalità Server Headless Attiva (Max risparmio)"'
alias desktop-mode='power-max; radio-on; gui-start; echo "🚀 Modalità Desktop Attiva (Bentornato!)"'

# Utils
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'
alias book="libgen-downloader -s"
alias paper='scidownl'
alias ff='fastfetch'
alias fastfetch='fastfetch --logo-type kitty'

# --- 7. Custom Functions ---

# ROS2 Humble (Docker Mode)
# Minimal, GUI-enabled environment
ros-start() {
    # Check if we are in a ROS2 project folder (which MUST have a src/ folder)
    if [ -d "./src" ]; then
        export ROS_WS_ROOT="$(pwd)"
        echo "📂 Detected ROS2 Workspace Root: $ROS_WS_ROOT"
    else
        export ROS_WS_ROOT="$HOME/ros2-workspace"
        echo "📂 No local 'src' found. Using default: $HOME/ros2-workspace"
    fi

    xhost +local:docker >/dev/null
    docker compose -f ~/ros2-workspace/docker-compose.yml up -d --build
    echo "🐳 ROS2: Humble is ONLINE (GUI enabled)"
}
alias ros-shell='docker exec -it ros2_humble bash -c "source /opt/ros/humble/setup.bash && [ -f install/setup.bash ] && source install/setup.bash; exec bash"'
alias ros-stop='docker compose -f ~/ros2-workspace/docker-compose.yml down && xhost -local:docker >/dev/null && echo "💤 ROS2: Humble is OFFLINE"'

function vivado() {
    mkdir -p ~/.cache/vivado
    if [ -f /opt/2025.2/Vivado/settings64.sh ]; then
        source /opt/2025.2/Vivado/settings64.sh
    fi
    command vivado -log ~/.cache/vivado/vivado.log -journal ~/.cache/vivado/vivado.jou "$@"
}

# --- 8. Final Polishing ---
fpath=($ZDOTDIR/completions "${fpath[@]}")
autoload -Uz compinit && compinit -C

# Keybinds
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
