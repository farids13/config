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

# Fungsi untuk memeriksa apakah package sudah terinstall
is_package_installed() {
    local pkg=$1
    if [ "$PLUGIN_TYPE" = "generic/apt" ]; then
        dpkg -l "$pkg" 2>/dev/null | grep -q ^ii
        return $?
    elif [ "$PLUGIN_TYPE" = "generic/snap" ]; then
        snap list | grep -q "^$pkg\s"
        return $?
    else
        command -v "$pkg" >/dev/null 2>&1
        return $?
    fi
}

# Fungsi untuk memeriksa ketersediaan package di repository
is_package_available() {
    local pkg=$1
    if [ "$PLUGIN_TYPE" = "generic/apt" ]; then
        apt-cache show "$pkg" >/dev/null 2>&1
        return $?
    elif [ "$PLUGIN_TYPE" = "generic/snap" ]; then
        snap find "$pkg" >/dev/null 2>&1
        return $?
    fi
    return 1
}

# Fungsi untuk menginstall package
install_package() {
    local pkg=$1
    echo "Menginstall $pkg..."
    
    if [ "$PLUGIN_TYPE" = "generic/apt" ]; then
        sudo apt-get install -y "$pkg"
    elif [ "$PLUGIN_TYPE" = "generic/snap" ]; then
        sudo snap install "$pkg" --classic
    else
        echo "Tipe plugin tidak didukung: $PLUGIN_TYPE"
        return 1
    fi
    
    return $?
}

# Fungsi untuk menginstall
install() {
    if [ -z "$PACKAGES" ]; then
        echo "Tidak ada package yang ditentukan untuk diinstall."
        return 1
    fi
    
    echo "Memeriksa dan menginstall package..."
    
    for pkg in $PACKAGES; do
        if is_package_installed "$pkg"; then
            echo "✓ $pkg sudah terinstall"
        else
            if is_package_available "$pkg"; then
                install_package "$pkg" || {
                    echo "Gagal menginstall $pkg"
                    return 1
                }
            else
                echo "Package $pkg tidak tersedia di repository"
                return 1
            fi
        fi
    done
    
    echo "Semua package berhasil diinstall!"
}

# Fungsi untuk menghapus
uninstall() {
    if [ -z "$PACKAGES" ]; then
        echo "Tidak ada package yang ditentukan untuk dihapus."
        return 1
    fi
    
    echo "Menghapus package..."
    
    for pkg in $PACKAGES; do
        if is_package_installed "$pkg"; then
            echo "Menghapus $pkg..."
            if [ "$PLUGIN_TYPE" = "generic/apt" ]; then
                sudo apt-get remove -y "$pkg"
            elif [ "$PLUGIN_TYPE" = "generic/snap" ]; then
                sudo snap remove "$pkg"
            fi
        else
            echo "$pkg tidak terinstall, dilewati"
        fi
    done
    
    echo "Proses selesai."
}

# Fungsi untuk mengecek status
status() {
    if [ -z "$PACKAGES" ]; then
        echo "Tidak ada package yang ditentukan."
        return 1
    fi
    
    echo "Status package:"
    echo "----------------"
    
    for pkg in $PACKAGES; do
        if is_package_installed "$pkg"; then
            echo -e "${COLOR_GREEN}✓ $pkg: Terinstall${COLOR_RESET}"
        else
            echo -e "${COLOR_RED}✗ $pkg: Tidak terinstall${COLOR_RESET}"
        fi
    done
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
