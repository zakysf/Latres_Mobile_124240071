import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'login_screen.dart';

/// Halaman Root dengan BottomNavigationBar
/// Berisi 3 Menu: Home (Beranda), Favorit, Profil
class RootScreen extends StatefulWidget {
  final String username;
  const RootScreen({super.key, required this.username});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  /// Fungsi Logout: Menghapus session SharedPreferences dan kembali ke LoginScreen
  /// Menggunakan Navigator.pushAndRemoveUntil
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('username');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil logout.'),
          backgroundColor: Colors.grey,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Hapus semua riwayat stack navigasi
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // List halaman yang akan ditampilkan sesuai tab aktif
    final List<Widget> pages = [
      // 1. Tab Home (Daftar Acara TV dari API TVMaze)
      const HomeScreen(),
      // 2. Tab Favorit (sementara placeholder, kita hubungkan ke Hive di step 4)
      _buildFavoritePlaceholder(),
      // 3. Tab Profil (menampilkan data user & logout)
      _buildProfilePlaceholder(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          _selectedIndex == 0
              ? 'Skuy Nonton!'
              : _selectedIndex == 1
              ? 'Daftar Favorit'
              : 'Profil Pengguna',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildFavoritePlaceholder() {
    return const Center(
      child: Text(
        'Halaman Favorit (Hive Local Database)\nAkan dibuat di tahap 4',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  Widget _buildProfilePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 90, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            widget.username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
