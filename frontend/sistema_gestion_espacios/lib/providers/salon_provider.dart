import 'package:flutter/foundation.dart';
import '../models/salon.dart'; // Asegúrate de que este archivo exista y contenga la clase Salon
import '../services/salon_service.dart'; // Descomentado

class SalonProvider with ChangeNotifier {
  List<Salon> _salones = [];
  bool _isLoading = false;
  String? _error;

  List<Salon> get salones => _salones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSalones() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ** Implementación real usando SalonService **
      _salones = await SalonService.getSalones();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Puedes añadir métodos para crear, actualizar, eliminar salones aquí si los necesitas
} 