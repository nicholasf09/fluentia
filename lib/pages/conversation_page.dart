import 'package:flutter/material.dart';
import 'dart:convert';
import '../widgets/chat_bubble.dart';
import '../services/api_service.dart';
import './feedback_page.dart';

class ConversationPage extends StatefulWidget {
  final String personaName;
  final String topic;
  final String topicId;
  final String firstMessage;
  final String userId;
  final String imagePath;
  final int? voiceId;

  const ConversationPage({
    super.key,
    required this.personaName,
    required this.topic,
    required this.topicId,
    required this.firstMessage,
    required this.userId,
    required this.imagePath,
    this.voiceId,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late List<Map<String, dynamic>> _messages;
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  bool _isRecording = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    final cleanFirst = widget.firstMessage
        .replaceAll(RegExp(r"<think>.*?</think>", dotAll: true), "")
        .trim();

    _messages = [
      {
        "text": cleanFirst.isEmpty ? "（初回メッセージなし）" : cleanFirst,
        "isUser": false
      },
    ];
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
      _controller.clear();
      _isTyping = false;
      _isSending = true;
    });

    try {
      final url = Uri.parse("${ApiService.baseUrl}/chat/");
      final body = {
        "prompt": text,
        "user_id": widget.userId,
        "persona": widget.personaName,
        "topic": widget.topic,
        "topic_id": widget.topicId,
      };

      print("🚀 Sending message to /chat/: $body");

      final response = await ApiService.postJson(url, body);

      String reply = (response["response"] ?? "").toString();
      int voiceId = response["voice_id"];
      
      print("🚀 Received reply: $reply (voiceId: $voiceId)");
      reply = reply
          .replaceAll(RegExp(r"<think>.*?</think>", dotAll: true), "")
          .trim();

      if (reply.isEmpty) reply = "（応答なし）";

      if (!mounted) return;
      setState(() {
        _messages.add({"text": reply, "isUser": false});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({"text": "⚠️ Error: $e", "isUser": false});
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = widget.imagePath;
    final personaName = widget.personaName;

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
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    avatarPath,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 55,
                        height: 55,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.white),
                      );
                    },
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

                // 🔹 Tombol Feedback dengan transisi animasi
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 450),
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                FeedbackPage(
                          userId: widget.userId,
                          topic: widget.topic,
                          avatarPath: avatarPath,
                          personaName: personaName,
                        ),
                        transitionsBuilder: (context, animation,
                            secondaryAnimation, child) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0.1, 0.0), // geser dari kanan
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ));

                          final fadeAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );

                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
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
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 🔹 Chat Area
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              clipBehavior: Clip.none,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final safeText =
                    (msg["text"] ?? "（メッセージなし）").toString().trim();
                return ChatBubble(
                  text: safeText.isEmpty ? "（メッセージなし）" : safeText,
                  isUser: msg["isUser"] ?? false,
                  avatarPath: !(msg["isUser"] ?? false) ? avatarPath : null,
                  voiceId: !(msg["isUser"] ?? false) ? widget.voiceId : null,
                );
              },
            ),
          ),

          // 🔹 Input Area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Stack(
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
                                onChanged: (v) =>
                                    setState(() => _isTyping = v.trim().isNotEmpty),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                // 🔹 Tombol kirim / mic
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
                                  setState(() => _isRecording = !_isRecording);
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
          ),
        ],
      ),
    );
  }
}
