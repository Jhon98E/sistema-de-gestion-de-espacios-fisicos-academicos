import 'package:flutter/foundation.dart';
import '../models/horario.dart';
import '../models/asignatura_programa_cohorte.dart';
import '../models/asignatura_programa_cohorte_detalle.dart';
import '../services/horarios_service.dart';

class HorarioProvider with ChangeNotifier {
  List<Horario> _horarios = [];
  List<AsignaturaProgramaCohorte> _asignaturasProgramasCohortes = [];
  List<AsignaturaProgramaCohorteDetalle> _asignaturasProgramasCohortesDetalles = [];
  bool _isLoading = false;
  String? _error;

  List<Horario> get horarios => _horarios;
  List<AsignaturaProgramaCohorte> get asignaturasProgramasCohortes => _asignaturasProgramasCohortes;
  List<AsignaturaProgramaCohorteDetalle> get asignaturasProgramasCohortesDetalles => _asignaturasProgramasCohortesDetalles;
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

  Future<void> createHorario(Horario horario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevoHorario = await HorariosService.createHorario(horario);
      _horarios.add(nuevoHorario);
    } catch (e) {
      _error = e.toString();
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

  Future<void> createAsignaturaProgramaCohorte(AsignaturaProgramaCohorte asignaturaProgramaCohorte) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaAsignacion = await HorariosService.createAsignaturaProgramaCohorte(asignaturaProgramaCohorte);
      _asignaturasProgramasCohortes.add(nuevaAsignacion);
    } catch (e) {
      _error = e.toString();
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
      _asignaturasProgramasCohortesDetalles = await HorariosService.getAsignaturasProgramasCohortesDetalles();
    } catch (e) {
      _error = e.toString();
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
      final nuevoDetalle = await HorariosService.createAsignaturaProgramaCohorteDetalle(detalle);
      _asignaturasProgramasCohortesDetalles.add(nuevoDetalle);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAsignaturaProgramaCohorteDetalle(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await HorariosService.deleteAsignaturaProgramaCohorteDetalle(id);
      _asignaturasProgramasCohortesDetalles.removeWhere((d) => d.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 