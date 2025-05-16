// lib/features/activity6/models/semantic_domain.dart

/// {@template semantic_domain}
/// Representa un dominio semántico dentro del diccionario Namtrik-Español.
///
/// Un dominio semántico es una categoría conceptual que agrupa términos
/// relacionados semánticamente (p. ej., "Animales", "Colores", "Partes del cuerpo").
/// Funciona como un nivel de organización que facilita la navegación y
/// visualización del vocabulario en categorías significativas.
///
/// Cada dominio incluye:
/// - Un identificador único para referencia en la base de datos
/// - Un nombre en Namtrik que se muestra en la interfaz de usuario
/// - Una ruta a un recurso visual representativo
///
/// Ejemplo de uso:
/// ```dart
/// final domain = SemanticDomain(
///   id: 1,
///   name: 'Ushamera',
///   imagePath: 'assets/images/dictionary/ushamera.png',
/// );
/// ```
///
/// Este modelo es utilizado principalmente en:
/// - La pantalla inicial del diccionario para mostrar las categorías disponibles
/// - El filtrado de entradas por dominio en la pantalla de listado
/// - La construcción de rutas a recursos asociados (imágenes/audio)
/// {@endtemplate}
class SemanticDomain {
  /// Identificador único para el dominio semántico.
  ///
  /// Este valor numérico sirve como clave primaria en el sistema de datos
  /// y permite la rápida búsqueda y filtrado de entradas asociadas a este dominio.
  /// Se asigna secuencialmente durante la carga inicial de datos.
  final int id;

  /// El nombre del dominio semántico en Namtrik (p. ej., "Ushamera", "Pisielɵ").
  ///
  /// Este nombre se muestra directamente en la interfaz de usuario como
  /// etiqueta de la categoría. En el contexto de la Actividad 6, representa
  /// una agrupación lingüísticamente significativa en el idioma Namtrik.
  final String name;

  /// Ruta al recurso de imagen que representa visualmente este dominio.
  ///
  /// Apunta a un archivo de imagen (generalmente .png) que proporciona una
  /// representación visual del concepto del dominio. Esta imagen se muestra
  /// en la tarjeta del dominio en la pantalla principal del diccionario.
  ///
  /// El formato esperado es: 'assets/images/dictionary/{nombre_normalizado}.png'
  final String imagePath;

  /// Crea una instancia de [SemanticDomain] con los parámetros requeridos.
  ///
  /// Todos los campos son obligatorios para garantizar la funcionalidad completa
  /// del dominio en la interfaz y la lógica de la aplicación.
  ///
  /// [id] Identificador único del dominio
  /// [name] Nombre del dominio en Namtrik
  /// [imagePath] Ruta completa al recurso de imagen representativa
  SemanticDomain({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  /// Convierte esta instancia de [SemanticDomain] en un Map.
  ///
  /// Este método facilita la serialización del modelo para:
  /// - Almacenamiento persistente
  /// - Transmisión entre componentes
  /// - Depuración y logging
  ///
  /// Las claves del mapa resultante corresponden a los nombres de los campos del modelo.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
    };
  }

  /// Crea una instancia de [SemanticDomain] a partir de un Map.
  ///
  /// Este constructor de fábrica permite la deserialización de un mapa de datos
  /// (típicamente proveniente de JSON o base de datos) en una instancia válida
  /// del modelo. Espera encontrar todas las claves requeridas en el mapa.
  ///
  /// [map] Mapa con datos para construir el dominio
  /// Retorna una nueva instancia de [SemanticDomain]
  factory SemanticDomain.fromMap(Map<String, dynamic> map) {
    return SemanticDomain(
      id: map['id'] as int,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
    );
  }

  /// Devuelve una representación en cadena de la instancia [SemanticDomain].
  ///
  /// Este método facilita la depuración y logging al proporcionar una
  /// representación textual clara del objeto. Incluye todos los campos
  /// relevantes del modelo.
  @override
  String toString() => 'SemanticDomain(id: $id, name: $name, imagePath: $imagePath)';
}
