// lib/features/activity6/models/semantic_domain.dart

/// Representa un dominio semántico utilizado para categorizar las entradas del diccionario en la Actividad 6.
///
/// Cada dominio tiene un ID único, un nombre y una imagen asociada.
class SemanticDomain {
  /// Identificador único para el dominio semántico.
  final int id;

  /// El nombre del dominio semántico (p. ej., "Animales", "Frutas").
  final String name;

  /// Ruta al recurso de imagen que representa este dominio.
  final String imagePath; // Asumiendo que imagePath es requerido

  /// Crea una instancia de [SemanticDomain].
  SemanticDomain({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  /// Convierte esta instancia de [SemanticDomain] en un Map.
  ///
  /// Las claves corresponden a los nombres de las columnas de la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
    };
  }

  /// Crea una instancia de [SemanticDomain] a partir de un Map (p. ej., de una consulta de base de datos).
  factory SemanticDomain.fromMap(Map<String, dynamic> map) {
    return SemanticDomain(
      id: map['id'] as int,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
    );
  }

  /// Devuelve una representación en cadena de la instancia [SemanticDomain].
  @override
  String toString() => 'SemanticDomain(id: $id, name: $name, imagePath: $imagePath)';
}
