import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/chat_bubble.dart';
import './feedback_page.dart';

class ConversationPage extends StatefulWidget {
  final String persona;
  final String topic;
  final String firstMessage;
  final String userId;

  const ConversationPage({
    super.key,
    required this.persona,
    required this.topic,
    required this.firstMessage,
    required this.userId,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late List<Map<String, dynamic>> _messages;
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  bool _isRecording = false;
  bool _isSending = false; // loading state ketika menunggu LLM

  @override
  void initState() {
    super.initState();
    // Mulai percakapan dengan firstMessage dari backend
    _messages = [
      {"text": widget.firstMessage, "isUser": false},
    ];
  }

  String _getPersonaAvatar(String persona) {
    switch (persona.toLowerCase()) {
      case "manager":
        return "assets/images/boss.png";
      case "shop staff":
        return "assets/images/cashier.png";
      case "friend":
        return "assets/images/friend.png";
      default:
        return "";
    }
  }

  String _getPersonaName(String persona) {
    switch (persona.toLowerCase()) {
      case "manager":
        return "Tanaka";
      case "shop staff":
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
      _controller.clear();
      _isTyping = false;
      _isSending = true;
    });

    try {
      final url = Uri.parse("https://u1083-nicholas.gpu3.petra.ac.id/chat/"); 
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "prompt": text,
          "user_id": widget.userId,
          "persona": widget.persona,
          "topic": widget.topic,
        }),
      );

      String reply = "";
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        reply = data["response"] ?? "No response";
      } else {
        reply = "Error: ${res.statusCode}";
      }

      setState(() {
        _messages.add({"text": reply, "isUser": false});
      });
    } catch (e) {
      setState(() {
        _messages.add({"text": "Error: $e", "isUser": false});
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
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
            padding: const EdgeInsets.only(left: 16, right: 8, top: 1, bottom: 1),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        personaName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                // Ganti tombol more dengan tombol feedback/analisa
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FeedbackPage(
                          userId: widget.userId,
                          persona: widget.persona,
                          topic: widget.topic,
                          avatarPath: avatarPath,
                          personaName: personaName,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F8FFD), Color(0xFF76C7FD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white),
                  ),
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(56),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    decoration: const InputDecoration(
                                      hintText: "Type your message...",
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
                                // Hapus loading dari dalam input
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    // Mic/send button/loading di kanan luar input
                    Positioned(
                      right: 0,
                      child: _isSending
                          ? Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x334F8FFD),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : GestureDetector(
                              onTap: _isTyping
                                  ? _sendMessage
                                  : () {
                                      setState(() {
                                        _isRecording = !_isRecording;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(_isRecording
                                              ? "🎤 Recording..."
                                              : "Recording stopped"),
                                        ),
                                      );
                                    },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF4F8FFD), Color(0xFF76C7FD)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x334F8FFD),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isTyping
                                      ? Icons.send
                                      : (_isRecording ? Icons.mic : Icons.mic_none),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
