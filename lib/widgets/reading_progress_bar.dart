import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Reusable Widget 1: Progress Bar membaca buku custom oranye/amber sesuai foto referensi
class ReadingProgressBar extends StatelessWidget {
  final double progressPercent;
  final double height;
  final Color progressColor;
  final Color backgroundColor;

  const ReadingProgressBar({
    super.key,
    required this.progressPercent,
    this.height = 6.0,
    this.progressColor = AppColors.progressAmber,
    this.backgroundColor = AppColors.progressBackground,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        width: double.infinity,
        color: backgroundColor,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progressPercent.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: progressColor,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}
