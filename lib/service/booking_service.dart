// LOKASI: lib/service/booking_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart'; // Pastikan path ke model Anda benar

class BookingService {
  final String _baseUrl = "http://10.0.2.2:8080/api/booking";

  // Fungsi untuk mengambil semua booking milik satu user
  Future<List<BookingModel>> fetchBookingsByAccountId(int accountId) async {
    final url = Uri.parse("$_baseUrl/bookings/$accountId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return []; // Bukan error jika user belum pernah booking
      } else {
        throw Exception('Gagal memuat data booking');
      }
    } catch (e) {
      print("Error di fetchBookingsByAccountId: $e");
      return [];
    }
  }

  // --- PENAMBAHAN: Method yang hilang untuk membuat booking baru ---
  Future<bool> bookBook({
    required int accountId,
    required int bukuId,
    required DateTime expiredDate,
  }) async {
    final url = Uri.parse(_baseUrl); // Menggunakan base URL

    // Siapkan body request sesuai API Anda
    final body = jsonEncode({
      'bukuId': bukuId,
      'accountId': accountId,
      // API Anda menerima ISO 8601 String
      'expiredDate': expiredDate.toIso8601String(),
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Jika butuh token, tambahkan di sini
          // 'Authorization': 'Bearer YOUR_TOKEN'
        },
        body: body,
      );

      // Request dianggap berhasil jika status code 200 (OK) atau 201 (Created)
      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      print("Error di bookBook: $e");
      return false;
    }
  }
}