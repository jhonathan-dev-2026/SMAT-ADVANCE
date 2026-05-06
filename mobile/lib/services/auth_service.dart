import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // CAMBIO 1: Si usas Chrome o Windows, usa 127.0.0.1
  final String baseUrl = "http://127.0.0.1:8000"; 

  Future<bool> login(String username, String password) async {
    try {
      // CAMBIO 2: Enviamos los datos en el cuerpo (body) para que el servidor responda
      final response = await http.post(
        Uri.parse('$baseUrl/token'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 10)); // Evita que se quede cargando infinito

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return true;
      }
    } catch (e) {
      print("Error de conexión: $e");
    }
    return false; 
  }

  // --- FUNCIÓN 2: RECUPERAR TOKEN ---
  // Sirve para sacar la "llave" guardada cuando queramos hacer otras peticiones
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // --- FUNCIÓN 3: LOGOUT ---
  // Sirve para borrar la "llave" y que el usuario tenga que loguearse de nuevo
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}