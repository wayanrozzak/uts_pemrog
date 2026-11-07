/// Status membaca buku
class ReadingStatus {
  static const String currentlyReading = 'currently_reading';
  static const String forReading = 'for_reading';
  static const String read = 'read';

  static String getLabel(String status) {
    switch (status) {
      case currentlyReading:
        return 'Currently Reading';
      case forReading:
        return 'For Reading';
      case read:
        return 'Read';
      default:
        return 'Unknown';
    }
  }
}

/// Model untuk data Buku yang disimpan ke Database (Supabase / Local DB)
/// Memenuhi ketentuan UTS: Primary Key + >4 fields data dan mendukung CRUD lengkap.
class SavedBook {
  final String id;
  final String studentId;
  final String bookId;
  final String title;
  final String author;
  final String coverUrl;
  final String description;
  final int totalPages;
  final int currentPage;
  final String status; // 'currently_reading', 'for_reading', 'read'
  final int readingTimeMinutes;
  final DateTime startedDate;
  final double rating;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedBook({
    required this.id,
    this.studentId = '2415051111',
    required this.bookId,
    required this.title,
    required this.author,
    this.coverUrl = '',
    this.description = '',
    required this.totalPages,
    this.currentPage = 0,
    this.status = ReadingStatus.currentlyReading,
    this.readingTimeMinutes = 0,
    DateTime? startedDate,
    this.rating = 0.0,
    this.note = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : startedDate = startedDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Hitung persentase progress membaca (0.0 sampai 1.0)
  double get progressPercent {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  // Sisa halaman
  int get pagesRemaining => (totalPages - currentPage).clamp(0, totalPages);

  // Label "Started: X days ago" sesuai desain foto
  String get startedDaysAgoText {
    final diff = DateTime.now().difference(startedDate).inDays;
    if (diff <= 0) return 'Started: today';
    if (diff == 1) return 'Started: 1 day ago';
    return 'Started: $diff days ago';
  }

  SavedBook copyWith({
    String? id,
    String? studentId,
    String? bookId,
    String? title,
    String? author,
    String? coverUrl,
    String? description,
    int? totalPages,
    int? currentPage,
    String? status,
    int? readingTimeMinutes,
    DateTime? startedDate,
    double? rating,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedBook(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      startedDate: startedDate ?? this.startedDate,
      rating: rating ?? this.rating,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'book_id': bookId,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'description': description,
      'total_pages': totalPages,
      'current_page': currentPage,
      'status': status,
      'reading_time_minutes': readingTimeMinutes,
      'started_date': startedDate.toIso8601String(),
      'rating': rating,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavedBook.fromMap(Map<String, dynamic> map) {
    return SavedBook(
      id: map['id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '2415051111',
      bookId: map['book_id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Untitled',
      author: map['author']?.toString() ?? 'Unknown Author',
      coverUrl: map['cover_url']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      totalPages: (map['total_pages'] as num?)?.toInt() ?? 100,
      currentPage: (map['current_page'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? ReadingStatus.currentlyReading,
      readingTimeMinutes: (map['reading_time_minutes'] as num?)?.toInt() ?? 0,
      startedDate: map['started_date'] != null
          ? DateTime.tryParse(map['started_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      note: map['note']?.toString() ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
