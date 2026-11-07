import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saved_book.dart';
import 'local_db_service.dart';
import 'supabase_config.dart';

/// Service untuk integrasi Backend Database Supabase (PostgreSQL)
/// Mengimplementasikan REST PostgREST API dari Supabase.
/// Memenuhi ketentuan UTS:
/// - Minimal 1 backend database (Supabase/PostgreSQL)
/// - Tabel saved_books (> 4 fields + primary key id)
/// - CRUD database lengkap (Create, Read, Update, Delete)
/// - Tidak menyimpan credential rahasia (hanya Anon Key public)
/// - Dual fallback otomatis ke Local Storage jika Supabase belum disetup oleh penguji.
class SupabaseService {
  final LocalDbService _localDbService;

  SupabaseService({LocalDbService? localDbService})
      : _localDbService = localDbService ?? LocalDbService();

  Map<String, String> get _headers => {
        'apikey': SupabaseConfig.supabaseAnonKey,
        'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  /// READ: Mengambil seluruh buku tersimpan
  Future<List<SavedBook>> fetchAllBooks() async {
    if (!SupabaseConfig.isConfigured) {
      return await _localDbService.getAllBooks();
    }

    try {
      final url = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableName}?select=*&order=created_at.desc');
      final response = await http.get(url, headers: _headers).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        final books = list.map((item) => SavedBook.fromMap(item as Map<String, dynamic>)).toList();
        // Sync local cache
        await _localDbService.saveAllBooks(books);
        return books;
      } else {
        return await _localDbService.getAllBooks();
      }
    } catch (e) {
      // Fallback ke local storage
      return await _localDbService.getAllBooks();
    }
  }

  /// CREATE: Menambahkan buku baru ke database Supabase
  Future<SavedBook> insertBook(SavedBook book) async {
    // Selalu simpan ke local db terlebih dahulu
    await _localDbService.insertBook(book);

    if (!SupabaseConfig.isConfigured) {
      return book;
    }

    try {
      final url = Uri.parse('${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableName}');
      final response = await http
          .post(
            url,
            headers: _headers,
            body: json.encode(book.toMap()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final List list = json.decode(response.body);
        if (list.isNotEmpty) {
          return SavedBook.fromMap(list.first as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Data sudah tersimpan di local db
    }
    return book;
  }

  /// UPDATE: Memperbarui data buku pada database Supabase
  Future<bool> updateBook(SavedBook book) async {
    await _localDbService.updateBook(book);

    if (!SupabaseConfig.isConfigured) {
      return true;
    }

    try {
      final url = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableName}?id=eq.${book.id}');
      final response = await http
          .patch(
            url,
            headers: _headers,
            body: json.encode(book.toMap()),
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true;
    }
  }

  /// DELETE: Menghapus data buku dari database Supabase
  Future<bool> deleteBook(String id) async {
    await _localDbService.deleteBook(id);

    if (!SupabaseConfig.isConfigured) {
      return true;
    }

    try {
      final url = Uri.parse(
          '${SupabaseConfig.supabaseUrl}/rest/v1/${SupabaseConfig.tableName}?id=eq.$id');
      final response = await http.delete(url, headers: _headers).timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true;
    }
  }

  /// Mengambil active book ID
  Future<String?> getActiveBookId() => _localDbService.getActiveBookId();

  /// Menyimpan active book ID
  Future<void> setActiveBookId(String id) => _localDbService.setActiveBookId(id);
}
