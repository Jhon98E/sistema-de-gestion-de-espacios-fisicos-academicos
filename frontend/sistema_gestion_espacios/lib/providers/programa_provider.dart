import 'package:flutter/foundation.dart';
import '../models/programa.dart';
import '../models/asignatura_programa.dart';
import '../models/asignatura.dart';
import '../services/programas_service.dart';

class ProgramaProvider with ChangeNotifier {
  List<Programa> _programas = [];
  List<AsignaturaPrograma> _asignaturasProgramas = [];
  bool _isLoading = false;
  String? _error;

  List<Programa> get programas => _programas;
  List<AsignaturaPrograma> get asignaturasProgramas => _asignaturasProgramas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProgramas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _programas = await ProgramaService.getProgramas();
      _asignaturasProgramas = await ProgramaService.getAsignaturasProgramas();
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
      _asignaturasProgramas = await ProgramaService.getAsignaturasProgramas();
    } catch (e) {
      _error = e.toString();
      print('Error loading asignaturas programas: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPrograma(Programa programa) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevoPrograma = await ProgramaService.createPrograma(programa);
      _programas.add(nuevoPrograma);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePrograma(int id, Programa programa) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final programaActualizado = await ProgramaService.updatePrograma(id, programa);
      final index = _programas.indexWhere((p) => p.id == id);
      if (index != -1) {
        _programas[index] = programaActualizado;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePrograma(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ProgramaService.deletePrograma(id);
      _programas.removeWhere((p) => p.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> asignarAsignatura(AsignaturaPrograma asignaturaPrograma) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaAsignacion = await ProgramaService.asignarAsignatura(asignaturaPrograma);
      print('API response for asignarAsignatura: ${nuevaAsignacion.toJson()}');
      _asignaturasProgramas.add(nuevaAsignacion);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAsignaturaPrograma(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ProgramaService.deleteAsignaturaPrograma(id);
      _asignaturasProgramas.removeWhere((ap) => ap.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Programa?> getProgramaById(int id) async {
    try {
      final programa = _programas.firstWhere((programa) => programa.id == id);
      return Future.value(programa);
    } catch (e) {
      print('Programa with id $id not found: $e');
      return Future.value(null);
    }
  }
} 