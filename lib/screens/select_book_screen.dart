import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_book.dart';
import '../providers/library_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/book_card_widget.dart';
import 'add_book_screen.dart';

/// SCREEN 2: Select Book Screen (Modal / Sheet)
/// Mereplikasi secara persis UI foto sisi kanan referensi UTS:
/// - Header: "Select Book" dengan ikon close (X) di kanan atas
/// - Grid 3 kolom dengan buku-buku (Dear Life, Harry Potter, Sophie's World, Amazon Unbound, dll)
/// - Highlight border oranye/amber pada buku yang dipilih
/// - Tombol bawah: "Add new book" (outlined) dan "Confirm" (solid purple)
class SelectBookScreen extends StatefulWidget {
  const SelectBookScreen({super.key});

  @override
  State<SelectBookScreen> createState() => _SelectBookScreenState();
}

class _SelectBookScreenState extends State<SelectBookScreen> {
  String? _selectedBookId;

  @override
  void initState() {
    super.initState();
    final currentActive = context.read<LibraryProvider>().activeBook;
    _selectedBookId = currentActive?.id;
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final books = libraryProvider.savedBooks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: "Select Book" & Close (X) button
            _buildHeader(context),
            const SizedBox(height: 8),

            // Responsive Grid of Books (3 kolom di compact, 4-5 kolom di wide)
            Expanded(
              child: books.isEmpty
                  ? _buildEmptyState(context)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 800
                            ? 5
                            : (constraints.maxWidth > 550 ? 4 : 3);

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            final isSelected = book.id == _selectedBookId;

                            return BookCardWidget(
                              book: book,
                              displayMode: BookCardDisplayMode.grid,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedBookId = book.id;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
            ),

            // Bottom Buttons: "Add new book" & "Confirm"
            _buildBottomButtons(context, libraryProvider, books),
          ],
        ),
      ),
    );
  }

  /// Header Modal: "Select Book" dengan tombol close bulat
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Book',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan kosong jika belum ada buku
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.library_books_outlined, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Belum ada buku di rak Anda',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddBookScreen()),
              );
            },
            child: const Text('Tambah Buku Baru'),
          ),
        ],
      ),
    );
  }

  /// Bar Tombol Bawah: "Add new book" & "Confirm" persis foto kanan
  Widget _buildBottomButtons(
    BuildContext context,
    LibraryProvider provider,
    List<SavedBook> books,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Left button: "Add new book"
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddBookScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Add new book',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Right button: "Confirm"
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedBookId == null
                  ? null
                  : () async {
                      final selectedBook = books.firstWhere(
                        (b) => b.id == _selectedBookId,
                        orElse: () => books.first,
                      );
                      await provider.setActiveBook(selectedBook);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Buku "${selectedBook.title}" dipilih sebagai buku bacaan aktif!',
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
