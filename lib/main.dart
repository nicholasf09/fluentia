import 'package:flutter/material.dart';
import 'package:fluentia/pages/home_page.dart';
import 'package:fluentia/pages/auth_page.dart';
import 'package:fluentia/services/api_service.dart';
import 'package:fluentia/services/usage_tracker.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final UsageTracker usageTracker = UsageTracker.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 🔧 pastikan SharedPreferences siap
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
  Widget? _startPage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    usageTracker.initialize();
  }

  @override
  void dispose() {
    usageTracker.dispose();
    super.dispose();
  }


  void changeTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  Future<void> _checkLoginStatus() async {
    final token = await ApiService.getToken();

    // Tambahkan sedikit delay agar splash tidak terlalu cepat
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      if (token != null && token.isNotEmpty) {
        _startPage = const HomePage();
      } else {
        _startPage = const AuthPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluentia',
      debugShowCheckedModeBanner: false,
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
      // ⏳ tampilkan splash kalau _startPage belum diset
      home: _startPage ?? const SplashScreen(),
    );
  }
}

/// ======================================================
/// ✨ Splash Screen (Logo Fluentia + Gradient)
/// ======================================================
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F8FFD), Color(0xFFA9D6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Fluentia",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: 10),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
