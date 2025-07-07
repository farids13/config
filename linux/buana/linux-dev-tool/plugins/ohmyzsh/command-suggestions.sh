#!/bin/bash

# Direktori untuk menyimpan command suggestions
SUGGESTIONS_BACKUP_DIR="$(dirname "$0")/suggestions_backup"
SUGGESTIONS_FILE="$HOME/.zsh_history"
BACKUP_FILE="$SUGGESTIONS_BACKUP_DIR/command_suggestions_$(date +%Y%m%d_%H%M%S).bak"

# Buat direktori backup jika belum ada
mkdir -p "$SUGGESTIONS_BACKUP_DIR"

# Fungsi untuk membackup command suggestions
backup_suggestions() {
    if [ -f "$SUGGESTIONS_FILE" ]; then
        cp "$SUGGESTIONS_FILE" "$BACKUP_FILE"
        if [ $? -eq 0 ]; then
            echo "✓ Command suggestions berhasil dibackup ke: $BACKUP_FILE"
            return 0
        else
            echo "✗ Gagal membackup command suggestions"
            return 1
        fi
    else
        echo "✗ File command suggestions tidak ditemukan: $SUGGESTIONS_FILE"
        return 1
    fi
}

# Fungsi untuk menampilkan daftar backup yang tersedia dengan nomor
list_backups_with_numbers() {
    local i=1
    local backups=()
    
    echo "Daftar backup yang tersedia:"
    echo "---------------------------"
    
    while IFS= read -r backup; do
        if [ -f "$backup" ]; then
            backups+=("$backup")
            echo "$i. $(basename "$backup") - $(date -r "$backup" '+%Y-%m-%d %H:%M:%S')"
            ((i++))
        fi
    done < <(find "$SUGGESTIONS_BACKUP_DIR" -name "*.bak" -type f -printf '%T@ %p\n' | sort -nr | cut -d' ' -f2-)
    
    if [ ${#backups[@]} -eq 0 ]; then
        echo "Tidak ada backup yang tersedia"
        return 1
    fi
    
    echo "$i. Kembali ke menu sebelumnya"
    echo ""
    
    # Baca pilihan pengguna
    local choice
    read -p "Pilih nomor backup yang akan dipulihkan [1-${#backups[@]}]: " choice
    
    # Validasi input
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "✗ Masukan tidak valid. Harap masukkan nomor."
        return 1
    fi
    
    if [ "$choice" -eq "$i" ]; then
        echo "Operasi dibatalkan."
        return 2
    fi
    
    if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#backups[@]}" ]; then
        echo "✗ Pilihan tidak valid. Harap pilih nomor antara 1 dan ${#backups[@]}."
        return 1
    fi
    
    # Kembalikan path file yang dipilih
    echo "${backups[$((choice-1))]}"
    return 0
}

# Fungsi untuk merestore command suggestions
restore_suggestions() {
    echo "Mencari backup yang tersedia..."
    
    # Dapatkan daftar backup dan minta pengguna memilih
    local selected_backup
    selected_backup=$(list_backups_with_numbers)
    local status=$?
    
    if [ $status -eq 1 ]; then
        echo "✗ Tidak ada backup yang tersedia untuk dipulihkan"
        return 1
    elif [ $status -eq 2 ]; then
        # Pengguna memilih untuk kembali
        return 0
    fi
    
    echo ""
    echo "Memulihkan command suggestions dari: $(basename "$selected_backup")"
    
    # Konfirmasi sebelum memulihkan
    read -p "Apakah Anda yakin ingin memulihkan backup ini? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operasi dibatalkan."
        return 0
    fi
    
    # Lakukan pemulihan
    cp "$selected_backup" "$SUGGESTIONS_FILE"
    
    if [ $? -eq 0 ]; then
        echo "✓ Command suggestions berhasil dipulihkan"
        echo "Jalankan 'source ~/.zshrc' untuk menerapkan perubahan"
        return 0
    else
        echo "✗ Gagal memulihkan command suggestions"
        return 1
    fi
}

# Fungsi untuk menampilkan daftar backup yang tersedia
list_suggestions() {
    echo "Daftar backup command suggestions yang tersedia (terbaru ke terlama):"
    echo "---------------------------------------------------------------"
    local i=1
    find "$SUGGESTIONS_BACKUP_DIR" -name "*.bak" -type f -printf '%T@ %p\n' | sort -nr | cut -d' ' -f2- | while read -r backup; do
        echo "$i. $(basename "$backup") - $(date -r "$backup" '+%Y-%m-%d %H:%M:%S')"
        ((i++))
    done
    
    if [ $i -eq 1 ]; then
        echo "Tidak ada backup yang tersedia"
    fi
    echo ""
}

# Fungsi untuk membersihkan backup lama
clean_old_backups() {
    local days=${1:-30}  # Default 30 hari
    echo "Menghapus backup yang lebih lama dari $days hari..."
    find "$SUGGESTIONS_BACKUP_DIR" -name "*.bak" -mtime +$days -exec rm -i {} \;
}

# Main function
main() {
    case "$1" in
        backup)
            backup_suggestions
            ;;
        restore)
            restore_suggestions
            ;;
        list)
            list_suggestions
            ;;
        clean)
            clean_old_backups "$2"
            ;;
        *)
            echo "Penggunaan: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  backup     : Membackup command suggestions"
            echo "  restore    : Merestore command suggestions dari backup terbaru"
            echo "  list       : Menampilkan daftar backup yang tersedia"
            echo "  clean [n]  : Menghapus backup yang lebih lama dari n hari (default: 30)"
            echo ""
            exit 1
            ;;
    esac
}

# Jalankan main function
main "$@"
