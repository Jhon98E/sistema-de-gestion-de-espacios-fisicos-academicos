import 'package:flutter/foundation.dart';
import '../models/horario.dart';
import '../services/horarios_service.dart';

class HorarioProvider with ChangeNotifier {
  List<Horario> _horarios = [];
  bool _isLoading = false;
  String? _error;

  List<Horario> get horarios => _horarios;
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
} 