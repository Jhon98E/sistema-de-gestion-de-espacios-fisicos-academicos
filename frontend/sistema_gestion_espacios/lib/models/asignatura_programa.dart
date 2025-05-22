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
    // Extraemos los nombres de los objetos anidados 'asignatura' y 'programa'
    final asignaturaNombre = json['asignatura'] != null ? json['asignatura']['nombre'] : null;
    final programaNombre = json['programa'] != null ? json['programa']['nombre'] : null;

    return AsignaturaPrograma(
      id: json['id'],
      asignaturaId: json['asignatura_id'] is int ? json['asignatura_id'] : (json['asignatura_id'] != null ? int.tryParse(json['asignatura_id'].toString()) : 0), // Manejo flexible del tipo
      programaId: json['programa_id'] is int ? json['programa_id'] : (json['programa_id'] != null ? int.tryParse(json['programa_id'].toString()) : 0),     // Manejo flexible del tipo
      nombreAsignatura: asignaturaNombre, // Usamos el nombre extraído
      nombrePrograma: programaNombre,     // Usamos el nombre extraído
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asignatura_id': asignaturaId,
      'programa_id': programaId,
    };
  }
} 