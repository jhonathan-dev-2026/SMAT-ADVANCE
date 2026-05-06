import 'package:flutter/material.dart';
import '../models/estacion.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'add_estacion_screen.dart';
import '../screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Estacion> _estaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEstaciones();
  }

  Future<void> _cargarEstaciones() async {
    setState(() => _isLoading = true);
    final data = await _apiService.fetchEstaciones();
    setState(() {
      _estaciones = data;
      _isLoading = false;
    });
  }

  void _logout(BuildContext context) async {
    await AuthService().logout(); // Borra el token de SharedPreferences
    if (!mounted) return;

    // 4. RESETEA LA NAVEGACIÓN
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('SMAT - Monitoreo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _estaciones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sensors_off,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text("No hay estaciones registradas",
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarEstaciones,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _estaciones
                        .length, // Cambia a _estaciones.length si el modelo usa List
                    itemBuilder: (context, index) {
                      final est = _estaciones[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.router, color: Colors.white),
                          ),
                          title: Text(est.nombre,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(est.ubicacion),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      );
                    },
                  ),
                ),
      // AQUÍ ESTÁ EL BOTÓN QUE TE FALTABA PARA CREAR
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEstacionScreen()),
          );
          if (result == true) _cargarEstaciones();
        },
        label: const Text("Nueva Estación"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
