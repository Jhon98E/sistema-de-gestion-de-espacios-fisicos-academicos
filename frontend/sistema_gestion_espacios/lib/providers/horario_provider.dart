import 'package:flutter/foundation.dart';
import '../models/horario.dart';
import '../models/asignatura_programa_cohorte.dart';
import '../models/asignatura_programa_cohorte_detalle.dart';
import '../services/horarios_service.dart';

class HorarioProvider with ChangeNotifier {
  List<Horario> _horarios = [];
  List<AsignaturaProgramaCohorte> _asignaturasProgramasCohortes = [];
  List<Map<String, dynamic>> _asignaturasProgramas = [];
  bool _isLoading = false;
  String? _error;

  List<Horario> get horarios => _horarios;
  List<AsignaturaProgramaCohorte> get asignaturasProgramasCohortes => _asignaturasProgramasCohortes;
  List<Map<String, dynamic>> get asignaturasProgramas => _asignaturasProgramas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHorarios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _horarios = await HorariosService.getHorarios();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Horario> createHorario(Horario horario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevoHorario = await HorariosService.createHorario(horario);
      _horarios.add(nuevoHorario);
      return nuevoHorario;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHorario(int id, Horario horario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final horarioActualizado = await HorariosService.updateHorario(id, horario);
      final index = _horarios.indexWhere((h) => h.id == id);
      if (index != -1) {
        _horarios[index] = horarioActualizado;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHorario(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await HorariosService.deleteHorario(id);
      _horarios.removeWhere((h) => h.id == id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAsignaturasProgramasCohortes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _asignaturasProgramasCohortes = await HorariosService.getAsignaturasProgramasCohortes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAsignaturasProgramasCohortesDetalles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _asignaturasProgramasCohortes = await HorariosService.getAsignaturasProgramasCohortes();
      // Aquí podríamos agregar lógica adicional para cargar más detalles si es necesario
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAsignaturasProgramas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Traer la lista de asignaturas-programas (solo ids)
      final asignaturasProgramas = await HorariosService.getAsignaturasProgramas();
      // 2. Traer la lista de programas
      final programas = await HorariosService.getProgramas();
      // 3. Traer la lista de asignaturas
      final asignaturas = await HorariosService.getAsignaturas();

      // 4. Unir los datos
      _asignaturasProgramas = asignaturasProgramas.map((ap) {
        final programa = programas.firstWhere(
          (p) => p['id'] == ap['programa_id'],
          orElse: () => {'nombre': 'Desconocido'},
        );
        final asignatura = asignaturas.firstWhere(
          (a) => a['id'] == ap['asignatura_id'],
          orElse: () => {'nombre': 'Desconocida'},
        );
        return {
          'id': ap['id'],
          'asignatura_id': ap['asignatura_id'],
          'programa_id': ap['programa_id'],
          'asignatura_nombre': asignatura['nombre'],
          'programa_nombre': programa['nombre'],
        };
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createAsignaturaPrograma(int asignaturaId, int programaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaAsignacion = await HorariosService.createAsignaturaPrograma(asignaturaId, programaId);
      _asignaturasProgramas.add(nuevaAsignacion);
      return nuevaAsignacion;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AsignaturaProgramaCohorte> createAsignaturaProgramaCohorte(AsignaturaProgramaCohorte asignaturaProgramaCohorte) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaAsignacion = await HorariosService.createAsignaturaProgramaCohorte(asignaturaProgramaCohorte);
      _asignaturasProgramasCohortes.add(nuevaAsignacion);
      return nuevaAsignacion;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAsignaturaProgramaCohorteDetalle(AsignaturaProgramaCohorteDetalle detalle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await HorariosService.createAsignaturaProgramaCohorteDetalle(detalle);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAsignaturaProgramaCohorte(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await HorariosService.deleteAsignaturaProgramaCohorte(id);
      _asignaturasProgramasCohortes.removeWhere((apc) => apc.id == id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 