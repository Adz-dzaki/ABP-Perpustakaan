import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  static Future<bool> bookBook({
    required int memberId,
    required int bookDetailId,
  }) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/booking');

    final now = DateTime.now();
    final expired = now.add(const Duration(days: 3));

    final body = jsonEncode({
      'bookingDate': now.toIso8601String(),
      'expiredDate': expired.toIso8601String(),
      'memberIdFk': memberId,
      'bukuDetailsIdFk': bookDetailId,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }
}
