import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final String? avatarPath;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.avatarPath,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  String? _translation;
  bool _isLoading = false;

  Future<void> _translateText() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("https://u1083-nicholas.gpu3.petra.ac.id/translate"), // ganti sesuai servermu
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "text": widget.text,
          "target_lang": "id", // bisa diganti "en", "id", dsb
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _translation = data["translation"];
        });
      } else {
        setState(() {
          _translation = "⚠️ Failed to translate";
        });
      }
    } catch (e) {
      setState(() {
        _translation = "⚠️ Error: $e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        widget.isUser ? Colors.blue.shade100 : Colors.grey.shade200;

    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 18),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade400,
                backgroundImage: widget.avatarPath != null
                    ? AssetImage(widget.avatarPath!)
                    : null,
                child: widget.avatarPath == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Bubble utama
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(widget.isUser ? 16 : 0),
                      bottomRight: Radius.circular(widget.isUser ? 0 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_translation != null) ...[
                        const SizedBox(height: 2),
                        const Divider(
                          color: Colors.black26,
                          thickness: 0.5,
                          height: 16,
                        ),
                        Text(
                          _translation!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                // Tombol kecil di pojok kanan bawah
                if (!widget.isUser)
                  Positioned(
                    bottom: -12,
                    right: 16,
                    child: Row(
                      children: [
                        _buildMiniCircleButton(
                          icon: _isLoading
                              ? Icons.hourglass_top
                              : Icons.translate,
                          onTap: _translateText,
                        ),
                        const SizedBox(width: 6),
                        _buildMiniCircleButton(
                          icon: Icons.volume_up,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("🔊 Speaker tapped (dummy)"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 3,
                offset: const Offset(1, 2),
              )
            ],
          ),
          child: Icon(icon, size: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
