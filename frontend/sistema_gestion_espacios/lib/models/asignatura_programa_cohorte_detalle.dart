class AsignaturaProgramaCohorteDetalle {
  final int? id;
  final int asignaturaProgramaCohorteId;
  final int cohorteId;

  AsignaturaProgramaCohorteDetalle({
    this.id,
    required this.asignaturaProgramaCohorteId,
    required this.cohorteId,
  });

  factory AsignaturaProgramaCohorteDetalle.fromJson(Map<String, dynamic> json) {
    return AsignaturaProgramaCohorteDetalle(
      id: json['id'],
      asignaturaProgramaCohorteId: json['asignatura_programa_cohorte_id'],
      cohorteId: json['cohorte_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asignatura_programa_cohorte_id': asignaturaProgramaCohorteId,
      'cohorte_id': cohorteId,
    };
  }
} 