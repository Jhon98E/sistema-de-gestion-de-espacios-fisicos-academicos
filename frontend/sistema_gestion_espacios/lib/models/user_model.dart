class User {
  final int? id;
  final String nombre;
  final String apellido;
  final String codigoUsuario;
  final String rol;
  final String email;
  final String password;

  User({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.codigoUsuario,
    required this.rol,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'codigo_usuario': codigoUsuario,
      'rol': rol,
      'email': email,
      'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      codigoUsuario: json['codigo_usuario'],
      rol: json['rol'],
      email: json['email'],
      password: json['password'],
    );
  }
} 