import 'package:flutter/material.dart';
import '../models/saved_book.dart';
import '../repositories/book_repository.dart';

/// Provider utama untuk mengelola State Rak Buku / Database Personal (CRUD)
/// Memenuhi ketentuan UTS: Provider + ChangeNotifier, shared state (last read book, filter, tabs),
/// operasi CRUD lengkap ke backend database.
class LibraryProvider extends ChangeNotifier {
  final BookRepository _repository;

  LibraryProvider({BookRepository? repository})
      : _repository = repository ?? BookRepository();

  List<SavedBook> _savedBooks = [];
  SavedBook? _activeBook;
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentTab = 'currently_reading'; // 'currently_reading', 'for_reading', 'read', 'all'
  String _searchQuery = '';

  // Getters
  List<SavedBook> get savedBooks => _savedBooks;
  SavedBook? get activeBook => _activeBook;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get currentTab => _currentTab;
  String get searchQuery => _searchQuery;

  /// Buku yang difilter sesuai tab yang aktif dan query pencarian
  List<SavedBook> get filteredBooks {
    // Jika sedang dalam pencarian, cari di seluruh buku agar buku yang baru ditambahkan langsung ditemukan
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      return _savedBooks
          .where((book) =>
              book.title.toLowerCase().contains(q) ||
              book.author.toLowerCase().contains(q) ||
              book.note.toLowerCase().contains(q))
          .toList();
    }

    var list = _savedBooks;

    // Filter berdasarkan status tab jika tidak sedang mencari
    if (_currentTab != 'all') {
      list = list.where((book) => book.status == _currentTab).toList();
    }

    return list;
  }

  /// Memuat data buku tersimpan dari Database
  Future<void> loadSavedBooks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _savedBooks = await _repository.getSavedBooks();

      // Cari active book (Your Last Read Book)
      final activeId = await _repository.getActiveBookId();
      if (activeId != null && _savedBooks.any((b) => b.id == activeId)) {
        _activeBook = _savedBooks.firstWhere((b) => b.id == activeId);
      } else if (_savedBooks.isNotEmpty) {
        // Default ke buku pertama yang sedang dibaca atau buku pertama
        final readingBooks = _savedBooks.where((b) => b.status == ReadingStatus.currentlyReading).toList();
        _activeBook = readingBooks.isNotEmpty ? readingBooks.first : _savedBooks.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat rak buku: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Menetapkan tab aktif (Currently Reading, For Reading, Read)
  void setTab(String tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    notifyListeners();
  }

  /// Mengatur query pencarian dalam rak
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// CREATE: Menambah buku baru ke rak / database
  Future<bool> addBook(SavedBook book) async {
    _isLoading = true;
    notifyListeners();

    try {
      final inserted = await _repository.saveBook(book);
      _savedBooks.removeWhere((b) => b.id == inserted.id);
      _savedBooks.insert(0, inserted);

      // Jika buku yang ditambahkan statusnya currently_reading dan belum ada active book
      if (_activeBook == null || inserted.status == ReadingStatus.currentlyReading) {
        _activeBook = inserted;
        await _repository.setActiveBookId(inserted.id);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menyimpan buku: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// UPDATE: Memperbarui data buku pada database
  Future<bool> updateBook(SavedBook updatedBook) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.updateSavedBook(updatedBook);
      if (success) {
        final index = _savedBooks.indexWhere((b) => b.id == updatedBook.id);
        if (index >= 0) {
          _savedBooks[index] = updatedBook;
        }

        if (_activeBook?.id == updatedBook.id) {
          _activeBook = updatedBook;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Data tidak dapat diperbarui.');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memperbarui buku: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// DELETE: Menghapus buku dari database
  Future<bool> deleteBook(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteSavedBook(id);
      if (success) {
        _savedBooks.removeWhere((b) => b.id == id);

        if (_activeBook?.id == id) {
          _activeBook = _savedBooks.isNotEmpty ? _savedBooks.first : null;
          if (_activeBook != null) {
            await _repository.setActiveBookId(_activeBook!.id);
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Gagal menghapus buku.');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menghapus buku: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Mengubah buku yang sedang aktif dibaca ("Your Last Read Book")
  Future<void> setActiveBook(SavedBook book) async {
    _activeBook = book;
    await _repository.setActiveBookId(book.id);
    notifyListeners();
  }
}
