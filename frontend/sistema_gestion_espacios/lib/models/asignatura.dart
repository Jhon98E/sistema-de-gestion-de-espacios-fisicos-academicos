class Asignatura {
  final int? id;
  final String nombre;
  final String codigoAsignatura;

  Asignatura({
    this.id,
    required this.nombre,
    required this.codigoAsignatura,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'nombre': nombre,
      'codigo_asignatura': codigoAsignatura,
    };
  }

  factory Asignatura.fromJson(Map<String, dynamic> json) {
    return Asignatura(
      id: json['id'],
      nombre: json['nombre'],
      codigoAsignatura: json['codigo_asignatura'],
    );
  }

  Asignatura copyWith({
    int? id,
    String? nombre,
    String? codigoAsignatura,
  }) {
    return Asignatura(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigoAsignatura: codigoAsignatura ?? this.codigoAsignatura,
    );
  }
} 