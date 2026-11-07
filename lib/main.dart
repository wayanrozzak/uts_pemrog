import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/book_provider.dart';
import 'providers/library_provider.dart';
import 'providers/stats_provider.dart';
import 'repositories/book_repository.dart';
import 'screens/main_navigation_screen.dart';
import 'services/api_service.dart';
import 'services/local_db_service.dart';
import 'services/supabase_service.dart';
import 'utils/app_colors.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bottomNavBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BookShelfApp());
}

class BookShelfApp extends StatelessWidget {
  const BookShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Arsitektur Dependensi
    // UI -> Provider -> Repository -> Service/Data Source -> REST API / Database
    final apiService = ApiService();
    final localDbService = LocalDbService();
    final supabaseService = SupabaseService(localDbService: localDbService);
    final bookRepository = BookRepository(
      apiService: apiService,
      dbService: supabaseService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(repository: bookRepository)..loadSavedBooks(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookProvider(repository: bookRepository)..fetchBooks(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'BookShelf UTS Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
