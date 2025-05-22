class AsignaturaProgramaCohorte {
  final int? id;
  final int asignaturaProgramaId;
  final int salonId;
  final int horarioId;
  final String fechaInicio;
  final String fechaFin;

  AsignaturaProgramaCohorte({
    this.id,
    required this.asignaturaProgramaId,
    required this.salonId,
    required this.horarioId,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory AsignaturaProgramaCohorte.fromJson(Map<String, dynamic> json) {
    return AsignaturaProgramaCohorte(
      id: json['id'],
      asignaturaProgramaId: json['asignatura_programa_id'],
      salonId: json['salon_id'],
      horarioId: json['horario_id'],
      fechaInicio: json['fecha_inicio'],
      fechaFin: json['fecha_fin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asignatura_programa_id': asignaturaProgramaId,
      'salon_id': salonId,
      'horario_id': horarioId,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
    };
  }
} 