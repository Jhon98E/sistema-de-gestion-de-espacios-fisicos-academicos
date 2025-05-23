import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import 'package:flutter/material.dart';

class AuthService {
  static const String baseUrl = 'http://ms-usuarios:8000';
  static const String registerEndpoint = '/usuarios/crear-usuario';
  static const String loginEndpoint = '/auth/login';

  Future<Map<String, dynamic>> register(Usuario usuario) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuario.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error en el registro: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
          'grant_type': 'password',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error en el login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> getUsuarioActual(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/validate-token'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // El backend retorna los datos bajo ciertas claves, adaptamos a Usuario
      return {
        'id': data['user_id'],
        'nombre': data['nombre_completo']?.split(' ')?.first ?? '',
        'apellido': data['nombre_completo']?.split(' ')?.skip(1)?.join(' ') ?? '',
        'codigo_usuario': data['codigo_usuario'],
        'rol': data['rol'],
        'email': data['email'],
        'password': '',
      };
    } else {
      throw Exception('Token inválido');
    }
  }

  Future<Map<String, dynamic>> updateUsuario(Usuario usuario, String token) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode(usuario.toJson(includePassword: usuario.password.isNotEmpty));
    print('DEBUG updateUsuario headers: ' + headers.toString());
    print('DEBUG updateUsuario body: ' + body);
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/actualizar-usuario/${usuario.id}'),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar usuario: ${response.body}');
    }
  }
} 