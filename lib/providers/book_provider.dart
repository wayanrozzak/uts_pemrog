import 'package:flutter/material.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';

/// Provider untuk mengelola state Katalog Buku dari REST API
/// Memenuhi ketentuan UTS: Provider + ChangeNotifier, state loading/data/error, parsing JSON.
class BookProvider extends ChangeNotifier {
  final BookRepository _repository;

  BookProvider({BookRepository? repository})
      : _repository = repository ?? BookRepository();

  List<Book> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = 'bestseller';
  String _selectedCategory = 'All';

  // Getters
  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  final List<String> categories = [
    'All',
    'Fiction',
    'Philosophy',
    'Fantasy',
    'Technology',
    'Biography',
    'Thriller',
  ];

  /// Mengambil data dari REST API
  Future<void> fetchBooks({String? query}) async {
    final search = query ?? _searchQuery;
    _searchQuery = search;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final actualQuery = _selectedCategory == 'All'
          ? search
          : '$search subject:${_selectedCategory.toLowerCase()}';

      _books = await _repository.searchApiBooks(query: actualQuery);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat katalog buku: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Memilih kategori buku
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchBooks();
  }

  /// Reset error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
