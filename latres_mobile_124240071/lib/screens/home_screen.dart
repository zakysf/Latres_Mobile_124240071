import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'detail_screen.dart';

/// Halaman Home (Daftar Shows)
/// - Mengambil data dari API TVMaze https://api.tvmaze.com/shows
/// - Tampilan Grid (2 kolom) dengan: Gambar, Judul, Rating
/// - Loading indicator saat data sedang diambil
/// - Navigasi ke DetailPage saat item di-klik
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variabel penampung state data dari API
  List<dynamic> _shows = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Lifecycle method bawaan StatefulWidget: dipanggil sekali saat layar pertama kali dibuat
    _fetchShows();
  }

  /// Fungsi untuk mengambil data shows dari API melalui ApiService
  Future<void> _fetchShows() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Memanggil method static dari ApiService
      final data = await ApiService.getShows();
      setState(() {
        _shows = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Jika masih loading, tampilkan CircularProgressIndicator (Kriteria b.iv)
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 16),
            Text(
              'Memuat daftar serial TV...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 2. Jika terjadi error koneksi / fetch gagal, tampilkan pesan error & tombol Coba Lagi
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Data',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchShows,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Tampilkan data dalam bentuk GridView (Kriteria b.iii)
    return RefreshIndicator(
      onRefresh: _fetchShows,
      color: Colors.redAccent,
      backgroundColor: const Color(0xFF1E1E1E),
      child: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _shows.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 kolom sesuai screenshot soal
          childAspectRatio: 0.65, // Rasio proporsional poster film
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final show = _shows[index];
          return _buildShowCard(show);
        },
      ),
    );
  }

  /// Widget untuk merender setiap item kartu film
  Widget _buildShowCard(dynamic show) {
    // Ekstraksi data wajib: Gambar, Judul, Rating (Kriteria b.iii)
    final String title = show['name'] ?? 'Tanpa Judul';
    final String? imageUrl = show['image']?['medium'];
    final dynamic ratingAverage = show['rating']?['average'];
    final String ratingText = ratingAverage != null ? '$ratingAverage' : 'N/A';

    return GestureDetector(
      // Navigasi ke DetailPage saat kartu di-klik
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(showId: show['id']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior:
            Clip.antiAlias, // Memotong gambar agar sudutnya melengkung
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Poster Gambar
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.redAccent,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.movie,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                  ),

                  // Badge Rating di pojok kiri atas poster
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            ratingText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Judul Acara TV di bagian bawah kartu
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
