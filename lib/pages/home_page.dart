import 'package:flutter/material.dart';
import '../widgets/persona_card.dart';
import '../services/api_service.dart';
import '../services/usage_tracker.dart';
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
  int? userId;
  String? userName;

  final UsageTracker _activityTracker = UsageTracker();

  // Dummy progress + streak data (nanti bisa ambil dari backend)
  int practiceMinutes = 0;
  final int targetMinutes = 30;
  int streakDays = 0;
  final int bestStreakDays = 14;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final id = await _loadUserId();
    await _loadCachedUsername();
    await _fetchPersonas();
    await _loadUserProfile();
    await _fetchActivityInfo(id);
  }

  Future<int?> _loadUserId() async {
    final id = await ApiService.getUserId();
    final parsedId = id != null ? int.tryParse(id) : null;
    if (!mounted) return parsedId;
    setState(() => userId = parsedId);
    return parsedId;
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

  Future<void> _fetchActivityInfo([int? providedId]) async {
    final id = providedId ?? userId;
    if (id == null) return;

    try {
      final data =
          await _activityTracker.fetchActivityInfo(overrideUserId: id);
      if (data == null || !mounted) return;

      setState(() {
        practiceMinutes = (data['today_minutes'] as num?)?.toInt() ?? 0;
        streakDays = (data['streak'] as num?)?.toInt() ?? 0;
      });
    } catch (e) {
      debugPrint("Error fetching activity info: $e");
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
    final double practiceProgress = targetMinutes == 0
        ? 0
        : (practiceMinutes / targetMinutes).clamp(0.0, 1.0);

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
                        final id = userId ?? await _loadUserId();
                        if (id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("User ID not found. Please login again.")),
                          );
                          return;
                        }

                        _fadeSlideNavigate(
                          context,
                          FeedbackHistoryPage(userId: id),
                        );
                      },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFDFEFF), Color(0xFFE6EEFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFD5E3FF),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F8FFD).withOpacity(0.15),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
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
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B2541),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Practice speaking Japanese daily!",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7693),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1B2541),
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
    final double safeProgress = progress.clamp(0.0, 1.0);
    final bool goalCompleted = safeProgress >= 1.0;
    final String rawName = (userName ?? '').trim();
    final String displayName = rawName.isEmpty ? "ともだち" : rawName;
    final String greeting = "$displayNameさん";
    final String combinedGreeting = "こんにちは, $greeting";

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFDFEFF), Color(0xFFE6EEFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F8FFD).withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F8FFD).withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF4F8FFD),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        combinedGreeting,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1B2541),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Daily speaking progress",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF566076),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD5E3FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Streak",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7693),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$streakDays 日",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4F8FFD),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD5E3FF)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: safeProgress == 0 ? 0.001 : safeProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF76C7FD), Color(0xFF4F8FFD)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F8FFD).withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$practiceMinutes m",
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF8A93A8)),
                ),
                Text(
                  "$targetMinutes m",
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF8A93A8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
