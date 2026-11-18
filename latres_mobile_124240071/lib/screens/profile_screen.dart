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
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
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
              'Mahasiswa Informatika / Praktikan Mobile',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 28),

            // 3. Card Kesan & Pesan Praktikum (Kriteria e.ii)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kesan
                  Row(
                    children: [
                      const Icon(Icons.sentiment_satisfied_alt,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Kesan Selama Praktikum:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Praktikum Pemrograman Mobile sangat seru dan membuka wawasan baru tentang pengembangan aplikasi cross-platform. Penjelasan materi dari modul praktikum sangat terstruktur, mulai dari UI dasar, State Management, HTTP Request API, hingga Local Storage Hive dan SharedPreferences!',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 28),

                  // Pesan
                  Row(
                    children: [
                      const Icon(Icons.favorite,
                          color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Pesan untuk Asisten Praktikum:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terima kasih banyak kepada seluruh Mas & Mbak Asisten Praktikum yang selalu sabar, ramah, dan solutif dalam membimbing serta menjawab berbagai kendala kami selama sesi lab. Sukses selalu untuk tim asisten! 🚀',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

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
