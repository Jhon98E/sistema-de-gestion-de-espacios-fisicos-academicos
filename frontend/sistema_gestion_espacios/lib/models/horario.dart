class Horario {
  final int? id;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final String jornada;

  Horario({
    this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.jornada,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'],
      diaSemana: json['dia_semana'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      jornada: json['jornada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'jornada': jornada,
    };
  }
} 