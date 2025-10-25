import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚙️ base URL FastAPI lokal
  static const String baseUrl = "http://127.0.0.1:8000"; 
  // kalau kamu jalankan di Android Emulator: ganti jadi "http://10.0.2.2:8000"
  // kalau di HP fisik: pakai IP lokal misalnya "http://192.168.1.5:8000"

  // ==== GET semua persona ====
  static Future<List<dynamic>> getAllPersona() async {
    final response = await http.get(Uri.parse('$baseUrl/persona'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data persona');
    }
  }

  // ==== POST tambah persona ====
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


  // ==== 🆕 GET semua topik berdasarkan persona ====
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

  // ==== (opsional) GET detail topik tertentu ====
  static Future<Map<String, dynamic>> getTopicDetail(int topicId) async {
    final response = await http.get(Uri.parse('$baseUrl/topics/$topicId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail topik');
    }
  }
}
