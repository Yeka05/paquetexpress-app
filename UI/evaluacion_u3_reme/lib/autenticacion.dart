import 'dart:convert';
import 'package:http/http.dart' as http;


class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000";
  static String? token;
  static String? nombre;

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data["access_token"];
      nombre = data["nombre"];
      return true;
    }
    return false;
  }
}
