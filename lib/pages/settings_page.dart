import 'package:flutter/material.dart';
import '../main.dart'; // pastikan path benar

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool useGoogleTranslate = true;
  String ttsVoice = "Female";
  String aiEngine = "Qwen 2.5";
  bool darkMode = false; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 🔹 Dark Mode
          SwitchListTile(
            value: darkMode,
            onChanged: (val) {
              setState(() => darkMode = val);
              final themeMode = val ? ThemeMode.dark : ThemeMode.light;
              FluentiaApp.of(context)?.changeTheme(themeMode);
            },
            title: const Text("Dark Mode"),
          ),
          const Divider(),

          // Toggle Google Translate
          SwitchListTile(
            value: useGoogleTranslate,
            onChanged: (val) {
              setState(() => useGoogleTranslate = val);
            },
            title: const Text("Enable Google Translate"),
          ),
          const Divider(),

          // TTS Voice
          ListTile(
            title: const Text("TTS Voice"),
            subtitle: Text(ttsVoice),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text("Select Voice"),
                  children: [
                    SimpleDialogOption(
                      child: const Text("Female"),
                      onPressed: () => Navigator.pop(context, "Female"),
                    ),
                    SimpleDialogOption(
                      child: const Text("Male"),
                      onPressed: () => Navigator.pop(context, "Male"),
                    ),
                  ],
                ),
              );
              if (selected != null) {
                setState(() => ttsVoice = selected);
              }
            },
          ),
          const Divider(),

          // AI Engine
          ListTile(
            title: const Text("AI Engine"),
            subtitle: Text(aiEngine),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text("Select AI Engine"),
                  children: [
                    SimpleDialogOption(
                      child: const Text("Qwen 2.5"),
                      onPressed: () => Navigator.pop(context, "Qwen 2.5"),
                    ),
                    SimpleDialogOption(
                      child: const Text("CaLM"),
                      onPressed: () => Navigator.pop(context, "CaLM"),
                    ),
                  ],
                ),
              );
              if (selected != null) {
                setState(() => aiEngine = selected);
              }
            },
          ),
        ],
      ),
    );
  }
}
