import 'package:flutter/material.dart';
import '../models/saved_book.dart';
import '../screens/edit_book_screen.dart';
import '../utils/app_colors.dart';
import 'reading_progress_bar.dart';

enum BookCardDisplayMode { list, grid }

/// Reusable Widget 5: Kartu buku serbaguna untuk mode List (HomeScreen/Library)
/// dan mode Grid 3 kolom (Select Book Screen sesuai foto kanan).
class BookCardWidget extends StatelessWidget {
  final SavedBook book;
  final BookCardDisplayMode displayMode;
  final bool isSelected;
  final bool showEditButton;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onLongPress;

  const BookCardWidget({
    super.key,
    required this.book,
    this.displayMode = BookCardDisplayMode.list,
    this.isSelected = false,
    this.showEditButton = true,
    this.onTap,
    this.onEdit,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (displayMode == BookCardDisplayMode.grid) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  /// Tampilan mode List sesuai foto kiri ("Other Books")
  Widget _buildListCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                _buildCover(width: 58, height: 82),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (showEditButton)
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                color: AppColors.primaryLight,
                                size: 22,
                              ),
                              tooltip: 'Edit Buku',
                              onPressed: onEdit ??
                                  () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EditBookScreen(book: book),
                                      ),
                                    );
                                  },
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.startedDaysAgoText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Minutes read
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${book.readingTimeMinutes} minutes read',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress
                      Row(
                        children: [
                          Text(
                            'Page ${book.currentPage} of ${book.totalPages}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ReadingProgressBar(
                              progressPercent: book.progressPercent,
                              height: 5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tampilan mode Grid sesuai foto kanan ("Select Book")
  Widget _buildGridCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.cardSelected : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.borderHighlight : AppColors.border,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.borderHighlight.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                Expanded(
                  child: Center(
                    child: _buildCover(width: double.infinity, height: double.infinity),
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // Started
                Text(
                  book.startedDaysAgoText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                // Progress: "23 p" --- [bar] --- "754 p"
                Row(
                  children: [
                    Text(
                      '${book.currentPage} p',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ReadingProgressBar(
                        progressPercent: book.progressPercent,
                        height: 4,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${book.totalPages} p',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildCover({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: book.coverUrl.isNotEmpty
            ? Image.network(
                book.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceLight,
      padding: const EdgeInsets.all(4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_rounded, color: AppColors.primaryLight, size: 24),
            const SizedBox(height: 2),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
