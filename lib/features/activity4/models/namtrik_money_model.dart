/// {@template namtrik_money_model}
/// Representa una denominación de dinero (billete o moneda) en Namtrik,
/// utilizado en la Actividad 4: "Anwan ashipelɵ kɵkun" (Aprendamos a usar el dinero).
///
/// Este modelo encapsula toda la información necesaria para visualizar, reproducir y
/// calcular valores con las denominaciones monetarias en el idioma Namtrik:
/// - Identificador único (`number`)
/// - Imágenes de anverso y reverso (`moneyImages`)
/// - Nombre o descripción en Namtrik (`moneyNamtrik`)
/// - Valor numérico (`valueMoney`)
/// - Audio con la pronunciación correcta (`audiosNamtrik`)
///
/// Se utiliza en todos los niveles de la Actividad 4, especialmente para:
/// - Nivel 1: Presentar cada denominación individual con imagen, texto y audio
/// - Nivel 2: Formar grupos de denominaciones que representan precios de artículos
/// - Nivel 3: Mostrar conjuntos de dinero y asociarlos con su nombre en Namtrik
/// - Nivel 4: Permitir la selección de denominaciones para formar valores específicos
///
/// Ejemplo de uso:
/// ```dart
/// // Crear una instancia manualmente
/// final moneyModel = NamtrikMoneyModel(
///   number: 1,
///   moneyImages: ['assets/images/money/1000.png'],
///   moneyNamtrik: 'Kan warrasa',
///   valueMoney: 1000,
///   audiosNamtrik: 'kan_warrasa.mp3',
/// );
///
/// // O cargar desde JSON
/// final jsonData = {
///   'number': 1,
///   'money_images': ['assets/images/money/1000.png'],
///   'money_namtrik': 'Kan warrasa',
///   'value_money': 1000,
///   'audios_namtrik': 'kan_warrasa.mp3'
/// };
/// final moneyModel = NamtrikMoneyModel.fromJson(jsonData);
///
/// // Acceder a sus propiedades
/// print('Valor: ${moneyModel.valueMoney}, Nombre: ${moneyModel.moneyNamtrik}');
/// ```
/// {@endtemplate}
class NamtrikMoneyModel {
  /// Número identificador único para esta denominación de dinero.
  ///
  /// Se utiliza como clave primaria para identificar y buscar denominaciones específicas
  /// en listas y mapas. También sirve como referencia en los archivos JSON de configuración.
  final int number;
  
  /// Lista de rutas a las imágenes que representan este billete o moneda.
  /// 
  /// Generalmente contiene dos elementos:
  /// - El primero `[0]` es la imagen del anverso (cara principal)
  /// - El segundo `[1]`, cuando existe, es la imagen del reverso
  ///
  /// Ejemplo: `['assets/images/money/1000_front.png', 'assets/images/money/1000_back.png']`
  final List<String> moneyImages;
  
  /// Nombre o descripción de la denominación en idioma Namtrik.
  ///
  /// Contiene la representación textual del valor monetario en el idioma nativo.
  /// Es el texto que se muestra en la interfaz y coincide con el audio reproducido.
  ///
  /// Ejemplo: 'Kan warrasa' (para mil pesos)
  final String moneyNamtrik;
  
  /// Valor numérico de la denominación.
  ///
  /// Representa el valor monetario en unidades enteras (sin decimales).
  /// Se utiliza para:
  /// - Cálculos de sumas en el Nivel 4
  /// - Validación de opciones correctas
  /// - Ordenamiento de denominaciones
  ///
  /// Ejemplo: 1000 (para mil pesos)
  final int valueMoney;
  
  /// Ruta al archivo de audio que pronuncia el nombre de la denominación en Namtrik.
  ///
  /// Puede contener un único archivo o varios separados por espacios para
  /// nombres compuestos. El servicio se encarga de reproducirlos secuencialmente.
  ///
  /// Ejemplo: 'kan.mp3 warrasa.mp3'
  final String audiosNamtrik;

  /// {@macro namtrik_money_model}
  NamtrikMoneyModel({
    required this.number,
    required this.moneyImages,
    required this.moneyNamtrik,
    required this.valueMoney,
    required this.audiosNamtrik,
  });

  /// Crea una instancia de [NamtrikMoneyModel] desde un mapa JSON.
  ///
  /// Este constructor factory facilita la deserialización de datos cargados
  /// desde archivos JSON, convirtiendo las claves del formato snake_case 
  /// utilizado en JSON al formato camelCase utilizado en Dart.
  ///
  /// [json] El mapa JSON con los datos de la denominación.
  /// Retorna una nueva instancia de [NamtrikMoneyModel].
  factory NamtrikMoneyModel.fromJson(Map<String, dynamic> json) {
    return NamtrikMoneyModel(
      number: json['number'] as int,
      // Asegura que la lista se interprete como List<String>
      moneyImages: List<String>.from(json['money_images'] as List? ?? []),
      moneyNamtrik: json['money_namtrik'] as String,
      valueMoney: json['value_money'] as int,
      audiosNamtrik: json['audios_namtrik'] as String,
    );
  }

  /// Convierte la instancia de [NamtrikMoneyModel] a un mapa JSON.
  /// 
  /// Este método serializa las propiedades del modelo a un formato adecuado
  /// para almacenamiento en archivos JSON, convirtiendo de camelCase a snake_case.
  ///
  /// Retorna un [Map<String, dynamic>] con los datos serializados.
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'money_images': moneyImages,
      'money_namtrik': moneyNamtrik,
      'value_money': valueMoney,
      'audios_namtrik': audiosNamtrik,
    };
  }
  
  /// Representación en cadena de texto del modelo, útil para depuración.
  ///
  /// Retorna una descripción legible del modelo incluyendo su número,
  /// nombre en Namtrik y valor.
  @override
  String toString() {
    return 'NamtrikMoneyModel{number: $number, moneyNamtrik: $moneyNamtrik, valueMoney: $valueMoney}';
  }
}