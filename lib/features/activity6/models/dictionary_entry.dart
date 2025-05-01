import 'dart:convert'; // For jsonEncode/Decode if needed for map<string, string>

class DictionaryEntry {
  final int id;
  final int domainId;
  final String? namtrik; // Main Namtrik term/phrase
  final String? spanish; // Main Spanish translation
  final String? namtrikVariant; // Optional variant (e.g., answer)
  final String? spanishVariant; // Optional variant (e.g., answer)
  final String? imagePath; // Path to image asset, nullable
  final String? audioPath; // Path to main audio asset, nullable
  final String? audioVariantPath; // Path to variant audio asset, nullable
  final Map<String, String>? compositionsSpanish; // Nullable map for compositions

  // Fields specific to 'Saludos' domain
  final String? greetings_ask_namtrik;
  final String? greetings_ask_spanish;
  final String? greetings_answer_namtrik;
  final String? greetings_answer_spanish;
  final String? images_greetings; // Specific image for greetings
  final String? audio_greetings_ask; // Audio for greeting question
  final String? audio_greetings_answer; // Audio for greeting answer

  DictionaryEntry({
    required this.id,
    required this.domainId,
    this.namtrik,
    this.spanish,
    this.namtrikVariant,
    this.spanishVariant,
    this.imagePath,
    this.audioPath,
    this.audioVariantPath,
    this.compositionsSpanish,
    // Add greetings fields to constructor
    this.greetings_ask_namtrik,
    this.greetings_ask_spanish,
    this.greetings_answer_namtrik,
    this.greetings_answer_spanish,
    this.images_greetings,
    this.audio_greetings_ask,
    this.audio_greetings_answer,
  });

  // Convert a DictionaryEntry into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'domainId': domainId,
      'namtrik': namtrik,
      'spanish': spanish,
      'namtrikVariant': namtrikVariant,
      'spanishVariant': spanishVariant,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'audioVariantPath': audioVariantPath,
      'compositionsSpanish': compositionsSpanish != null ? jsonEncode(compositionsSpanish) : null,
      // Add greetings fields to map
      'greetings_ask_namtrik': greetings_ask_namtrik,
      'greetings_ask_spanish': greetings_ask_spanish,
      'greetings_answer_namtrik': greetings_answer_namtrik,
      'greetings_answer_spanish': greetings_answer_spanish,
      'images_greetings': images_greetings,
      'audio_greetings_ask': audio_greetings_ask,
      'audio_greetings_answer': audio_greetings_answer,
    };
  }

  /// Crea una DictionaryEntry desde un Map, soportando campos multimedia con prefijos por dominio
  /// (por ejemplo, animal_image, arbol_image, etc.) y el caso especial de 'saludos' con dos audios.
  factory DictionaryEntry.fromMap(Map<String, dynamic> map, {String? domain}) {
    // Detectar prefijo según el dominio si está presente
    String? prefix = domain?.toLowerCase().replaceAll(' ', '_').replaceAll('ɵ', 'o'); // Basic normalization for prefix
    String? imagePath, audioPath, audioVariantPath;
    String? namtrik, spanish, namtrikVariant, spanishVariant;
    int? id = map['id'] as int? ?? map['number'] as int?; // Handle 'number' as potential ID

    // --- Special Handling for "Wamap amɵñikun" ---
    if (domain == 'Wamap amɵñikun') {
      prefix = 'saludo'; // Use 'saludo' as the prefix for this specific domain
      namtrik = map['${prefix}_pregunta_namtrik'] as String?;
      spanish = map['${prefix}_pregunta_spanish'] as String?;
      namtrikVariant = map['${prefix}_respuesta_namtrik'] as String?;
      spanishVariant = map['${prefix}_respuesta_spanish'] as String?;
      imagePath = map['${prefix}_image'] as String?;
      audioPath = map['${prefix}_audio_pregunta'] as String?; // Map pregunta audio to main audioPath
      audioVariantPath = map['${prefix}_audio_respuesta'] as String?; // Map respuesta audio to audioVariantPath
    }
    // --- Generic Handling for other domains ---
    else if (prefix != null && prefix.isNotEmpty) {
      // Try to find fields with prefix, fallback to generic names
      namtrik = map['${prefix}_namtrik'] as String? ?? map['namtrik'] as String?;
      spanish = map['${prefix}_spanish'] as String? ?? map['spanish'] as String?;
      namtrikVariant = map['${prefix}_namtrik_variant'] as String? ?? map['namtrikVariant'] as String?;
      spanishVariant = map['${prefix}_spanish_variant'] as String? ?? map['spanishVariant'] as String?;
      imagePath = map['${prefix}_image'] as String? ?? map['imagePath'] as String?;
      audioPath = map['${prefix}_audio'] as String? ?? map['audioPath'] as String?;
      audioVariantPath = map['${prefix}_audio_variant'] as String? ?? map['audioVariantPath'] as String?;
    }
    // --- Fallback if no domain or prefix match ---
    else {
      namtrik = map['namtrik'] as String?;
      spanish = map['spanish'] as String?;
      namtrikVariant = map['namtrikVariant'] as String?;
      spanishVariant = map['spanishVariant'] as String?;
      imagePath = map['imagePath'] as String?;
      audioPath = map['audioPath'] as String?;
      audioVariantPath = map['audioVariantPath'] as String?;
    }

    // Ensure ID is not null, maybe throw error or use a default if critical
    if (id == null) {
      // Handle missing ID appropriately, e.g., throw an error or assign a default
      // For now, let's assign a placeholder, but this should be reviewed
      id = -1; // Placeholder ID
      print("Warning: DictionaryEntry created with placeholder ID for map: $map");
    }


    // Note: The 'greetings_*' fields might be redundant now if 'Wamap amɵñikun' covers 'Saludos'
    // Keeping them for now in case 'Saludos' is a distinct domain elsewhere.
    String? audioGreetingsAsk = map['audio_greetings_ask'] as String?;
    String? audioGreetingsAnswer = map['audio_greetings_answer'] as String?;

    return DictionaryEntry(
      id: id, // Use the determined ID
      domainId: map['domainId'] as int, // Assuming domainId is always provided correctly
      namtrik: namtrik ?? '', // Use determined namtrik, fallback to empty
      spanish: spanish ?? '', // Use determined spanish, fallback to empty
      namtrikVariant: namtrikVariant, // Use determined variant
      spanishVariant: spanishVariant, // Use determined variant
      imagePath: imagePath, // Use determined imagePath
      audioPath: audioPath, // Use determined audioPath
      audioVariantPath: audioVariantPath, // Use determined audioVariantPath
      compositionsSpanish: map['compositionsSpanish'] != null && map['compositionsSpanish'] is String
          ? (jsonDecode(map['compositionsSpanish'] as String) as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value as String))
          : null,
      // Pass the potentially redundant greetings fields
      greetings_ask_namtrik: map['greetings_ask_namtrik'] as String?,
      greetings_ask_spanish: map['greetings_ask_spanish'] as String?,
      greetings_answer_namtrik: map['greetings_answer_namtrik'] as String?,
      greetings_answer_spanish: map['greetings_answer_spanish'] as String?,
      images_greetings: map['images_greetings'] as String?,
      audio_greetings_ask: audioGreetingsAsk,
      audio_greetings_answer: audioGreetingsAnswer,
    );
  }

  @override
  String toString() {
    return 'DictionaryEntry(id: $id, domainId: $domainId, namtrik: $namtrik, spanish: $spanish, ...)'; // Truncated for brevity
  }
}
