import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/saved_book.dart';
import '../providers/book_provider.dart';
import '../providers/library_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/book_status_badge.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';
import 'edit_book_screen.dart';

/// SCREEN 3: Catalog / Explore Screen
/// Mengintegrasikan REST API (Google Books API) secara langsung:
/// - Operasi HTTP GET
/// - Menampilkan buku dari JSON response yang dikonversi ke Dart Model (Book)
/// - Memiliki Loading State, Error State (dengan retry), dan Empty State
/// - Pencarian terintegrasi: Mencari ke Rak Buku Lokal & Katalog Online Google Books
/// - Layout responsif (Compact 2 kolom / Wide 4 kolom)
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BookProvider>();
      if (provider.books.isEmpty) {
        provider.fetchBooks();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final libraryProvider = context.watch<LibraryProvider>();

    final query = _searchController.text.trim().toLowerCase();
    // Buku dari rak lokal pengguna yang cocok dengan pencarian
    final savedMatches = query.isNotEmpty
        ? libraryProvider.savedBooks
            .where((b) =>
                b.title.toLowerCase().contains(query) ||
                b.author.toLowerCase().contains(query) ||
                b.note.toLowerCase().contains(query))
            .toList()
        : <SavedBook>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Catalog (REST API)'),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.primaryLight,
            ),
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryLight),
            tooltip: 'Refresh API Data',
            onPressed: () => bookProvider.fetchBooks(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (_) => setState(() {}),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  bookProvider.fetchBooks(query: value.trim());
                }
              },
              decoration: InputDecoration(
                hintText: 'Cari judul, pengarang di Rak & Google Books...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          bookProvider.fetchBooks(query: 'bestseller');
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

          // Category Filter Chips
          _buildCategoryChips(bookProvider),
          const SizedBox(height: 8),

          // Main Content: Local Saved Matches + Online API Results
          Expanded(
            child: _buildBodyContent(bookProvider, savedMatches),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BookProvider provider) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final cat = provider.categories[index];
          final isSelected = provider.selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => provider.setCategory(cat),
              backgroundColor: AppColors.surfaceLight,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryLight : AppColors.border,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(BookProvider provider, List<SavedBook> savedMatches) {
    // 1. Loading State
    if (provider.isLoading && savedMatches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryLight),
            SizedBox(height: 16),
            Text(
              'Mengambil data dari Google Books API...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // 2. Error State
    if (provider.hasError && savedMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 14),
              Text(
                provider.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.fetchBooks(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State (jika API kosong dan di rak juga kosong)
    if (provider.books.isEmpty && savedMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 14),
            const Text(
              'Tidak ada buku yang ditemukan untuk pencarian ini.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
                provider.fetchBooks(query: 'bestseller');
              },
              child: const Text('Tampilkan Buku Populer'),
            ),
          ],
        ),
      );
    }

    // 4. Data State: Tampilkan hasil pencarian dari Rak Buku Anda (jika ada) + Hasil API
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bagian Buku dari Rak Anda (Jika sedang mencari dan ada kecocokan)
        if (savedMatches.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📚 Di Rak Buku Anda (${savedMatches.length} ditemukan)',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Tersimpan',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...savedMatches.map((saved) => _buildSavedBookTile(context, saved)),
              ],
            ),
          ),
          if (provider.books.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                '🌐 Hasil Dari Google Books API',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],

        // Bagian Hasil API (Grid atau List)
        if (provider.books.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              if (_isGridView) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 5
                    : (constraints.maxWidth > 600 ? 4 : 2);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: provider.books.length,
                  itemBuilder: (context, index) {
                    final book = provider.books[index];
                    return _buildApiBookGridCard(context, book);
                  },
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.books.length,
                itemBuilder: (context, index) {
                  final book = provider.books[index];
                  return _buildApiBookListCard(context, book);
                },
              );
            },
          ),
      ],
    );
  }

  /// Tile untuk buku tersimpan di rak lokal pengguna dengan tombol Edit langsung
  Widget _buildSavedBookTile(BuildContext context, SavedBook saved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 42,
              height: 60,
              child: saved.coverUrl.isNotEmpty
                  ? Image.network(
                      saved.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.book, color: AppColors.primaryLight),
                    )
                  : const Icon(Icons.book, color: AppColors.primaryLight),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  saved.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  saved.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                BookStatusBadge(status: saved.status),
              ],
            ),
          ),
          // Tombol Edit Buku
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryLight, size: 24),
            tooltip: 'Edit Buku Ini',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditBookScreen(book: saved)),
              );
            },
          ),
          // Tombol Detail
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            tooltip: 'Lihat Detail',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BookDetailScreen(savedBook: saved)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApiBookGridCard(BuildContext context, Book book) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookDetailScreen(apiBook: book)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: book.thumbnail.isNotEmpty
                          ? Image.network(
                              book.thumbnail,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildCoverPlaceholder(book.title),
                            )
                          : _buildCoverPlaceholder(book.title),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  book.authorNames,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${book.pageCount} hal',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.bookmark_add_outlined,
                        size: 18,
                        color: AppColors.primaryLight,
                      ),
                      tooltip: 'Simpan ke Rak',
                      onPressed: () => _quickSaveToLibrary(context, book),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApiBookListCard(BuildContext context, Book book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookDetailScreen(apiBook: book)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 55,
                    height: 75,
                    child: book.thumbnail.isNotEmpty
                        ? Image.network(
                            book.thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildCoverPlaceholder(book.title),
                          )
                        : _buildCoverPlaceholder(book.title),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authorNames,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${book.pageCount > 0 ? '${book.pageCount} Halaman' : 'Halaman n/a'} • ${book.publishedDate}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined, color: AppColors.primaryLight),
                  tooltip: 'Simpan ke Rak Buku',
                  onPressed: () => _quickSaveToLibrary(context, book),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder(String title) {
    return Container(
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(Icons.book_rounded, color: AppColors.primaryLight, size: 28),
      ),
    );
  }

  void _quickSaveToLibrary(BuildContext context, Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBookScreen(initialBook: book),
      ),
    );
  }
}
