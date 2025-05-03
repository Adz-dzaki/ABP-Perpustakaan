import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class BookService {
  static Future<List<BookModel>> fetchBooks() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/books'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BookModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data buku');
    }
  }
}
