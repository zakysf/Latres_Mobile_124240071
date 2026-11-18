import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

/// Halaman Profil Pengguna (ProfileScreen)
/// Mengikuti materi Modul IV (Navigation - Logout) & Modul VI (SharedPreferences)
///
/// Kriteria e:
/// - Menampilkan username dari SharedPreferences (Kriteria e.i)
/// - Menampilkan Kesan dan Pesan selama praktikum (Kriteria e.ii)
/// - Ada tombol Logout fungsional yang menghapus sesi dan kembali ke Login (Kriteria e.iii)
class ProfileScreen extends StatefulWidget {
  final String fallbackUsername;
  const ProfileScreen({super.key, required this.fallbackUsername});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsernameFromPrefs();
  }

  /// Membaca username langsung dari SharedPreferences
  Future<void> _loadUsernameFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? widget.fallbackUsername;
      _isLoading = false;
    });
  }

  /// Fungsi Logout: menghapus sesi SharedPreferences dan redirect ke LoginScreen
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('username');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda telah berhasil logout.'),
          backgroundColor: Colors.grey,
        ),
      );

      // Navigator.pushAndRemoveUntil untuk menghapus seluruh stack halaman
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Center(
        child: Column(
          children: [
            // 1. Avatar Profil Pengguna
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent, width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF2A2A2A),
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Menampilkan Username dari SharedPreferences (Kriteria e.i)
            Text(
              _username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Jekk',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 28),

            // kesan dan pesan
            Text(
              "Kesan: Mantap aja sih sejauh ini. Aslabnya mantap, ganteng, mengayomi, memaklumi praktikan yang mungkin agak lemot, dsb. Jujur materinya banyak dan ngebut bgt kalo lagi kelas tuh, jadinya agak challenging juga buat belajar mobil ni.",
            ),
            const SizedBox(height: 28),
            Text(
              "Pesan: Terus improve buat materi prak mobile ini biar gimana caranya praktikan bisa paham konsep dari setiap modulnya (secara konsep umum dan di kode nya gimana), karena kalo sampe praktek dan jelasin detail bakal lama bgt dan kayaknya ga cukup cuma 2 jam.",
            ),
            const SizedBox(height: 28),

            // 4. Tombol Logout (Kriteria e.iii)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
