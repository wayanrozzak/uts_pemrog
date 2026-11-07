/// Model untuk Buku dari REST API (Google Books API / Open Library)
class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String publisher;
  final String publishedDate;
  final String description;
  final int pageCount;
  final List<String> categories;
  final String thumbnail;
  final double averageRating;
  final String language;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.publisher = '',
    this.publishedDate = '',
    this.description = '',
    this.pageCount = 0,
    this.categories = const [],
    this.thumbnail = '',
    this.averageRating = 0.0,
    this.language = 'en',
  });

  String get authorNames => authors.isNotEmpty ? authors.join(', ') : 'Penulis Tidak Diketahui';

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};

    // Handle thumbnail secure URL
    String cover = '';
    if (volumeInfo['imageLinks'] != null) {
      final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>;
      cover = (imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '').toString();
      if (cover.startsWith('http://')) {
        cover = cover.replaceFirst('http://', 'https://');
      }
    }

    // Authors handling
    List<String> parsedAuthors = [];
    if (volumeInfo['authors'] != null) {
      parsedAuthors = List<String>.from(volumeInfo['authors'].map((a) => a.toString()));
    }

    // Categories handling
    List<String> parsedCategories = [];
    if (volumeInfo['categories'] != null) {
      parsedCategories = List<String>.from(volumeInfo['categories'].map((c) => c.toString()));
    }

    return Book(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: volumeInfo['title']?.toString() ?? 'Tanpa Judul',
      authors: parsedAuthors,
      publisher: volumeInfo['publisher']?.toString() ?? '',
      publishedDate: volumeInfo['publishedDate']?.toString() ?? '',
      description: volumeInfo['description']?.toString() ?? 'Tidak ada deskripsi tersedia.',
      pageCount: (volumeInfo['pageCount'] as num?)?.toInt() ?? 0,
      categories: parsedCategories,
      thumbnail: cover,
      averageRating: (volumeInfo['averageRating'] as num?)?.toDouble() ?? 0.0,
      language: volumeInfo['language']?.toString() ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volumeInfo': {
        'title': title,
        'authors': authors,
        'publisher': publisher,
        'publishedDate': publishedDate,
        'description': description,
        'pageCount': pageCount,
        'categories': categories,
        'imageLinks': {
          'thumbnail': thumbnail,
        },
        'averageRating': averageRating,
        'language': language,
      }
    };
  }
}

class UniqueKey {
  @override
  String toString() => DateTime.now().millisecondsSinceEpoch.toString();
}
