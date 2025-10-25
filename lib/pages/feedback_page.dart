import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackPage extends StatefulWidget {
  final String userId;
  final String? persona;
  final String? topic;
  final String? avatarPath;
  final String? personaName;

  const FeedbackPage({
    super.key,
    required this.userId,
    this.persona,
    this.topic,
    this.avatarPath,
    this.personaName,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool _isLoading = true;
  String? feedbackRaw;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchFeedback();
  }

  Future<void> _fetchFeedback() async {
    try {
      final url = Uri.parse("https://u1083-nicholas.gpu3.petra.ac.id/feedback/");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"user_id": widget.userId}),
      );

      if (res.statusCode == 200) {
        setState(() {
          final decoded = json.decode(res.body);
          print("FEEDBACK RAW:\n${decoded['items'][0]['content']}");
          if (decoded['items'] != null && decoded['items'].isNotEmpty) {
            feedbackRaw = decoded['items'][0]['content'] ?? '';
          } else {
            feedbackRaw = '';
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          error = "Error: ${res.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        _isLoading = false;
      });
    }
  }

  // Bersihkan label seperti "Grammar Accuracy:" dari teks
  Map<String, String> _parseFeedback(String text) {
    String clean(String section) {
      return section.replaceAll(RegExp(r'^[A-Za-z\s&()–\-:]+:'), '').trim();
    }

    final parts = text.split('###');
    return {
      'overall': parts.length > 0 ? clean(parts[0]) : '',
      'grammar': parts.length > 1 ? clean(parts[1]) : '',
      'vocab': parts.length > 2 ? clean(parts[2]) : '',
      'formality': parts.length > 3 ? clean(parts[3]) : '',
      'communication': parts.length > 4 ? clean(parts[4]) : '',
      'summary': parts.length > 5 ? clean(parts[5]) : '',
    };
  }

  // Ekstrak skor numerik dari teks
  double _extractScore(String text) {
    // Bersihkan whitespace dan newline dulu
    final cleanText = text.replaceAll('\n', ' ').trim();
    print("RAW SCORE TEXT: '$text'");
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(cleanText);
    if (match != null) {
      final value = double.tryParse(match.group(0)!);
      if (value != null) {
        return value.clamp(0, 10);
      }
    }
    return 0;
  }


  // Pesan motivasi sesuai skor
  String _scoreMessage(double score) {
    if (score <= 3) return "Masih perlu latihan, tetap semangat!";
    if (score <= 6) return "Kemajuan terlihat, terus asah kemampuanmu!";
    if (score <= 8) return "Sudah bagus! Pertahankan dan perhatikan detail kecil.";
    return "Hebat! Kamu mendekati kefasihan alami!";
  }

  @override
  Widget build(BuildContext context) {
    final avatarPath = widget.avatarPath ?? "assets/images/boss.png";
    final personaName = widget.personaName ?? "Persona";
    final topic = widget.topic ?? "-";

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: SafeArea(
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(personaName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        topic,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Feedback Analysis",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4F8FFD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : feedbackRaw == null || feedbackRaw!.isEmpty
                  ? const Center(child: Text("No feedback available."))
                  : _buildFeedbackContent(_parseFeedback(feedbackRaw!)),
    );
  }

  Widget _buildFeedbackContent(Map<String, String> parsed) {
    final sections = [
      {
        "title": "Grammar Accuracy",
        "icon": Icons.text_fields_rounded,
        "color": const Color(0xFF3ECF8E),
        "content": parsed['grammar'] ?? ""
      },
      {
        "title": "Vocabulary & Naturalness",
        "icon": Icons.translate_rounded,
        "color": const Color(0xFFED8F1D),
        "content": parsed['vocab'] ?? ""
      },
      {
        "title": "Formality & Persona Consistency",
        "icon": Icons.handshake_rounded,
        "color": const Color(0xFF9A6AFF),
        "content": parsed['formality'] ?? ""
      },
      {
        "title": "Communication Effectiveness",
        "icon": Icons.chat_bubble_rounded,
        "color": const Color(0xFF50B6F2),
        "content": parsed['communication'] ?? ""
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 10),
        _buildScoreCircle(parsed['overall'] ?? ''),
        const SizedBox(height: 20),
        ...sections.map((s) => _buildFeedbackCard(
              s['title'] as String,
              s['content'] as String,
              s['icon'] as IconData,
              s['color'] as Color,
            )),
        const SizedBox(height: 16),
        _buildSummaryCard(parsed['summary'] ?? ''),
      ],
    );
  }

  Widget _buildScoreCircle(String text) {
    final score = _extractScore(text);
    final percentage = score / 10;
    final message = _scoreMessage(score);

    return Center(
      child: Column(
        children: [
          const Text(
            "Overall Score",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F8FFD),
            ),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentage),
            duration: const Duration(seconds: 1),
            builder: (context, value, _) => Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4F8FFD),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F8FFD),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "/10",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(
      String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.08),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  radius: 18,
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content.isNotEmpty ? content : "(no feedback)",
              style: TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String summary) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF4F8FFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Short Feedback Summary (Indonesian)",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            summary.isNotEmpty ? summary : "(tidak ada ringkasan)",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
