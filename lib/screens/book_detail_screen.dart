import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/saved_book.dart';
import '../providers/library_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/book_status_badge.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/reading_progress_bar.dart';
import 'add_book_screen.dart';
import 'edit_book_screen.dart';

/// SCREEN 4: Detail Screen
/// Mendukung passing data dari List/Catalog maupun Rak Buku (SavedBook / Book)
/// Memenuhi ketentuan UTS:
/// - Navigasi list -> detail dengan passing data
/// - Tampilan detail lengkap: Cover, judul, pengarang, deskripsi, rating, progress
/// - Operasi update status, edit catatan, dan delete dengan Confirmation Dialog.
class BookDetailScreen extends StatelessWidget {
  final Book? apiBook;
  final SavedBook? savedBook;

  const BookDetailScreen({
    super.key,
    this.apiBook,
    this.savedBook,
  }) : assert(apiBook != null || savedBook != null, 'Harus menyediakan apiBook atau savedBook');

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();

    // Cek apakah buku ini sudah ada di database tersimpan
    SavedBook? currentSavedBook = savedBook;
    if (apiBook != null) {
      final matches = libraryProvider.savedBooks.where((b) => b.bookId == apiBook!.id);
      if (matches.isNotEmpty) {
        currentSavedBook = matches.first;
      }
    } else if (savedBook != null) {
      final matches = libraryProvider.savedBooks.where((b) => b.id == savedBook!.id);
      if (matches.isNotEmpty) {
        currentSavedBook = matches.first;
      }
    }

    final isAlreadySaved = currentSavedBook != null;
    final savedForAction = currentSavedBook;

    final title = currentSavedBook?.title ?? apiBook?.title ?? '';
    final author = currentSavedBook?.author ?? apiBook?.authorNames ?? '';
    final coverUrl = currentSavedBook?.coverUrl ?? apiBook?.thumbnail ?? '';
    final description = currentSavedBook?.description.isNotEmpty == true
        ? currentSavedBook!.description
        : (apiBook?.description ?? 'Tidak ada deskripsi tersedia.');
    final totalPages = currentSavedBook?.totalPages ?? apiBook?.pageCount ?? 0;
    final rating = currentSavedBook?.rating ?? apiBook?.averageRating ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Buku'),
        actions: [
          if (savedForAction != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, size: 26, color: AppColors.primaryLight),
              tooltip: 'Edit Buku & Catatan',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditBookScreen(book: savedForAction)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: 'Hapus dari Rak',
              onPressed: () => _confirmDelete(context, savedForAction, libraryProvider),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Cover & Header Card
            _buildHeroCoverSection(context, title, author, coverUrl, currentSavedBook),
            const SizedBox(height: 24),

            // Reading Progress Card (jika sudah disimpan di rak)
            if (currentSavedBook != null) ...[
              _buildReadingProgressSection(context, currentSavedBook),
              const SizedBox(height: 20),
            ],

            // Metadata Chips (Rating, Halaman, Bahasa)
            _buildMetadataRow(rating, totalPages, apiBook?.language ?? 'en'),
            const SizedBox(height: 24),

            // Deskripsi / Sinopsis
            const Text(
              'Sinopsis & Deskripsi',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Catatan Pribadi (Personal Notes)
            if (isAlreadySaved && currentSavedBook.note.isNotEmpty) ...[
              const Text(
                'Catatan Pribadi',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.edit_note_rounded, color: AppColors.primaryLight, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentSavedBook.note,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            _buildActionButtons(context, isAlreadySaved, currentSavedBook, apiBook),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCoverSection(
    BuildContext context,
    String title,
    String author,
    String coverUrl,
    SavedBook? saved,
  ) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 140,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: coverUrl.isNotEmpty
                  ? Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderCover(title),
                    )
                  : _buildPlaceholderCover(title),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            author,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          if (saved != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BookStatusBadge(status: saved.status),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => EditBookScreen(book: saved)),
                    );
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.primaryLight),
                  label: const Text(
                    'Edit Buku',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                    side: const BorderSide(color: AppColors.primaryLight, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover(String title) {
    return Container(
      color: AppColors.surfaceLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_rounded, color: AppColors.primaryLight, size: 48),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(double rating, int pages, String lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMetaItem(
          Icons.star_rounded,
          AppColors.progressAmber,
          rating > 0 ? rating.toStringAsFixed(1) : '4.5',
          'Rating',
        ),
        _buildMetaItem(
          Icons.auto_stories_rounded,
          AppColors.primaryLight,
          pages > 0 ? '$pages hal' : '200 hal',
          'Panjang Buku',
        ),
        _buildMetaItem(
          Icons.language_rounded,
          AppColors.info,
          lang.toUpperCase(),
          'Bahasa',
        ),
      ],
    );
  }

  Widget _buildMetaItem(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingProgressSection(BuildContext context, SavedBook saved) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Membaca',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(saved.progressPercent * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.progressAmber,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ReadingProgressBar(
            progressPercent: saved.progressPercent,
            height: 8,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Halaman ${saved.currentPage} dari ${saved.totalPages}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                'Waktu baca: ${saved.readingTimeMinutes} menit',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool isAlreadySaved,
    SavedBook? saved,
    Book? api,
  ) {
    if (isAlreadySaved && saved != null) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditBookScreen(book: saved)),
                );
              },
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: const Text('Edit Buku & Update Progress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
    }

    // Buku belum disimpan di rak: tombol Tambah ke Rak Buku
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddBookScreen(initialBook: api),
            ),
          );
        },
        icon: const Icon(Icons.bookmark_add_rounded, size: 20),
        label: const Text('Simpan ke Rak Buku Saya'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  /// Menampilkan Confirmation Dialog sebelum delete (sesuai kriteria UTS)
  void _confirmDelete(
    BuildContext context,
    SavedBook book,
    LibraryProvider provider,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hapus Buku',
      message:
          'Apakah Anda yakin ingin menghapus buku "${book.title}" dari rak buku Anda? Data catatan dan progress akan dihapus.',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.deleteBook(book.id);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Buku "${book.title}" berhasil dihapus dari rak.'),
              backgroundColor: AppColors.surfaceLight,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus buku dari database.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
