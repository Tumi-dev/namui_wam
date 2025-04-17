// lib/features/activity6/models/semantic_domain.dart
class SemanticDomain {
  final int id;
  final String name;
  final String imagePath; // Assuming imagePath is required

  SemanticDomain({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  // Convert a SemanticDomain into a Map. The keys must correspond to the names of the
  // columns in the database table.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
    };
  }

  // Optional: Implement a method to create a SemanticDomain from a Map
  factory SemanticDomain.fromMap(Map<String, dynamic> map) {
    return SemanticDomain(
      id: map['id'] as int,
      name: map['name'] as String,
      imagePath: map['imagePath'] as String,
    );
  }

  @override
  String toString() => 'SemanticDomain(id: $id, name: $name, imagePath: $imagePath)';
}
