import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:fluentia/services/api_service.dart';

const double _translateButtonSize = 36;
const double _translateButtonOverlap = _translateButtonSize / 2;


class ChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final String? avatarPath;
  final int? voiceId;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.avatarPath,
    this.voiceId,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  String? _translation;
  bool _isLoadingTranslate = false;
  bool _isPlaying = false;

  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _translateRotationController;

  // 🌐 Ganti dengan URL backend-mu
  static const String baseUrl = "https://u1083-nicholas-backend.gpu3.petra.ac.id";

  @override
  void initState() {
    super.initState();
    _translateRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _translateRotationController.dispose();
    super.dispose();
  }

  // === 🎧 Fungsi untuk memutar suara dari backend ===
  Future<void> _playTTS() async {
  if (_isPlaying || widget.text.trim().isEmpty) return;

  setState(() => _isPlaying = true);

  try {
    final bytes = await ApiService.generateTTS(widget.text, speaker: widget.voiceId ?? 1);
    if (bytes != null) {
      await _player.play(BytesSource(bytes));
    } else {
      _showSnack("⚠️ Gagal memutar suara (null bytes)");
    }
  } catch (e) {
    _showSnack("⚠️ Error: $e");
  }

  setState(() => _isPlaying = false);
}


  // === 🌍 Fungsi untuk terjemahkan teks ===
  Future<void> _translateText() async {
    if (_isLoadingTranslate || widget.text.trim().isEmpty) return;

    setState(() => _isLoadingTranslate = true);
    _translateRotationController.repeat();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/translate"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "text": widget.text,
          "target_lang": "id",
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _translation = data["translation"] ?? "⚠️ Terjemahan tidak tersedia.";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _translation = "⚠️ Gagal menerjemahkan (Status: ${response.statusCode})";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translation = "⚠️ Error: $e";
        });
      }
    } finally {
      if (mounted) {
        _translateRotationController
          ..stop()
          ..reset();
        setState(() => _isLoadingTranslate = false);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeText =
        widget.text.trim().isEmpty ? "（メッセージなし）" : widget.text.trim();
    final bubbleColor =
        widget.isUser ? Colors.blue.shade100 : Colors.grey.shade200;

    final bool showAssistantActions = !widget.isUser;
    final double avatarBottomMargin =
        showAssistantActions ? 18 + _translateButtonOverlap : 18;

    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isUser)
            Container(
              margin: EdgeInsets.only(
                right: 8,
                bottom: avatarBottomMargin,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade400,
                backgroundImage: widget.avatarPath != null &&
                        widget.avatarPath!.isNotEmpty
                    ? AssetImage(widget.avatarPath!)
                    : null,
                child: (widget.avatarPath == null ||
                        widget.avatarPath!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(widget.isUser ? 16 : 0),
                          bottomRight: Radius.circular(widget.isUser ? 0 : 16),
                        ),
                      ),
                      child: SelectionArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              safeText,
                              style: const TextStyle(fontSize: 16),
                              softWrap: true,
                            ),
                            if (_translation != null) ...[
                              const SizedBox(height: 4),
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
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (showAssistantActions)
                      const SizedBox(height: _translateButtonOverlap),
                  ],
                ),
                if (showAssistantActions)
                  Positioned(
                    bottom: 0,
                    right: 12,
                    child: _buildMiniCircleButton(
                      onTap: _isLoadingTranslate ? null : _translateText,
                      size: _translateButtonSize,
                      child: _isLoadingTranslate
                          ? AnimatedBuilder(
                              animation: _translateRotationController,
                              child: const Icon(Icons.autorenew,
                                  size: 18, color: Colors.black87),
                              builder: (_, child) => Transform.rotate(
                                angle:
                                    _translateRotationController.value * 2 * math.pi,
                                child: child,
                              ),
                            )
                          : const Icon(Icons.translate,
                              size: 18, color: Colors.black87),
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
    IconData? icon,
    Widget? child,
    required VoidCallback? onTap,
    double size = 28,
    double iconSize = 16,
  }) {
    final Widget effectiveChild =
        child ??
        Icon(
          icon,
          size: iconSize,
          color: Colors.black87,
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 3,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: effectiveChild,
        ),
      ),
    );
  }
}
