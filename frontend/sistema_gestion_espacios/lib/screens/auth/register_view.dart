import 'package:flutter/material.dart';
import '../../widgets/auth/register_form.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.33; // aproximadamente un tercio

    return Scaffold(
      backgroundColor: const Color(0xFFDFEAEF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Círculo con ícono
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF457B9D),
                ),
                child: const Icon(Icons.school, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 40),
              const Text(
                'Sistema de Espacios Físicos',
                style: TextStyle(
                  color: Color(0xFF1D3557),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
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

              // Card del formulario (centrada y más angosta)
              Center(
                child: SizedBox(
                  width: cardWidth < 350 ? 350 : cardWidth,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: const [
                          RegisterForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
