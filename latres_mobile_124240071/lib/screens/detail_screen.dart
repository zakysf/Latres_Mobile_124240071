import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/favorite_show.dart';
import '../services/api_service.dart';

/// Halaman Detail TV Show
/// Mengikuti materi Modul IV (Navigation & Passing Data)
/// Mengikuti materi Modul V (HTTP Request getSingleData)
/// Mengikuti materi Modul VI (Hive Database CRUD - Favorite)
///
/// Kriteria c:
/// - Mengambil data dari https://api.tvmaze.com/shows/{id}
/// - Menampilkan: Gambar, Judul, Rating, Genre, Summary/Overview
/// - Tombol favorit untuk menambah/menghapus show ke daftar favorit (Hive)
/// - Tombol kembali (Back) ke halaman sebelumnya
class DetailScreen extends StatefulWidget {
  final int showId;
  const DetailScreen({super.key, required this.showId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? _showDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  /// Fungsi untuk mengambil data detail show berdasarkan ID dari API
  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getShowDetail(widget.showId);
      setState(() {
        _showDetail = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Fungsi helper untuk mengecek apakah show ini sudah ada di dalam Hive 'favorites'
  bool _isFavorite() {
    final box = Hive.box<FavoriteShow>('favorites');
    return box.values.any((item) => item.id == widget.showId);
  }

  /// Fungsi toggle Favorit: menambah atau menghapus dari Hive Box
  void _toggleFavorite() {
    if (_showDetail == null) return;

    final box = Hive.box<FavoriteShow>('favorites');
    final bool currentlyFavorite = _isFavorite();

    if (currentlyFavorite) {
      // Jika sudah ada, cari kuncinya lalu hapus (Delete)
      final dynamic targetKey = box.keys.firstWhere(
        (key) => box.get(key)?.id == widget.showId,
        orElse: () => null,
      );

      if (targetKey != null) {
        box.delete(targetKey);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari daftar favorit.'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Jika belum ada, buat objek FavoriteShow lalu simpan (Create / Add)
      final newFavorite = FavoriteShow(
        id: widget.showId,
        name: _showDetail!['name'] ?? 'Tanpa Judul',
        imageUrl: _showDetail!['image']?['original'] ??
            _showDetail!['image']?['medium'],
        rating: '${_showDetail!['rating']?['average'] ?? 'N/A'}',
        genres: (_showDetail!['genres'] as List<dynamic>?)?.join(', ') ?? '-',
      );

      box.add(newFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ditambahkan ke daftar favorit! ❤️'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 1),
        ),
      );
    }

    // Rebuild tampilan tombol favorit
    setState(() {});
  }

  /// Fungsi helper untuk membersihkan tag HTML dari string summary
  String _cleanHtml(String? rawHtml) {
    if (rawHtml == null || rawHtml.isEmpty) {
      return 'Tidak ada deskripsi/overview untuk serial ini.';
    }
    // Menghapus tag HTML seperti <p>, <b>, <i>, dll menggunakan RegExp
    return rawHtml
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'Detail',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Kembali ke halaman sebelumnya (Kriteria c.iv & Modul 4)
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Kondisi Loading
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 16),
            Text('Memuat informasi serial...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // 2. Kondisi Error
    if (_errorMessage != null || _showDetail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Gagal Mengambil Detail',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Data tidak ditemukan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchDetail,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Kondisi Berhasil: Menampilkan Detail
    final show = _showDetail!;
    final String title = show['name'] ?? 'Tanpa Judul';
    final String? imageUrl =
        show['image']?['original'] ?? show['image']?['medium'];
    final dynamic rating = show['rating']?['average'];
    final String ratingText = rating != null ? '$rating' : 'N/A';
    final List<dynamic>? genresList = show['genres'];
    final String genresText =
        (genresList != null && genresList.isNotEmpty)
            ? genresList.join(', ')
            : 'General';
    final String summaryClean = _cleanHtml(show['summary']);
    final bool favorited = _isFavorite();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gambar Poster Show (Kriteria c.ii.1)
          if (imageUrl != null)
            Container(
              width: double.infinity,
              height: 380,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF121212).withValues(alpha: 0.9),
                      const Color(0xFF121212),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              height: 240,
              width: double.infinity,
              color: const Color(0xFF1E1E1E),
              child: const Icon(Icons.movie, size: 80, color: Colors.grey),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Judul (Kriteria c.ii.2)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Rating Bintang (Kriteria c.ii.3)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      ratingText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (show['status'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${show['status']}',
                          style: TextStyle(
                              color: Colors.grey[300], fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. Genre (Kriteria c.ii.4)
                Text(
                  genresText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),

                // Baris Tombol Aksi: Tombol Nonton & Tombol Favorit
                Row(
                  children: [
                    // Tombol Nonton (Sesuai Screenshot Soal)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Memutar serial: $title...'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: const Text(
                          'Nonton',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tombol Favorit (Kriteria c.iii)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: favorited
                              ? Colors.redAccent
                              : Colors.grey.shade700,
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          favorited ? Icons.favorite : Icons.favorite_border,
                          color: favorited ? Colors.redAccent : Colors.white,
                        ),
                        tooltip: favorited
                            ? 'Hapus dari Favorit'
                            : 'Tambah ke Favorit',
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 5. Summary / Overview (Kriteria c.ii.5)
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summaryClean,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
