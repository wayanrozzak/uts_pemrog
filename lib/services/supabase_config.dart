/// Konfigurasi Supabase untuk integrasi Backend Database UTS
/// Catatan Keamanan UTS: Hanya gunakan Anon Key (public), JANGAN PERNAH menyertakan service_role key.
class SupabaseConfig {
  // Masukkan Supabase Project URL dan Anon Key jika ingin menghubungkan langsung ke Supabase
  // Jika dibiarkan kosong, aplikasi otomatis beralih ke Local Persistent Storage (SQLite/JSON Cache)
  static const String supabaseUrl = ''; // Contoh: 'https://xyzcompany.supabase.co'
  static const String supabaseAnonKey = ''; // Contoh: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String tableName = 'saved_books';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
