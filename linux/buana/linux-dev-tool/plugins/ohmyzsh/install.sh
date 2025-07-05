#!/bin/bash

# Dapatkan direktori script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")/$(basename "$SCRIPT_DIR")"

# Muat konfigurasi
if [ -f "$PLUGIN_DIR/plugin.conf" ]; then
    source "$PLUGIN_DIR/plugin.conf"
else
    echo "Error: File konfigurasi plugin tidak ditemukan!"
    exit 1
fi

# Fungsi untuk memeriksa dependensi
check_dependencies() {
    local missing_deps=()
    
    for dep in "${DEPENDENCIES[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Dependensi yang hilang: ${missing_deps[*]}"
        echo "Menginstall dependensi..."
        sudo apt-get update
        sudo apt-get install -y "${missing_deps[@]}" || {
            echo "Gagal menginstall dependensi yang diperlukan"
            exit 1
        }
    fi
}

# Fungsi untuk menginstall Oh My Zsh
install() {
    echo "Memeriksa Oh My Zsh..."
    
    # Periksa apakah Oh My Zsh sudah terinstall
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "✓ Oh My Zsh sudah terinstall"
        return 0
    fi
    
    check_dependencies
    
    echo "Menginstall Oh My Zsh..."
    
    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Install plugin tambahan
    install_plugins
    
    # Konfigurasi .zshrc
    configure_zshrc
    
    echo ""
    echo "✓ Oh My Zsh berhasil diinstall"
    echo "Jalankan 'zsh' untuk memulai menggunakan Zsh"
    echo "Atau logout dan login kembali"
}

# Fungsi untuk menginstall plugin Zsh
install_plugins() {
    echo "Menginstall plugin Zsh..."
    
    local custom_plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    for plugin in "${ZSH_PLUGINS[@]}"; do
        echo "  - Memeriksa $plugin..."
        
        case $plugin in
            "zsh-autosuggestions")
                if [ ! -d "$custom_plugins_dir/zsh-autosuggestions" ]; then
                    git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_plugins_dir/zsh-autosuggestions"
                    echo "    ✓ zsh-autosuggestions diinstall"
                else
                    echo "    ✓ zsh-autosuggestions sudah terinstall"
                fi
                ;;
                
            "zsh-syntax-highlighting")
                if [ ! -d "$custom_plugins_dir/zsh-syntax-highlighting" ]; then
                    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_plugins_dir/zsh-syntax-highlighting"
                    echo "    ✓ zsh-syntax-highlighting diinstall"
                else
                    echo "    ✓ zsh-syntax-highlighting sudah terinstall"
                fi
                ;;
                
            "zsh-completions")
                if [ ! -d "$custom_plugins_dir/zsh-completions" ]; then
                    git clone https://github.com/zsh-users/zsh-completions "$custom_plugins_dir/zsh-completions"
                    echo "    ✓ zsh-completions diinstall"
                else
                    echo "    ✓ zsh-completions sudah terinstall"
                fi
                ;;
                
            *)
                echo "    ✗ Plugin tidak dikenali: $plugin"
                ;;
        esac
    done
}

# Fungsi untuk mengkonfigurasi .zshrc
configure_zshrc() {
    echo "Mengkonfigurasi .zshrc..."
    
    local zshrc_file="$HOME/.zshrc"
    
    # Backup .zshrc lama jika ada
    if [ -f "$zshrc_file" ]; then
        cp "$zshrc_file" "${zshrc_file}.backup.$(date +%Y%m%d%H%M%S)"
        echo "  ✓ Backup .zshrc lama dibuat"
    fi
    
    # Buat array plugin untuk .zshrc
    local plugins_str="${ZSH_PLUGINS[*]}"
    
    # Buat .zshrc baru
    cat > "$zshrc_file" << EOF
# If you come from bash you might have to change your \$PATH.
export PATH="\$HOME/.local/bin:\$PATH"

# Path to your oh-my-zsh installation.
export ZSH="\$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="$ZSH_THEME"

# Plugin configuration
plugins=(
    $plugins_str
)

# Load Oh My Zsh
source \$ZSH/oh-my-zsh.sh

# User configuration

# Aliases
alias ll='ls -la'
alias update='sudo apt update && sudo apt upgrade -y'
alias cls='clear'

# Load custom environment variables
if [ -f ~/.env ]; then
    source ~/.env
fi

# Load zsh-completions if installed
if [ -d "\$ZSH/custom/plugins/zsh-completions" ]; then
    fpath=("\$ZSH/custom/plugins/zsh-completions" \$fpath)
    autoload -U compinit && compinit
fi
EOF
    
    echo "  ✓ .zshrc telah dikonfigurasi"
}

# Fungsi untuk menghapus Oh My Zsh
uninstall() {
    echo "Menghapus Oh My Zsh..."
    
    # Hapus direktori Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        rm -rf "$HOME/.oh-my-zsh"
        echo "  ✓ Direktori Oh My Zsh dihapus"
    fi
    
    # Kembalikan .zshrc asli jika ada backup
    if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
        mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc"
        echo "  ✓ .zshrc asli dikembalikan"
    fi
    
    echo ""
    echo "✓ Oh My Zsh telah dihapus"
    echo "Jalankan 'chsh -s $(which bash)' untuk mengembalikan shell default jika diperlukan"
}

# Fungsi untuk mengecek status Oh My Zsh
status() {
    echo "Memeriksa status Oh My Zsh..."
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "✓ Oh My Zsh terinstall"
        echo "Lokasi: $HOME/.oh-my-zsh"
        
        # Cek tema yang digunakan
        if [ -f "$HOME/.zshrc" ]; then
            local current_theme=$(grep -E '^ZSH_THEME=' "$HOME/.zshrc" | cut -d'"' -f2)
            echo "Tema: ${current_theme:-Tidak dikonfigurasi}"
            
            # Cek plugin yang aktif
            echo "Plugin yang aktif:"
            grep -A 10 '^plugins=' "$HOME/.zshrc" | grep -v '^#' | grep -v '^$' | tr -d ' ' | tr '\n' ' '
            echo ""
        fi
    else
        echo "✗ Oh My Zsh tidak terinstall"
    fi
}

# Handle command line arguments
case "$1" in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    status)
        status
        ;;
    *)
        echo "Penggunaan: $0 {install|uninstall|status}"
        exit 1
        ;;
esac

exit 0
