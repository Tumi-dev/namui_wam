/// {@template namtrik_money_model}
/// Representa una denominación de dinero (billete o moneda) en Namtrik,
/// utilizado en la Actividad 4.
///
/// Contiene información como un número identificador, las rutas de las imágenes
/// asociadas, el nombre de la denominación en Namtrik, su valor numérico
/// y la ruta del archivo de audio correspondiente.
/// {@endtemplate}
class NamtrikMoneyModel {
  /// Número identificador único para esta denominación de dinero.
  final int number;
  /// Lista de rutas a las imágenes que representan este billete o moneda.
  /// (ej. ['assets/images/money/1000.png']).
  final List<String> moneyImages;
  /// Nombre o descripción de la denominación en idioma Namtrik.
  final String moneyNamtrik;
  /// Valor numérico de la denominación (ej. 1000, 5000).
  final int valueMoney;
  /// Ruta al archivo de audio que pronuncia el nombre de la denominación en Namtrik.
  /// (ej. 'assets/audio/money/1000.mp3').
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
  /// Útil para deserializar datos cargados desde archivos JSON.
  /// [json] El mapa JSON con los datos de la denominación.
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
  /// Útil para serialización.
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'money_images': moneyImages,
      'money_namtrik': moneyNamtrik,
      'value_money': valueMoney,
      'audios_namtrik': audiosNamtrik,
    };
  }
}