import 'dart:convert'; // Para jsonEncode/Decode si es necesario para map<string, string>

/// Representa una única entrada en el diccionario, típicamente asociada con un [SemanticDomain].
///
/// Contiene términos en Namtrik y Español, junto con variantes opcionales, rutas de medios,
/// y campos específicos para ciertos dominios como saludos.
class DictionaryEntry {
  /// Identificador único para la entrada del diccionario.
  final int id;

  /// Identificador que vincula esta entrada a un [SemanticDomain].
  final int domainId;

  /// El término o frase principal en el idioma Namtrik.
  final String? namtrik;

  /// La traducción principal del término/frase en Español.
  final String? spanish;

  /// Una variante opcional del término Namtrik (p. ej., una respuesta a una pregunta).
  final String? namtrikVariant;

  /// Una variante opcional de la traducción al Español.
  final String? spanishVariant;

  /// Ruta a un recurso de imagen asociado (nulable).
  final String? imagePath;

  /// Ruta al recurso de audio principal (nulable).
  final String? audioPath;

  /// Ruta a un recurso de audio para el término variante (nulable).
  final String? audioVariantPath;

  /// Un mapa que contiene composiciones o términos relacionados en Español (nulable).
  /// Almacenado como una cadena JSON en la base de datos, decodificado/codificado aquí.
  final Map<String, String>? compositionsSpanish;

  // Campos específicos para el dominio 'Saludos' (potencialmente redundantes si se manejan con lógica de prefijos)
  /// La versión Namtrik de una pregunta de saludo.
  final String? greetings_ask_namtrik;
  /// La versión en Español de una pregunta de saludo.
  final String? greetings_ask_spanish;
  /// La versión Namtrik de una respuesta de saludo.
  final String? greetings_answer_namtrik;
  /// La versión en Español de una respuesta de saludo.
  final String? greetings_answer_spanish;
  /// Ruta de imagen específica para saludos.
  final String? images_greetings;
  /// Ruta de audio para la pregunta de saludo.
  final String? audio_greetings_ask;
  /// Ruta de audio para la respuesta de saludo.
  final String? audio_greetings_answer;

  /// Crea una instancia de [DictionaryEntry].
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
    // Añadir campos de saludos al constructor
    this.greetings_ask_namtrik,
    this.greetings_ask_spanish,
    this.greetings_answer_namtrik,
    this.greetings_answer_spanish,
    this.images_greetings,
    this.audio_greetings_ask,
    this.audio_greetings_answer,
  });

  /// Convierte esta instancia de [DictionaryEntry] en un Map adecuado para la inserción
  /// en la base de datos u otros formatos de serialización.
  ///
  /// El mapa [compositionsSpanish] se codifica en una cadena JSON.
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
      // Añadir campos de saludos al mapa
      'greetings_ask_namtrik': greetings_ask_namtrik,
      'greetings_ask_spanish': greetings_ask_spanish,
      'greetings_answer_namtrik': greetings_answer_namtrik,
      'greetings_answer_spanish': greetings_answer_spanish,
      'images_greetings': images_greetings,
      'audio_greetings_ask': audio_greetings_ask,
      'audio_greetings_answer': audio_greetings_answer,
    };
  }

  /// Crea un [DictionaryEntry] a partir de un Map, típicamente recuperado de una base de datos.
  ///
  /// Maneja nombres de campo dinámicos basados en el [domain] proporcionado para soportar
  /// prefijos específicos del dominio (p. ej., `animal_image`, `arbol_audio`).
  /// Incluye manejo especial para el dominio "Wamap amɵñikun" (saludos).
  ///
  /// Recurre a nombres de campo genéricos (`namtrik`, `imagePath`, etc.) si ningún prefijo
  /// coincide o no se proporciona ningún dominio.
  ///
  /// Si falta el campo 'id', intenta usar 'number' como ID alternativo
  /// y asigna un ID de marcador de posición (-1) con una advertencia si no se encuentra ninguno.
  ///
  /// Decodifica el campo `compositionsSpanish` desde una cadena JSON si está presente.
  factory DictionaryEntry.fromMap(Map<String, dynamic> map, {String? domain}) {
    // Detectar prefijo según el dominio si está presente
    String? prefix = domain?.toLowerCase().replaceAll(' ', '_').replaceAll('ɵ', 'o'); // Normalización básica para el prefijo
    String? imagePath, audioPath, audioVariantPath;
    String? namtrik, spanish, namtrikVariant, spanishVariant;
    int? id = map['id'] as int? ?? map['number'] as int?; // Manejar 'number' como posible ID

    // --- Manejo Especial para "Wamap amɵñikun" ---
    if (domain == 'Wamap amɵñikun') {
      prefix = 'saludo'; // Usar 'saludo' como el prefijo para este dominio específico
      namtrik = map['${prefix}_pregunta_namtrik'] as String?;
      spanish = map['${prefix}_pregunta_spanish'] as String?;
      namtrikVariant = map['${prefix}_respuesta_namtrik'] as String?;
      spanishVariant = map['${prefix}_respuesta_spanish'] as String?;
      imagePath = map['${prefix}_image'] as String? ?? map['images_greetings'] as String?; // Recaída a images_greetings
      audioPath = map['${prefix}_audio_pregunta'] as String? ?? map['audio_greetings_ask'] as String?; // Mapear audio pregunta a audioPath principal, recaída
      audioVariantPath = map['${prefix}_audio_respuesta'] as String? ?? map['audio_greetings_answer'] as String?; // Mapear audio respuesta a audioVariantPath, recaída
    }
    // --- Manejo Genérico para otros dominios ---
    else if (prefix != null && prefix.isNotEmpty) {
      // Intentar encontrar campos con prefijo, recaída a nombres genéricos
      namtrik = map['${prefix}_namtrik'] as String? ?? map['namtrik'] as String?;
      spanish = map['${prefix}_spanish'] as String? ?? map['spanish'] as String?;
      namtrikVariant = map['${prefix}_namtrik_variant'] as String? ?? map['namtrikVariant'] as String?;
      spanishVariant = map['${prefix}_spanish_variant'] as String? ?? map['spanishVariant'] as String?;
      imagePath = map['${prefix}_image'] as String? ?? map['imagePath'] as String?;
      audioPath = map['${prefix}_audio'] as String? ?? map['audioPath'] as String?;
      audioVariantPath = map['${prefix}_audio_variant'] as String? ?? map['audioVariantPath'] as String?;
    }
    // --- Recaída si no hay coincidencia de dominio o prefijo ---
    else {
      namtrik = map['namtrik'] as String?;
      spanish = map['spanish'] as String?;
      namtrikVariant = map['namtrikVariant'] as String?;
      spanishVariant = map['spanishVariant'] as String?;
      imagePath = map['imagePath'] as String?;
      audioPath = map['audioPath'] as String?;
      audioVariantPath = map['audioVariantPath'] as String?;
    }

    // Asegurarse de que el ID no sea nulo, tal vez lanzar un error o usar un valor predeterminado si es crítico
    if (id == null) {
      // Manejar ID faltante apropiadamente, p. ej., lanzar un error o asignar un valor predeterminado
      // Por ahora, asignemos un marcador de posición, pero esto debería ser revisado
      id = -1; // ID de marcador de posición
      print("Advertencia: DictionaryEntry creado con ID de marcador de posición para el mapa: $map");
    }


    // Nota: Los campos 'greetings_*' podrían ser redundantes ahora si 'Wamap amɵñikun' cubre 'Saludos'
    // Manteniéndolos por ahora en caso de que 'Saludos' sea un dominio distinto en otro lugar.
    // Estos se utilizan principalmente como recaídas si los campos con prefijo no se encuentran para los saludos.
    String? audioGreetingsAsk = map['audio_greetings_ask'] as String?;
    String? audioGreetingsAnswer = map['audio_greetings_answer'] as String?;

    return DictionaryEntry(
      id: id, // Usar el ID determinado
      domainId: map['domainId'] as int, // Suponiendo que domainId siempre se proporciona correctamente
      namtrik: namtrik ?? '', // Usar namtrik determinado, recaída a vacío
      spanish: spanish ?? '', // Usar spanish determinado, recaída a vacío
      namtrikVariant: namtrikVariant, // Usar variante determinada
      spanishVariant: spanishVariant, // Usar variante determinada
      imagePath: imagePath, // Usar imagePath determinado
      audioPath: audioPath, // Usar audioPath determinado
      audioVariantPath: audioVariantPath, // Usar audioVariantPath determinado
      compositionsSpanish: map['compositionsSpanish'] != null && map['compositionsSpanish'] is String
          ? (jsonDecode(map['compositionsSpanish'] as String) as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value as String))
          : null,
      // Pasar los campos de saludos potencialmente redundantes (usados como recaídas en la lógica anterior)
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
    // Proporciona una representación de cadena más informativa, truncada por brevedad.
    return 'DictionaryEntry(id: $id, domainId: $domainId, namtrik: $namtrik, spanish: $spanish, ...)';
  }
}
