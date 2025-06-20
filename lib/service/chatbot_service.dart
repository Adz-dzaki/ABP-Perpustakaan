import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/chat';

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['reply'] ?? 'Tidak ada balasan.';
      } else {
        print('Server error: ${response.statusCode}');
        return 'Maaf, terjadi masalah di server kami.';
      }
    } catch (e) {
      print('Connection error: $e');
      return 'Tidak dapat terhubung ke server chatbot.';
    }
  }
}