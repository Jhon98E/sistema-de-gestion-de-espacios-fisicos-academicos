import 'package:flutter/material.dart';

class AppTheme {
  // Colores base
  static const Color primaryColor = Color(0xFF1565C0); // Azul más oscuro
  static const Color secondaryColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFFFF4081);

  // Colores de texto consistentes
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textLightColor = Color(0xFFBDBDBD);

  // Tema base por defecto
  static final ThemeData defaultTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
      titleLarge: TextStyle(color: textPrimaryColor),
      titleMedium: TextStyle(color: textPrimaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
    ),
  );

  // Temas por sección
  static final ThemeData salonesTheme = ThemeData(
    primaryColor: const Color(0xFF4CAF50), // Verde
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      primary: const Color(0xFF4CAF50),
      secondary: const Color(0xFF81C784),
      tertiary: const Color(0xFF2E7D32),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
      titleLarge: TextStyle(color: textPrimaryColor),
      titleMedium: TextStyle(color: textPrimaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF81C784),
    ),
  );

  static final ThemeData asignaturasTheme = ThemeData(
    primaryColor: const Color(0xFF9C27B0), // Púrpura
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9C27B0),
      primary: const Color(0xFF9C27B0),
      secondary: const Color(0xFFBA68C8),
      tertiary: const Color(0xFF6A1B9A),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
      titleLarge: TextStyle(color: textPrimaryColor),
      titleMedium: TextStyle(color: textPrimaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFBA68C8),
    ),
  );

  static final ThemeData horariosTheme = ThemeData(
    primaryColor: const Color(0xFFFF9800), // Naranja
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9800),
      primary: const Color(0xFFFF9800),
      secondary: const Color(0xFFFFB74D),
      tertiary: const Color(0xFFE65100),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
      titleLarge: TextStyle(color: textPrimaryColor),
      titleMedium: TextStyle(color: textPrimaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFB74D),
    ),
  );

  static final ThemeData usuariosTheme = ThemeData(
    primaryColor: const Color(0xFFE91E63), // Rosa
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE91E63),
      primary: const Color(0xFFE91E63),
      secondary: const Color(0xFFF48FB1),
      tertiary: const Color(0xFFC2185B),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
      titleLarge: TextStyle(color: textPrimaryColor),
      titleMedium: TextStyle(color: textPrimaryColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFF48FB1),
    ),
  );

  // Estilos comunes
  static final cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: accentColor),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
} 