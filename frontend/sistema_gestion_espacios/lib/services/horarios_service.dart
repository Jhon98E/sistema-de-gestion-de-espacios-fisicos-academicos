import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/horario.dart';

class HorariosService {
  static const String _baseUrl = 'http://ms-horarios:8005/';
  
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<List<Horario>> getHorarios() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}horarios/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Horario.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los horarios');
    }
  }

  static Future<Horario> getHorarioById(int id) async {
    final response = await http.get(
      Uri.parse('${_baseUrl}horarios/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Horario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar el horario');
    }
  }

  static Future<Horario> createHorario(Horario horario) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}horarios/crear-horario'),
      headers: _headers,
      body: json.encode(horario.toJson()),
    );

    if (response.statusCode == 201) {
      return Horario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear el horario');
    }
  }

  static Future<Horario> updateHorario(int id, Horario horario) async {
    final response = await http.put(
      Uri.parse('${_baseUrl}horarios/actualizar-horario/$id'),
      headers: _headers,
      body: json.encode(horario.toJson()),
    );

    if (response.statusCode == 200) {
      return Horario.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el horario');
    }
  }

  static Future<void> deleteHorario(int id) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}horarios/eliminar-horario/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el horario');
    }
  }
} 