import 'package:flutter/material.dart';
import './conversation_page.dart';
import '../widgets/topic_card.dart'; // pastikan path sesuai dengan lokasi TopicCard kamu

class TopicSelectionPage extends StatelessWidget {
  final String persona;
  const TopicSelectionPage(this.persona, {super.key});

  // Dummy data: daftar topik per persona
  List<Map<String, dynamic>> getTopics() {
    switch (persona) {
      case "Boss":
        return [
          {
            "jpTitle": "休暇申請",
            "enTitle": "Request Time Off",
            "description":
                "Learn to formally request vacation days using proper keigo",
            "level": "Medium",
            "levelColor": Colors.amber,
          },
          {
            "jpTitle": "進捗報告",
            "enTitle": "Report Work Progress",
            "description":
                "Practice giving professional status updates on projects",
            "level": "Hard",
            "levelColor": Colors.red,
          },
        ];
      case "Friend":
        return [
          {
            "jpTitle": "夕食に誘う",
            "enTitle": "Invite to Dinner",
            "description": "Practice inviting your friend politely",
            "level": "Easy",
            "levelColor": Colors.green,
          },
          {
            "jpTitle": "趣味の話",
            "enTitle": "Talk about Hobbies",
            "description": "Learn casual phrases about daily hobbies",
            "level": "Medium",
            "levelColor": Colors.amber,
          },
        ];
      default:
        return [
          {
            "jpTitle": "一般会話",
            "enTitle": "General Conversation",
            "description": "Basic practice for any situation",
            "level": "Easy",
            "levelColor": Colors.green,
          },
        ];
    }
  }

  // Mapping persona ke gambar
  String getPersonaImage() {
    switch (persona) {
      case "Boss":
        return "assets/images/boss.png";
      case "Shop Clerk":
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

    return Scaffold(
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
          padding: const EdgeInsets.only(left: 20, right: 8, top: 1, bottom: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                      persona,
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConversationPage(
                        persona: persona,
                        topic: topic["enTitle"], // kirim English title ke next page
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
