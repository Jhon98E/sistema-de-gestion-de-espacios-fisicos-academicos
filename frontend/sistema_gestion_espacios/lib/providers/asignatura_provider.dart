import 'package:flutter/foundation.dart';
import '../models/asignatura.dart';
import '../services/asignatura_service.dart';

class AsignaturaProvider with ChangeNotifier {
  final AsignaturaService _asignaturaService = AsignaturaService();
  List<Asignatura> _asignaturas = [];
  bool _isLoading = false;
  String? _error;

  List<Asignatura> get asignaturas => _asignaturas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAsignaturas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _asignaturas = await _asignaturaService.getAsignaturas();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAsignatura(Asignatura asignatura) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaAsignatura = await _asignaturaService.createAsignatura(asignatura);
      _asignaturas.add(nuevaAsignatura);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAsignatura(int id, Asignatura asignatura) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final asignaturaActualizada = await _asignaturaService.updateAsignatura(id, asignatura);
      final index = _asignaturas.indexWhere((a) => a.id == id);
      if (index != -1) {
        _asignaturas[index] = asignaturaActualizada;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAsignatura(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _asignaturaService.deleteAsignatura(id);
      _asignaturas.removeWhere((a) => a.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Asignatura?> getAsignaturaById(int id) async {
    try {
      return await _asignaturaService.getAsignaturaById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
} 