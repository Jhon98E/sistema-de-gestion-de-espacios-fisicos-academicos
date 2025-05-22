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
      await loadAsignaturasAndProgramasForNames();
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
      await loadAsignaturasAndProgramasForNames();
    } catch (e) {
      _error = e.toString();
      print('Error loading asignaturas programas: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAsignaturasAndProgramasForNames() async {
    try {
      // ** IMPORTANTE: Esta parte requiere acceso a AsignaturaProvider y ProgramaProvider **
      // Como no tengo acceso directo aquí, esta lógica es conceptual.
      // Deberías asegurarte de que AsignaturaProvider y ProgramaProvider
      // estén cargados antes de llamar a este método y acceder a sus listas.

      // Ejemplo conceptual:
      // final asignaturaProvider = ... get AsignaturaProvider ...;
      // final programaProvider = ... get ProgramaProvider ...;
      // final todasAsignaturas = asignaturaProvider.asignaturas;
      // final todosProgramas = programaProvider.programas;

      // Para este ejemplo, modificaré AsignaturaPrograma para incluir los nombres si están disponibles
      // basándome en la estructura actual, asumiendo que los nombres vienen del backend
      // en la respuesta inicial o que se pueden obtener de las listas completas cargadas previamente.
      // Si los nombres *no* vienen del backend en la respuesta de getAsignaturasProgramas,
      // la lógica para obtenerlos y asignarlos a cada objeto AsignaturaPrograma sería más compleja.

      // Revertimos a la lógica original ya que parece que los nombres deberían venir con AsignaturaPrograma
      // y el problema es que el backend no los está enviando o el mapeo es incorrecto.
      // La modificación anterior asume que necesitas cargar las listas completas para obtener los nombres,
      // lo cual sería ineficiente si el endpoint ya debería incluirlos.

      // Vamos a asumir que el endpoint getAsignaturasProgramas() *debería* retornar 'nombre_asignatura' y 'nombre_programa'.
      // El problema puede ser en la deserialización o en la respuesta del backend.
      // Revertiré los cambios en loadProgramas/loadAsignaturasProgramas a su estado original
      // y me centraré en asegurar que el modelo AsignaturaPrograma maneje correctamente los campos.

      // Código original para loadAsignaturasProgramas (mantener como estaba):
      // _asignaturasProgramas = await ProgramaService.getAsignaturasProgramas();

    } catch (e) {
      // Manejar error si la carga de asignaturas/programas falla aquí también
      print('Error getting names for AsignaturaPrograma: $e');
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