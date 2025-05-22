class Programa {
  final int? id;
  final String nombre;
  final String descripcion;
  final String codigoPrograma;

  Programa({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.codigoPrograma,
  });

  factory Programa.fromJson(Map<String, dynamic> json) {
    return Programa(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      codigoPrograma: json['codigo_programa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo_programa': codigoPrograma,
    };
  }
} 