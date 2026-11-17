import 'dart:convert';

import 'package:http/http.dart' as http;

// Mekanisme fetch & parse data API harus dipisah dari UI di file tersendiri
class ApiService {
  // Base URL dari API TVMaze
  static const String baseUrl = 'https://api.tvmaze.com';

  /// 1. Mengambil daftar semua TV Shows
  /// Endpoint: GET https://api.tvmaze.com/shows
  /// Return: List data shows dalam bentuk dynamic (`List<Map<String, dynamic>>`)
  static Future<List<dynamic>> getShows() async {
    final Uri url = Uri.parse('$baseUrl/shows');

    try {
      final response = await http.get(url);

      // Cek apakah response dari server berhasil (Status Code 200)
      if (response.statusCode == 200) {
        // Parse data JSON mentah menjadi List Dart menggunakan jsonDecode
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
          'Gagal memuat daftar shows. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Melempar error agar bisa ditangkap dan ditampilkan di UI
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  /// 2. Mengambil detail satu TV Show berdasarkan ID
  /// Endpoint: GET https://api.tvmaze.com/shows/{id}
  /// Digunakan pada halaman Detail (Kriteria c.i)
  static Future<Map<String, dynamic>> getShowDetail(int id) async {
    final Uri url = Uri.parse('$baseUrl/shows/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse JSON mentah menjadi Map Dart
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
          'Gagal memuat detail show. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }
}
