import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/programa.dart';
import '../models/asignatura_programa.dart';

class ProgramaService {
  static const String baseUrl = 'http://ms-programas:8001';

  // Obtener todos los programas
  static Future<List<Programa>> getProgramas() async {
    final response = await http.get(Uri.parse('$baseUrl/programas/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Programa.fromJson(json)).toList();
    }
    throw Exception('Error al cargar programas');
  }

  // Crear un nuevo programa
  static Future<Programa> createPrograma(Programa programa) async {
    final response = await http.post(
      Uri.parse('$baseUrl/programas/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(programa.toJson()),
    );
    if (response.statusCode == 200) {
      return Programa.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear programa');
  }

  // Actualizar un programa
  static Future<Programa> updatePrograma(int id, Programa programa) async {
    final response = await http.put(
      Uri.parse('$baseUrl/programas/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(programa.toJson()),
    );
    if (response.statusCode == 200) {
      return Programa.fromJson(json.decode(response.body));
    }
    throw Exception('Error al actualizar programa');
  }

  // Eliminar un programa
  static Future<void> deletePrograma(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/programas/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar programa');
    }
  }

  // Obtener todas las asignaturas de programas
  static Future<List<AsignaturaPrograma>> getAsignaturasProgramas() async {
    final response = await http.get(Uri.parse('$baseUrl/programas/asignaturas_programas/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => AsignaturaPrograma.fromJson(json)).toList();
    }
    throw Exception('Error al cargar asignaturas de programas');
  }

  // Asignar una asignatura a un programa
  static Future<AsignaturaPrograma> asignarAsignatura(AsignaturaPrograma asignaturaPrograma) async {
    final response = await http.post(
      Uri.parse('$baseUrl/programas/asignar_asignatura'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(asignaturaPrograma.toJson()),
    );
    if (response.statusCode == 200) {
      return AsignaturaPrograma.fromJson(json.decode(response.body));
    }
    throw Exception('Error al asignar asignatura');
  }

  // Eliminar una asignatura de un programa
  static Future<void> deleteAsignaturaPrograma(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/programas/asignaturas_programas/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar asignatura del programa');
    }
  }
} 