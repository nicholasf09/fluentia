import 'package:flutter/material.dart';
import '../widgets/persona_card.dart';
import './topic_selection_page.dart';
import './settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data progress
    const int practiceMinutes = 15;
    const int targetMinutes = 30;
    final double practiceProgress = practiceMinutes / targetMinutes;

    return Scaffold(
      backgroundColor: const Color(0xFFE9ECF2),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.only(top: 100), // space for custom app bar
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Card(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.bar_chart, color: Color(0xFF4F8FFD), size: 28),
                              SizedBox(width: 10),
                              Text(
                                "Today's Progress",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF222B45),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Progress bar gradient custom
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Stack(
                              children: [
                                // Background bar
                                Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                // Gradient progress
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Container(
                                      height: 14,
                                      width: constraints.maxWidth * practiceProgress,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF76C7FD), Color(0xFF4F8FFD)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "0m",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        "30m",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Daily goals label
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Daily Goals: $practiceMinutes/$targetMinutes minutes",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Choose a Persona:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  PersonaCard(
                    title: "Tanaka (Manager)",
                    description:
                        "Practice speaking in a professional setting with a company manager",
                    imagePath: "assets/images/boss.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicSelectionPage("Boss"),
                        ),
                      );
                    },
                  ),
                  PersonaCard(
                    title: "Honda (Shop Staff)",
                    description:
                        "Learn polite interactions with a friendly convenience store cashier",
                    imagePath: "assets/images/cashier.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicSelectionPage("Shop Clerk"),
                        ),
                      );
                    },
                  ),
                  PersonaCard(
                    title: "Akira (Friend)",
                    description:
                        "Enjoy everyday conversation with a casual friend your age",
                    imagePath: "assets/images/friend.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicSelectionPage("Friend"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Custom AppBar with shadow
          Container(
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
            padding: const EdgeInsets.only(left: 20, right: 8, top: 1, bottom: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Fluentia",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        "Practice speaking Japanese daily",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                  tooltip: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}