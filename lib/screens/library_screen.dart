import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_book.dart';
import '../providers/library_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/book_card_widget.dart';
import '../widgets/confirm_dialog.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

/// SCREEN 7: Library Screen
/// Tab "Library" pada Bottom Navigation Bar (sesuai icon tengah pada foto).
/// Menampilkan koleksi seluruh buku yang disimpan di Database pengguna.
/// Mendukung filter tab, pencarian lokal, delete dengan konfirmasi, dan edit.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();
    final allBooks = provider.savedBooks;

    // Filter list
    var displayList = allBooks;
    if (_activeFilter != 'all') {
      displayList = displayList.where((b) => b.status == _activeFilter).toList();
    }

    if (_searchController.text.trim().isNotEmpty) {
      final q = _searchController.text.trim().toLowerCase();
      displayList = displayList
          .where((b) => b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Library / Rak Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight),
            tooltip: 'Tambah Buku',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddBookScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search within Library
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari di rak buku Anda...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('all', 'Semua (${allBooks.length})'),
                _buildFilterChip(
                  ReadingStatus.currentlyReading,
                  'Reading (${allBooks.where((b) => b.status == ReadingStatus.currentlyReading).length})',
                ),
                _buildFilterChip(
                  ReadingStatus.forReading,
                  'Plan (${allBooks.where((b) => b.status == ReadingStatus.forReading).length})',
                ),
                _buildFilterChip(
                  ReadingStatus.read,
                  'Finished (${allBooks.where((b) => b.status == ReadingStatus.read).length})',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Book List
          Expanded(
            child: displayList.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final book = displayList[index];

                      return Dismissible(
                        key: Key(book.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                        ),
                        confirmDismiss: (direction) async {
                          return await ConfirmDialog.show(
                            context,
                            title: 'Hapus Buku',
                            message: 'Yakin ingin menghapus "${book.title}" dari rak buku?',
                          );
                        },
                        onDismissed: (_) {
                          provider.deleteBook(book.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Buku "${book.title}" telah dihapus.'),
                              backgroundColor: AppColors.surfaceLight,
                            ),
                          );
                        },
                        child: BookCardWidget(
                          book: book,
                          displayMode: BookCardDisplayMode.list,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookDetailScreen(savedBook: book),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => setState(() => _activeFilter = key),
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isSelected ? AppColors.primaryLight : AppColors.border),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada buku yang cocok di rak Anda.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddBookScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Buku Baru'),
          ),
        ],
      ),
    );
  }
}
