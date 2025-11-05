import 'package:flutter/material.dart';
import '../services/api_service.dart'; // opsional, untuk integrasi login
import './home_page.dart'; // ganti sesuai rute utama aplikasi

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _username = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🔵 Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F8FFD), Color(0xFFA9D6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 🔹 White card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.75,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: _buildForm(context),
            ),
          ),
          // 🔹 Logo & title
          Positioned(
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "Fluentia",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Learn Japanese through conversation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const SizedBox(height: 10),
          Text(
            isLogin ? "Masuk ke Akunmu" : "Buat Akun Baru",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // === Name (Register only)
          if (!isLogin) ...[
            TextFormField(
              controller: _username,
              decoration: _inputDecoration("Nama Pengguna"),
              validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
            ),
            const SizedBox(height: 16),
          ],

          // === Email
          TextFormField(
            controller: _email,
            decoration: _inputDecoration("Email"),
            validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
          ),
          const SizedBox(height: 16),

          // === Password
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            decoration: _inputDecoration("Kata Sandi").copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                v!.length < 6 ? "Minimal 6 karakter" : null,
          ),
          const SizedBox(height: 28),

          // === Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F8FFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isLogin ? "Masuk" : "Daftar",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // === Toggle Login/Register
          GestureDetector(
            onTap: () => setState(() => isLogin = !isLogin),
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: isLogin
                      ? "Belum punya akun? "
                      : "Sudah punya akun? ",
                  style: const TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: isLogin ? "Daftar" : "Masuk",
                      style: const TextStyle(
                        color: Color(0xFF4F8FFD),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF6F8FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (isLogin) {
        // 🔹 LOGIN ke FastAPI
        result = await ApiService.login(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      } else {
        // 🔹 REGISTER ke FastAPI
        result = await ApiService.register(
          username: _username.text.trim(),
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      }

      if (!mounted) return;

      if (result["success"] == true) {
        // ✅ Simpan user ID dan token (sudah ditangani di ApiService)
        final userId = await ApiService.getUserId();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isLogin ? "Login berhasil!" : "Registrasi sukses!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Terjadi kesalahan."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
