import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Define los colores principales de la aplicación
      primaryColor: Colors.blue,
      // Define el color de fondo de la aplicación
      scaffoldBackgroundColor: Colors.white,
      // Define el esquema de colores de la aplicación
      colorScheme: const ColorScheme.light(
        // Define el color primario de la aplicación
        primary: Colors.blue,
        // Define el color secundario de la aplicación
        secondary: Color(0xFF64B5F6),
        // Define el color de fondo de la aplicación
        background: Colors.white,
      ),
      textTheme: const TextTheme(
        // Define el estilo de texto para los encabezados grandes
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        // Define el estilo de texto para los encabezados medianos
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
      // Define el tema de los botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // Define un gradiente principal para la aplicación
  static LinearGradient get mainGradient {
    return const LinearGradient(
      // begin: Alignment.topLeft,
      begin: Alignment.topLeft,
      // end: Alignment.bottomRight,
      end:Alignment.topRight,
      colors: [
        Color(0xFF0D47A1), // Azul oscuro
        Color(0xFF1976D2), // Azul medio
        Color(0xFF64B5F6), // Azul claro
      ],
    );
  }
}