import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/favorite_show.dart';
import 'screens/login_screen.dart';

void main() async {
  // Memastikan binding Flutter sudah terinisialisasi sebelum menjalankan operasi async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk penyimpanan lokal (Modul VI)
  await Hive.initFlutter();

  // Daftarkan Adapter untuk model FavoriteShow dan buka Box 'favorites'
  Hive.registerAdapter(FavoriteShowAdapter());
  await Hive.openBox<FavoriteShow>('favorites');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NontonSkuy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.redAccent,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
