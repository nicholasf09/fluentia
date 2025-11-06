import 'package:flutter/material.dart';
import '../services/api_service.dart';
import './conversation_page.dart';
import '../widgets/topic_card.dart';

// ✅ Global key untuk menampilkan snackbar dari mana pun tanpa error context
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class TopicSelectionPage extends StatefulWidget {
  final String personaName;
  final String imagePath;

  const TopicSelectionPage({
    super.key,
    required this.personaName,
    required this.imagePath,
  });

  @override
  State<TopicSelectionPage> createState() => _TopicSelectionPageState();
}

class _TopicSelectionPageState extends State<TopicSelectionPage> {
  bool _isLoading = false;
  List<dynamic> _topics = [];
  String? _userId;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchTopics();
  }

  /// ✅ Tampilkan snackbar lewat global messenger
  void _safeShowSnackBar(String message) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// === Ambil daftar topik dari API berdasarkan persona ===
  Future<void> _fetchTopics() async {
    setState(() => _isLoading = true);
    try {
      final topics = await ApiService.getTopicsByPersona(widget.personaName);
      if (!mounted) return;
      setState(() => _topics = topics);
    } catch (e) {
      _safeShowSnackBar("Gagal memuat topik: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserId() async {
    try {
      final id = await ApiService.getUserId();
      final username = await ApiService.getUsername();
      if (!mounted) return;
      setState(() {
        _userId = id;
        _username = username;
      });
    } catch (e) {
      if (!mounted) return;
      _safeShowSnackBar("Gagal memuat data pengguna: $e");
    }
  }

  /// === Ambil pesan pertama dari endpoint /chat ===
  Future<Map<String, dynamic>> _fetchFirstMessage(
    String topicId,
    String userId,
    String username,
  ) async {
    if (topicId.isEmpty || userId.isEmpty) {
      throw Exception("TopicId atau UserId tidak boleh kosong");
    }

    final url = Uri.parse("${ApiService.baseUrl}/chat/");
    final body = {
      "prompt": "",
      "user_id": userId,
      "persona": widget.personaName,
      "topic_id": topicId,
      "username": username,
    };

    debugPrint("🚀 Sending to /chat/: $body");
    final response = await ApiService.postJson(url, body);
    final reply = response["response"] ?? "エラーが発生しました。";
    final voiceId = response["voice_id"];

    return {"text": reply, "voice_id": voiceId};
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case "easy":
        return Colors.green;
      case "medium":
        return Colors.amber;
      case "hard":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ======================================================
  // 🌫️ Helper untuk Fade Navigation
  // ======================================================
  Future<void> _fadeNavigate(BuildContext context, Widget page) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: rootScaffoldMessengerKey,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.imagePath,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.personaName,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          "Choose a topic to practice",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                      _safeShowSnackBar("Settings tapped");
                    },
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),
          ),

          /// === BODY ===
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _topics.length,
                    itemBuilder: (context, index) {
                      final topic = _topics[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TopicCard(
                          jpTitle: topic["jp_title"] ?? "タイトルなし",
                          enTitle: topic["en_title"] ?? "No Title",
                          description: topic["description"] ?? "No description",
                          level: topic["level"] ?? "Easy",
                          levelColor: _getLevelColor(topic["level"] ?? "Easy"),
                          onTap: () async {
                            if (!mounted) return;
                            debugPrint(
                              "🟢 Start conversation tapped for topic ${topic["en_title"]}",
                            );
                            final userId = _userId;
                            final username = _username;
                            if (userId == null || userId.isEmpty) {
                              rootScaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "User ID tidak ditemukan. Silakan login kembali.",
                                  ),
                                ),
                              );
                              return;
                            }
                            if (username == null || username.isEmpty) {
                              rootScaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Username tidak ditemukan. Silakan login kembali.",
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() => _isLoading = true);

                            try {
                              final firstMessage = await _fetchFirstMessage(
                                topic["topic_id"]?.toString() ?? "",
                                userId,
                                username,
                              );

                              debugPrint("✅ First message: $firstMessage");

                              if (!mounted) return;
                              setState(() => _isLoading = false);

                              final globalContext =
                                  rootScaffoldMessengerKey.currentContext;

                              if (globalContext != null) {
                                debugPrint("🚀 Navigating with fade...");
                                await _fadeNavigate(
                                  globalContext,
                                  ConversationPage(
                                    personaName: widget.personaName,
                                    topic: topic["en_title"] ?? "No Title",
                                    topicId:
                                        topic["topic_id"]?.toString() ?? "",
                                    firstMessage: firstMessage["text"] ?? "",
                                    voiceId: firstMessage["voice_id"],
                                    userId: userId,
                                    imagePath: widget.imagePath,
                                  ),
                                );
                              } else {
                                debugPrint(
                                  "⚠️ globalContext is null, cannot navigate",
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                rootScaffoldMessengerKey.currentState
                                    ?.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Gagal memuat percakapan: $e",
                                        ),
                                      ),
                                    );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),

        /// === LOADING OVERLAY ===
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
