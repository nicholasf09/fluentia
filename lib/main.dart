import 'package:fluentia/pages/home_page.dart';
import 'package:fluentia/pages/topic_selection_page.dart'; // ✅ tambahkan ini
import 'package:flutter/material.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrint("🔥 Flutter caught error: ${details.exceptionAsString()}");
    if (details.stack != null) {
      debugPrintStack(stackTrace: details.stack);
    }
  };

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

      // ✅ Tambahkan ini agar semua _safeShowSnackBar() di seluruh app aman
      scaffoldMessengerKey: rootScaffoldMessengerKey,

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
