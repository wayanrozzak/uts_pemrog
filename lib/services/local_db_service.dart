import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_book.dart';

/// Service Database Lokal Persisten
/// Mengimplementasikan operasi CRUD lengkap (Create, Read, Update, Delete)
/// dan menjamin data tersimpan secara persisten di perangkat.
class LocalDbService {
  static const String _storageKey = 'bookshelf_saved_books_v1';
  static const String _activeBookKey = 'bookshelf_active_book_id_v1';

  /// Membaca semua data buku tersimpan
  Future<List<SavedBook>> getAllBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      // Jika pertama kali dijalankan, inisialisasi dengan data default sesuai screenshot UTS
      final initialData = _getInitialSeededBooks();
      await saveAllBooks(initialData);
      return initialData;
    }

    try {
      final List decoded = json.decode(jsonString);
      return decoded.map((item) => SavedBook.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _getInitialSeededBooks();
    }
  }

  /// Menyimpan seluruh list buku ke local storage
  Future<bool> saveAllBooks(List<SavedBook> books) async {
    final prefs = await SharedPreferences.getInstance();
    final dataList = books.map((b) => b.toMap()).toList();
    return await prefs.setString(_storageKey, json.encode(dataList));
  }

  /// CREATE: Menambahkan buku baru ke database
  Future<SavedBook> insertBook(SavedBook book) async {
    final books = await getAllBooks();
    // Cek apakah sudah ada ID yang sama
    final existingIndex = books.indexWhere((b) => b.id == book.id);
    if (existingIndex >= 0) {
      books[existingIndex] = book;
    } else {
      books.insert(0, book);
    }
    await saveAllBooks(books);
    return book;
  }

  /// READ: Mengambil satu buku berdasarkan ID
  Future<SavedBook?> getBookById(String id) async {
    final books = await getAllBooks();
    final matches = books.where((b) => b.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// UPDATE: Memperbarui data buku yang ada di database
  Future<bool> updateBook(SavedBook updatedBook) async {
    final books = await getAllBooks();
    final index = books.indexWhere((b) => b.id == updatedBook.id);
    if (index >= 0) {
      books[index] = updatedBook.copyWith(updatedAt: DateTime.now());
      await saveAllBooks(books);
      return true;
    }
    return false;
  }

  /// DELETE: Menghapus data buku dari database
  Future<bool> deleteBook(String id) async {
    final books = await getAllBooks();
    final initialCount = books.length;
    books.removeWhere((b) => b.id == id);
    if (books.length < initialCount) {
      await saveAllBooks(books);
      return true;
    }
    return false;
  }

  /// Menyimpan ID buku yang sedang aktif dibaca ("Your Last Read Book")
  Future<void> setActiveBookId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeBookKey, id);
  }

  /// Mengambil ID buku yang sedang aktif dibaca
  Future<String?> getActiveBookId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeBookKey);
  }

  /// Data seed awal yang persis seperti tampilan pada screenshot UTS
  List<SavedBook> _getInitialSeededBooks() {
    final now = DateTime.now();
    return [
      SavedBook(
        id: 'seed_dear_life',
        studentId: '2415051111',
        bookId: 'dear_life_01',
        title: 'Dear Life',
        author: 'Rachel Clarke',
        coverUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
        description: 'A beautiful, profound memoir about life, love, death and palliative care.',
        totalPages: 140,
        currentPage: 70,
        status: ReadingStatus.currentlyReading,
        readingTimeMinutes: 60,
        startedDate: now.subtract(const Duration(days: 10)),
        rating: 4.8,
        note: 'Buku yang sangat menyentuh tentang makna hidup dan welas asih.',
      ),
      SavedBook(
        id: 'seed_sophies_world',
        studentId: '2415051111',
        bookId: 'sophie_world_03',
        title: "Sophie's World",
        author: 'Jostein Gaarder',
        coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
        description: 'Petualangan filosofis seorang gadis remaja melalui sejarah pemikiran dunia.',
        totalPages: 160,
        currentPage: 38,
        status: ReadingStatus.currentlyReading,
        readingTimeMinutes: 35,
        startedDate: now.subtract(const Duration(days: 20)),
        rating: 4.6,
        note: 'Bab Socrates dan Plato sangat menarik dipelajari.',
      ),
      SavedBook(
        id: 'seed_the_secret_cage',
        studentId: '2415051111',
        bookId: 'secret_cage_05',
        title: 'The Secret Cage',
        author: 'Alison Williams',
        coverUrl: 'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?w=400',
        description: 'A psychological thriller about secrets and survival.',
        totalPages: 566,
        currentPage: 104,
        status: ReadingStatus.currentlyReading,
        readingTimeMinutes: 90,
        startedDate: now.subtract(const Duration(days: 10)),
        rating: 4.4,
        note: 'Plot twist di halaman 80 sangat mengejutkan!',
      ),
      SavedBook(
        id: 'seed_harry_potter',
        studentId: '2415051111',
        bookId: 'hp_deathly_02',
        title: 'Harry Potter and the Deathly Hallows',
        author: 'J.K. Rowling',
        coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
        description: 'Seri terakhir pertempuran Harry Potter melawan Lord Voldemort.',
        totalPages: 754,
        currentPage: 23,
        status: ReadingStatus.currentlyReading,
        readingTimeMinutes: 60,
        startedDate: now.subtract(const Duration(days: 7)),
        rating: 4.9,
        note: 'Nostalgia membaca seri fantasi terbaik.',
      ),
      SavedBook(
        id: 'seed_amazon_unbound',
        studentId: '2415051111',
        bookId: 'amazon_unbound_04',
        title: 'Amazon Unbound',
        author: 'Brad Stone',
        coverUrl: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=400',
        description: 'Jeff Bezos and the Invention of a Global Empire.',
        totalPages: 130,
        currentPage: 108,
        status: ReadingStatus.forReading,
        readingTimeMinutes: 45,
        startedDate: now.subtract(const Duration(days: 44)),
        rating: 4.5,
        note: 'Mempelajari cara kerja inovasi teknologi global.',
      ),
      SavedBook(
        id: 'seed_death_of_ivan',
        studentId: '2415051111',
        bookId: 'death_ivan_06',
        title: 'The Death Of Ivan Ilych',
        author: 'Leo Tolstoy',
        coverUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400',
        description: 'Masterpiece Leo Tolstoy tentang refleksi makna kehidupan.',
        totalPages: 189,
        currentPage: 174,
        status: ReadingStatus.read,
        readingTimeMinutes: 120,
        startedDate: now.subtract(const Duration(days: 32)),
        rating: 4.7,
        note: 'Selesai dibaca. Refleksi yang sangat mendalam.',
      ),
    ];
  }
}
