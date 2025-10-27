import 'package:flutter/material.dart';
import '../services/api_service.dart';
import './feedback_page.dart';

class FeedbackHistoryPage extends StatefulWidget {
  final int userId;

  const FeedbackHistoryPage({super.key, required this.userId});

  @override
  State<FeedbackHistoryPage> createState() => _FeedbackHistoryPageState();
}

class _FeedbackHistoryPageState extends State<FeedbackHistoryPage> {
  bool _isLoading = true;
  List<dynamic> _feedbackList = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchFeedbackHistory();
  }

  Future<void> _fetchFeedbackHistory() async {
    try {
      final data = await ApiService.getFeedbackByUser(widget.userId.toString());
      setState(() {
        _feedbackList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Feedback History",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _feedbackList.isEmpty
                  ? const Center(
                      child: Text("Belum ada riwayat feedback."),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _feedbackList.length,
                      itemBuilder: (context, index) {
                        final item = _feedbackList[index];
                        final personaName = item['persona_name'] ?? "Persona";
                        final topic = item['topic_name'] ?? "-";
                        final score = (item['score'] is num)
                            ? item['score'].toDouble()
                            : 0.0;
                        final date = DateTime.tryParse(
                                item['created_at'] ?? DateTime.now().toString()) ??
                            DateTime.now();

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FeedbackPage(
                                  userId: widget.userId.toString(),
                                  personaName: personaName,
                                  topic: topic,
                                  avatarPath: "assets/images/boss.png", // bisa dinamis nanti
                                ),
                              ),
                            );
                          },
                          child: _buildFeedbackCard(personaName, topic, score, date),
                        );
                      },
                    ),
    );
  }

  Widget _buildFeedbackCard(
      String persona, String topic, double score, DateTime date) {
    final percent = (score / 10).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar (sementara default)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/images/boss.png",
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          persona,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5), // ⬅️ tanggal sedikit turun
                        child: Text(
                          ".",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.5), // ⬅️ tanggal lebih turun dikit
                        child: Text(
                          _formatDate(date),
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Text(
                  topic,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                ],
              ),
            ),

            // Circle Score
            SizedBox(
              width: 65,
              height: 65,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4F8FFD)),
                  ),
                  Text(
                    score % 1 == 0 ? score.toInt().toString() : score.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4F8FFD),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
