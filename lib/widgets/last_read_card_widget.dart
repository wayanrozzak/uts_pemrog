import 'package:flutter/material.dart';
import '../models/saved_book.dart';
import '../utils/app_colors.dart';
import 'reading_progress_bar.dart';

/// Reusable Widget 4: Kartu khusus "Your Last Read Book" sesuai foto referensi UTS
class LastReadCardWidget extends StatelessWidget {
  final SavedBook book;
  final VoidCallback? onTap;
  final VoidCallback? onChangeBook;

  const LastReadCardWidget({
    super.key,
    required this.book,
    this.onTap,
    this.onChangeBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                _buildBookCover(),
                const SizedBox(width: 16),
                // Book Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Book Title
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Started days ago
                      Text(
                        book.startedDaysAgoText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Minutes read with clock icon
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${book.readingTimeMinutes} minutes read',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress: Page X of Y & Progress Bar
                      Row(
                        children: [
                          Text(
                            'Page ${book.currentPage} of ${book.totalPages}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ReadingProgressBar(
                              progressPercent: book.progressPercent,
                              height: 6,
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

  Widget _buildBookCover() {
    return Container(
      width: 72,
      height: 102,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: book.coverUrl.isNotEmpty
            ? Image.network(
                book.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderCover(),
              )
            : _buildPlaceholderCover(),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: AppColors.surfaceLight,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, color: AppColors.primaryLight, size: 28),
          const SizedBox(height: 4),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
