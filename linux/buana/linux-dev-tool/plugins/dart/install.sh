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

# Fungsi untuk menginstall Dart
install() {
    echo "Memeriksa Dart SDK..."
    
    # Periksa apakah Dart sudah terinstall
    if command -v dart &> /dev/null; then
        echo "✓ Dart sudah terinstall"
        dart --version
        return 0
    fi
    
    check_dependencies
    
    echo "Menginstall Dart SDK..."
    
    # Tambahkan repository Dart
    sudo apt-get update
    sudo apt-get install -y apt-transport-https
    sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
    sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
    
    # Install Dart
    sudo apt-get update
    sudo apt-get install -y dart
    
    # Set PATH di .bashrc jika belum ada
    if ! grep -q "export PATH=\"\$PATH:/usr/lib/dart/bin\"" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Set PATH for Dart" >> ~/.bashrc
        echo "export PATH=\"\$PATH:/usr/lib/dart/bin\"" >> ~/.bashrc
        echo "✓ PATH untuk Dart telah ditambahkan ke ~/.bashrc"
    fi
    
    # Tambahkan PATH untuk saat ini
    export PATH="$PATH:/usr/lib/dart/bin"
    
    # Verifikasi instalasi
    if command -v dart &> /dev/null; then
        echo ""
        echo "✓ Dart SDK berhasil diinstall:"
        dart --version
        echo ""
        echo "Lokasi: $(which dart)"
        return 0
    else
        echo "✗ Gagal menginstall Dart SDK"
        return 1
    fi
}

# Fungsi untuk menghapus Dart
uninstall() {
    echo "Menghapus Dart SDK..."
    
    # Hapus instalasi Dart
    sudo apt-get remove -y dart
    sudo apt-get autoremove -y
    
    # Hapus repository Dart
    sudo rm -f /etc/apt/sources.list.d/dart_stable.list
    
    # Hapus PATH dari .bashrc
    sed -i '/export PATH=\"\$PATH:\/usr\/lib\/dart\/bin\"/d' ~/.bashrc
    
    echo "✓ Dart SDK telah dihapus"
    echo "Jalankan 'source ~/.bashrc' atau buka terminal baru untuk memperbarui environment variables"
}

# Fungsi untuk mengecek status Dart
status() {
    echo "Memeriksa status Dart SDK..."
    
    if command -v dart &> /dev/null; then
        echo "✓ Dart terdeteksi"
        echo "Versi: $(dart --version 2>&1)"
        echo "Lokasi: $(which dart)"
    else
        echo "✗ Dart tidak terdeteksi"
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
