import 'package:flutter/foundation.dart';

class Cohorte {
  final int? id;
  final String nombre;
  final int programaId;
  final String fechaInicio; // Consider using DateTime if needed for frontend logic
  final String fechaFin; // Consider using DateTime
  final String estado;

  Cohorte({
    this.id,
    required this.nombre,
    required this.programaId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
  });

  factory Cohorte.fromJson(Map<String, dynamic> json) {
    return Cohorte(
      id: json['id'],
      nombre: json['nombre'],
      programaId: json['programa_id'],
      fechaInicio: json['fecha_inicio'],
      fechaFin: json['fecha_fin'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'nombre': nombre,
      'programa_id': programaId,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'estado': estado,
    };
  }
} 