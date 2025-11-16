import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class UsageTracker with WidgetsBindingObserver {
  DateTime? _startTime;

  void startSession() {
    _startTime = DateTime.now();
  }

  int endSession() {
    if (_startTime == null) return 0;
    final duration = DateTime.now().difference(_startTime!);
    return duration.inMinutes;
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.get("user_id");
    if (storedId is int) return storedId;
    if (storedId is String) return int.tryParse(storedId);
    return null;
  }

  Future<void> sendMinutesToServer(int minutes) async {
    if (minutes <= 0) return;

    final userId = await _getUserId();
    if (userId == null) return;

    final url = Uri.parse("${ApiService.baseUrl}/activity/update");

    await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "minutes": minutes,
        }));
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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      startSession();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      final minutes = endSession();
      await sendMinutesToServer(minutes);
    }
  }
}
