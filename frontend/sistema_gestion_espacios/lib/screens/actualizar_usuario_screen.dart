import 'package:flutter/material.dart';

class ActualizarUsuarioScreen extends StatelessWidget {
  const ActualizarUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar usuario'),
      ),
      body: const Center(
        child: Text(
          'Aquí irá el formulario para actualizar usuario',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 