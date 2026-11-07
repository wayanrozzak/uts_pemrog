import '../models/book.dart';
import '../models/saved_book.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

/// Repository Pattern untuk aplikasi BookShelf
/// Menggabungkan data dari REST API (Katalog Buku) dan Backend Database (Buku Tersimpan/CRUD)
/// Memastikan pemisahan tanggung jawab (Separation of Concerns) sesuai standar arsitektur UTS.
class BookRepository {
  final ApiService _apiService;
  final SupabaseService _dbService;

  BookRepository({
    ApiService? apiService,
    SupabaseService? dbService,
  })  : _apiService = apiService ?? ApiService(),
        _dbService = dbService ?? SupabaseService();

  // --- REST API Operations ---

  /// Mengambil daftar buku dari REST API eksternal (Google Books)
  Future<List<Book>> searchApiBooks({String query = 'programming', int maxResults = 20}) async {
    return await _apiService.fetchBooks(query: query, maxResults: maxResults);
  }

  /// Mengambil detail satu buku dari REST API
  Future<Book> getApiBookDetail(String volumeId) async {
    return await _apiService.fetchBookById(volumeId);
  }

  // --- Database CRUD Operations ---

  /// READ: Mengambil seluruh buku yang tersimpan di database
  Future<List<SavedBook>> getSavedBooks() async {
    return await _dbService.fetchAllBooks();
  }

  /// CREATE: Menyimpan buku baru ke database
  Future<SavedBook> saveBook(SavedBook book) async {
    return await _dbService.insertBook(book);
  }

  /// UPDATE: Memperbarui data buku pada database
  Future<bool> updateSavedBook(SavedBook book) async {
    return await _dbService.updateBook(book);
  }

  /// DELETE: Menghapus buku dari database
  Future<bool> deleteSavedBook(String id) async {
    return await _dbService.deleteBook(id);
  }

  /// Mengambil buku aktif yang terakhir dibaca ("Your Last Read Book")
  Future<String?> getActiveBookId() async {
    return await _dbService.getActiveBookId();
  }

  /// Menetapkan buku aktif yang terakhir dibaca
  Future<void> setActiveBookId(String id) async {
    await _dbService.setActiveBookId(id);
  }
}
