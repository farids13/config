#!/bin/bash

# Update dan upgrade sistem
echo " Memperbarui paket sistem..."
sudo apt update && sudo apt upgrade -y

# Install dependensi yang diperlukan
echo " Menginstal dependensi yang diperlukan..."
sudo apt install -y wget curl git zsh unzip

# Install Java (OpenJDK 17)
echo " Menginstal Java (OpenJDK 17)..."
sudo apt install -y openjdk-17-jdk

# Install Dart SDK
echo " Menginstal Dart SDK..."
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
sudo apt-get update
#!/bin/bash

# Fungsi untuk menampilkan header
show_header() {
    clear
    echo "================================================"
    echo "  Linux Development Environment Setup Tool"
    echo "  by Your Name"
    echo "================================================"
    echo ""
}

# Fungsi untuk menampilkan menu utama
show_menu() {
    show_header
    echo "PILIHAN INSTALASI:"
    echo "1. Instal Semua (Java, Dart, Oh My Zsh)"
    echo "2. Instal Java"
    echo "3. Instal Dart"
    echo "4. Instal Oh My Zsh"
    echo "5. Instal Plugin ZSH"
    echo "6. Konfigurasi .zshrc"
    echo "7. Keluar"
    echo ""
    read -p "Pilih opsi (1-7): " choice
}

# Fungsi untuk memeriksa apakah perintah ada
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Fungsi untuk menginstal Java
install_java() {
    echo ""
    echo "[1/3] Memeriksa Java..."
    if command_exists java; then
        echo "✓ Java sudah terinstal"
        java -version
    else
        echo "☕ Menginstal Java (OpenJDK 17)..."
        sudo apt update
        sudo apt install -y openjdk-17-jdk
        echo "✓ Java berhasil diinstal"
        java -version
    fi
    echo ""
}

# Fungsi untuk menginstal Dart
install_dart() {
    echo ""
    echo "[2/3] Memeriksa Dart..."
    if command_exists dart; then
        echo "✓ Dart sudah terinstal"
        dart --version
    else
        echo "🎯 Menginstal Dart SDK..."
        sudo apt-get update
        sudo apt-get install -y apt-transport-https
        sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
        sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
        sudo apt-get update
        sudo apt-get install -y dart
        echo "✓ Dart berhasil diinstal"
        dart --version
    fi
    echo ""
}

# Fungsi untuk menginstal Oh My Zsh
install_ohmyzsh() {
    echo ""
    echo "[3/3] Memeriksa Oh My Zsh..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "✓ Oh My Zsh sudah terinstal"
    else
        echo "🐚 Menginstal Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo "✓ Oh My Zsh berhasil diinstal"
    fi
    echo ""
}

# Fungsi untuk menginstal plugin ZSH
install_zsh_plugins() {
    echo ""
    echo "🔌 Menginstal plugin ZSH..."
    
    # zsh-autosuggestions
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        echo "  - Menginstal zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        echo "  ✓ zsh-autosuggestions sudah terinstal"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        echo "  - Menginstal zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        echo "  ✓ zsh-syntax-highlighting sudah terinstal"
    fi
    
    echo "✓ Plugin ZSH selesai diinstal"
    echo ""
}

# Fungsi untuk mengkonfigurasi .zshrc
configure_zshrc() {
    echo ""
    echo "⚙️  Mengkonfigurasi .zshrc..."
    
    # Backup .zshrc yang sudah ada
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d%H%M%S)
        echo "  - File .zshrc lama telah di-backup"
    fi
    
    # Buat .zshrc baru
    cat > ~/.zshrc << 'EOL'
# If you come from bash you might have to change your $PATH.
export PATH="$HOME/.local/bin:$HOME/.pub-cache/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Alias yang berguna
alias ll='ls -la'
alias update='sudo apt update && sudo apt upgrade -y'
alias cls='clear'

# Set Java Home
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Set Dart to PATH
export PATH="$PATH:/usr/lib/dart/bin"
EOL

    echo "✓ File .zshrc telah dikonfigurasi"
    echo ""
}

# Fungsi untuk menampilkan hasil instalasi
show_summary() {
    echo ""
    echo "================================================"
    echo "  INSTALASI SELESAI"
    echo "================================================"
    echo ""
    
    # Tampilkan versi yang terinstal
    if command_exists java; then
        echo "Java:"
        java -version
        echo ""
    fi
    
    if command_exists dart; then
        echo "Dart:"
        dart --version
        echo ""
    fi
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh:"
        zsh --version
        echo ""
    fi
    
    echo "================================================"
    echo "  Instalasi selesai!"
    echo "  Silakan restart terminal atau jalankan 'zsh'"
    echo "  untuk memulai menggunakan ZSH."
    echo "================================================"
    echo ""
}

# Main program
while true; do
    show_menu
    
    case $choice in
        1)
            show_header
            echo "Menginstal semua komponen..."
            install_java
            install_dart
            install_ohmyzsh
            install_zsh_plugins
            configure_zshrc
            show_summary
            ;;
        2)
            show_header
            install_java
            ;;
        3)
            show_header
            install_dart
            ;;
        4)
            show_header
            install_ohmyzsh
            ;;
        5)
            show_header
            install_zsh_plugins
            ;;
        6)
            show_header
            configure_zshrc
            ;;
        7)
            echo ""
            echo "Terima kasih telah menggunakan script ini!"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo "Pilihan tidak valid. Silakan pilih 1-7."
            sleep 2
            ;;
    esac
    
    if [ "$choice" -ge 1 ] && [ "$choice" -le 6 ]; then
        read -p "Tekan Enter untuk kembali ke menu utama..."
    fi
done
EOL

# Set ZSH sebagai default shell
echo " Mengatur ZSH sebagai default shell..."
sudo chsh -s $(which zsh) $(whoami)

# Selesai
echo "
 Instalasi selesai! Silakan restart terminal atau jalankan 'zsh' untuk memulai.
"
echo "Versi Java yang terinstal:"
java -version
echo "\nVersi Dart yang terinstal:"
dart --version
echo "\nVersi ZSH yang terinstal:"
zsh --version