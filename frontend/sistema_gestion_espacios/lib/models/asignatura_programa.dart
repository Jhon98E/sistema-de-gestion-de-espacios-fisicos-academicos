class AsignaturaPrograma {
  final int? id;
  final int asignaturaId;
  final int programaId;
  final String? nombreAsignatura;
  final String? nombrePrograma;

  AsignaturaPrograma({
    this.id,
    required this.asignaturaId,
    required this.programaId,
    this.nombreAsignatura,
    this.nombrePrograma,
  });

  factory AsignaturaPrograma.fromJson(Map<String, dynamic> json) {
    return AsignaturaPrograma(
      id: json['id'],
      asignaturaId: json['asignatura_id'],
      programaId: json['programa_id'],
      nombreAsignatura: json['nombre_asignatura'],
      nombrePrograma: json['nombre_programa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asignatura_id': asignaturaId,
      'programa_id': programaId,
    };
  }
} 