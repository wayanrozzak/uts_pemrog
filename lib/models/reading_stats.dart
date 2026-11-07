/// Model untuk data statistik membaca di Report Screen
class ReadingStats {
  final int totalMinutesRead;
  final int totalBooksRead;
  final int totalPagesRead;
  final int streakDays;
  final List<DailyReading> weeklyActivity;

  ReadingStats({
    required this.totalMinutesRead,
    required this.totalBooksRead,
    required this.totalPagesRead,
    required this.streakDays,
    required this.weeklyActivity,
  });
}

class DailyReading {
  final String dayName;
  final int minutes;

  DailyReading({required this.dayName, required this.minutes});
}
