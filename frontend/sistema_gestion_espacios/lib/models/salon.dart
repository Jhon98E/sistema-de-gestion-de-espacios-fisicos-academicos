class Salon {
  final int? id;
  final String nombre;
  final int capacidad;
  final String tipo;
  final bool disponibilidad;

  Salon({
    this.id,
    required this.nombre,
    required this.capacidad,
    required this.tipo,
    required this.disponibilidad,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'],
      nombre: json['nombre'],
      capacidad: json['capacidad'],
      tipo: json['tipo'],
      disponibilidad: json['disponibilidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'capacidad': capacidad,
      'tipo': tipo,
      'disponibilidad': disponibilidad,
    };
  }

  Salon copyWith({
    int? id,
    String? nombre,
    int? capacidad,
    String? tipo,
    bool? disponibilidad,
  }) {
    return Salon(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      capacidad: capacidad ?? this.capacidad,
      tipo: tipo ?? this.tipo,
      disponibilidad: disponibilidad ?? this.disponibilidad,
    );
  }
} 