import 'package:flutter/material.dart';

/// Palet warna utama aplikasi BookShelf
/// Mengikuti desain modern dark violet / purple aesthetic sesuai foto referensi UTS.
class AppColors {
  // Background Colors
  static const Color background = Color(0xFF130B24);
  static const Color surface = Color(0xFF1F1438);
  static const Color surfaceLight = Color(0xFF2A1B4A);
  static const Color card = Color(0xFF23173E);
  static const Color cardSelected = Color(0xFF2D1E4E);
  static const Color bottomNavBg = Color(0xFF170E2C);

  // Border & Divider
  static const Color border = Color(0xFF38275C);
  static const Color borderHighlight = Color(0xFFFF9E2C); // Golden border for selected card

  // Accent Colors
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6D28D9);
  
  // Progress Bar & Amber Highlight
  static const Color progressAmber = Color(0xFFFF9E2C);
  static const Color progressBackground = Color(0xFF38275C);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB5ACCA);
  static const Color textMuted = Color(0xFF7B7095);
  static const Color textHint = Color(0xFF5E5475);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Reading status colors
  static const Color currentlyReading = Color(0xFF8B5CF6);
  static const Color forReading = Color(0xFF3B82F6);
  static const Color read = Color(0xFF10B981);
}
