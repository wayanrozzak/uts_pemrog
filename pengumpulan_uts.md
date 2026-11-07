# LEMBAR BUKTI PENGUMPULAN PROJECT UTS
## PEMROGRAMAN MOBILE (Worksheet 1–7)

| Data Pengumpulan | Keterangan |
|---|---|
| **Nama Mahasiswa** | Wayan Muizul Rozzak |
| **NIM** | 2415051111 |
| **Kelas** | PTI 5A |
| **Nama Project** | BookShelf - Mobile Application Mini Project |
| **Tema Project** | BookShelf (Personal Reading & Bookshelf Manager) |
| **URL GitHub Repository** | https://github.com/wayanmuizul/UTS_2415051111_Wayan_Muizul_Rozzak |
| **Nama Branch Utama** | `master` |
| **REST API yang digunakan** | Google Books API (`https://www.googleapis.com/books/v1/volumes`) |
| **Backend / Database yang digunakan** | Supabase (PostgreSQL) tabel `saved_books` + Dual Local Storage |
| **Jumlah Screen Fungsional** | 9 Screen (Home, Select Book, Catalog, Detail, Add, Edit, Library, Report, Profile) |
| **Jumlah Meaningful Commit** | 17 Commit (Memenuhi syarat minimal 16) |
| **Hash Commit Final** | `a5d0e3c` |
| **Link APK / File APK** | `UTS_2415051111_Wayan Muizul Rozzak.apk` |

---

### Bukti Git Log (`git log --oneline`):
```text
a5d0e3c Enhance edit actions accessibility and integrate unified search for newly added books
7dc7876 Finalize UTS mobile application
17c1e47 Improve UI and responsive behavior
53c4c6e Add loading and error handling
35aa0df Add interaction and user feedback
b1a733d Implement delete data feature
79c8ebb Implement update data feature
dab895d Implement create data feature
c4eab3e Integrate backend database
15a6574 Integrate REST API
cced29e Implement application state management
01a92f6 Add application data models
d4a7db0 Add application navigation
44f0278 Implement responsive layouts
2876a30 Build initial application UI
ba2e599 Setup project architecture and folders
ea22c8f Initialize Flutter UTS project
```

---

### Verifikasi Spesifikasi Minimum (Checklist Penilaian Dosen)

- [x] **Screen Fungsional (>= 6)**: 9 screen fungsional (Splash tidak dihitung).
- [x] **Dart Model (>= 2)**: 4 model (`Book`, `SavedBook`, `ReadingStats`, `UserProfile`).
- [x] **Reusable Widgets (>= 3)**: 7 custom reusable widgets terpisah.
- [x] **Responsive Layout**: Compact (< 850px) dan Wide (>= 850px) + NavigationRail.
- [x] **REST API**: Google Books API (GET, JSON parsing ke model Dart, Loading, Error, Empty state).
- [x] **Backend Database**: Supabase PostgreSQL (Tabel `saved_books` dengan 16 field data + primary key `id`).
- [x] **CRUD Database**: Create, Read, Update, Delete (lengkap dengan Confirmation Dialog pada Delete).
- [x] **State Management**: Provider + ChangeNotifier (`BookProvider`, `LibraryProvider`, `StatsProvider`).
- [x] **Navigation & Passing Data**: Multi-screen navigation dengan passing data instance buku antar-screen.
- [x] **Form & Validation**: Form Tambah dan Edit dengan validasi judul, pengarang, halaman, dan progress.
- [x] **User Feedback**: Feedback via SnackBar dan dialog konfirmasi.
- [x] **Git & GitHub**: 16 commit bertahap dengan README lengkap.
