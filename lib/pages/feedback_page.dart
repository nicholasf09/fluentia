import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackPage extends StatefulWidget {
  final String userId;

  const FeedbackPage({super.key, required this.userId});

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
      final url = Uri.parse("http://127.0.0.1:8000/feedback/");
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
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback Analysis")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
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
