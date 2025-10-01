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
  Map<String, dynamic>? feedbackData;
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
          feedbackData = json.decode(res.body);
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

  @override
  Widget build(BuildContext context) {
    final avatarPath = widget.avatarPath ?? "assets/images/boss.png";
    final personaName = widget.personaName ?? "Persona";
    final topic = widget.topic ?? "-";

    return Scaffold(
      backgroundColor: Colors.white,
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
                      Text(
                        personaName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topic,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
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
              : (feedbackData?['items'] == null || feedbackData!['items'].isEmpty)
                  ? const Center(child: Text("No feedback available."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: feedbackData?['items']?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = feedbackData!['items'][index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? "Feedback ${index + 1}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(item['content'] ?? "-"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}