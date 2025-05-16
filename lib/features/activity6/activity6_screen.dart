import 'package:flutter/material.dart';
import 'package:namuiwam/core/themes/app_theme.dart';
import 'package:namuiwam/features/activity6/screens/dictionary_domain_screen.dart';

/// {@template activity6_screen}
/// Pantalla principal para la Actividad 6: "Wammeran tulisha manchípik kui asamik pөrik (Diccionario)"
///
/// Implementa una herramienta de diccionario bilingüe Namtrik-Español que permite a los usuarios:
/// - Explorar categorías semánticas (animales, colores, partes del cuerpo, etc.)
/// - Acceder a términos individuales con su traducción
/// - Ver representaciones visuales de los términos
/// - Escuchar la pronunciación correcta en Namtrik
///
/// Esta pantalla actúa como contenedor principal configurando:
/// - La barra de navegación (AppBar) con título representativo
/// - El fondo con gradiente estándar de la aplicación
/// - La estructura base de la interfaz
///
/// Delega la visualización del contenido principal (cuadrícula de dominios semánticos)
/// al componente especializado [DictionaryDomainScreen].
///
/// Ejemplo de navegación a esta pantalla:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const Activity6Screen(),
///   ),
/// );
/// ```
/// {@endtemplate}
class Activity6Screen extends StatelessWidget {
  /// {@macro activity6_screen}
  const Activity6Screen({super.key});

  /// Navega hacia la pantalla de inicio de la aplicación.
  ///
  /// Implementa la navegación desde cualquier nivel del diccionario
  /// directamente a la página inicial de la aplicación, ignorando cualquier
  /// pantalla intermedia que pueda existir en la pila de navegación.
  ///
  /// Este método se invoca cuando el usuario presiona el botón de inicio (Home)
  /// en la barra de navegación, permitiendo salir rápidamente de la actividad.
  ///
  /// [context] El contexto de construcción para la navegación.
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Construye la interfaz de usuario de la pantalla principal del diccionario.
  ///
  /// Crea un [Scaffold] con:
  /// - [AppBar] que muestra el título de la actividad y botón de inicio
  /// - Contenedor con el gradiente de fondo común a todas las actividades
  /// - [DictionaryDomainScreen] como widget principal que implementa la funcionalidad
  ///   específica del diccionario
  ///
  /// La interfaz aplica el tema visual consistente con el resto de la aplicación,
  /// pero utiliza sus propios colores temáticos (coral) en los componentes internos.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: AppTheme.homeIcon,
          onPressed: () => _navigateToHome(context),
        ),
        title: const Text(
          'Wammeran tulisha manchípik kui asamik pɵrik',
          style: AppTheme.activityTitleStyle,
        ),
        backgroundColor: Colors.transparent, // Color de fondo transparente de la AppBar
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: DictionaryDomainScreen(),
      ),
    );
  }
}