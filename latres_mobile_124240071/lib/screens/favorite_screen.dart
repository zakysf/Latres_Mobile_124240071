import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/favorite_show.dart';
import 'detail_screen.dart';

/// Halaman Daftar Favorit (FavoriteScreen)
/// Mengikuti materi Modul VI (Hive Database & ValueListenableBuilder)
///
/// Kriteria d:
/// - Menampilkan daftar TV show yang disukai/favorit
/// - Disimpan menggunakan Hive Box 'favorites'
/// - Bisa dihapus (menggunakan box.deleteAt atau box.delete)
/// - Jika item di-klik, bernavigasi ke DetailScreen
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder mendengarkan perubahan secara reaktif dari Box Hive (Modul VI)
    // Ketika ada penambahan atau penghapusan item di Hive, UI ini langsung update otomatis!
    return ValueListenableBuilder<Box<FavoriteShow>>(
      valueListenable: Hive.box<FavoriteShow>('favorites').listenable(),
      builder: (context, box, _) {
        // Kondisi jika belum ada serial yang difavoritkan
        if (box.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum Ada Favorit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jelajahi Beranda dan tekan ikon hati pada serial TV yang kamu sukai!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        // Tampilkan daftar favorit menggunakan ListView.builder (Modul II & VI)
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: box.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final favorite = box.getAt(index);
            if (favorite == null) return const SizedBox.shrink();

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 6.0),
                // 1. Gambar Thumbnail Poster
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: favorite.imageUrl != null
                      ? Image.network(
                          favorite.imageUrl!,
                          width: 48,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 48,
                            height: 64,
                            color: Colors.black26,
                            child: const Icon(Icons.movie,
                                color: Colors.grey, size: 24),
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 64,
                          color: Colors.black26,
                          child: const Icon(Icons.movie,
                              color: Colors.grey, size: 24),
                        ),
                ),

                // 2. Judul Acara TV
                title: Text(
                  favorite.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                // 3. Rating Bintang
                subtitle: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      favorite.rating,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // 4. Tombol Hapus (Kriteria d.iii & Modul VI halaman 122)
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  tooltip: 'Hapus dari favorit',
                  onPressed: () {
                    // Hapus data dari Box Hive berdasarkan index
                    box.deleteAt(index);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${favorite.name} dihapus dari favorit.'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                // 5. Navigasi ke DetailScreen saat item diklik (Kriteria d.iv & Modul IV)
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(showId: favorite.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
