/// {@template namtrik_article_model}
/// Representa un artículo con su precio en Namtrik, utilizado en la Actividad 4.
///
/// Contiene información sobre el artículo, como su número identificador, la ruta de su imagen,
/// su precio numérico, el nombre del precio en Namtrik y una lista de imágenes de dinero
/// que representan su valor.
/// {@endtemplate}
class NamtrikArticleModel {
  /// Número identificador único del artículo.
  final int number;
  /// Ruta de la imagen que representa el artículo (ej. 'assets/images/articles/item1.png').
  final String imageArticle;
  /// Precio numérico del artículo.
  final int priceArticle;
  /// Nombre o descripción del precio en idioma Namtrik.
  final String namePriceNamtrik;
  /// Lista de enteros que representan las imágenes de billetes/monedas necesarias
  /// para formar el precio del artículo. Cada entero podría corresponder a un valor
  /// o a un índice de imagen específico.
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
  /// Útil para deserializar datos cargados desde archivos JSON.
  /// [json] El mapa JSON con los datos del artículo.
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
  /// Útil para serialización.
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
  @override
  String toString() {
    return 'NamtrikArticleModel{number: $number, imageArticle: $imageArticle, priceArticle: $priceArticle, namePriceNamtrik: $namePriceNamtrik}';
  }
}
