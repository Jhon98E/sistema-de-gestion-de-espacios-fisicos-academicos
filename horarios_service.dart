import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/horario.dart';
import '../models/asignatura_programa_cohorte.dart';
import '../models/asignatura_programa_cohorte_detalle.dart';

class HorariosService {
  static const String _baseUrl = 'http://ms-horarios:8005/';
  
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ... existing code ...

  static Future<List<Map<String, dynamic>>> getAsignaturasProgramas() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}programas/asignaturas_programas/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Error al cargar las asignaturas-programas');
    }
  }

  static Future<Map<String, dynamic>> createAsignaturaPrograma(int asignaturaId, int programaId) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}programas/asignar_asignatura'),
      headers: _headers,
      body: json.encode({
        'asignatura_id': asignaturaId,
        'programa_id': programaId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al crear la asignación asignatura-programa');
    }
  }

  static Future<AsignaturaProgramaCohorteDetalle> createAsignaturaProgramaCohorteDetalle(AsignaturaProgramaCohorteDetalle detalle) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}asignaturas_programas_cohortes_detalles'),
      headers: _headers,
      body: json.encode(detalle.toJson()),
    );

    if (response.statusCode == 200) {
      return AsignaturaProgramaCohorteDetalle.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear el detalle de asignatura-programa-cohorte');
    }
  }

  // ... rest of existing code ...
}