import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reading_stats.dart';
import '../providers/library_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/reading_progress_bar.dart';
import '../widgets/stat_card_widget.dart';

/// SCREEN 8: Report / Reading Statistics Screen
/// Tab "Report" pada Bottom Navigation Bar (sesuai icon kiri pada foto referensi).
/// Menampilkan grafik dan statistik aktivitas membaca buku pengguna.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final statsProvider = context.watch<StatsProvider>();
    final stats = statsProvider.getStats(libraryProvider.savedBooks);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reading Report & Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Header Card
            _buildStreakBanner(stats.streakDays),
            const SizedBox(height: 20),

            // Grid of Stat Cards
            _buildStatGrid(context, stats),
            const SizedBox(height: 24),

            // Weekly Activity Bar Chart
            _buildWeeklyChartSection(stats.weeklyActivity),
            const SizedBox(height: 24),

            // Annual Reading Goal Progress
            _buildGoalProgressCard(stats.totalBooksRead),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBanner(int streakDays) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.4),
            AppColors.surfaceLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.progressAmber,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays Hari Berturut-turut! 🔥',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hebat! Anda konsisten membaca setiap hari minggu ini.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, ReadingStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            StatCardWidget(
              title: 'Waktu Membaca',
              value: '${stats.totalMinutesRead}m',
              subtitle: 'Total menit aktif',
              icon: Icons.timer_rounded,
              accentColor: AppColors.progressAmber,
            ),
            StatCardWidget(
              title: 'Buku Selesai',
              value: '${stats.totalBooksRead}',
              subtitle: 'Buku tamat',
              icon: Icons.check_circle_rounded,
              accentColor: AppColors.success,
            ),
            StatCardWidget(
              title: 'Halaman Dibaca',
              value: '${stats.totalPagesRead}',
              subtitle: 'Akumulasi halaman',
              icon: Icons.menu_book_rounded,
              accentColor: AppColors.primaryLight,
            ),
            StatCardWidget(
              title: 'Reading Streak',
              value: '${stats.streakDays}d',
              subtitle: 'Hari berturut-turut',
              icon: Icons.bolt_rounded,
              accentColor: AppColors.warning,
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyChartSection(List<DailyReading> weekly) {
    final maxMinutes = weekly.map((e) => e.minutes).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitas Mingguan (Menit)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '7 Hari Terakhir',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Bar Chart Visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekly.map((d) {
              final heightFactor = maxMinutes > 0 ? (d.minutes / maxMinutes) : 0.0;
              final barHeight = (heightFactor * 100).clamp(12.0, 100.0);
              final isToday = d.dayName == 'Sat';

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${d.minutes}m',
                    style: TextStyle(
                      color: isToday ? AppColors.progressAmber : AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 18,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.progressAmber : AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d.dayName,
                    style: TextStyle(
                      color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard(int booksRead) {
    const targetBooks = 25;
    final progress = (booksRead / targetBooks).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target Membaca 2026',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$booksRead dari $targetBooks buku',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ReadingProgressBar(
            progressPercent: progress,
            height: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% dari target tercapai. Terus pertahankan semangat membaca!',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
