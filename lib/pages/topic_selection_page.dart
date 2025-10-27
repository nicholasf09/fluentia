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

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  /// ✅ Tampilkan snackbar lewat global messenger (tidak pakai context)
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

  /// === Ambil pesan pertama dari endpoint /chat ===
  Future<String> _fetchFirstMessage(String topicId, String userId) async {
    if (topicId.isEmpty || userId.isEmpty) {
      throw Exception("TopicId atau UserId tidak boleh kosong");
    }

    final url = Uri.parse("${ApiService.baseUrl}/chat/");
    final body = {
      "prompt": "",
      "user_id": userId,
      "persona": widget.personaName,
      "topic_id": topicId,
    };

    debugPrint("🚀 Sending to /chat/: $body");
    final response = await ApiService.postJson(url, body);
    return response["response"] ?? "エラーが発生しました。";
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

  @override
  Widget build(BuildContext context) {
    const userId = "1";

    return Stack(
      children: [
        Scaffold(
          // ✅ gunakan global messenger agar tidak error
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
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
                          description:
                              topic["description"] ?? "No description",
                          level: topic["level"] ?? "Easy",
                          levelColor:
                              _getLevelColor(topic["level"] ?? "Easy"),
                          onTap: () async {
                            if (!mounted) return;
                            debugPrint("🟢 Start conversation tapped for topic ${topic["en_title"]}");
                            setState(() => _isLoading = true);

                            try {
                              final firstMessage = await _fetchFirstMessage(
                                topic["topic_id"]?.toString() ?? "",
                                userId,
                              );

                              debugPrint("✅ First message: $firstMessage");

                              if (!mounted) return;
                              setState(() => _isLoading = false);

                              // ✅ Gunakan context global dari rootScaffoldMessengerKey agar tidak bisa "deactivated"
                              final globalContext = rootScaffoldMessengerKey.currentContext;

                              if (globalContext != null) {
                                debugPrint("🚀 Navigating to ConversationPage...");
                                await Navigator.of(globalContext).push(
                                  MaterialPageRoute(
                                    builder: (_) => ConversationPage(
                                      personaName: widget.personaName,
                                      topic: topic["en_title"] ?? "No Title",
                                      topicId: topic["topic_id"]?.toString() ?? "",
                                      firstMessage: firstMessage,
                                      userId: userId,
                                      imagePath: widget.imagePath,
                                    ),
                                  ),
                                );
                              } else {
                                debugPrint("⚠️ globalContext is null, cannot navigate");
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                rootScaffoldMessengerKey.currentState?.showSnackBar(
                                  SnackBar(content: Text("Gagal memuat percakapan: $e")),
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
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
