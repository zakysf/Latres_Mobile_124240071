import 'package:flutter/material.dart';

/// Halaman Detail TV Show (Placeholder untuk pengujian navigasi dari Home)
/// Akan kita lengkapi secara mendalam di Tahap 4
class DetailScreen extends StatelessWidget {
  final int showId;
  const DetailScreen({super.key, required this.showId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Detail Show'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Show ID: $showId',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              'Navigasi berhasil! Data detail & fitur favorit akan dibuat di Tahap 4.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
