import 'package:flutter/material.dart';
import '../services/api_service.dart';
import './conversation_page.dart';
import '../widgets/topic_card.dart';

class TopicSelectionPage extends StatefulWidget {
  final String personaName;
  final String imagePath;

  const TopicSelectionPage({
    super.key,
    required this.personaName,
    required this.imagePath,
  });

  @override
  _TopicSelectionPageState createState() => _TopicSelectionPageState();
}

class _TopicSelectionPageState extends State<TopicSelectionPage> {
  bool _isLoading = false;
  List<dynamic> _topics = [];

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  // === Ambil data topik dari API berdasarkan persona ===
  Future<void> _fetchTopics() async {
    setState(() => _isLoading = true);
    try {
      final topics = await ApiService.getTopicsByPersona(widget.personaName);
      setState(() => _topics = topics);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memuat topik: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === Fetch pesan pembuka dari backend (LLM) ===
  Future<String> _fetchFirstMessage(
      String persona, String topic, String userId) async {
    final url = Uri.parse("${ApiService.baseUrl}/chat/");
    final body = {
      "prompt": "",
      "user_id": userId,
      "persona": persona,
      "topic": topic,
    };

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
    final imagePath = widget.imagePath;
    final userId = "user123";

    return Stack(
      children: [
        Scaffold(
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
              padding:
                  const EdgeInsets.only(left: 16, right: 8, top: 1, bottom: 1),
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
                      imagePath,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Settings tapped")),
                      );
                    },
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _topics.isEmpty
                  ? const Center(child: Text("Tidak ada topik tersedia."))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
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
                              levelColor: _getLevelColor(
                                  topic["level"] ?? "Easy"),
                              onTap: () async {
                                setState(() => _isLoading = true);
                                try {
                                  final firstMessage = await _fetchFirstMessage(
                                    widget.personaName,
                                    topic["en_title"],
                                    userId,
                                  );
                                  if (!mounted) return;
                                  setState(() => _isLoading = false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ConversationPage(
                                        persona: widget.personaName,
                                        topic: topic["en_title"],
                                        firstMessage: firstMessage,
                                        userId: userId,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Gagal memuat percakapan: $e"),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
