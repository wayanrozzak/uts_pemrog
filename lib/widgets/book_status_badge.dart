import 'package:flutter/material.dart';
import '../models/saved_book.dart';
import '../utils/app_colors.dart';

/// Reusable Widget 2: Badge pill status buku dengan warna spesifik
class BookStatusBadge extends StatelessWidget {
  final String status;

  const BookStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;

    switch (status) {
      case ReadingStatus.currentlyReading:
        badgeColor = AppColors.currentlyReading;
        label = 'Reading';
        break;
      case ReadingStatus.forReading:
        badgeColor = AppColors.forReading;
        label = 'Plan to Read';
        break;
      case ReadingStatus.read:
        badgeColor = AppColors.read;
        label = 'Finished';
        break;
      default:
        badgeColor = AppColors.textMuted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withAlpha(100), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
