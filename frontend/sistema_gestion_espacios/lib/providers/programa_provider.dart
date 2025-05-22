import 'package:flutter/foundation.dart';
import '../models/programa.dart';
import '../models/asignatura_programa.dart';
import '../models/asignatura.dart';
import '../services/programas_service.dart';

// Importar los modelos Asignatura y Programa completos para acceder a sus nombres
import '../models/asignatura.dart';
import '../models/programa.dart';

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
      // Aquí solo cargamos las AsignaturaPrograma sin nombres aún
      _asignaturasProgramas = await ProgramaService.getAsignaturasProgramas();
      // La lógica de poblar nombres se hará cuando se necesite, quizás en la UI o en un método específico si se mantiene aquí.
      // O, modificar loadAsignaturasProgramas para que reciba las listas completas.

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Modificar este método para que reciba las listas completas de asignaturas y programas
  Future<void> loadAsignaturasProgramas(List<Asignatura> todasAsignaturas, List<Programa> todosProgramas) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fetchedAsignaturasProgramas = await ProgramaService.getAsignaturasProgramas();

      // Ahora, enriquecer cada AsignaturaPrograma con los nombres
      _asignaturasProgramas = fetchedAsignaturasProgramas.map((ap) {
        final asignatura = todasAsignaturas.firstWhere(
          (a) => a.id == ap.asignaturaId,
          orElse: () => Asignatura(id: ap.asignaturaId, nombre: 'Desconocida', codigoAsignatura: ''), // Fallback
        );
        final programa = todosProgramas.firstWhere(
          (p) => p.id == ap.programaId,
          orElse: () => Programa(id: ap.programaId, nombre: 'Desconocido', descripcion: '', codigoPrograma: ''), // Fallback
        );
        
        // Crear una nueva instancia con los nombres poblados
        return AsignaturaPrograma(
          id: ap.id,
          asignaturaId: ap.asignaturaId,
          programaId: ap.programaId,
          nombreAsignatura: asignatura.nombre,
          nombrePrograma: programa.nombre,
        );
      }).toList();

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