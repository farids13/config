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

# Fungsi untuk menginstall Java
install() {
    echo "Memeriksa Java..."
    
    # Periksa apakah Java sudah terinstall
    if command -v java &> /dev/null; then
        local installed_version=$(java -version 2>&1 | grep -oP 'version "\K[0-9]+' | head -1)
        if [ "$installed_version" == "$JAVA_VERSION" ]; then
            echo "✓ Java $JAVA_VERSION sudah terinstall"
            java -version
            return 0
        else
            echo "Versi Java yang terinstall berbeda. Versi saat ini: $installed_version"
            read -p "Lanjutkan dengan menginstall Java $JAVA_VERSION? [y/N] " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                return 1
            fi
            # Hapus versi lama jika ada
            sudo apt-get remove -y "openjdk-${installed_version}-jdk" "openjdk-${installed_version}-jre"
        fi
    fi
    
    check_dependencies
    
    echo "Menginstall OpenJDK $JAVA_VERSION..."
    
    # Untuk Java 21, kita bisa menggunakan package default di Ubuntu 22.04+
    if [ "$JAVA_VERSION" -ge 21 ]; then
        # Install OpenJDK 21 dari repository default
        sudo apt-get update
        sudo apt-get install -y openjdk-${JAVA_VERSION}-jdk
    else
        # Untuk versi lama, gunakan PPA
        sudo add-apt-repository -y ppa:openjdk-r/ppa
        sudo apt-get update
        sudo apt-get install -y openjdk-${JAVA_VERSION}-jdk
    fi
    
    # Set JAVA_HOME di .bashrc jika belum ada
    if ! grep -q "export JAVA_HOME=" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Set JAVA_HOME" >> ~/.bashrc
        echo "export JAVA_HOME=$JAVA_HOME_DIR" >> ~/.bashrc
        echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> ~/.bashrc
        echo "✓ JAVA_HOME telah ditambahkan ke ~/.bashrc"
    fi
    
    # Load environment variables
    export JAVA_HOME=$JAVA_HOME_DIR
    export PATH="$JAVA_HOME/bin:$PATH"
    
    # Verifikasi instalasi
    if command -v java &> /dev/null; then
        echo ""
        echo "✓ Java berhasil diinstall:"
        java -version
        echo ""
        echo "JAVA_HOME: $JAVA_HOME"
        return 0
    else
        echo "✗ Gagal menginstall Java"
        return 1
    fi
}

# Fungsi untuk menghapus Java
uninstall() {
    echo "Menghapus Java..."
    
    # Hapus instalasi Java
    sudo apt-get remove -y "openjdk-${JAVA_VERSION}-jdk" "openjdk-${JAVA_VERSION}-jre"
    sudo apt-get autoremove -y
    
    # Hapus JAVA_HOME dari .bashrc
    sed -i '/export JAVA_HOME=/d' ~/.bashrc
    sed -i '/export PATH=\"\$JAVA_HOME\/bin:\$PATH\"/d' ~/.bashrc
    
    echo "✓ Java telah dihapus"
    echo "Jalankan 'source ~/.bashrc' atau buka terminal baru untuk memperbarui environment variables"
}

# Fungsi untuk mengecek status Java
status() {
    echo "Memeriksa status Java..."
    
    if command -v java &> /dev/null; then
        local installed_version=$(java -version 2>&1 | awk -F '[\"\\"]' '/version/ {print $2}' | cut -d'.' -f1)
        echo "✓ Java terdeteksi"
        echo "Versi: $(java -version 2>&1 | head -n 1)"
        echo "JAVA_HOME: ${JAVA_HOME:-Tidak diatur}"
        echo "Lokasi: $(which java)"
    else
        echo "✗ Java tidak terdeteksi"
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
