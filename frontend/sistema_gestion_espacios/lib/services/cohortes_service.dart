import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cohorte.dart';

class CohorteService {
  static const String baseUrl = 'http://ms-cohortes:8003';

  // Obtener todas las cohortes
  static Future<List<Cohorte>> getCohortes() async {
    final response = await http.get(Uri.parse('$baseUrl/cohortes/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Cohorte.fromJson(json)).toList();
    }
    throw Exception('Error al cargar cohortes');
  }

  // Obtener cohorte por ID
  static Future<Cohorte> getCohorteById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/cohortes/$id'));
    if (response.statusCode == 200) {
      return Cohorte.fromJson(json.decode(response.body));
    }
    throw Exception('Error al cargar cohorte con ID $id');
  }

  // Obtener cohorte por nombre
  static Future<List<Cohorte>> getCohorteByNombre(String nombre) async {
    final response = await http.get(Uri.parse('$baseUrl/cohortes/consultar_por_nombre/$nombre'));
    if (response.statusCode == 200) {
       List<dynamic> data = json.decode(response.body);
      return data.map((json) => Cohorte.fromJson(json)).toList();
    }
     // Assuming the API returns a list, even if empty or with one result
    if (response.statusCode == 404) { // Assuming 404 for not found by name
      return [];
    }
    throw Exception('Error al cargar cohorte con nombre $nombre');
  }

  // Crear una nueva cohorte
  static Future<Cohorte> createCohorte(Cohorte cohorte) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cohortes/crear_cohorte'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cohorte.toJson()),
    );
    if (response.statusCode == 201) { // Assuming 201 for creation success
      return Cohorte.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear cohorte');
  }

  // Actualizar una cohorte
  static Future<Cohorte> updateCohorte(int id, Cohorte cohorte) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cohortes/actualizar_cohorte/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cohorte.toJson()),
    );
    if (response.statusCode == 200) {
      return Cohorte.fromJson(json.decode(response.body));
    }
    throw Exception('Error al actualizar cohorte con ID $id');
  }

  // Eliminar una cohorte
  static Future<void> deleteCohorte(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/cohortes/eliminar_cohorte/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar cohorte con ID $id');
    }
  }
} 