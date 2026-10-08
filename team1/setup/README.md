# Panduan Tantangan Forensik Digital

Kelompok [Nama Kelompok] | Kontak: [Nomor HP / Penanggung Jawab]

### Informasi Barang Bukti

| Item          | Keterangan                     |
| ------------- | ------------------------------ |
| Media         | NVMe / External Drive          |
| Kapasitas     | 8 GB (Original Space: 200+ GB) |
| Sistem file   | `ext4`                         |
| Skema partisi | GPT                            |
| Label volume  | `CONFIDENTIAL`                 |
| Dibuat di     | Linux                          |

---

### Deskripsi Tantangan

Pada 27 September 2026, **Billy** (Developer) menyerahkan drive miliknya ke departemen IT setelah menyelesaikan proyek. System Administrator (**Bob**) ditugaskan melalui **Tiket #IT-8842** untuk menghapus data (_wipe_) dan melakukan _re-imaging_ sistem operasi Linux standar pada drive tersebut.

Namun, tim SOC mendeteksi aktivitas janggal pada _low-level disk access_. Bob diduga memanfaatkan proses _re-imaging_ sebagai alibi untuk menyembunyikan data rahasia perusahaan (_intellectual property_) sebelum menyerahkan drive kembali.

Tugas kalian: Analisis drive ini, lacak jejak digital yang ditinggalkan Bob, dan pulihkan berkas rahasia yang disembunyikan.

- **Format flag:** `FLAG{...}`

---

### Hint

1. Membuka drive secara biasa via File Manager hanya akan menampilkan direktori Linux bersih (`/home/billy`, `/home/bob`). **Flag tidak tersimpan di dalam folder atau berkas biasa.**
2. Periksa berkas log sistem di `/var/log/sys_audit.log` dan tiket di direktori kerja Bob untuk menemukan _breadcrumb_ (petunjuk offset sektor dan _XOR mask_).
3. Payload disembunyikan pada _unallocated space_ (Sektor 100) di luar batas partisi aktif (`/dev/sdb1`).
4. Berkas terenkripsi dengan _single-byte XOR_. Setelah dideskripsi, _magic header_ berkas zip tersebut sengaja dirusak menjadi `0xDEADBEEF` dan harus diperbaiki manual (`50 4B 03 04`).

---

### Aturan Integritas Barang Bukti (WAJIB)

- Dilarang mengubah, menambah, menghapus, atau merusak data di drive asli.
- Buat **image forensik** (`.raw` / `.dd` / `.E01`) terlebih dahulu menggunakan `dc3dd`, `dd`, atau FTK Imager.
- Lakukan analisis forensik **hanya pada salinan image**, bukan pada drive fisik utama.
- Hitung dan catat nilai _hash_ SHA-256 dari image sebagai bukti integritas data.
- Catat setiap langkah analisis dalam _investigation logsheet_.

Selamat mengerjakan!
