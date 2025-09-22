import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Feedback"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Words Learned
            const Text(
              "Words Learned:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text("休み")),
                Chip(label: Text("理由")),
                Chip(label: Text("進捗")),
              ],
            ),
            const SizedBox(height: 24),

            // Keigo Feedback
            const Text(
              "Keigo Feedback:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Good job using polite expressions like 「〜たいです」.\n"
              "Try to use more 丁寧語 when speaking to a boss.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // Suggestions
            const Text(
              "Suggestions:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "・Try longer sentences\n"
              "・Use more connecting words (それで, しかし)\n"
              "・Practice listening to keigo patterns",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Spacer(),

            // Back button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text("Back to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
