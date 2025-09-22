import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';

class ConversationPage extends StatefulWidget {
  final String persona;
  final String topic;

  const ConversationPage({super.key, required this.persona, required this.topic});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final List<Map<String, dynamic>> _messages = [
    {"text": "こんにちは！今日はどうしましたか？こんにちは！今日はどうしましたか？", "isUser": false},
    {"text": "すみません、休みをいただきたいです。", "isUser": true},
  ];

  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false; // untuk toggle mic <-> keyboard
  bool _isRecording = false; // dummy state rekaman

  String _getPersonaAvatar(String persona) {
    switch (persona.toLowerCase()) {
      case "boss":
        return "assets/images/boss.png";
      case "shop clerk":
        return "assets/images/cashier.png";
      case "friend":
        return "assets/images/friend.png";
      default:
        return "";
    }
  }

  String _getPersonaName(String persona) {
    switch (persona.toLowerCase()) {
      case "boss":
        return "Tanaka";
      case "shop clerk":
        return "Honda";
      case "friend":
        return "Akira";
      default:
        return persona;
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": _controller.text.trim(), "isUser": true});
      _controller.clear();
      _isTyping = false;
      // Dummy reply
      _messages.add({"text": "わかりました。詳しく教えてください。", "isUser": false});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = _getPersonaAvatar(widget.persona);
    final personaName = _getPersonaName(widget.persona);

    return Scaffold(
      // Custom AppBar: white background + shadow (Container)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: SafeArea(
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
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),

                // Avatar
                if (avatarPath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      avatarPath,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(personaName),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                const SizedBox(width: 12),

                // Name + topic
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        personaName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.topic,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // (Optional) settings / more button
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    // placeholder action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("More tapped")),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(
                  text: msg["text"],
                  isUser: msg["isUser"],
                  avatarPath: !msg["isUser"] ? avatarPath : null,
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your reply...",
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      setState(() {
                        _isTyping = v.trim().isNotEmpty;
                      });
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isTyping ? Icons.send : (_isRecording ? Icons.mic_none : Icons.mic),
                    color: _isTyping ? Colors.blue : Colors.red,
                  ),
                  tooltip: _isTyping ? "Send" : (_isRecording ? "Stop Recording" : "Hold to Talk"),
                  onPressed: () {
                    if (_isTyping) {
                      _sendMessage();
                    } else {
                      setState(() {
                        _isRecording = !_isRecording;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isRecording ? "🎤 Recording..." : "Recording stopped"),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(_isTyping ? Icons.keyboard : Icons.mic, color: Colors.black),
                  tooltip: _isTyping ? "Switch to keyboard" : "Switch to mic",
                  onPressed: () {
                    setState(() {
                      _isTyping = !_isTyping;
                      _isRecording = false;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
