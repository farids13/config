# Linux Development Environment Setup Tool

Tool untuk mengatur environment development Linux dengan mudah dan fleksibel menggunakan sistem plugin.

## Fitur

- **Sistem Plugin** - Setiap tool dikemas dalam plugin terpisah
- **Mudah Diperluas** - Tambahkan plugin baru dengan mudah
- **Manajemen Dependensi** - Otomatis menginstal dependensi yang diperlukan
- **Konfigurasi Fleksibel** - Setiap plugin dapat dikonfigurasi sesuai kebutuhan
- **Antarmuka Interaktif** - Mudah digunakan dengan menu interaktif

## Daftar Plugin yang Tersedia

- **Java Development Kit** - OpenJDK untuk pengembangan Java
- **Dart SDK** - Untuk pengembangan aplikasi Flutter/Dart
- **Oh My Zsh** - Framework manajemen konfigurasi untuk Zsh
- **Generic Package Installer** - Untuk menginstall package dari repository sistem (apt, snap, dll)

## Persyaratan Sistem

- Sistem operasi berbasis Debian/Ubuntu (disarankan Ubuntu 20.04+)
- Akses root/sudo untuk menginstal paket sistem
- Koneksi internet untuk mengunduh paket dan dependensi

## Cara Menginstal

1. Clone repositori ini:
   ```bash
   git clone https://github.com/username/linux-dev-tool.git
   cd linux-dev-tool
   ```

2. Berikan izin eksekusi pada script instalasi:
   ```bash
   chmod +x install.sh
   ```

3. Jalankan script instalasi:
   ```bash
   ./install.sh
   ```

4. Ikuti petunjuk di layar untuk menyelesaikan instalasi

## Cara Menggunakan

### Menginstal Semua Plugin
Untuk menginstal semua plugin yang tersedia:
```bash
./linux-dev-tool --install-all
```

### Menginstal Plugin Tertentu
Untuk menginstal plugin tertentu, gunakan opsi `--install` diikuti dengan nama plugin:
```bash
./linux-dev-tool --install nama_plugin
```
Contoh:
```bash
./linux-dev-tool --install ohmyzsh
```

### Melihat Daftar Plugin yang Tersedia
Untuk melihat daftar plugin yang tersedia:
```bash
./linux-dev-tool --list
```

### Menghapus Plugin
Untuk menghapus plugin yang sudah terinstall:
```bash
./linux-dev-tool --remove nama_plugin
```

### Memeriksa Status Plugin
Untuk memeriksa status plugin:
```bash
./linux-dev-tool --status nama_plugin
```

## Plugin Generik

Linux Dev Tool menyediakan sistem plugin generik yang memungkinkan Anda menambahkan package baru hanya dengan membuat file konfigurasi sederhana, tanpa perlu menulis script instalasi manual.

### Cara Membuat Plugin Generik

1. Buat direktori baru di folder `plugins/`:
   ```bash
   mkdir -p plugins/nama-package
   ```

2. Buat file `plugin.conf` dengan format berikut:
   ```ini
   # Konfigurasi Plugin
   PLUGIN_NAME="Nama Package"
   PLUGIN_DESCRIPTION="Deskripsi singkat tentang package"
   PLUGIN_VERSION="1.0.0"
   PLUGIN_AUTHOR="Nama Anda"
   PLUGIN_ENABLED=true
   
   # Tipe plugin: generic/apt, generic/snap, dll
   PLUGIN_TYPE="generic/apt"
   
   # Daftar package yang akan diinstall (pisahkan dengan spasi)
   PACKAGES="nama-package1 nama-package2"
   
   # Dependensi yang diperlukan
   DEPENDENCIES=("apt" "apt-get" "dpkg")
   ```

### Contoh Konfigurasi Plugin

#### 1. Plugin Vim (Sederhana)
```bash
mkdir -p plugins/vim
cat > plugins/vim/plugin.conf << 'EOF'
PLUGIN_NAME="Vim Editor"
PLUGIN_DESCRIPTION="Editor teks Vim yang powerful"
PLUGIN_VERSION="1.0.0"
PLUGIN_ENABLED=true
PLUGIN_TYPE="generic/apt"
PACKAGES="vim"
DEPENDENCIES=("apt" "apt-get" "dpkg")
EOF
```

#### 2. Plugin Java Development Kit
```bash
mkdir -p plugins/java
cat > plugins/java/plugin.conf << 'EOF'
# Konfigurasi Plugin Java Development Kit
PLUGIN_NAME="Java Development Kit"
PLUGIN_DESCRIPTION="OpenJDK 21 untuk pengembangan Java"
PLUGIN_VERSION="21.0.2"
PLUGIN_ENABLED=true

# Tipe plugin: generic/apt
PLUGIN_TYPE="generic/apt"

# Daftar package yang akan diinstall
PACKAGES="openjdk-21-jdk openjdk-21-jre"

# Dependensi yang diperlukan
DEPENDENCIES=("wget" "gnupg" "software-properties-common")

# Tambahkan repository OpenJDK
PRE_INSTALL="sudo add-apt-repository -y ppa:openjdk-r/ppa && sudo apt-get update"

# Set environment variables
POST_INSTALL="echo 'export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64' | sudo tee -a /etc/environment && echo 'export PATH=\$PATH:\$JAVA_HOME/bin' | sudo tee -a /etc/environment"
EOF
```

#### 3. Plugin Dart SDK
```bash
mkdir -p plugins/dart
cat > plugins/dart/plugin.conf << 'EOF'
# Konfigurasi Plugin Dart SDK
PLUGIN_NAME="Dart SDK"
PLUGIN_DESCRIPTION="SDK untuk pengembangan aplikasi Flutter/Dart"
PLUGIN_VERSION="3.4.1"
PLUGIN_ENABLED=true

# Tipe plugin: generic/apt
PLUGIN_TYPE="generic/apt"

# Daftar package yang akan diinstall
PACKAGES="dart"

# Dependensi yang diperlukan
DEPENDENCIES=("wget" "gnupg" "apt-transport-https")

# Tambahkan repository Dart
POST_INSTALL="wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg && echo 'deb [signed-by=/usr/share/keyrings/dart.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list"
EOF
```

### Membuat Plugin Baru dengan Bantuan AI

Anda bisa dengan mudah membuat plugin baru dengan bantuan AI seperti ChatGPT. Format plugin generik yang baru memudahkan pembuatan plugin hanya dengan file konfigurasi, tanpa perlu menulis script instalasi manual.

Berikut adalah prompt yang bisa Anda gunakan:

```
Saya ingin membuat plugin untuk Linux Dev Tool dengan spesifikasi berikut:

1. Nama Plugin: [Nama Plugin]
2. Deskripsi: [Deskripsi singkat tentang plugin]
3. Tipe Package Manager: [apt/snap/flatpak/dll]
4. Nama Package: [nama-package1 nama-package2]
5. Dependensi yang dibutuhkan: [dependensi1 dependensi2]
6. Repository tambahan (jika ada): [URL repository]
7. Environment variables yang perlu diset (jika ada): [VARIABLE=value]
8. Perintah khusus sebelum/sesudah instalasi (jika ada): [perintah]

Tolong buatkan file plugin.conf untuk saya dengan format yang sesuai dengan dokumentasi Linux Dev Tool versi terbaru yang mendukung plugin generik. Pastikan untuk menggunakan variabel PRE_INSTALL untuk perintah sebelum instalasi dan POST_INSTALL untuk perintah setelah instalasi.
```

Contoh penggunaan prompt:
```
Saya ingin membuat plugin untuk Linux Dev Tool dengan spesifikasi berikut:

1. Nama Plugin: Visual Studio Code
2. Deskripsi: Editor kode sumber yang ringan tapi powerful
3. Tipe Package Manager: apt
4. Nama Package: code
5. Dependensi yang dibutuhkan: wget gpg
6. Repository tambahan: https://packages.microsoft.com/repos/code
7. Environment variables: -
8. Perintah khusus: 
   - Sebelum: wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
   - Sesudah: -

Tolong buatkan file plugin.conf untuk saya.
```

### Menggunakan Plugin

Setelah membuat konfigurasi plugin, jalankan Linux Dev Tool:
```bash
ldt
```
Pilih plugin yang diinginkan dari menu dan ikuti petunjuk di layar.

## Cara Menggunakan

Setelah instalasi selesai, Anda dapat menjalankan tool dengan perintah:

```bash
ldt
```

### Alur Menu Utama

1. **Pilih Aksi** - Pilih aksi yang ingin dilakukan:
   - **Install** - Menginstal plugin yang dipilih
   - **Uninstall** - Menghapus plugin yang terinstal
   - **Status** - Memeriksa status plugin
   - **Keluar** - Keluar dari aplikasi

2. **Pilih Plugin** - Setelah memilih aksi, pilih plugin yang ingin dikelola

### Mode Non-Interaktif

Anda juga dapat menggunakan opsi command line:

```bash
# Menampilkan bantuan
ldt --help

# Menampilkan versi
ldt --version
```

### Menu Plugin

Setiap plugin menyediakan opsi:
- **Install** - Menginstall package
- **Uninstall** - Menghapus package
- **Status** - Memeriksa status instalasi
- **Kembali** - Kembali ke menu utama

Atau langsung dari direktori proyek:

```bash
./linux-dev-tool
```

## Membuat Plugin Baru

1. Buat direktori baru di folder `plugins/`:
   ```bash
   mkdir -p plugins/nama-plugin
   ```

2. Buat file `plugin.conf` di dalam direktori plugin:
   ```ini
   # Konfigurasi Plugin
   PLUGIN_NAME="Nama Plugin"
   PLUGIN_DESCRIPTION="Deskripsi plugin"
   PLUGIN_VERSION="1.0.0"
   PLUGIN_AUTHOR="Nama Anda"
   PLUGIN_ENABLED=true
   
   # Dependensi yang diperlukan
   DEPENDENCIES=("dep1" "dep2")
   ```

3. Buat file `install.sh` untuk logika instalasi:
   ```bash
   #!/bin/bash
   
   install() {
       echo "Menginstall plugin..."
       # Logika instalasi di sini
   }
   
   uninstall() {
       echo "Menghapus plugin..."
       # Logika uninstall di sini
   }
   
   status() {
       echo "Memeriksa status plugin..."
       # Logika pengecekan status di sini
   }
   
   case "$1" in
       install) install ;;
       uninstall) uninstall ;;
       status) status ;;
       *) echo "Penggunaan: $0 {install|uninstall|status}" ;;
   esac
   ```

4. Berikan izin eksekusi pada script:
   ```bash
   chmod +x plugins/nama-plugin/install.sh
   ```

## Kontribusi

Kontribusi sangat diterima! Silakan buat pull request atau laporkan issue jika menemukan masalah.

## Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).
