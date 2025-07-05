#!/bin/bash

# Script untuk menginstall Linux Dev Tool

# Warna untuk output
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[0;32m"
COLOR_BLUE="\033[0;34m"
COLOR_YELLOW="\033[0;33m"

# Fungsi untuk menampilkan header
show_header() {
    clear
    echo -e "${COLOR_BLUE}========================================${COLOR_RESET}"
    echo -e "${COLOR_BLUE}  Linux Development Environment Setup${COLOR_RESET}"
    echo -e "${COLOR_BLUE}  Installer Tool${COLOR_RESET}"
    echo -e "${COLOR_BLUE}========================================${COLOR_RESET}"
    echo ""
}

# Fungsi untuk memeriksa apakah perintah ada
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Fungsi untuk menginstall dependensi
install_dependencies() {
    echo "Menginstall dependensi yang diperlukan..."
    
    # Daftar dependensi yang diperlukan
    local dependencies=("git" "curl" "wget" "zsh")
    local missing_deps=()
    
    # Periksa dependensi yang hilang
    for dep in "${dependencies[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
    # Install dependensi yang hilang
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Menginstall: ${missing_deps[*]}"
        sudo apt-get update
        sudo apt-get install -y "${missing_deps[@]}" || {
            echo "Gagal menginstall dependensi yang diperlukan"
            exit 1
        }
        echo -e "${COLOR_GREEN}✓ Dependensi berhasil diinstall${COLOR_RESET}"
    else
        echo -e "${COLOR_GREEN}✓ Semua dependensi sudah terinstall${COLOR_RESET}"
    fi
}

# Fungsi untuk menginstall Linux Dev Tool
install_ldt() {
    echo "Menginstall Linux Dev Tool..."
    
    # Buat direktori instalasi
    local install_dir="/opt/linux-dev-tool"
    
    # Hapus instalasi lama jika ada
    if [ -d "$install_dir" ]; then
        echo "Menghapus instalasi lama..."
        sudo rm -rf "$install_dir"
    fi
    
    # Salin file ke direktori instalasi
    echo "Mengcopy file..."
    sudo mkdir -p "$install_dir"
    sudo cp -r . "$install_dir/"
    
    # Buat symlink
    echo "Membuat symlink..."
    sudo ln -sf "$install_dir/linux-dev-tool" "/usr/local/bin/ldt"
    
    # Berikan izin eksekusi
    sudo chmod +x "$install_dir/linux-dev-tool"
    sudo chmod +x "$install_dir/plugins/"*/"/install.sh"
    
    echo -e "${COLOR_GREEN}✓ Linux Dev Tool berhasil diinstall${COLOR_RESET}"
    echo ""
    echo "Anda sekarang dapat menjalankan Linux Dev Tool dengan perintah:"
    echo -e "  ${COLOR_YELLOW}ldt${COLOR_RESET}"
    echo ""
    echo "Atau langsung dari direktori saat ini:"
    echo -e "  ${COLOR_YELLOW}./linux-dev-tool${COLOR_RESET}"
}

# Fungsi utama
main() {
    show_header
    
    # Pastikan script dijalankan sebagai non-root
    if [ "$EUID" -eq 0 ]; then
        echo "Jangan jalankan script ini sebagai root!"
        echo "Jalankan sebagai pengguna biasa."
        exit 1
    fi
    
    # Periksa sistem operasi
    if [ ! -f "/etc/os-release" ]; then
        echo "Sistem operasi tidak didukung!"
        exit 1
    fi
    
    # Dapatkan nama distribusi
    . /etc/os-release
    echo -e "${COLOR_BLUE}Sistem Operasi:${COLOR_RESET} $PRETTY_NAME"
    
    # Konfirmasi instalasi
    read -p "Lanjutkan instalasi? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [ -n "$REPLY" ]; then
        echo "Instalasi dibatalkan"
        exit 0
    fi
    
    # Mulai instalasi
    install_dependencies
    install_ldt
    
    # Tampilkan pesan selesai
    echo ""
    echo -e "${COLOR_GREEN}Instalasi selesai!${COLOR_RESET}"
    echo -e "Jalankan ${COLOR_YELLOW}ldt${COLOR_RESET} untuk memulai"
    echo ""
}

# Jalankan fungsi utama
main "$@"
