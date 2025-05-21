import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/auth/login_form.dart';
import 'register_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.33; // aproximadamente un tercio

    return Scaffold(
      backgroundColor: const Color(0xFFDFEAEF), // azul clarito
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Círculo con ícono SVG
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF457B9D), // círculo azul más oscuro
                ),
                child: SvgPicture.string(
                  '''
                  <svg width="50" height="50" viewBox="0 0 25 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M14.5 22V18C14.5 17.4696 14.2893 16.9609 13.9142 16.5858C13.5391 16.2107 13.0304 16 12.5 16C11.9696 16 11.4609 16.2107 11.0858 16.5858C10.7107 16.9609 10.5 17.4696 10.5 18V22" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M18.5 10L22.5 12V20C22.5 20.5304 22.2893 21.0391 21.9142 21.4142C21.5391 21.7893 21.0304 22 20.5 22H4.5C3.96957 22 3.46086 21.7893 3.08579 21.4142C2.71071 21.0391 2.5 20.5304 2.5 20V12L6.5 10" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M18.5 5V22" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M4.5 6L12.5 2L20.5 6" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M6.5 5V22" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M12.5 11C13.6046 11 14.5 10.1046 14.5 9C14.5 7.89543 13.6046 7 12.5 7C11.3954 7 10.5 7.89543 10.5 9C10.5 10.1046 11.3954 11 12.5 11Z" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  ''',
                  height: 50,
                ),
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
                'Ingrese sus credenciales para acceder al sistema',
                style: TextStyle(
                  color: Color(0xFF5D7A89),
                  fontSize: 14,
                  fontWeight: FontWeight.w600, // Cambiado a bold
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
                        children: [
                          LoginForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterView()),
                  );
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
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
