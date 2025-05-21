// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/auth/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Espacios Físicos',
      debugShowCheckedModeBanner: false,
      home: const LoginView(),
    );
  }
}
