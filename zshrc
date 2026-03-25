export EDITOR=vim 

# ==========================================
# ALIAS PER GESTIONE ENERGETICA E AMBIENTE
# ==========================================



# --- 1. Docker e Kubernetes (Minikube) ---
alias lab-up='sudo systemctl start docker && minikube start && echo "⚡ Lab Online! (Docker e Minikube attivi)"'
alias lab-down='minikube stop && sudo systemctl stop docker && echo "💤 Lab Spento. Batteria salva!"'


# --- 2. Gestione Energetica (TLP) ---
alias power-save='sudo systemctl start tlp && echo "🍃 Risparmio energetico TLP ATTIVATO"'
alias power-max='sudo systemctl stop tlp && echo "🔥 Risparmio energetico TLP DISATTIVATO (Prestazioni massime)"'

# --- 3. Interfaccia Grafica (Headless vs GUI) ---
# Cambia l'ambiente immediatamente senza riavviare
alias gui-start='sudo systemctl isolate graphical.target'
alias gui-stop='sudo systemctl isolate multi-user.target && echo "🖥️ Interfaccia grafica terminata."'
# Cambia cosa succederà al prossimo avvio del PC
alias boot-cli='sudo systemctl set-default multi-user.target && echo "Al prossimo avvio: Solo Terminale (Headless)"'
alias boot-gui='sudo systemctl set-default graphical.target && echo "Al prossimo avvio: Interfaccia Grafica abilitata"'

# --- 4. Radio e Antenne (Wi-Fi e Bluetooth) ---
alias radio-off='sudo rfkill block bluetooth wifi && echo "📡 Wi-Fi e Bluetooth SPENTI"'
alias radio-on='sudo rfkill unblock bluetooth wifi && echo "📡 Wi-Fi e Bluetooth ACCESI"'

# ==========================================
# SUPER-ALIAS (Tutto in uno)
# ==========================================
alias server-mode='gui-stop; radio-off; lab-down; power-save; echo "🦇 Modalità Server Headless Attiva (Max risparmio)"'
alias desktop-mode='power-max; radio-on; gui-start; echo "🚀 Modalità Desktop Attiva (Bentornato!)"'
export PATH=$PATH:$HOME/go/bin
alias book="libgen-downloader -s"
alias paper='scidownl'
source /opt/2025.2/Vivado/settings64.sh

# Redirect Vivado trash to cache
function vivado() {
    mkdir -p ~/.cache/vivado
    command vivado -log ~/.cache/vivado/vivado.log -journal ~/.cache/vivado/vivado.jou "$@"
}
