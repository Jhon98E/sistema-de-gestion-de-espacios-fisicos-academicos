import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/salon.dart';

class SalonService {
  static const String baseUrl = 'http://ms-salones:8004';

  // Obtener todos los salones
  static Future<List<Salon>> getSalones() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/salones/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Salon.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener salones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la petición GET /salones/: $e');
    }
  }

  // Obtener un salón específico
  static Future<Salon> getSalon(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/salones/$id'));
      if (response.statusCode == 200) {
        return Salon.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener salón: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la petición GET /salones/$id: $e');
    }
  }

  // Crear un nuevo salón
  static Future<Salon> createSalon(Salon salon) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/salones/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(salon.toJson()),
      );

      if (response.statusCode == 200) {
        return Salon.fromJson(json.decode(response.body));
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw Exception('Error de validación: ${error['detail']}');
      } else {
        throw Exception('Error al crear salón: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la petición POST /salones/: $e');
    }
  }

  // Actualizar un salón existente
  static Future<Salon> updateSalon(int id, Salon salon) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/salones/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(salon.toJson()),
      );

      if (response.statusCode == 200) {
        return Salon.fromJson(json.decode(response.body));
      } else if (response.statusCode == 422) {
        final error = json.decode(response.body);
        throw Exception('Error de validación: ${error['detail']}');
      } else {
        throw Exception('Error al actualizar salón: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la petición PUT /salones/$id: $e');
    }
  }

  // Eliminar un salón
  static Future<void> deleteSalon(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/salones/$id'));
      
      if (response.statusCode != 200) {
        if (response.statusCode == 422) {
          final error = json.decode(response.body);
          throw Exception('Error de validación: ${error['detail']}');
        } else {
          throw Exception('Error al eliminar salón: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error en la petición DELETE /salones/$id: $e');
    }
  }
} 