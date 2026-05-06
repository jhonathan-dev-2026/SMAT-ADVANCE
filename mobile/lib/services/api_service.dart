import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/estacion.dart';
import '../services/auth_service.dart';

class ApiService {
  final String baseUrl =
      kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";

  // Agregamos el token al GET para que sea una "Petición Protegida"
  Future<List<Estacion>> fetchEstaciones() async {
    try {
      final token = await AuthService().getToken(); // Recuperamos el token

      final response = await http.get(
        Uri.parse('$baseUrl/estaciones/'),
        headers: {
          'Authorization': 'Bearer $token', // <--- Importante para la seguridad
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Estacion.fromJson(data)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión con el Backend SMAT');
    }
  }

  Future<void> createEstacion(Estacion estacion) async {
    final token = await AuthService().getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/estaciones/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(estacion.toJson()),
    );

    if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Por favor reingrese.');
    }

    // El backend suele devolver 201 cuando se CREA algo
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo crear la estación');
    }
  }
}
