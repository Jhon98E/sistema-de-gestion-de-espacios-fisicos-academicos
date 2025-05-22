import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/salon.dart';

class SalonService {
  // ** Define aquí la URL base de tu microservicio de salones **
  static const String _baseUrl = 'http://ms-salones:8004'; // <<-- Usamos la URL base sin la barra final
  
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<List<Salon>> getSalones() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}/salones/'), // Endpoint GET /salones/
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON que es una lista de objetos
        final List<dynamic> data = json.decode(response.body);
        // Mapear cada objeto JSON a una instancia de Salon
        return data.map((json) => Salon.fromJson(json)).toList();
      } else {
        // Manejar errores si la respuesta no es 200 OK
        throw Exception('Error al cargar los salones: ${response.statusCode}');
      }
    } catch (e) {
      // Capturar cualquier excepción durante la llamada HTTP o el procesamiento
      print('Error en getSalones: $e'); // Imprimir error para depuración
      throw Exception('Fallo al conectar con el servicio de salones: $e');
    }
  }

  static Future<Salon> getSalonById(int id) async {
    final response = await http.get(
      Uri.parse('${_baseUrl}/salones/$id'), // Endpoint GET /salones/{salon_id}
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Salon.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar el salón con id $id: ${response.statusCode}');
    }
  }

  static Future<Salon> createSalon(Salon salon) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}/salones/'), // Endpoint POST /salones/
      headers: _headers,
      body: json.encode(salon.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) { // 200 o 201 son comunes para creación exitosa
      return Salon.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear el salón: ${response.statusCode}');
    }
  }

  static Future<Salon> updateSalon(int id, Salon salon) async {
    final response = await http.put(
      Uri.parse('${_baseUrl}/salones/$id'), // Endpoint PUT /salones/{salon_id}
      headers: _headers,
      body: json.encode(salon.toJson()),
    );

    if (response.statusCode == 200) {
      return Salon.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el salón con id $id: ${response.statusCode}');
    }
  }

  static Future<void> deleteSalon(int id) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}/salones/$id'), // Endpoint DELETE /salones/{salon_id}
      headers: _headers,
    );

    if (response.statusCode != 200) { // El 200 indica éxito en la eliminación según tu API
      throw Exception('Error al eliminar el salón con id $id: ${response.statusCode}');
    }
    // Si el código es 200, la eliminación fue exitosa y no necesitamos retornar nada.
  }

  // Puedes añadir métodos para crear, actualizar, eliminar salones si los necesitas
  // static Future<Salon> createSalon(Salon salon) async { ... }
  // static Future<void> deleteSalon(int id) async { ... }

} 