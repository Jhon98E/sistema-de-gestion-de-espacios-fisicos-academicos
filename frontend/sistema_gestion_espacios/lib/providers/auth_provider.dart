import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _error;
  String? _token;
  Usuario? _usuarioActual;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  Usuario? get usuarioActual => _usuarioActual;

  Future<bool> register(Usuario usuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(usuario);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);
      _token = response['access_token'];
      await _storage.write(key: 'token', value: _token);
      await fetchUsuarioActual();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUsuarioActual() async {
    if (_token == null) return;
    try {
      final usuarioJson = await _authService.getUsuarioActual(_token!);
      _usuarioActual = Usuario.fromJson(usuarioJson);
      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    _token = null;
    _usuarioActual = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _token = await _storage.read(key: 'token');
    if (_token != null) {
      await fetchUsuarioActual();
    }
    notifyListeners();
  }

  Future<bool> actualizarUsuario(Usuario usuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final usuarioJson = await _authService.updateUsuario(usuario, _token!);
      _usuarioActual = Usuario.fromJson(usuarioJson);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
} 