import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚙️ Base URL FastAPI
  static const String baseUrl = "http://127.0.0.1:8000";
  // Android emulator: "http://10.0.2.2:8000"
  // HP fisik: ganti sesuai IP laptop misalnya "http://192.168.1.5:8000"

  // =======================================================
  // 🔹 PERSONA
  // =======================================================
  static Future<List<dynamic>> getAllPersona() async {
    final response = await http.get(Uri.parse('$baseUrl/persona'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data persona');
    }
  }

  static Future<void> addPersona(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/persona'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menambahkan persona');
    }
  }

  // =======================================================
  // 🔹 TOPIC
  // =======================================================
  static Future<List<dynamic>> getTopicsByPersona(String personaName) async {
    final encodedPersona = Uri.encodeComponent(personaName);
    final response =
        await http.get(Uri.parse('$baseUrl/topics?persona=$encodedPersona'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data;
      } else {
        throw Exception("Format data tidak sesuai (harus berupa list)");
      }
    } else {
      throw Exception('Gagal memuat data topik untuk $personaName');
    }
  }

  static Future<Map<String, dynamic>> getTopicDetail(int topicId) async {
    final response = await http.get(Uri.parse('$baseUrl/topics/$topicId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail topik');
    }
  }

  // =======================================================
  // 🧠 FEEDBACK
  // =======================================================
  static Future<Map<String, dynamic>> generateFeedback({
    required String userId,
    required String topicId,
    String? persona,
    String? topic,
  }) async {
    final url = Uri.parse('$baseUrl/feedback/generate/');
    final body = json.encode({
      "user_id": userId,
      "topic_id": topicId,
      "persona": persona ?? "",
      "topic": topic ?? "",
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Gagal generate feedback (${response.statusCode}): ${response.body}');
    }
  }

  static Future<List<dynamic>> getFeedbackByUser(String userId) async {
    final url = Uri.parse('$baseUrl/feedback/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['items'] ?? [];
    } else {
      throw Exception('Gagal mengambil feedback user ($userId)');
    }
  }

  static Future<Map<String, dynamic>> getFeedbackById(String feedbackId) async {
    final url = Uri.parse("$baseUrl/feedback/detail/$feedbackId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load feedback detail");
    }
  }

  // =======================================================
  // 🔐 AUTH (LOGIN & REGISTER)
  // =======================================================
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/register/");
    final body = json.encode({
      "name": name,
      "email": email,
      "password": password,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data.containsKey("token")) await saveToken(data["token"]);
      if (data.containsKey("user_id")) await saveUserId(data["user_id"]);
      return {"success": true, "data": data};
    } else {
      return {
        "success": false,
        "message": data["detail"] ?? "Gagal mendaftar."
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login/");
    final body = json.encode({
      "email": email,
      "password": password,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      if (data.containsKey("token")) await saveToken(data["token"]);
      if (data.containsKey("user_id")) await saveUserId(data["user_id"]);
      return {"success": true, "data": data};
    } else {
      return {
        "success": false,
        "message": data["detail"] ?? "Email atau password salah."
      };
    }
  }

  // =======================================================
  // 💾 TOKEN & USER ID MANAGEMENT
  // =======================================================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> saveUserId(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_id", id.toString());
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user_id");
  }

  // =======================================================
  // 👤 PROFILE (opsional)
  // =======================================================
  static Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl/user/profile/");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = json.decode(response.body);

    print(data);
    if (response.statusCode == 200) {
      return {"success": true, "data": data};
    } else {
      return {"success": false, "message": data["detail"] ?? "Gagal memuat profil."};
    }
  }
 // =======================================================
  // 🌐 GENERIC POST HELPER (untuk keperluan umum seperti /chat, /feedback)
  // =======================================================
  static Future<Map<String, dynamic>> postJson(Uri url, Map<String, dynamic> body) async {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print("📡 POST → $url | status: ${response.statusCode}");
    print("📦 Response: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal melakukan POST ke $url (${response.statusCode})");
    }
  }
}
