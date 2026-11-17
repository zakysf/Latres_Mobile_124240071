import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'root_screen.dart';

/// Halaman Login (LoginScreen)
/// Mengikuti materi Modul III (State & Data) dan Modul VI (Local Storage - SharedPreferences).
///
/// Fitur:
/// 1. Form input Username & Password dengan TextEditingController.
/// 2. Validasi kredensial: Username = NIM (124240071) & Password = 123.
/// 3. Error handling: SnackBar peringatan & border warna merah jika gagal login.
/// 4. Menyimpan sesi login (isLogin & username) ke SharedPreferences.
/// 5. Auto-login: Mengecek sesi di initState(), jika sudah login langsung diarahkan ke RootScreen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controller untuk mengambil teks input dari TextField
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Variabel State
  bool _isLoginFailed = false; // Menandakan apakah login terakhir kali gagal
  bool _obscurePassword = true; // Untuk toggle visibility password (show/hide)
  bool _isCheckingSession = true; // Untuk menampilkan loading saat mengecek auto-login

  @override
  void initState() {
    super.initState();
    // Jalankan pengecekan sesi login saat halaman pertama kali termuat
    _checkLoginSession();
  }

  @override
  void dispose() {
    // Selalu dispose controller ketika widget dihancurkan untuk mencegah memory leak
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fungsi untuk memeriksa apakah user sudah login sebelumnya melalui SharedPreferences
  Future<void> _checkLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLogin = prefs.getBool('isLogin') ?? false;

    if (isLogin && mounted) {
      final String savedUsername = prefs.getString('username') ?? '124240071';
      // Jika sudah login, langsung ganti halaman ke RootScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RootScreen(username: savedUsername),
        ),
      );
    } else {
      // Jika belum login, hentikan indikator loading
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  /// Fungsi yang dieksekusi saat tombol Login ditekan
  Future<void> _handleLogin() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // Validasi input tidak boleh kosong
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoginFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password wajib diisi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Validasi kredensial sesuai kriteria Latihan Responsi:
    // Username = NIM (124240071) dan Password = 123
    const String validNIM = '124240071';
    const String validPassword = '123';

    if (username == validNIM && password == validPassword) {
      // Login BERHASIL:
      setState(() {
        _isLoginFailed = false;
      });

      // Simpan session login ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLogin', true);
      await prefs.setString('username', username);

      if (mounted) {
        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil! Selamat datang.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Berpindah ke RootScreen dan hapus halaman login dari stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RootScreen(username: username),
          ),
        );
      }
    } else {
      // Login GAGAL:
      setState(() {
        _isLoginFailed = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Gagal: Username (NIM) atau Password salah!'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika masih mengecek sesi SharedPreferences, tampilkan loading circle
    if (_isCheckingSession) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Tema Dark mirip Netflix/NontonSkuy
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo / Ikon Film
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    size: 72,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Judul Aplikasi
                const Text(
                  'NontonSkuy!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Streaming serial & TV show favoritmu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 36),

                // 3. Form Input Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Silakan Masuk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gunakan NIM kamu dan password: 123',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Username Field (Input NIM)
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Masukkan NIM (124240071)',
                        labelText: 'Username (NIM)',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Password Field (Input 123)
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Masukkan Password (123)',
                        labelText: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),

                      // Tombol Login
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // Hint info untuk memudahkan penguji / asdos
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Demo NIM: 124240071 | Pass: 123',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper Widget untuk membuat TextField yang rapi
  /// Sesuai materi Modul 3: border dinamis berubah menjadi merah saat error (_isLoginFailed)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final Color borderColor = _isLoginFailed ? Colors.redAccent : Colors.grey.shade700;
    final Color focusColor = _isLoginFailed ? Colors.redAccent : Colors.redAccent;

    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: _isLoginFailed ? Colors.redAccent : Colors.grey[400],
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(
          icon,
          color: _isLoginFailed ? Colors.redAccent : Colors.grey[400],
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusColor, width: 1.8),
        ),
      ),
    );
  }
}
