import 'package:flutter/material.dart';
import '../widgets/persona_card.dart';
import '../services/api_service.dart';
import './topic_selection_page.dart';
import './auth_page.dart';
import './feedback_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> personas = [];
  bool loading = true;
  String? userId;
  String? userName;


  // Dummy progress (nanti bisa ambil dari backend)
  final int practiceMinutes = 15;
  final int targetMinutes = 30;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserId();
    await _loadCachedUsername();
    await _fetchPersonas();
    await _loadUserProfile();
  }

  Future<void> _loadUserId() async {
    final id = await ApiService.getUserId();
    setState(() => userId = id);
  }

  Future<void> _loadCachedUsername() async {
    final cached = await ApiService.getUsername();
    if (!mounted) return;
    if (cached != null && cached.isNotEmpty) {
      setState(() => userName = cached);
    }
  }

  Future<void> _fetchPersonas() async {
    try {
      final data = await ApiService.getAllPersona();
      setState(() {
        personas = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("ΓÜá∩╕Å Error fetching personas: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await ApiService.getUserProfile();

      if (result['success'] == true && result['data'] is Map<String, dynamic>) {
        final data = result['data'] as Map<String, dynamic>;
        final nestedUser = data['user'];
        String? profileUsername = data['username'] as String?;

        if ((profileUsername == null || profileUsername.isEmpty) &&
            nestedUser is Map<String, dynamic>) {
          final nestedUsername = nestedUser['username'];
          if (nestedUsername is String && nestedUsername.isNotEmpty) {
            profileUsername = nestedUsername;
          }
        }

        profileUsername ??= data['name'] as String?;
        profileUsername ??= data['username_katakana'] as String?;

        if (profileUsername != null && profileUsername.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            userName = profileUsername;
          });
        } else {
          debugPrint("Username tidak ditemukan di profil.");
        }
      } else {
        debugPrint("Gagal mengambil profil: ${result['message']}");
      }
    } catch (e) {
      debugPrint("Error getUserProfile: $e");
    }
  }

  Future<void> _handleSignOut() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double practiceProgress =
        (practiceMinutes / targetMinutes).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFE9ECF2),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Progress Card ===
                  _buildProgressCard(practiceProgress),
                  const SizedBox(height: 32),

                  const Text(
                    "Choose a Persona:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222B45),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // === Persona List ===
                  if (loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (personas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "No personas found.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    Column(
                      children: personas.map((p) {
                        return PersonaCard(
                          name: p['name'],
                          role: p['role'],
                          levelFormality: p['level_formality'],
                          description: p['description'] ?? '',
                          imagePath: p['image_path'],
                          onTap: () {
                            _fadeSlideNavigate(
                              context,
                              TopicSelectionPage(
                                personaName: p['name'],
                                imagePath: p['image_path'],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 15),

                  // === Feedback History Button ===
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final id = await ApiService.getUserId();
                        if (id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("User ID not found. Please login again.")),
                          );
                          return;
                        }

                        _fadeSlideNavigate(
                          context,
                          FeedbackHistoryPage(userId: int.parse(id)),
                        );
                      },
                      child: Container(
                        width: double.infinity, 
                        padding: const EdgeInsets.symmetric(vertical: 14), 
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: const [
                            Icon(Icons.history_rounded, color: Color(0xFF4F8FFD), size: 22),
                            SizedBox(width: 10),
                            Text(
                              "View Feedback History",
                              style: TextStyle(
                                color: Color(0xFF4F8FFD),
                                fontSize: 15.5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // === Custom App Bar ===
          _buildAppBar(context),
        ],
      ),
    );
  }

  // ======================================================
  // ≡ƒî½∩╕Å Helper untuk Fade + Slide Navigation
  // ======================================================
  void _fadeSlideNavigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          final slide = Tween<Offset>(
            begin: const Offset(0.5, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  // ======================================================
  // ≡ƒº▒ Custom App Bar
  // ======================================================
  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 20, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Fluentia",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Practice speaking Japanese daily",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _handleSignOut,
            child: const Icon(
              Icons.logout_rounded,
              size: 28, // ukuran diperbesar
              weight: 800, // membuat ikon lebih tebal (Flutter 3.10+)
            ),
          )
        ],
      ),
    );
  }

  // ======================================================
  // ≡ƒôè Progress Card
  // ======================================================
  Widget _buildProgressCard(double progress) {
    final String greeting = "こんにちは、${userName ?? 'ゲスト'}さん！"; // ← Tambahkan greeting Jepang

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ≡ƒæï Greeting Section
            Row(
              children: [
                const Icon(Icons.waving_hand_rounded,
                    color: Color(0xFF4F8FFD), size: 28),
                const SizedBox(width: 10),
                Text(
                  greeting, // ΓåÉ tampilkan sapaan
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222B45),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),


            // === Progress Bar ===
            Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF76C7FD), Color(0xFF4F8FFD)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("0m",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("$targetMinutes m",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF4F8FFD),
                  size: 24,
                ),
                const SizedBox(width: 8), // jarak kecil antara ikon dan teks
                Text(
                  "Daily Goals: $practiceMinutes / $targetMinutes minutes",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
