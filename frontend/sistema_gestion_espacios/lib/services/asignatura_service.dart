import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asignatura.dart';

class AsignaturaService {
  static const String baseUrl = 'http://ms-asignaturas:8002';
  static const String asignaturaEndpoint = '/asignatura';

  Future<List<Asignatura>> getAsignaturas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$asignaturaEndpoint/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Asignatura.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener asignaturas: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Asignatura> getAsignaturaById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$asignaturaEndpoint/$id'),
      );

      if (response.statusCode == 200) {
        return Asignatura.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener la asignatura: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Asignatura> createAsignatura(Asignatura asignatura) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$asignaturaEndpoint/crear-asignatura'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(asignatura.toJson()),
      );

      if (response.statusCode == 200) {
        return Asignatura.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear la asignatura: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Asignatura> updateAsignatura(int id, Asignatura asignatura) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$asignaturaEndpoint/actualizar-asignatura/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(asignatura.toJson()),
      );

      if (response.statusCode == 200) {
        return Asignatura.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar la asignatura: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteAsignatura(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$asignaturaEndpoint/eliminar-asignatura/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la asignatura: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 