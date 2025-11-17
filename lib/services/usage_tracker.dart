import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'usage_tracker_web_stub.dart'
    if (dart.library.html) 'usage_tracker_web_html.dart';

class UsageTracker with WidgetsBindingObserver {
  UsageTracker._internal();

  static final UsageTracker instance = UsageTracker._internal();

  static const Duration _flushInterval = Duration(seconds: 30);
  static const Duration _idleTimeout = Duration(minutes: 2);
  static const String _loginPingPrefsKey = "last_login_ping_date";

  Timer? _flushTimer;
  Timer? _idleTimer;
  DateTime? _sessionStart;
  Duration _unflushedDuration = Duration.zero;
  bool _isIdle = false;
  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addObserver(this);
    _registerInteractionListeners();
    _resetIdleTimer();
    _resumeSession();
    _startFlushTimer();
    registerBeforeUnloadHandler(_handleBeforeUnload);
  }

  void dispose() {
    _flushTimer?.cancel();
    _idleTimer?.cancel();
    _removeInteractionListeners();
    WidgetsBinding.instance.removeObserver(this);
    unregisterBeforeUnloadHandler();
    _initialized = false;
  }

  Future<void> _handleBeforeUnload() async {
    await _captureElapsed();
    await _flushAccumulated(force: true);
  }

  void _registerInteractionListeners() {
    GestureBinding.instance.pointerRouter
        .addGlobalRoute(_handlePointerInteraction);
    HardwareKeyboard.instance.addHandler(_handleHardwareKeyEvent);
  }

  void _removeInteractionListeners() {
    GestureBinding.instance.pointerRouter
        .removeGlobalRoute(_handlePointerInteraction);
    HardwareKeyboard.instance.removeHandler(_handleHardwareKeyEvent);
  }

  void _handlePointerInteraction(PointerEvent event) {
    if (event.down || event is PointerMoveEvent) {
      _onUserInteraction();
    }
  }

  bool _handleHardwareKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _onUserInteraction();
    }
    return false;
  }

  void _onUserInteraction() {
    if (!_initialized) return;
    if (_isIdle) {
      _isIdle = false;
      _sessionStart = DateTime.now();
    } else {
      _sessionStart ??= DateTime.now();
    }
    _resetIdleTimer();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleTimeout, _onIdle);
  }

  Future<void> _onIdle() async {
    _isIdle = true;
    await _captureElapsed();
    await _flushAccumulated(force: true);
    _sessionStart = null;
  }

  void _resumeSession() {
    if (_isIdle) return;
    _sessionStart ??= DateTime.now();
  }

  Future<void> _pauseSession() async {
    await _captureElapsed();
    await _flushAccumulated(force: true);
    _sessionStart = null;
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) async {
      await _captureElapsed();
      await _flushAccumulated();
    });
  }

  Future<void> _captureElapsed() async {
    if (_sessionStart == null) return;
    final elapsed = DateTime.now().difference(_sessionStart!);
    if (elapsed.inSeconds <= 0) return;
    _unflushedDuration += elapsed;
    _sessionStart = DateTime.now();
  }

  Future<void> _flushAccumulated({bool force = false}) async {
    final seconds = _unflushedDuration.inSeconds;
    if (!force && seconds < 5) return;
    if (seconds <= 0) return;

    _unflushedDuration = Duration.zero;
    final success = await _postUsage(seconds);
    if (!success) {
      _unflushedDuration += Duration(seconds: seconds);
    }
  }

  Future<bool> _postUsage(int seconds,
      {int? overrideUserId, bool allowZeroSeconds = false}) async {
    if (!allowZeroSeconds && seconds <= 0) return true;
    final userId = overrideUserId ?? await _getUserId();
    if (userId == null) return false;

    final url = Uri.parse("${ApiService.baseUrl}/activity/update");
    final minutes = seconds / 60.0;

    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id": userId,
            "seconds": seconds,
            "minutes": minutes,
          }));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint("Failed to post usage: $e");
      return false;
    }
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.get("user_id");
    if (storedId is int) return storedId;
    if (storedId is String) return int.tryParse(storedId);
    return null;
  }

  Future<void> ensureDailyLoginPing({int? overrideUserId}) async {
    final userId = overrideUserId ?? await _getUserId();
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final lastPing = prefs.getString(_loginPingPrefsKey);
    if (lastPing == todayKey) return;

    final success = await _postUsage(0,
        overrideUserId: userId, allowZeroSeconds: true);
    if (success) {
      await prefs.setString(_loginPingPrefsKey, todayKey);
    }
  }

  Future<Map<String, dynamic>?> fetchActivityInfo({int? overrideUserId}) async {
    final id = overrideUserId ?? await _getUserId();
    if (id == null) return null;

    try {
      return await ApiService.fetchActivityInfo(id);
    } catch (e) {
      debugPrint("Error fetching activity info: $e");
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isIdle = false;
      _resumeSession();
      _resetIdleTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(_pauseSession());
    }
  }
}
