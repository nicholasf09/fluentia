import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚙️ Base URL FastAPI lokal
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

  static Future<Map<String, dynamic>> postJson(Uri url, Map<String, dynamic> body) async {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    print("📡 Response status: ${response.statusCode}");
    print("📦 Response body: ${response.body}");
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal melakukan POST request");
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
  // 🧠 FEEDBACK (baru)
  // =======================================================

  /// 🚀 Generate feedback dari GPU & langsung auto-save ke DB
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

    print("📤 Sending feedback generation request to: $url");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print("📡 Status: ${response.statusCode}");
    print("📦 Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Gagal generate feedback (${response.statusCode}): ${response.body}');
    }
  }

  /// 📄 Ambil semua feedback berdasarkan user ID (riwayat)
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
}
