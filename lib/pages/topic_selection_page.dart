import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './conversation_page.dart';
import '../widgets/topic_card.dart'; // pastikan path sesuai

class TopicSelectionPage extends StatefulWidget {
  final String persona;
  const TopicSelectionPage(this.persona, {super.key});

  @override
  _TopicSelectionPageState createState() => _TopicSelectionPageState();
}

class _TopicSelectionPageState extends State<TopicSelectionPage> {
  bool _isLoading = false;
  
  // --- API Call pertama untuk dapatkan opening message ---
  Future<String> _fetchFirstMessage(String persona, String topic, String userId) async {
    final url = Uri.parse("https://u1083-nicholas.gpu3.petra.ac.id/chat/"); 
    final body = jsonEncode({
      "prompt": "", // kosong, system_prompt di-handle backend
      "user_id": userId,
      "persona": persona,
      "topic": topic
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["response"] ?? "エラーが発生しました。";
    } else {
      throw Exception("Failed to connect API");
    }
  }

  // --- Dummy data topik ---
  List<Map<String, dynamic>> getTopics() {
    switch (widget.persona) {
      case "Manager":
        return [
          {
            "jpTitle": "休暇申請",
            "enTitle": "Request Time Off (Cuti/Sakit)",
            "description": "Belajar mengajukan izin cuti atau sakit dengan manajer",
            "level": "Medium",
            "levelColor": Colors.amber,
          },
          {
            "jpTitle": "進捗報告",
            "enTitle": "Report Project Progress",
            "description": "Latihan melaporkan progres proyek dengan bahasa formal",
            "level": "Hard",
            "levelColor": Colors.red,
          },
          {
            "jpTitle": "遅刻願い",
            "enTitle": "Request Permission for Being Late",
            "description": "Latihan meminta izin terlambat masuk kerja dengan manajer",
            "level": "Medium",
            "levelColor": Colors.amber,
          },
        ];

      case "Shop Staff":
        return [
          {
            "jpTitle": "値段を聞く",
            "enTitle": "Ask for Price",
            "description": "Latihan menanyakan harga barang dengan kasir",
            "level": "Easy",
            "levelColor": Colors.green,
          },
          {
            "jpTitle": "商品の場所を聞く",
            "enTitle": "Ask Location/Availability",
            "description": "Latihan menanyakan lokasi atau ketersediaan produk",
            "level": "Medium",
            "levelColor": Colors.amber,
          },
          {
            "jpTitle": "支払いをする",
            "enTitle": "Make a Payment",
            "description": "Latihan melakukan proses pembayaran di kasir",
            "level": "Easy",
            "levelColor": Colors.green,
          },
        ];

      case "Friend":
        return [
          {
            "jpTitle": "趣味の話",
            "enTitle": "Talk about Hobbies",
            "description": "Latihan bercerita tentang hobi dengan teman",
            "level": "Easy",
            "levelColor": Colors.green,
          },
          {
            "jpTitle": "おすすめを聞く",
            "enTitle": "Ask for Recommendations",
            "description": "Latihan bertanya rekomendasi tempat/kuliner",
            "level": "Medium",
            "levelColor": Colors.amber,
          },
          {
            "jpTitle": "予定を立てる",
            "enTitle": "Plan an Outing",
            "description": "Latihan mengajak jalan atau mengatur jadwal",
            "level": "Medium",
            "levelColor": Colors.amber,
          },
        ];

      default:
        return [
          {
            "jpTitle": "一般会話",
            "enTitle": "General Conversation",
            "description": "Latihan percakapan umum untuk situasi apa saja",
            "level": "Easy",
            "levelColor": Colors.green,
          },
        ];
    }
  }

  // --- Mapping persona ke gambar ---
  String getPersonaImage() {
    switch (widget.persona) {
      case "Manager":
        return "assets/images/boss.png";
      case "Shop Staff":
        return "assets/images/cashier.png";
      case "Friend":
        return "assets/images/friend.png";
      default:
        return "assets/images/default.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = getTopics();
    final imagePath = getPersonaImage();
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
              padding: const EdgeInsets.only(left: 16, right: 8, top: 1, bottom: 1),
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
                          widget.persona,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TopicCard(
                    jpTitle: topic["jpTitle"],
                    enTitle: topic["enTitle"],
                    description: topic["description"],
                    level: topic["level"],
                    levelColor: topic["levelColor"],
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        final firstMessage = await _fetchFirstMessage(
                          widget.persona,
                          topic["enTitle"],
                          userId,
                        );
                        if (!mounted) return;
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConversationPage(
                              persona: widget.persona,
                              topic: topic["enTitle"],
                              firstMessage: firstMessage,
                              userId: userId,
                            ),
                          ),
                        );
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to load: $e")),
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
