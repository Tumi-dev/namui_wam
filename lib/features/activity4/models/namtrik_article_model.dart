/// {@template namtrik_article_model}
/// Representa un artículo con su precio en Namtrik, utilizado en la Actividad 4:
/// "Anwan ashipelɵ kɵkun" (Aprendamos a usar el dinero).
///
/// Este modelo encapsula toda la información necesaria para presentar artículos
/// y sus precios en el contexto de compra/venta simulada:
/// - Identificador único (`number`)
/// - Imagen del artículo (`imageArticle`)
/// - Valor numérico del precio (`priceArticle`)
/// - Nombre del precio en Namtrik (`namePriceNamtrik`)
/// - Denominaciones que componen el precio (`numberMoneyImages`)
///
/// Se utiliza principalmente en el Nivel 2 de la Actividad 4: "Escojamos el dinero correcto",
/// donde el usuario debe seleccionar la combinación de billetes y monedas que corresponde
/// exactamente al precio del artículo mostrado.
///
/// El modelo facilita:
/// - La carga de imágenes de artículos desde los assets
/// - La visualización del precio en texto Namtrik
/// - La validación de las respuestas correctas mediante la lista de denominaciones
///
/// Ejemplo de uso:
/// ```dart
/// // Crear una instancia manualmente
/// final articleModel = NamtrikArticleModel(
///   number: 1,
///   imageArticle: 'apple.png',
///   priceArticle: 2000,
///   namePriceNamtrik: 'Parin warrasa',
///   numberMoneyImages: [2, 4], // IDs de las denominaciones necesarias
/// );
///
/// // O cargar desde JSON
/// final jsonData = {
///   'number': 1,
///   'image_articles': 'apple.png',
///   'price_articles': 2000,
///   'name_price_namtrik': 'Parin warrasa',
///   'number_money_images': [2, 4]
/// };
/// final articleModel = NamtrikArticleModel.fromJson(jsonData);
///
/// // Acceder a sus propiedades
/// print('Artículo: ${articleModel.imageArticle}, Precio: ${articleModel.priceArticle}');
/// ```
/// {@endtemplate}
class NamtrikArticleModel {
  /// Número identificador único del artículo.
  ///
  /// Se utiliza como clave primaria para identificar y buscar artículos específicos
  /// en listas y mapas. También sirve como referencia en los archivos JSON de configuración.
  final int number;
  
  /// Ruta de la imagen que representa el artículo.
  /// 
  /// Contiene el nombre del archivo de imagen, al que se le añade el prefijo de ruta
  /// mediante el método `getArticleImagePath` del servicio.
  ///
  /// Ejemplo: 'apple.png' (se convierte en 'assets/images/articles/apple.png')
  final String imageArticle;
  
  /// Precio numérico del artículo.
  ///
  /// Representa el valor monetario en unidades enteras (sin decimales).
  /// Se utiliza para:
  /// - Mostrar referencias visuales al usuario (opcional)
  /// - Validaciones internas
  /// - Cálculos de valores totales
  ///
  /// Ejemplo: 2000 (para dos mil pesos)
  final int priceArticle;
  
  /// Nombre o descripción del precio en idioma Namtrik.
  ///
  /// Contiene la representación textual del valor monetario en Namtrik.
  /// Es el texto que se muestra en la interfaz junto al artículo.
  ///
  /// Ejemplo: 'Parin warrasa' (para dos mil pesos)
  final String namePriceNamtrik;
  
  /// Lista de enteros que representan los identificadores de las denominaciones
  /// necesarias para formar el precio del artículo.
  ///
  /// Cada entero corresponde al campo `number` de un [NamtrikMoneyModel].
  /// Esta lista define la combinación correcta que el usuario debe seleccionar
  /// en el Nivel 2.
  ///
  /// Ejemplo: `[2, 4]` (podría representar un billete de 1000 y otro de 1000)
  final List<int> numberMoneyImages;

  /// {@macro namtrik_article_model}
  NamtrikArticleModel({
    required this.number,
    required this.imageArticle,
    required this.priceArticle,
    required this.namePriceNamtrik,
    required this.numberMoneyImages,
  });

  /// Crea una instancia de [NamtrikArticleModel] desde un mapa JSON.
  ///
  /// Este constructor factory facilita la deserialización de datos cargados
  /// desde archivos JSON, convirtiendo las claves del formato snake_case 
  /// utilizado en JSON al formato camelCase utilizado en Dart.
  ///
  /// [json] El mapa JSON con los datos del artículo.
  /// Retorna una nueva instancia de [NamtrikArticleModel].
  factory NamtrikArticleModel.fromJson(Map<String, dynamic> json) {
    return NamtrikArticleModel(
      number: json['number'] as int,
      imageArticle: json['image_articles'] as String,
      priceArticle: json['price_articles'] as int,
      namePriceNamtrik: json['name_price_namtrik'] as String,
      // Asegura que la lista se interprete como List<int>
      numberMoneyImages: List<int>.from(json['number_money_images'] as List? ?? []),
    );
  }

  /// Convierte la instancia de [NamtrikArticleModel] a un mapa JSON.
  /// 
  /// Este método serializa las propiedades del modelo a un formato adecuado
  /// para almacenamiento en archivos JSON, convirtiendo de camelCase a snake_case.
  ///
  /// Retorna un [Map<String, dynamic>] con los datos serializados.
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'image_articles': imageArticle,
      'price_articles': priceArticle,
      'name_price_namtrik': namePriceNamtrik,
      'number_money_images': numberMoneyImages,
    };
  }

  /// Representación en cadena de texto del modelo, útil para depuración.
  ///
  /// Retorna una descripción legible del modelo incluyendo su número,
  /// imagen, precio y nombre del precio en Namtrik.
  @override
  String toString() {
    return 'NamtrikArticleModel{number: $number, imageArticle: $imageArticle, priceArticle: $priceArticle, namePriceNamtrik: $namePriceNamtrik}';
  }
}
