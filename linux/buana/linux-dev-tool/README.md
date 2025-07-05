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

Setelah instalasi selesai, Anda dapat menjalankan tool dengan perintah:

```bash
ldt
```

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
