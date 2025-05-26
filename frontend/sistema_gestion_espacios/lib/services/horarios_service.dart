import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/horario.dart';
import '../models/asignatura_programa_cohorte.dart';
import '../models/asignatura_programa_cohorte_detalle.dart';

class HorariosService {
  static const String _baseUrl = 'http://ms-horarios:8005/';
  static const String _programasUrl = 'http://ms-programas:8001/';
  
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

  static Future<List<AsignaturaProgramaCohorte>> getAsignaturasProgramasCohortes() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}asignaturas_programas_cohortes'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AsignaturaProgramaCohorte.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las asignaturas-programas-cohortes');
    }
  }

  static Future<AsignaturaProgramaCohorte> createAsignaturaProgramaCohorte(AsignaturaProgramaCohorte asignaturaProgramaCohorte) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}asignaturas_programas_cohortes'),
      headers: _headers,
      body: json.encode(asignaturaProgramaCohorte.toJson()),
    );

    if (response.statusCode == 200) {
      return AsignaturaProgramaCohorte.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear la asignatura-programa-cohorte');
    }
  }

  static Future<AsignaturaProgramaCohorte> getAsignaturaProgramaCohorteById(int id) async {
    final response = await http.get(
      Uri.parse('${_baseUrl}asignaturas_programas_cohortes/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return AsignaturaProgramaCohorte.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar la asignatura-programa-cohorte');
    }
  }

  static Future<void> deleteAsignaturaProgramaCohorte(int id) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}asignaturas_programas_cohortes/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la asignatura-programa-cohorte');
    }
  }

  static Future<List<AsignaturaProgramaCohorteDetalle>> getAsignaturasProgramasCohortesDetalles() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}asignaturas_programas_cohortes_detalles'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AsignaturaProgramaCohorteDetalle.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los detalles de asignaturas-programas-cohortes');
    }
  }

  static Future<List<Map<String, dynamic>>> getAsignaturasProgramas() async {
    final response = await http.get(
      Uri.parse('${_programasUrl}programas/asignaturas_programas/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Error al cargar las asignaturas-programas: ${response.statusCode}');
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
    print('DEBUG detalle.asignaturaProgramaCohorteId: ${detalle.asignaturaProgramaCohorteId}');
    print('DEBUG detalle.cohorteId: ${detalle.cohorteId}');
    final url = Uri.parse('${_baseUrl}asignaturas_programas_cohortes_detalles')
        .replace(queryParameters: {
          'asignatura_programa_cohorte_id': detalle.asignaturaProgramaCohorteId.toString(),
          'cohorte_id': detalle.cohorteId.toString(),
        });
    final response = await http.post(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return detalle;
    } else {
      throw Exception('Error al crear el detalle de asignatura-programa-cohorte');
    }
  }

  static Future<List<Map<String, dynamic>>> getProgramas() async {
    final response = await http.get(
      Uri.parse('${_programasUrl}programas/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Error al cargar los programas: \\${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAsignaturas() async {
    final response = await http.get(
      Uri.parse('http://ms-asignaturas:8002/asignatura/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => json as Map<String, dynamic>).toList();
    } else {
      throw Exception('Error al cargar las asignaturas: \\${response.statusCode}');
    }
  }
} 