#!/bin/bash

# Warna untuk output
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

# Fungsi untuk menampilkan pesan suksen
success() {
    echo -e "${COLOR_GREEN}✓ $1${COLOR_RESET}"
}

# Fungsi untuk menampilkan pesan error
error() {
    echo -e "${COLOR_RED}✗ $1${COLOR_RESET}"
}

# Fungsi untuk menampilkan pesan info
info() {
    echo -e "${COLOR_BLUE}➜ $1${COLOR_RESET}"
}

# Fungsi untuk memeriksa apakah perintah ada
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Fungsi untuk menginstall Zsh
install_zsh() {
    if ! command_exists zsh; then
        info "Menginstall Zsh..."
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y zsh
        elif command_exists yum; then
            sudo yum install -y zsh
        elif command_exists dnf; then
            sudo dnf install -y zsh
        else
            error "Package manager tidak didukung. Silakan install zsh secara manual."
            exit 1
        fi
        
        if [ $? -eq 0 ]; then
            success "Zsh berhasil diinstall"
        else
            error "Gagal menginstall Zsh"
            exit 1
        fi
    else
        success "Zsh sudah terinstall"
    fi
}

# Fungsi untuk menginstall Oh My Zsh
install_ohmyzsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        info "Menginstall Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        
        if [ $? -eq 0 ]; then
            success "Oh My Zsh berhasil diinstall"
        else
            error "Gagal menginstall Oh My Zsh"
            exit 1
        fi
    else
        success "Oh My Zsh sudah terinstall"
    fi
}

# Fungsi untuk mengatur Zsh sebagai shell default (tanpa password)
set_default_shell() {
    local current_shell=$(basename "$SHELL")
    local zsh_path=$(command -v zsh)
    
    if [ "$current_shell" != "zsh" ]; then
        info "Mencoba mengatur Zsh sebagai shell default..."
        if [ -n "$zsh_path" ]; then
            # Coba tanpa sudo dulu
            if chsh -s "$zsh_path" "$USER" 2>/dev/null; then
                success "Zsh telah diatur sebagai shell default"
            else
                info "Tidak bisa mengubah shell default tanpa password"
                info "Anda bisa mengubah shell default secara manual dengan perintah:"
                echo -e "${COLOR_BLUE}chsh -s $(which zsh)${COLOR_RESET}"
                info "Atau jalankan 'zsh' untuk menggunakan zsh di sesi ini"
                return 1
            fi
        else
            error "Zsh tidak ditemukan"
            return 1
        fi
    else
        success "Zsh sudah menjadi shell default"
    fi
}

# Fungsi untuk menginstall ldt
install_ldt() {
    local ldt_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/linux-dev-tool"
    local zsh_aliases="$HOME/.zsh_aliases"
    
    # Buat file .zsh_aliases jika belum ada
    if [ ! -f "$zsh_aliases" ]; then
        touch "$zsh_aliases"
        echo "# File untuk menyimpan alias kustom" > "$zsh_aliases"
    fi
    
    # Tambahkan alias ldt ke .zsh_aliases
    if ! grep -q "alias ldt=" "$zsh_aliases"; then
        echo "alias ldt='$ldt_path'" >> "$zsh_aliases"
        success "Alias 'ldt' ditambahkan ke $zsh_aliases"
    else
        # Update alias yang sudah ada
        sed -i "s|^alias ldt=.*|alias ldt='$ldt_path'|" "$zsh_aliases"
        success "Alias 'ldt' diperbarui di $zsh_aliases"
    fi
    
    # Pastikan .zshrc memuat .zsh_aliases
    if [ -f "$HOME/.zshrc" ] && ! grep -q "source \$HOME/.zsh_aliases" "$HOME/.zshrc"; then
        echo -e "\n# Muat alias kustom\nif [ -f ~/.zsh_aliases ]; then\n    . ~/.zsh_aliases\nfi" >> "$HOME/.zshrc"
    fi
    
    # Buat file ldt executable
    if [ -f "$ldt_path" ]; then
        chmod +x "$ldt_path"
        success "Linux Dev Tool (ldt) siap digunakan"
        echo -e "\n${COLOR_YELLOW}Untuk menggunakan ldt, jalankan perintah:${COLOR_RESET}"
        echo -e "${COLOR_BLUE}1. source ~/.zshrc${COLOR_RESET} (atau buka terminal baru)"
        echo -e "${COLOR_BLUE}2. ldt --help${COLOR_RESET} untuk melihat daftar perintah"
    else
        error "File linux-dev-tool tidak ditemukan di $ldt_path"
        return 1
    fi
}

# Fungsi utama
main() {
    echo -e "${COLOR_BLUE}=== Linux Dev Tool Installer ===${COLOR_RESET}\n"
    
    # Pastikan script dijalankan dengan bash
    if [ -z "$BASH_VERSION" ]; then
        error "Script ini harus dijalankan dengan bash"
        exit 1
    fi
    
    # Pastikan script dijalankan sebagai user biasa
    if [ "$EUID" -eq 0 ]; then
        error "Jangan jalankan script ini sebagai root. Jalankan sebagai user biasa."
        exit 1
    fi
    
    # Mulai instalasi
    install_zsh
    install_ohmyzsh
    set_default_shell
    install_ldt
    
    echo -e "\n${COLOR_GREEN}✓ Instalasi selesai!${COLOR_RESET}"
    echo -e "\n${COLOR_YELLOW}Catatan:${COLOR_RESET}"
    echo -e "- Gunakan ${COLOR_BLUE}zsh${COLOR_RESET} untuk memulai sesi zsh"
    echo -e "- Gunakan ${COLOR_BLUE}ldt --help${COLOR_RESET} untuk melihat daftar perintah yang tersedia"
    echo -e "- Untuk pembaruan, cukup jalankan ${COLOR_BLUE}git pull${COLOR_RESET} di direktori ini"
}

# Jalankan fungsi utama
main "$@"
