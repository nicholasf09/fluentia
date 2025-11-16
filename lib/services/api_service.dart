import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚙️ Base URL FastAPI
  static const String baseUrl = "https://u1083-nicholas-backend.gpu3.petra.ac.id";
  // Android emulator: "http://10.0.2.2:8000"
  // HP fisik: ganti sesuai IP laptop misalnya "http://192.168.1.5:8000"

  static const Map<String, String> _romajiKatakanaMap = {
    "kya": "キャ",
    "kyu": "キュ",
    "kyo": "キョ",
    "gya": "ギャ",
    "gyu": "ギュ",
    "gyo": "ギョ",
    "sha": "シャ",
    "shu": "シュ",
    "sho": "ショ",
    "sya": "シャ",
    "syu": "シュ",
    "syo": "ショ",
    "cha": "チャ",
    "chu": "チュ",
    "cho": "チョ",
    "cya": "チャ",
    "cyu": "チュ",
    "cyo": "チョ",
    "jya": "ジャ",
    "jyu": "ジュ",
    "jyo": "ジョ",
    "ja": "ジャ",
    "ju": "ジュ",
    "jo": "ジョ",
    "tya": "チャ",
    "tyu": "チュ",
    "tyo": "チョ",
    "dya": "ジャ",
    "dyu": "ジュ",
    "dyo": "ジョ",
    "nya": "ニャ",
    "nyu": "ニュ",
    "nyo": "ニョ",
    "hya": "ヒャ",
    "hyu": "ヒュ",
    "hyo": "ヒョ",
    "mya": "ミャ",
    "myu": "ミュ",
    "myo": "ミョ",
    "rya": "リャ",
    "ryu": "リュ",
    "ryo": "リョ",
    "bya": "ビャ",
    "byu": "ビュ",
    "byo": "ビョ",
    "pya": "ピャ",
    "pyu": "ピュ",
    "pyo": "ピョ",
    "fya": "フャ",
    "fyu": "フュ",
    "fyo": "フョ",
    "fa": "ファ",
    "fi": "フィ",
    "fe": "フェ",
    "fo": "フォ",
    "va": "ヴァ",
    "vi": "ヴィ",
    "vu": "ヴ",
    "ve": "ヴェ",
    "vo": "ヴォ",
    "tsa": "ツァ",
    "tsi": "ツィ",
    "tse": "ツェ",
    "tso": "ツォ",
    "je": "ジェ",
    "she": "シェ",
    "che": "チェ",
    "thi": "ティ",
    "dhi": "ディ",
    "twa": "トァ",
    "twi": "トィ",
    "twu": "トゥ",
    "twe": "トェ",
    "two": "トォ",
    "dwa": "ドァ",
    "dwi": "ドィ",
    "dwu": "ドゥ",
    "dwe": "ドェ",
    "dwo": "ドォ",
    "kwa": "クァ",
    "kwi": "クィ",
    "kwu": "クゥ",
    "kwe": "クェ",
    "kwo": "クォ",
    "shi": "シ",
    "si": "シ",
    "chi": "チ",
    "ti": "ティ",
    "tsu": "ツ",
    "tu": "トゥ",
    "ji": "ジ",
    "zi": "ジ",
    "zu": "ズ",
    "dzu": "ヅ",
    "di": "ディ",
    "du": "ドゥ",
    "fu": "フ",
    "hu": "フ",
    "ye": "イェ",
    "a": "ア",
    "i": "イ",
    "u": "ウ",
    "e": "エ",
    "o": "オ",
    "ka": "カ",
    "ki": "キ",
    "ku": "ク",
    "ke": "ケ",
    "ko": "コ",
    "ga": "ガ",
    "gi": "ギ",
    "gu": "グ",
    "ge": "ゲ",
    "go": "ゴ",
    "sa": "サ",
    "su": "ス",
    "se": "セ",
    "so": "ソ",
    "za": "ザ",
    "ze": "ゼ",
    "zo": "ゾ",
    "ta": "タ",
    "te": "テ",
    "to": "ト",
    "da": "ダ",
    "de": "デ",
    "do": "ド",
    "na": "ナ",
    "ni": "ニ",
    "nu": "ヌ",
    "ne": "ネ",
    "no": "ノ",
    "ha": "ハ",
    "hi": "ヒ",
    "he": "ヘ",
    "ho": "ホ",
    "ba": "バ",
    "bi": "ビ",
    "bu": "ブ",
    "be": "ベ",
    "bo": "ボ",
    "pa": "パ",
    "pi": "ピ",
    "pu": "プ",
    "pe": "ペ",
    "po": "ポ",
    "ma": "マ",
    "mi": "ミ",
    "mu": "ム",
    "me": "メ",
    "mo": "モ",
    "ya": "ヤ",
    "yu": "ユ",
    "yo": "ヨ",
    "ra": "ラ",
    "ri": "リ",
    "ru": "ル",
    "re": "レ",
    "ro": "ロ",
    "la": "ラ",
    "li": "リ",
    "lu": "ル",
    "le": "レ",
    "lo": "ロ",
    "wa": "ワ",
    "wo": "ヲ",
    "n": "ン"
  };

  static final List<String> _romajiSequences =
      (_romajiKatakanaMap.keys.toList()..sort((a, b) => b.length.compareTo(a.length)));
  static final RegExp _vowelRegex = RegExp(r'[aeiou]');
  static final RegExp _alphabetRegex = RegExp(r'[a-z]');

  static String _romajiToKatakana(String input) {
    if (input.isEmpty) return "";

    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    var index = 0;

    while (index < lower.length) {
      final char = lower[index];
      final originalChar = input[index];

      if (char == ' ' || char == '\t') {
        buffer.write(originalChar);
        index++;
        continue;
      }

      if (char == '-' || char == 'ー') {
        buffer.write('ー');
        index++;
        continue;
      }

      if (index + 1 < lower.length &&
          char == lower[index + 1] &&
          char != 'n' &&
          !_vowelRegex.hasMatch(char) &&
          _alphabetRegex.hasMatch(char)) {
        buffer.write('ッ');
        index++;
        continue;
      }

      var matched = false;
      for (final key in _romajiSequences) {
        if (lower.startsWith(key, index)) {
          final katakana = _romajiKatakanaMap[key];
          if (katakana != null) {
            buffer.write(katakana);
            index += key.length;
            matched = true;
            break;
          }
        }
      }

      if (matched) {
        continue;
      }

      if (char == 'n') {
        buffer.write('ン');
        index++;
        continue;
      }

      buffer.write(originalChar);
      index++;
    }

    return buffer.toString();
  }

  static String? _extractUsernameKatakana(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final directKatakana = payload["username_katakana"];
      if (directKatakana is String && directKatakana.isNotEmpty) {
        return directKatakana;
      }

      final nestedUser = payload["user"];
      if (nestedUser is Map<String, dynamic>) {
        final nestedKatakana = nestedUser["username_katakana"];
        if (nestedKatakana is String && nestedKatakana.isNotEmpty) {
          return nestedKatakana;
        }
      }
    }
    return null;
  }

  static String? _extractUsername(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final directUsername = payload["username"];
      if (directUsername is String && directUsername.isNotEmpty) {
        return directUsername;
      }

      final nestedUser = payload["user"];
      if (nestedUser is Map<String, dynamic>) {
        final nestedUsername = nestedUser["username"];
        if (nestedUsername is String && nestedUsername.isNotEmpty) {
          return nestedUsername;
        }
      }
    }
    return null;
  }

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
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/register/");
    final usernameKatakana = _romajiToKatakana(username);
    final body = json.encode({
      "username": username,
      "username_katakana": usernameKatakana,
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
      final extractedKatakana =
          _extractUsernameKatakana(data) ?? usernameKatakana;
      if (extractedKatakana.isNotEmpty) {
        await saveUsernameKatakana(extractedKatakana);
      } else {
        await clearUsernameKatakana();
      }
      final extractedUsername = _extractUsername(data) ?? username;
      if (extractedUsername.isNotEmpty) {
        await saveUsername(extractedUsername);
      } else {
        await clearUsername();
      }
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
      final extractedKatakana = _extractUsernameKatakana(data);
      if (extractedKatakana != null && extractedKatakana.isNotEmpty) {
        await saveUsernameKatakana(extractedKatakana);
      } else {
        await clearUsernameKatakana();
      }
      final extractedUsername = _extractUsername(data);
      if (extractedUsername != null && extractedUsername.isNotEmpty) {
        await saveUsername(extractedUsername);
      } else {
        await clearUsername();
      }
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

  static Future<void> saveUsernameKatakana(String katakana) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username_katakana", katakana);
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
  }

  static Future<void> clearUsernameKatakana() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("username_katakana");
  }

  static Future<void> clearUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("username");
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id");
  }

  static Future<String?> getUsernameKatakana() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("username_katakana");
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("username");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user_id");
    await prefs.remove("username_katakana");
    await prefs.remove("username");
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
      final extractedUsername = _extractUsername(data);
      if (extractedUsername != null && extractedUsername.isNotEmpty) {
        await saveUsername(extractedUsername);
      }
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
  // =======================================================
  // 🔊 VOICEVOX TTS (Text-to-Speech)
  // =======================================================
  static Future<Uint8List?> generateTTS(String text, {required int speaker}) async {
    final url = Uri.parse("$baseUrl/voice/stream");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "text": text,
          "speaker": speaker,
          "user_id": await getUserId(),
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print("⚠️ Gagal generate suara (${response.statusCode})");
        return null;
      }
    } catch (e) {
      print("❌ Error generate TTS: $e");
      return null;
    }
  }


  // =======================================================
  // 🔁 OPTIONAL: Ambil audio terakhir dari server (untuk polling / cache)
  // =======================================================
  static Future<String?> getLatestAudioUrl(String userId) async {
    final url = Uri.parse("$baseUrl/audio/latest?user_id=$userId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["audio_url"];
      } else {
        print("⚠️ Gagal mengambil audio terbaru (${response.statusCode})");
        return null;
      }
    } catch (e) {
      print("❌ Error mengambil audio: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchActivityInfo(int userId) async {
    final url = Uri.parse("$baseUrl/activity/info/$userId");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch activity info");
    }
  }
}
