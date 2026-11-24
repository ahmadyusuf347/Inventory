# Inventaris Kantor

Aplikasi Android untuk mencatat inventaris barang kantor. Data tersimpan di HP (SQLite), tanpa login, dan bisa diekspor ke Excel (.xlsx) dan PDF.

## Fitur
- Dashboard: jenis barang, total stok, stok menipis, nilai aset, stok per kategori
- Tambah, ubah, hapus (geser ke kiri) barang; tombol +/- untuk stok cepat
- Cari dan filter per kategori
- Ekspor Excel dan PDF, lalu bagikan lewat menu berbagi Android

## Build lewat GitHub
1. Buat repository baru di GitHub, lalu upload semua isi folder ini.
2. Buka tab **Actions**, pilih **Build APK**, klik **Run workflow** (atau otomatis jalan saat push ke `main`).
3. Setelah hijau, buka run tersebut dan unduh artifact **inventaris-kantor-apk**.
4. Ekstrak, kirim `app-release.apk` ke HP, lalu install.

## Jalankan lokal
```bash
flutter create . --platforms=android --org id.kantor --project-name inventaris_kantor
flutter pub get
flutter run
```
