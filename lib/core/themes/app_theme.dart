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

  // Estilos de texto constantes para botones
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle levelNumberStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle levelDescriptionStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );

  // Estilo para títulos de niveles
  static const TextStyle levelTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // Estilo para la descripción del juego en cada nivel
  static const TextStyle gameDescriptionStyle = TextStyle(
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static BoxDecoration gameDescriptionDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      color: Colors.white24,
      width: 1,
    ),
  );

  // Constantes para iconos
  static const double arrowIconSize = 20.0;
  static const Icon levelArrowIcon = Icon(
    Icons.arrow_forward,
    color: Colors.white70,
    size: arrowIconSize,
  );

  static const Icon homeIcon = Icon(
    Icons.home_sharp,
    color: Colors.white,
    size: 24.0,
  );

  static const Icon backArrowIcon = Icon(
    Icons.arrow_back,
    color: Colors.white,
    size: 24.0,
  );

  // Estilo para títulos de actividades
  static const TextStyle activityTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}