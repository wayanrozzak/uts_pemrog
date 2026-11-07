import 'package:flutter/material.dart';
import '../models/reading_stats.dart';
import '../models/saved_book.dart';

/// Provider untuk menghitung analitik membaca buku (Report Screen)
class StatsProvider extends ChangeNotifier {
  ReadingStats getStats(List<SavedBook> books) {
    int totalMinutes = 0;
    int totalPages = 0;
    int booksCompleted = 0;

    for (var b in books) {
      totalMinutes += b.readingTimeMinutes;
      totalPages += b.currentPage;
      if (b.status == ReadingStatus.read || b.currentPage >= b.totalPages) {
        booksCompleted++;
      }
    }

    // Weekly activity dummy/calculated
    final weekly = [
      DailyReading(dayName: 'Mon', minutes: 45),
      DailyReading(dayName: 'Tue', minutes: 30),
      DailyReading(dayName: 'Wed', minutes: 60),
      DailyReading(dayName: 'Thu', minutes: 20),
      DailyReading(dayName: 'Fri', minutes: 75),
      DailyReading(dayName: 'Sat', minutes: 90),
      DailyReading(dayName: 'Sun', minutes: 50),
    ];

    return ReadingStats(
      totalMinutesRead: totalMinutes,
      totalBooksRead: booksCompleted,
      totalPagesRead: totalPages,
      streakDays: books.isNotEmpty ? 12 : 0,
      weeklyActivity: weekly,
    );
  }
}
