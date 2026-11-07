import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/saved_book.dart';
import '../providers/library_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_text_field.dart';

/// SCREEN 5: Create / Add Screen
/// Form untuk menambahkan buku baru ke Database dengan validasi lengkap
/// Memenuhi ketentuan UTS:
/// - Form dengan input validasi (Title, Author, Pages, Page Progress)
/// - Menghasilkan model data baru untuk di-insert ke database (CREATE CRUD)
/// - Feedback user via SnackBar
class AddBookScreen extends StatefulWidget {
  final Book? initialBook;

  const AddBookScreen({super.key, this.initialBook});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _totalPagesController;
  late TextEditingController _currentPageController;
  late TextEditingController _readingTimeController;
  late TextEditingController _coverUrlController;
  late TextEditingController _notesController;

  String _status = ReadingStatus.currentlyReading;
  double _rating = 4.5;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final b = widget.initialBook;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.authorNames ?? '');
    _totalPagesController =
        TextEditingController(text: b != null && b.pageCount > 0 ? b.pageCount.toString() : '200');
    _currentPageController = TextEditingController(text: '0');
    _readingTimeController = TextEditingController(text: '15');
    _coverUrlController = TextEditingController(text: b?.thumbnail ?? '');
    _notesController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    _readingTimeController.dispose();
    _coverUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Buku ke Rak'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Cover jika ada URL
              if (_coverUrlController.text.isNotEmpty)
                Center(
                  child: Container(
                    width: 90,
                    height: 125,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _coverUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceLight,
                          child: const Icon(Icons.book, color: AppColors.primaryLight),
                        ),
                      ),
                    ),
                  ),
                ),

              // Title Field (Wajib)
              CustomTextField(
                controller: _titleController,
                label: 'Judul Buku *',
                hint: 'Contoh: Dear Life',
                prefixIcon: Icons.title_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul buku wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Author Field (Wajib)
              CustomTextField(
                controller: _authorController,
                label: 'Pengarang / Penulis *',
                hint: 'Contoh: Rachel Clarke',
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama pengarang wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Total Pages & Current Page Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _totalPagesController,
                      label: 'Total Halaman *',
                      hint: '140',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.menu_book_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Wajib diisi';
                        }
                        final numVal = int.tryParse(val.trim());
                        if (numVal == null || numVal <= 0) {
                          return 'Angka harus > 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      controller: _currentPageController,
                      label: 'Halaman Saat Ini',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.bookmark_border_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return null;
                        final current = int.tryParse(val.trim());
                        final total = int.tryParse(_totalPagesController.text.trim());
                        if (current == null || current < 0) {
                          return 'Harus >= 0';
                        }
                        if (total != null && current > total) {
                          return 'Tidak boleh > total';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Status Dropdown
              const Text(
                'Status Membaca',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    dropdownColor: AppColors.surface,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryLight),
                    items: const [
                      DropdownMenuItem(
                        value: ReadingStatus.currentlyReading,
                        child: Text('Currently Reading (Sedang Dibaca)'),
                      ),
                      DropdownMenuItem(
                        value: ReadingStatus.forReading,
                        child: Text('For Reading (Ingin Dibaca)'),
                      ),
                      DropdownMenuItem(
                        value: ReadingStatus.read,
                        child: Text('Read (Selesai Dibaca)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Reading Time Field
              CustomTextField(
                controller: _readingTimeController,
                label: 'Estimasi Waktu Baca (Menit)',
                hint: '60',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.timer_outlined,
              ),
              const SizedBox(height: 14),

              // Cover URL Field
              CustomTextField(
                controller: _coverUrlController,
                label: 'URL Gambar Cover (Opsional)',
                hint: 'https://images.unsplash.com/...',
                prefixIcon: Icons.image_outlined,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Rating Slider (User Interaction)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rating Buku',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.progressAmber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Slider(
                value: _rating,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                activeColor: AppColors.progressAmber,
                inactiveColor: AppColors.border,
                label: _rating.toStringAsFixed(1),
                onChanged: (val) => setState(() => _rating = val),
              ),
              const SizedBox(height: 14),

              // Notes Field
              CustomTextField(
                controller: _notesController,
                label: 'Catatan / Review Pribadi',
                hint: 'Tuliskan kutipan favorit atau catatan penting dari buku ini...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan ke Rak Buku',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<LibraryProvider>();
    final newBook = SavedBook(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      studentId: '2415051111',
      bookId: widget.initialBook?.id ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      coverUrl: _coverUrlController.text.trim().isNotEmpty
          ? _coverUrlController.text.trim()
          : 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
      description: widget.initialBook?.description ?? '',
      totalPages: int.parse(_totalPagesController.text.trim()),
      currentPage: int.tryParse(_currentPageController.text.trim()) ?? 0,
      status: _status,
      readingTimeMinutes: int.tryParse(_readingTimeController.text.trim()) ?? 0,
      startedDate: DateTime.now(),
      rating: _rating,
      note: _notesController.text.trim(),
    );

    final success = await provider.addBook(newBook);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Buku "${newBook.title}" berhasil ditambahkan ke database!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan buku. Silakan coba lagi.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
