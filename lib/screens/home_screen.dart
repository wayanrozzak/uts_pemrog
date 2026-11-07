import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_book.dart';
import '../providers/library_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/book_card_widget.dart';
import '../widgets/last_read_card_widget.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';
import 'select_book_screen.dart';

/// SCREEN 1: Home Dashboard
/// Mereplikasi secara persis UI foto sisi kiri referensi UTS:
/// - Header: "+ Add new book" button
/// - Section: "Your Last Read Book" (dengan cover, waktu baca, dan progress bar oranye)
/// - Section: "Other Books" dengan filter status (Currently Reading, For Reading, Read)
/// - Responsive layout (Compact vs Wide)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final activeBook = libraryProvider.activeBook;
    final filteredBooks = libraryProvider.filteredBooks;
    final currentTab = libraryProvider.currentTab;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;

            if (isWide) {
              return _buildWideLayout(
                context,
                activeBook: activeBook,
                filteredBooks: filteredBooks,
                currentTab: currentTab,
                libraryProvider: libraryProvider,
              );
            }

            return _buildCompactLayout(
              context,
              activeBook: activeBook,
              filteredBooks: filteredBooks,
              currentTab: currentTab,
              libraryProvider: libraryProvider,
            );
          },
        ),
      ),
    );
  }

  /// Layout Compact (Mobile < 650px) - Persis seperti foto kiri!
  Widget _buildCompactLayout(
    BuildContext context, {
    required SavedBook? activeBook,
    required List<SavedBook> filteredBooks,
    required String currentTab,
    required LibraryProvider libraryProvider,
  }) {
    return RefreshIndicator(
      color: AppColors.primaryLight,
      backgroundColor: AppColors.surface,
      onRefresh: () => libraryProvider.loadSavedBooks(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Top Header Bar
          _buildTopHeader(context),
          const SizedBox(height: 24),

          // Section 1: Your Last Read Book
          _buildLastReadSection(context, activeBook),
          const SizedBox(height: 28),

          // Section 2: Other Books
          _buildOtherBooksHeader(context),
          const SizedBox(height: 14),

          // Filter Tabs (Currently Reading, For Reading, Read)
          _buildFilterTabs(context, currentTab, libraryProvider),
          const SizedBox(height: 16),

          // List of Other Books
          _buildOtherBooksList(context, filteredBooks, activeBook),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Layout Wide (Tablet / Desktop >= 650px) - Memenuhi spesifikasi responsif UTS
  Widget _buildWideLayout(
    BuildContext context, {
    required SavedBook? activeBook,
    required List<SavedBook> filteredBooks,
    required String currentTab,
    required LibraryProvider libraryProvider,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          _buildTopHeader(context),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sisi Kiri: Hero Last Read Book & Quick Actions
                Expanded(
                  flex: 5,
                  child: ListView(
                    children: [
                      _buildLastReadSection(context, activeBook),
                      const SizedBox(height: 20),
                      _buildQuickStatsBanner(context, libraryProvider),
                    ],
                  ),
                ),
                const SizedBox(width: 28),
                // Sisi Kanan: Other Books dengan Tabs
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOtherBooksHeader(context),
                      const SizedBox(height: 12),
                      _buildFilterTabs(context, currentTab, libraryProvider),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildOtherBooksList(context, filteredBooks, activeBook),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Header Atas: Logo BookShelf & Tombol "+ Add new book"
  Widget _buildTopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BookShelf',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Wayan Muizul Rozzak • PTI 5A',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Tombol "+ Add new book" sesuai foto referensi
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddBookScreen()),
            );
          },
          icon: const Icon(Icons.add, size: 16, color: AppColors.primaryLight),
          label: const Text(
            'Add new book',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.6),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
        ),
      ],
    );
  }

  /// Section "Your Last Read Book"
  Widget _buildLastReadSection(BuildContext context, SavedBook? activeBook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Your Last Read Book',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SelectBookScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (activeBook != null)
          LastReadCardWidget(
            book: activeBook,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookDetailScreen(savedBook: activeBook),
                ),
              );
            },
            onChangeBook: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SelectBookScreen()),
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.menu_book, color: AppColors.textMuted, size: 36),
                  const SizedBox(height: 8),
                  const Text(
                    'Belum ada buku yang aktif dibaca',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SelectBookScreen()),
                      );
                    },
                    child: const Text('Pilih Buku dari Rak'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Section "Other Books" Header
  Widget _buildOtherBooksHeader(BuildContext context) {
    return const Text(
      'Other Books',
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Tabs Filter: "Currently Reading", "For Reading", "Read"
  Widget _buildFilterTabs(
    BuildContext context,
    String currentTab,
    LibraryProvider provider,
  ) {
    final tabs = [
      {'key': ReadingStatus.currentlyReading, 'label': 'Currently Reading'},
      {'key': ReadingStatus.forReading, 'label': 'For Reading'},
      {'key': ReadingStatus.read, 'label': 'Read'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = currentTab == tab['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 18),
            child: InkWell(
              onTap: () => provider.setTab(tab['key']!),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tab['label']!,
                    style: TextStyle(
                      color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 2.5,
                    width: isSelected ? 28 : 0,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Daftar buku pada "Other Books"
  Widget _buildOtherBooksList(
    BuildContext context,
    List<SavedBook> books,
    SavedBook? activeBook,
  ) {
    // Kecualikan buku yang sedang aktif ditampilkan di "Your Last Read Book"
    final displayBooks = books.where((b) => b.id != activeBook?.id).toList();

    if (displayBooks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 10),
            const Text(
              'Tidak ada buku pada kategori ini',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddBookScreen()),
                );
              },
              child: const Text('Tambah Buku Sekarang'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayBooks.length,
      itemBuilder: (context, index) {
        final book = displayBooks[index];
        return BookCardWidget(
          book: book,
          displayMode: BookCardDisplayMode.list,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BookDetailScreen(savedBook: book),
              ),
            );
          },
        );
      },
    );
  }

  /// Banner ringkasan statistik untuk layout Wide
  Widget _buildQuickStatsBanner(BuildContext context, LibraryProvider provider) {
    final total = provider.savedBooks.length;
    final reading = provider.savedBooks
        .where((b) => b.status == ReadingStatus.currentlyReading)
        .length;
    final finished =
        provider.savedBooks.where((b) => b.status == ReadingStatus.read).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Library Overview',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildStatItem('Total Books', '$total', AppColors.primaryLight)),
              Expanded(child: _buildStatItem('Reading', '$reading', AppColors.progressAmber)),
              Expanded(child: _buildStatItem('Finished', '$finished', AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
