import 'package:flutter/material.dart';
import '../services/api_service.dart';
import './feedback_detail_page.dart';
import './settings_page.dart'; // pastikan file ini ada

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


  // ---------- Custom AppBar ----------
  Widget _buildAppBar(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tombol Back
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
          ),

          const SizedBox(width: 8),

          // Judul
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Feedback History",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "View your past evaluations",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Tombol Settings
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------- UI utama ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: _isLoading
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
                              final personaName =
                                  item['persona_name'] ?? "Persona";
                              final topic = item['topic_name'] ?? "-";
                              final score = double.tryParse(
                                      item['score'].toString()) ??
                                  0.0;
                              final date = DateTime.tryParse(
                                      item['created_at'] ??
                                          DateTime.now().toString()) ??
                                  DateTime.now();

                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 500),
                                    pageBuilder: (context, animation, secondaryAnimation) => FeedbackDetailPage(
                                      userId: widget.userId.toString(),
                                      feedbackId: item['feedback_id'].toString(),
                                      personaName: personaName,
                                      topicName: topic,
                                      avatarPath: "assets/images/boss.png", // atau item['persona_image']
                                    ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      // Slide + Fade dari kanan
                                      final offsetAnimation = Tween<Offset>(
                                        begin: const Offset(0.2, 0.0), // 0.2 berarti geser 20% lebar layar dari kanan
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                                      );

                                      final fadeAnimation = Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(parent: animation, curve: Curves.easeOut),
                                      );

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: FadeTransition(
                                          opacity: fadeAnimation,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ));
                                },
                                child: _buildFeedbackCard(
                                    personaName, topic, score, date),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // ---------- Widget Card ----------
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
                      const Icon(Icons.circle, size: 5, color: Colors.grey),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.5),
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
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFF4F8FFD)),
                  ),
                  Text(
                    score % 1 == 0
                        ? score.toInt().toString()
                        : score.toStringAsFixed(1),
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
