# Laporan Investigasi Forensik Digital: Ekstraksi Flag

## 1. Ringkasan Kasus
* **Nama Kasus:** Investigation flag-1
* **Barang Bukti:** `flashdisk_evidence_01.E01` (Hasil imaging FTK Imager)
* **Flag Ditemukan:** `CODENAME{4P0ST3L_P3T3R_0F_GL0RY}`

---

## 2. Langkah Investigasi
1. **Akuisisi Bukti:** Membuat salinan citra disk flashdisk (`.E01`) melalui FTK Imager.
2. **Inisialisasi Kasus:** Membuat *New Case* di Autopsy dan memasukkan *Data Source* `flashdisk_evidence_01.E01` dengan modul *ingest* default.
3. **Navigasi File System:** Membuka hierarki *Data Sources* sampai partisi `vol2` (Win95 FAT32).
4. **Identifikasi File Terhapus:** Menemukan artefak bertanda silang merah (*Unallocated*) bernama `hidden_mission.txt`.
5. **Ekstraksi Flag:** Membuka panel *Text* > *Strings / Extracted Text* pada file tersebut untuk mengambil flag rahasia.

---

## 3. Bukti Temuan
![Bukti Ekstraksi Flag](src/Screenshot%202026-10-12%20085000.png)
