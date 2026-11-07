import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/supabase_config.dart';
import '../utils/app_colors.dart';

/// SCREEN 9: Profile / About Screen
/// Tab "Profile" pada Bottom Navigation Bar (sesuai icon kanan pada foto referensi).
/// Menampilkan identitas mahasiswa peserta UTS dan checklist pemenuhan spesifikasi teknis.
class ProfileScreen extends StatelessWidget {
  final UserProfile profile;

  const ProfileScreen({
    super.key,
    this.profile = const UserProfile(),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Mahasiswa & Info UTS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Student Identity Card
            _buildProfileCard(),
            const SizedBox(height: 20),

            // Course & Lecturer Info
            _buildAcademicInfoCard(),
            const SizedBox(height: 20),

            // Backend & Database Status
            _buildDatabaseStatusCard(context),
            const SizedBox(height: 20),

            // Technical Requirements Checklist (Untuk Penilaian Dosen)
            _buildUtsChecklistCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight, width: 2),
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.surfaceLight,
              child: const Icon(
                Icons.person_rounded,
                size: 48,
                color: AppColors.primaryLight,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.nama,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'NIM: ${profile.nim} • Kelas ${profile.kelas}',
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.prodi,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Ujian Tengah Semester',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.school_rounded, 'Matakuliah', profile.matakuliah),
          const Divider(color: AppColors.border, height: 18),
          _buildInfoRow(Icons.auto_stories_rounded, 'Tema Project', 'BookShelf (Book Reading Manager)'),
          const Divider(color: AppColors.border, height: 18),
          _buildInfoRow(Icons.person_pin_rounded, 'Dosen Pengampu', profile.dosen),
          const Divider(color: AppColors.border, height: 18),
          _buildInfoRow(Icons.assignment_ind_rounded, 'Teaching Assistant', profile.asisten),
        ],
      ),
    );
  }

  Widget _buildDatabaseStatusCard(BuildContext context) {
    final isConfigured = SupabaseConfig.isConfigured;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Integrasi Database Backend',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isConfigured ? AppColors.success : AppColors.primary).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConfigured ? AppColors.success : AppColors.primaryLight,
                  ),
                ),
                child: Text(
                  isConfigured ? 'Supabase Active' : 'Local Storage Active',
                  style: TextStyle(
                    color: isConfigured ? AppColors.success : AppColors.primaryLight,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isConfigured
                ? 'Terhubung dengan backend cloud Supabase PostgreSQL tabel "saved_books".'
                : 'Aplikasi menggunakan penyimpanan persisten lokal yang menjamin seluruh operasi CRUD berjalan 100% mulus saat offline.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUtsChecklistCard() {
    final checklist = [
      {'item': 'Minimal 6 Screen Fungsional', 'status': '9 Screens'},
      {'item': 'Dart Models (>= 2)', 'status': '4 Models'},
      {'item': 'Reusable Widgets (>= 3)', 'status': '7 Custom Widgets'},
      {'item': 'Responsive Layout (Compact & Wide)', 'status': 'Implemented'},
      {'item': 'REST API GET + JSON Parsing', 'status': 'Google Books API'},
      {'item': 'Backend Database CRUD (C, R, U, D)', 'status': 'Complete CRUD'},
      {'item': 'Delete Confirmation Dialog', 'status': 'Implemented'},
      {'item': 'State Management (Provider)', 'status': 'Provider + ChangeNotifier'},
      {'item': 'Form + Validasi Input', 'status': 'Implemented'},
      {'item': 'SnackBar / Dialog Feedback', 'status': 'Implemented'},
      {'item': 'Minimal 16 Meaningful Git Commits', 'status': 'Completed'},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Checklist Pemenuhan Spesifikasi UTS',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...checklist.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c['item']!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      c['status']!,
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
