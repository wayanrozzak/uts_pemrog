import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_book.dart';
import '../providers/library_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_text_field.dart';

/// SCREEN 6: Edit Data Screen
/// Form untuk memperbarui progress membaca dan data buku di Database (UPDATE CRUD)
/// Memenuhi ketentuan UTS:
/// - Form dengan validation
/// - Memperbarui status baca, halaman terkini, durasi baca, rating, dan catatan
/// - Feedback user via SnackBar
class EditBookScreen extends StatefulWidget {
  final SavedBook book;

  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _currentPageController;
  late TextEditingController _readingTimeController;
  late TextEditingController _notesController;

  late String _status;
  late double _rating;
  late double _progressSliderValue;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentPageController = TextEditingController(text: widget.book.currentPage.toString());
    _readingTimeController =
        TextEditingController(text: widget.book.readingTimeMinutes.toString());
    _notesController = TextEditingController(text: widget.book.note);
    _status = widget.book.status;
    _rating = widget.book.rating > 0 ? widget.book.rating : 4.0;
    _progressSliderValue = widget.book.currentPage.toDouble();
  }

  @override
  void dispose() {
    _currentPageController.dispose();
    _readingTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Update Progress Membaca'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card Info Buku
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 50,
                        height: 70,
                        child: widget.book.coverUrl.isNotEmpty
                            ? Image.network(
                                widget.book.coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: AppColors.surfaceLight),
                              )
                            : Container(color: AppColors.surfaceLight),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.book.author,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Halaman: ${widget.book.totalPages}',
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Progress Slider (User Interaction)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress Halaman Terkini',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_progressSliderValue.toInt()} / ${widget.book.totalPages} hal',
                    style: const TextStyle(
                      color: AppColors.progressAmber,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _progressSliderValue.clamp(0.0, widget.book.totalPages.toDouble()),
                min: 0.0,
                max: widget.book.totalPages.toDouble(),
                divisions: widget.book.totalPages > 0 ? widget.book.totalPages : 1,
                activeColor: AppColors.progressAmber,
                inactiveColor: AppColors.border,
                label: '${_progressSliderValue.toInt()} hal',
                onChanged: (val) {
                  setState(() {
                    _progressSliderValue = val;
                    _currentPageController.text = val.toInt().toString();

                    // Otomatis ubah status jika selesai
                    if (val.toInt() >= widget.book.totalPages) {
                      _status = ReadingStatus.read;
                    }
                  });
                },
              ),
              const SizedBox(height: 10),

              // Current Page Field
              CustomTextField(
                controller: _currentPageController,
                label: 'Atau Masukkan Nomor Halaman Manual',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.bookmark_added_rounded,
                onChanged: (val) {
                  final numVal = double.tryParse(val);
                  if (numVal != null &&
                      numVal >= 0 &&
                      numVal <= widget.book.totalPages) {
                    setState(() {
                      _progressSliderValue = numVal;
                    });
                  }
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Halaman wajib diisi';
                  }
                  final p = int.tryParse(val.trim());
                  if (p == null || p < 0) {
                    return 'Halaman harus >= 0';
                  }
                  if (p > widget.book.totalPages) {
                    return 'Tidak boleh melebihi ${widget.book.totalPages} halaman';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // Reading Time Added
              CustomTextField(
                controller: _readingTimeController,
                label: 'Total Waktu Membaca (Menit)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.access_time_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  if (int.tryParse(val.trim()) == null) return 'Harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rating Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rating Kepuasan Buku',
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
              const SizedBox(height: 16),

              // Catatan Pribadi
              CustomTextField(
                controller: _notesController,
                label: 'Catatan / Review Baru',
                hint: 'Perbarui insight, pemikiran, atau ringkasan bacaan...',
                prefixIcon: Icons.rate_review_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Save Changes Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitUpdate,
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
                          'Simpan Perubahan (Update)',
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

  void _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<LibraryProvider>();
    final updated = widget.book.copyWith(
      currentPage: int.parse(_currentPageController.text.trim()),
      readingTimeMinutes: int.tryParse(_readingTimeController.text.trim()) ?? widget.book.readingTimeMinutes,
      status: _status,
      rating: _rating,
      note: _notesController.text.trim(),
    );

    final success = await provider.updateBook(updated);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data "${updated.title}" berhasil diperbarui!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui data di database.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
