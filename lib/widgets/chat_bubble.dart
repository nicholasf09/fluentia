import 'package:flutter/material.dart';

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
  bool _showTranslation = false;

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
              clipBehavior: Clip.none, // biar tombol bisa keluar
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
                      if (_showTranslation) ...[
                        const SizedBox(height: 2),
                        const Divider(
                          color: Colors.black26,
                          thickness: 0.5,
                          height: 16,
                        ),
                        const Text(
                          "I would like to take a day off.",
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                // Tombol kecil di pojok kanan bawah (overview keluar bubble)
                if (!widget.isUser)
                  Positioned(
                    bottom: -12, // keluar dari bubble
                    right: 16,
                    child: Row(
                      children: [
                        _buildMiniCircleButton(
                          icon: Icons.translate,
                          onTap: () {
                            setState(() {
                              _showTranslation = !_showTranslation;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildMiniCircleButton(
                          icon: Icons.volume_up,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("🔊 Speaker tapped (dummy)")),
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
