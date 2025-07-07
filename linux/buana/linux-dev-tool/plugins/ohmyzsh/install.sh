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

# Fungsi untuk menambahkan alias ldt ke .zshrc
setup_ldt_alias() {
    local ldt_path="$(dirname "$PLUGIN_DIR")/linux-dev-tool"
    local alias_line="alias ldt='$ldt_path'"
    
    echo "Mengatur alias ldt..."
    
    # Hapus alias lama jika ada
    sed -i '/^alias ldt=/d' "$HOME/.zshrc"
    
    # Tambahkan alias baru di bagian yang sesuai
    if grep -q "# Custom aliases" "$HOME/.zshrc"; then
        # Tambahkan setelah baris "# Custom aliases"
        sed -i "/# Custom aliases/a $alias_line" "$HOME/.zshrc"
    else
        # Jika tidak menemukan bagian custom aliases, tambahkan di akhir file
        echo -e "\n# Linux Dev Tool alias\n$alias_line" >> "$HOME/.zshrc"
    fi
    
    echo "✓ Alias 'ldt' berhasil ditambahkan ke .zshrc"
    echo "  Jalankan 'source ~/.zshrc' untuk menerapkan perubahan atau buka terminal baru"
}

# Fungsi untuk mengkonfigurasi .zshrc
configure_zshrc() {
    echo "Mengkonfigurasi .zshrc..."
    
    # Backup .zshrc yang ada
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Buat string plugins
    local plugins_str=$(IFS=' '; echo "${PLUGINS[*]}")
    
    # Tulis konfigurasi baru
    cat > "$HOME/.zshrc" << EOL
# If you come from bash you might have to change your \$PATH.
export PATH=\$HOME/bin:/usr/local/bin:\$PATH

# Path to your oh-my-zsh installation.
export ZSH="\$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="$ZSH_THEME"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    $plugins_str
)

# Load Oh My Zsh
source \$ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:\$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n \$SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ========================================
# Custom aliases
# ========================================

# Linux Dev Tool alias
alias ldt='$PLUGIN_DIR/../../linux-dev-tool'

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Load extra aliases if exist
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# Load custom functions
if [ -f ~/.zsh_functions ]; then
    . ~/.zsh_functions
fi

# Load local zsh customizations
if [ -f ~/.zsh_local ]; then
    . ~/.zsh_local
fi

# Set ZSH options
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks   # remove superfluous blanks from history items
setopt inc_append_history   # save history entries as soon as they are entered
setopt share_history        # share history between different instances of the shell

# Enable autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#888888,bg=#333333,bold,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Load zsh-syntax-highlighting (should be at the end of .zshrc)
source \$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# Load zsh-autosuggestions (should be at the end of .zshrc)
source \$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
EOL

    # Setup ldt alias
    setup_ldt_alias
    
    echo "✓ Konfigurasi .zshrc selesai"
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

# Fungsi untuk menangani command suggestions
command_suggestions() {
    local utils_script="$(dirname "$0")/command-suggestions.sh"
    
    if [ ! -f "$utils_script" ]; then
        echo "✗ File command-suggestions.sh tidak ditemukan"
        return 1
    fi
    
    bash "$utils_script" "$@"
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
    backup-suggestions)
        shift
        command_suggestions backup "$@"
        ;;
    restore-suggestions)
        shift
        command_suggestions restore "$@"
        ;;
    list-suggestions)
        shift
        command_suggestions list "$@"
        ;;
    clean-suggestions)
        shift
        command_suggestions clean "$@"
        ;;
    *)
        echo "Penggunaan: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  install             : Install Oh My Zsh"
        echo "  uninstall           : Hapus Oh My Zsh"
        echo "  status              : Tampilkan status instalasi"
        echo "  backup-suggestions  : Backup command suggestions"
        echo "  restore-suggestions : Restore command suggestions dari backup"
        echo "  list-suggestions    : Tampilkan daftar backup yang tersedia"
        echo "  clean-suggestions [n]: Hapus backup yang lebih lama dari n hari (default: 30)"
        echo ""
        exit 1
        ;;
esac

exit 0
