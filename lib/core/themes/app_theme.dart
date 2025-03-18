import 'package:flutter/material.dart';

// Clase para definir los temas de la aplicación
class AppTheme {
  // Constructor privado para evitar instancias de la clase
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
      // Define el estilo de texto para la aplicación
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
      // Define el tema de los botones elevados para la aplicación
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

  // Define un gradiente principal para la aplicación que se usa en los temas
  static LinearGradient get mainGradient {
    return const LinearGradient(
      // Inicio del gradiente en la esquina inferior izquierda
      begin: Alignment.bottomLeft,
      // Fin del gradiente en la esquina superior derecha
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0D47A1), // Azul oscuro
        Color(0xFF1976D2), // Azul medio
        Color(0xFF64B5F6), // Azul claro
      ],
    );
  }

  // Estilos de texto constantes para botones de la aplicación
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );

  // Estilo para el número de nivel de la aplicación
  static const TextStyle levelNumberStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Estilo para la descripción de niveles de la aplicación
  static const TextStyle levelDescriptionStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );

  // Estilo para títulos de niveles de la aplicación
  static const TextStyle levelTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // Estilo para la descripción del juego en cada nivel de la aplicación
  static const TextStyle gameDescriptionStyle = TextStyle(
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Decoración para la descripción del juego en cada nivel de la aplicación
  static BoxDecoration gameDescriptionDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      color: Colors.white24,
      width: 1,
    ),
  );

  // Constantes para iconos de la aplicación
  static const double arrowIconSize = 20.0; 
  // Icono para la página de avance de la aplicación
  static const Icon levelArrowIcon = Icon(
    Icons.arrow_forward,
    color: Colors.white,
    size: arrowIconSize,
  );

  // Icono para la página de inicio de la aplicación
  static const Icon homeIcon = Icon(
    Icons.home_sharp,
    color: Colors.white,
    size: 24.0,
  );

  // Icono para la página de retroceso de la aplicación
  static const Icon backArrowIcon = Icon(
    Icons.arrow_back,
    color: Colors.white,
    size: 24.0,
  );

  // Estilo para títulos de actividades de la aplicación
  static const TextStyle activityTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}