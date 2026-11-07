# BookShelf - Mobile Application Mini Project (UTS Pemrograman Mobile)

Aplikasi mobile berbasis Flutter dengan tema **BookShelf** (Personal Reading & Bookshelf Manager) yang mengintegrasikan Dart Fundamentals, Flutter UI, Responsive Layout, Multi-screen Navigation, State Management (Provider), Architecture Pattern, REST API, serta Backend Database (Supabase / PostgreSQL) dengan CRUD lengkap.

---

## Identitas Mahasiswa

| Informasi | Detail |
|---|---|
| **Nama Mahasiswa** | Wayan Muizul Rozzak |
| **NIM** | 2415051111 |
| **Kelas** | PTI 5A |
| **Program Studi** | S1 Pendidikan Teknik Informatika |
| **Matakuliah** | Pemrograman Mobile |
| **Dosen Pengampu** | Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom |
| **Teaching Assistant** | Made Yuda Sadewa, S.Pd. |
| **Tema Project** | BookShelf (Personal Reading & Bookshelf Manager) |
| **Repository GitHub** | [UTS_2415051111_Wayan Muizul Rozzak](https://github.com/wayanmuizul/UTS_2415051111_Wayan_Muizul_Rozzak) |

---

## Tampilan UI dan Desain Aplikasi

Aplikasi mengadopsi tema **Dark Purple / Deep Violet Aesthetic** yang modern dan elegan sesuai dengan referensi desain:
- **Warna Utama**: Deep Purple (`#130B24`), Surface Card (`#1F1438`), Accent Purple (`#8B5CF6`).
- **Progress Indicator**: Oranye / Amber (`#FF9E2C`) untuk visualisasi progress membaca buku.
- **Kartu Hero "Your Last Read Book"**: Menampilkan cover, durasi membaca, nomor halaman, dan progress bar.
- **Modal "Select Book"**: Menampilkan grid responsif 3 kolom dengan border highlight keemasan pada buku yang sedang dipilih.

---

## Daftar Fitur Aplikasi

1. **Dashboard Utama (Home)**:
   - Ringkasan buku aktif yang terakhir dibaca (*Your Last Read Book*).
   - Filter tab status baca (*Currently Reading*, *For Reading*, *Read*).
   - Akses cepat tombol `+ Add new book`.
   - Ringkasan cepat statistik perpustakaan (*Total Books*, *Reading*, *Finished*).
2. **Select Active Book (Modal / Screen)**:
   - Grid 3 kolom menampilkan seluruh buku yang tersimpan di rak.
   - Indikator border highlight oranye/emas pada buku yang sedang dipilih.
   - Aksi konfirmasi untuk menetapkan buku aktif bacaan terkini.
3. **Katalog Buku Eksternal (REST API)**:
   - Mengambil data real-time dari **Google Books REST API** (`https://www.googleapis.com/books/v1/volumes`).
   - Pencarian judul atau penulis buku secara dinamis.
   - Filter kategori (*Fiction*, *Philosophy*, *Fantasy*, *Technology*, *Biography*, dll.).
   - Toggle tampilan antara mode Grid dan List.
   - Status penanganan lengkap: *Loading State*, *Error State* (dengan tombol Coba Lagi), dan *Empty State*.
   - Tombol cepat simpan buku dari katalog API ke rak pribadi.
4. **Detail Buku (Passing Data)**:
   - Informasi mendalam buku: Cover resolusi tinggi, judul, pengarang, penerbit, tahun rilis, rating, panjang halaman, dan sinopsis lengkap.
   - Progress bar interaktif jika buku sudah berada di dalam rak.
   - Menampilkan catatan pribadi (*Personal Notes*).
   - Aksi *Update Progress* dan *Hapus dari Rak*.
5. **Form Tambah Buku (Create - CRUD)**:
   - Form dengan validasi input (Judul wajib, Penulis wajib, Total halaman > 0, Halaman saat ini <= Total halaman).
   - Pilihan status membaca, estimasi durasi baca, rating slider interaktif, URL gambar cover, dan catatan pribadi.
   - Umpan balik pengguna via *SnackBar*.
6. **Form Edit Progress & Catatan (Update - CRUD)**:
   - Slider halaman interaktif yang tersinkronisasi otomatis dengan input angka.
   - Update status buku (otomatis berubah ke *Read* jika halaman mencapai total).
   - Pembaruan rating kepuasan dan catatan evaluasi bacaan.
7. **Rak Buku Saya (Library Screen)**:
   - Filter chip status (*Semua*, *Reading*, *Plan*, *Finished*).
   - Pencarian internal dalam koleksi rak buku.
   - Fitur hapus geser (*Swipe to Delete*) dengan konfirmasi dialog.
8. **Laporan & Statistik Membaca (Report Screen)**:
   - Statistik akumulatif: Total menit membaca, buku tamat, halaman terbaca, dan *Reading Streak*.
   - Visualisasi grafik batang aktivitas mingguan (Senin - Minggu).
   - Tracking target membaca tahunan (Goal Progress).
9. **Profil Mahasiswa & Info UTS (Profile Screen)**:
   - Identitas lengkap mahasiswa (Nama, NIM, Kelas, Dosen, Asisten).
   - Status koneksi database backend (Supabase / Local Database).
   - Checklist pemenuhan 100% rubrik penilaian UTS.

---

## Tech Stack & Dependensi

- **Framework**: Flutter 3.47+ (Dart SDK 3.13+)
- **State Management**: `provider: ^6.1.2` (ChangeNotifier, Consumer, context.watch, context.read)
- **REST API Client**: `http: ^1.2.1`
- **Database / Backend**:
  - Cloud Backend: **Supabase (PostgreSQL)** via PostgREST API
  - Local Persistence Fallback: `shared_preferences: ^2.2.3` (JSON Serialized Persistence)
- **Date & Number Formatting**: `intl: ^0.19.0`
- **Icons**: Material Icons & Cupertino Icons

---

## Arsitektur Aplikasi (Separation of Concerns)

Aplikasi dibangun menggunakan pola arsitektur bersih (*Clean & Layered Architecture*) yang direkomendasikan pada worksheet UTS:

```
lib/
├── models/                     # Dart Models (Data Entities & Serializers)
│   ├── book.dart               # Model untuk data katalog dari REST API
│   ├── saved_book.dart         # Model untuk data buku tersimpan di database
│   ├── reading_stats.dart      # Model statistik dan analitik membaca
│   └── user_profile.dart       # Model informasi identitas mahasiswa
├── services/                   # Data Sources & Remote Services
│   ├── api_service.dart        # HTTP Client untuk Google Books REST API
│   ├── supabase_service.dart   # Service komunikasi REST ke Database Supabase
│   ├── local_db_service.dart   # Service database lokal persisten (SharedPreferences)
│   └── supabase_config.dart    # Konfigurasi aman URL & Anon Key Supabase
├── repositories/               # Repository Pattern
│   └── book_repository.dart    # Mengabstraksi dan menggabungkan API & Database
├── providers/                  # State Management (ChangeNotifier)
│   ├── book_provider.dart      # Mengelola state katalog API, search, & category
│   ├── library_provider.dart   # Mengelola state CRUD database, filter, & active book
│   └── stats_provider.dart     # Menghitung analitik membaca buku pengguna
├── screens/                    # UI Presentation Layer (Minimal 6, disediakan 9)
│   ├── main_navigation_screen.dart # Navigasi responsif (BottomNav / NavigationRail)
│   ├── home_screen.dart            # SCREEN 1: Home Dashboard (Sesuai Foto Kiri)
│   ├── select_book_screen.dart     # SCREEN 2: Select Book Modal (Sesuai Foto Kanan)
│   ├── catalog_screen.dart         # SCREEN 3: Katalog REST API Google Books
│   ├── book_detail_screen.dart     # SCREEN 4: Detail Buku dengan Passing Data
│   ├── add_book_screen.dart        # SCREEN 5: Form Tambah Buku (Create CRUD)
│   ├── edit_book_screen.dart       # SCREEN 6: Form Edit Data (Update CRUD)
│   ├── library_screen.dart         # SCREEN 7: Koleksi Rak Buku Pribadi
│   ├── report_screen.dart          # SCREEN 8: Laporan & Grafik Membaca
│   └── profile_screen.dart         # SCREEN 9: Profil Mahasiswa & Checklist UTS
├── widgets/                    # Reusable Components (Minimal 3, disediakan 7)
│   ├── book_card_widget.dart       # Komponen kartu buku (List mode & Grid mode)
│   ├── last_read_card_widget.dart  # Hero Card "Your Last Read Book" (sesuai foto)
│   ├── reading_progress_bar.dart   # Custom progress bar warna oranye/amber
│   ├── book_status_badge.dart      # Chip penanda status membaca
│   ├── custom_text_field.dart      # Input form kustom dengan validasi
│   ├── stat_card_widget.dart       # Kartu metrik analitik
│   └── confirm_dialog.dart         # Dialog konfirmasi penghapusan data
├── utils/                      # Tema, Palet Warna, & Konstanta
│   ├── app_colors.dart             # Definisi warna dark purple & amber
│   └── app_theme.dart              # ThemeData Material 3 dark theme
└── main.dart                   # Entry point aplikasi & MultiProvider setup
```

**Alur Arsitektur**:
`UI (Screen / Widget) ➔ State (Provider) ➔ Repository ➔ Service / Data Source ➔ REST API / Supabase Database`.
Screen tidak pernah melakukan query HTTP atau query database secara langsung.

---

## Integrasi Database Backend (Supabase / PostgreSQL)

### Skema Tabel: `saved_books`
| Kolom | Tipe Data | Deskripsi |
|---|---|---|
| `id` | `TEXT PRIMARY KEY` | Identifier unik buku (UUID) |
| `student_id` | `TEXT` | NIM Mahasiswa (`2415051111`) |
| `book_id` | `TEXT` | ID referensi volume dari Google Books API / Custom |
| `title` | `TEXT` | Judul buku |
| `author` | `TEXT` | Nama pengarang/penulis |
| `cover_url` | `TEXT` | URL gambar cover buku |
| `description` | `TEXT` | Sinopsis atau deskripsi buku |
| `total_pages` | `INTEGER` | Jumlah total halaman buku |
| `current_page` | `INTEGER` | Halaman yang saat ini sudah dibaca |
| `status` | `TEXT` | `currently_reading`, `for_reading`, `read` |
| `reading_time_minutes`| `INTEGER` | Akumulasi durasi waktu membaca dalam menit |
| `started_date` | `TIMESTAMPTZ` | Tanggal mulai membaca buku |
| `rating` | `NUMERIC(2,1)` | Nilai rating kepuasan (1.0 - 5.0) |
| `note` | `TEXT` | Catatan refleksi atau kutipan pribadi |
| `created_at` | `TIMESTAMPTZ` | Timestamp pembuatan data |
| `updated_at` | `TIMESTAMPTZ` | Timestamp pembaruan data |

### SQL Script Supabase
File skrip SQL lengkap siap pakai tersedia di [`supabase_schema.sql`](./supabase_schema.sql).

---

## Checklist Pemenuhan Ketentuan UTS (Worksheet 1–7)

| Komponen | Spesifikasi Minimum | Implementasi pada Project | Status |
|---|---|---|:---:|
| **Screen Fungsional** | Minimal 6 screen (Splash tidak dihitung) | 9 screen fungsional lengkap | Terpenuhi |
| **Dart Model** | Minimal 2 model | 4 model (`Book`, `SavedBook`, `ReadingStats`, `UserProfile`) | Terpenuhi |
| **Reusable Widgets** | Minimal 3 widget | 7 custom widgets terpisah | Terpenuhi |
| **Responsive Layout** | Minimal 2 kondisi (Compact & Wide) | Compact (< 850px) & Wide (>= 850px) + NavigationRail | Terpenuhi |
| **REST API** | Minimal 1 REST API | Google Books API (Operasi GET & parsing model) | Terpenuhi |
| **Loading / Error / Empty** | Wajib untuk API & Data | Penanganan spinner, retry button, dan ilustrasi kosong | Terpenuhi |
| **Backend Database** | Minimal 1 database (Supabase) | Supabase PostgreSQL + Dual Local Persistence Cache | Terpenuhi |
| **Tabel Database** | Minimal 1 tabel (>= 4 fields + ID) | Tabel `saved_books` dengan 16 field data | Terpenuhi |
| **CRUD Database** | 4 Operasi (Create, Read, Update, Delete) | Tambah Buku, Baca Rak, Update Halaman, Hapus Buku | Terpenuhi |
| **Delete Confirmation** | Wajib menggunakan dialog | `ConfirmDialog` dengan tombol Batal dan Hapus | Terpenuhi |
| **State Management** | Provider + ChangeNotifier | `BookProvider`, `LibraryProvider`, `StatsProvider` | Terpenuhi |
| **Multi-screen Navigation**| Wajib | List ➔ Detail, Modal Select Book, Form Add & Edit | Terpenuhi |
| **Passing Data** | Wajib | Mengirim instance objek buku antar-layar | Terpenuhi |
| **Form & Validasi** | Minimal 1 form dengan validasi | Form Tambah & Edit dengan validasi teks dan angka | Terpenuhi |
| **Feedback Pengguna** | SnackBar / Dialog | Feedback SnackBar operasi sukses/gagal & dialog | Terpenuhi |
| **Git Commits** | Minimal 16 meaningful commits | 16 commit bertahap sesuai milestone UTS | Terpenuhi |

---

## Cara Menjalankan Project

1. **Clone Repository**:
   ```bash
   git clone https://github.com/wayanmuizul/UTS_2415051111_Wayan_Muizul_Rozzak.git
   cd bookshelf_uts
   ```

2. **Pasang Dependensi**:
   ```bash
   flutter pub get
   ```

3. **Verifikasi Analisis Kode & Pengujian**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Jalankan Aplikasi pada Emulator / Perangkat**:
   ```bash
   flutter run
   ```

5. **Membangun File APK**:
   ```bash
   flutter build apk --release
   ```
   File APK hasil build akan berlokasi di:
   `build/app/outputs/flutter-apk/app-release.apk`
   (Dapat di-rename menjadi `UTS_2415051111_Wayan Muizul Rozzak.apk`).
