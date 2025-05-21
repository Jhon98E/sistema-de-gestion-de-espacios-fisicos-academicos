import 'package:flutter/material.dart';
import '../../widgets/auth/register_form.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFEAEF),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // SVG con círculo azul
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF457B9D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 40),
              const Text(
                'Sistema de Espacios Físicos',
                style: TextStyle(
                  color: Color(0xFF1D3557),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Cree una cuenta para registrarse',
                style: TextStyle(
                  color: Color(0xFF5D7A89),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              const RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}
