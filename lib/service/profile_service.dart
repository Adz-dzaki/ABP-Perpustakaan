import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
// import 'profile_model.dart';

class ProfileService {
  static Future<ProfileModel> fetchProfile(int accountId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2/api/profile/$accountId'),
    );

    if (response.statusCode == 200) {
      return ProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
