import 'package:fluentia/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FluentiaApp());
}

class FluentiaApp extends StatefulWidget {
  const FluentiaApp({super.key});

  static _FluentiaAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_FluentiaAppState>();

  @override
  State<FluentiaApp> createState() => _FluentiaAppState();
}

class _FluentiaAppState extends State<FluentiaApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fluentia',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: const HomePage(),
    );
  }
}
