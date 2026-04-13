import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'autenticacion.dart';

class ServicioAPI {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<List<dynamic>> obtenerPaquetes() async {
    final res = await http.get(
      Uri.parse('$baseUrl/paquetes/'),
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> obtenerAgentes() async {
    final res = await http.get(Uri.parse('$baseUrl/agentes/'));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> obtenerEntregas() async {
    final res = await http.get(
      Uri.parse('$baseUrl/entregas/'),
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );
    return jsonDecode(res.body);
  }

  static Future<bool> registrarPaquete(Map data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/paquetes/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> registrarAgente(Map data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/agentes/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }


  static Future<bool> registrarEntrega({
    required int idPaquete,
    required double lat,
    required double lng,
    required Uint8List imagenBytes,
    required String nombreImagen,
    String estado = "entregado",
    String comentario = "",
  }) async {
    try {
      var req = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/entregas/'),
      );

      req.headers["Authorization"] = "Bearer ${AuthService.token}";

      req.fields['id_paquete'] = idPaquete.toString();
      req.fields['latitud'] = lat.toString();
      req.fields['longitud'] = lng.toString();
      req.fields['estado'] = estado;
      req.fields['comentario'] = comentario;

      
      req.files.add(
        http.MultipartFile.fromBytes(
          'imagen', 
          imagenBytes,
          filename: nombreImagen,
        ),
      );

      var res = await req.send();
      var responseString = await res.stream.bytesToString();

      print("STATUS: ${res.statusCode}");
      print("RESPUESTA BACKEND: $responseString");

      return res.statusCode == 200 || res.statusCode == 201;

    } catch (e) {
      print("ERROR FLUTTER: $e");
      return false;
    }
  }
}