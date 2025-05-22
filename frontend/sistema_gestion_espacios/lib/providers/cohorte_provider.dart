import 'package:flutter/foundation.dart';
import '../models/cohorte.dart';
import '../services/cohortes_service.dart';

class CohorteProvider with ChangeNotifier {
  List<Cohorte> _cohortes = [];
  bool _isLoading = false;
  String? _error;

  List<Cohorte> get cohortes => _cohortes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCohortes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cohortes = await CohorteService.getCohortes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCohorte(Cohorte cohorte) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaCohorte = await CohorteService.createCohorte(cohorte);
      _cohortes.add(nuevaCohorte);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCohorte(int id, Cohorte cohorte) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cohorteActualizada = await CohorteService.updateCohorte(id, cohorte);
      final index = _cohortes.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cohortes[index] = cohorteActualizada;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCohorte(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CohorteService.deleteCohorte(id);
      _cohortes.removeWhere((c) => c.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 