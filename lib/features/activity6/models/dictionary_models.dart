/// Define los modelos de datos para el diccionario.

class SemanticDomain {
  final int id;
  final String name;
  final String imagePath;

  SemanticDomain({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  // Método para convertir un mapa (de JSON o DB) a un objeto SemanticDomain
  factory SemanticDomain.fromMap(Map<String, dynamic> map) {
    return SemanticDomain(
      id: map['id'] as int,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
    );
  }

  // Método para convertir un objeto SemanticDomain a un mapa (para insertar en DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
    };
  }

  @override
  String toString() => 'SemanticDomain(id: $id, name: $name, imagePath: $imagePath)';
}

class DictionaryEntry {
  final int id;
  final int domainId; // Clave foránea para SemanticDomain
  final String name;
  final String translation;
  final String audioPath;
  final String imagePath;

  DictionaryEntry({
    required this.id,
    required this.domainId,
    required this.name,
    required this.translation,
    required this.audioPath,
    required this.imagePath,
  });

  // Método para convertir un mapa (de JSON o DB) a un objeto DictionaryEntry
  factory DictionaryEntry.fromMap(Map<String, dynamic> map) {
    return DictionaryEntry(
      id: map['id'] as int,
      domainId: map['domainId'] as int,
      name: map['name'] as String,
      translation: map['translation'] as String,
      audioPath: map['audioPath'] as String,
      imagePath: map['imagePath'] as String,
    );
  }

   // Método para convertir un objeto DictionaryEntry a un mapa (para insertar en DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'domainId': domainId,
      'name': name,
      'translation': translation,
      'audioPath': audioPath,
      'imagePath': imagePath,
    };
  }

  @override
  String toString() =>
      'DictionaryEntry(id: $id, domainId: $domainId, name: $name, translation: $translation, audioPath: $audioPath, imagePath: $imagePath)';
}
