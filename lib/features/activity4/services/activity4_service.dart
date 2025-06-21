import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:namuiwam/core/services/audio_service.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity4/models/namtrik_money_model.dart';
import 'package:namuiwam/features/activity4/models/namtrik_article_model.dart';

/// {@template activity4_service}
/// Servicio central que gestiona la lógica y datos para la Actividad 4: "Anwan ashipelɵ kɵkun" 
/// (Aprendamos a usar el dinero).
///
/// Responsabilidades principales:
/// - Cargar y gestionar datos de denominaciones monetarias de archivos JSON
/// - Generar opciones de juego para los diferentes niveles
/// - Proporcionar lógica de validación para verificar respuestas
/// - Gestionar la reproducción de audio para nombres en Namtrik
/// - Calcular valores totales y verificar equivalencias
///
/// Este servicio mantiene en memoria colecciones de datos compartidos entre niveles
/// para evitar recargas innecesarias, lo que optimiza el rendimiento.
///
/// Ejemplo de uso:
/// ```dart
/// final activity4Service = GetIt.instance<Activity4Service>();
/// 
/// // Obtener todas las denominaciones monetarias
/// final moneyItems = await activity4Service.getLevelData(level);
/// 
/// // Reproducir audio para un nombre en Namtrik
/// await activity4Service.playAudioForMoneyNamtrik('mil.mp3');
/// 
/// // Obtener un artículo aleatorio para el nivel 2
/// final randomArticle = await activity4Service.getRandomArticle();
/// ```
/// {@endtemplate}
class Activity4Service {
  /// Servicio para reproducción de archivos de audio.
  final _audioService = GetIt.instance<AudioService>();
  
  /// Colección en memoria de todas las denominaciones monetarias.
  /// Se carga una vez y se reutiliza en todos los niveles.
  List<NamtrikMoneyModel> _moneyItems = [];
  
  /// Colección en memoria de todos los artículos disponibles.
  /// Se utiliza principalmente en el nivel 2.
  List<NamtrikArticleModel> _articleItems = [];
  
  /// Generador de números aleatorios utilizado para selección y mezcla.
  final _random = Random();

  /// {@macro activity4_service}
  Activity4Service();

  /// Carga los datos de denominaciones monetarias desde el archivo JSON.
  ///
  /// Este método implementa un patrón singleton para la colección [_moneyItems],
  /// evitando recargas innecesarias de datos si ya están en memoria.
  /// 
  /// Pasos:
  /// 1. Verifica si los datos ya están cargados en memoria
  /// 2. Si no, lee el archivo JSON desde los assets
  /// 3. Convierte los datos JSON en objetos [NamtrikMoneyModel]
  /// 4. Almacena los modelos en [_moneyItems] para uso futuro
  ///
  /// [level] El modelo del nivel que solicita los datos (no afecta la carga)
  /// Retorna una lista de [NamtrikMoneyModel] con todas las denominaciones disponibles.
  ///
  /// Ejemplo:
  /// ```dart
  /// final moneyItems = await activity4Service.getLevelData(levelModel);
  /// final firstItem = moneyItems.first;
  /// print('Denominación: ${firstItem.moneyNamtrik}, Valor: ${firstItem.valueMoney}');
  /// ```
  Future<List<NamtrikMoneyModel>> getLevelData(LevelModel level) async {
    if (_moneyItems.isNotEmpty) {
      return _moneyItems;
    }

    // Cargar el archivo JSON
    final String response =
        await rootBundle.loadString('assets/data/namtrik_money.json');
    final data = await json.decode(response);

    // Extraer los datos del JSON
    _moneyItems = (data['money']['namui_wam'] as List)
        .map((item) => NamtrikMoneyModel.fromJson(item))
        .toList();

    return _moneyItems;
  }

  /// Carga los datos de artículos desde el archivo JSON.
  ///
  /// Similar a [getLevelData], implementa un patrón singleton para la colección
  /// [_articleItems], cargando los datos solo una vez y reutilizándolos.
  ///
  /// Pasos:
  /// 1. Verifica si los artículos ya están cargados en memoria
  /// 2. Si no, lee el archivo JSON desde los assets
  /// 3. Convierte los datos JSON en objetos [NamtrikArticleModel]
  /// 4. Almacena los modelos en [_articleItems] para uso futuro
  ///
  /// Retorna una lista de [NamtrikArticleModel] con todos los artículos disponibles.
  ///
  /// Ejemplo:
  /// ```dart
  /// final articles = await activity4Service.getArticlesData();
  /// for (var article in articles) {
  ///   print('Artículo: ${article.imageArticle}, Precio: ${article.priceArticle}');
  /// }
  /// ```
  Future<List<NamtrikArticleModel>> getArticlesData() async {
    if (_articleItems.isNotEmpty) {
      return _articleItems;
    }

    // Cargar el archivo JSON
    final String response =
        await rootBundle.loadString('assets/data/namtrik_articles.json');
    final data = await json.decode(response);

    // Extraer los datos del JSON
    _articleItems = (data['articles']['namui_wam'] as List)
        .map((item) => NamtrikArticleModel.fromJson(item))
        .toList();

    return _articleItems;
  }

  /// Selecciona un artículo aleatorio de la colección disponible.
  ///
  /// Utiliza [_random] para seleccionar un índice aleatorio de la lista de artículos.
  /// Si la lista está vacía, retorna null.
  ///
  /// Útil para:
  /// - Generar desafíos aleatorios en el Nivel 2
  /// - Evitar repeticiones predecibles en sesiones de juego sucesivas
  ///
  /// Retorna un [NamtrikArticleModel] aleatorio o null si no hay artículos disponibles.
  ///
  /// Ejemplo:
  /// ```dart
  /// final randomArticle = await activity4Service.getRandomArticle();
  /// if (randomArticle != null) {
  ///   displayArticleAndPrice(randomArticle);
  /// }
  /// ```
  Future<NamtrikArticleModel?> getRandomArticle() async {
    final articles = await getArticlesData();
    if (articles.isEmpty) return null;

    return articles[_random.nextInt(articles.length)];
  }

  /// Construye la ruta completa a la imagen de un artículo.
  ///
  /// Concatena el nombre de la imagen con la ruta base del directorio de artículos.
  ///
  /// [imageName] Nombre del archivo de imagen (ej: "item1.png")
  /// Retorna una cadena con la ruta completa (ej: "assets/images/articles/item1.png")
  String getArticleImagePath(String imageName) {
    return 'assets/images/articles/$imageName';
  }

  /// Construye la ruta completa a la imagen de una denominación monetaria.
  ///
  /// Concatena el nombre de la imagen con la ruta base del directorio de dinero.
  ///
  /// [imageName] Nombre del archivo de imagen (ej: "1000.png")
  /// Retorna una cadena con la ruta completa (ej: "assets/images/money/1000.png")
  String getMoneyImagePath(String imageName) {
    return 'assets/images/money/$imageName';
  }

  /// Busca y retorna un modelo de denominación monetaria por su número identificador.
  ///
  /// Utiliza [Iterable.firstWhere] para encontrar el primer elemento que coincida con el [number].
  /// Si no encuentra coincidencia, captura la excepción y retorna null.
  ///
  /// [number] El identificador numérico único de la denominación a buscar
  /// Retorna un [NamtrikMoneyModel] si encuentra coincidencia, null en caso contrario.
  NamtrikMoneyModel? getMoneyItemByNumber(int number) {
    try {
      return _moneyItems.firstWhere((item) => item.number == number);
    } catch (e) {
      return null;
    }
  }

  /// Reproduce secuencialmente los archivos de audio correspondientes a un valor monetario en Namtrik.
  ///
  /// Muchos valores monetarios en Namtrik se componen de múltiples palabras, cada una con su propio
  /// archivo de audio. Este método:
  /// 1. Detiene cualquier audio que esté reproduciéndose actualmente
  /// 2. Divide la cadena de entrada en nombres individuales de archivos
  /// 3. Reproduce cada archivo en secuencia, esperando a que termine antes de iniciar el siguiente
  ///
  /// [audiosNamtrik] Cadena con nombres de archivos separados por espacios (ej: "mil.mp3 pik.mp3")
  ///
  /// Ejemplo:
  /// ```dart
  /// // Reproducirá secuencialmente los archivos "mil.mp3" y "pik.mp3"
  /// await activity4Service.playAudioForMoneyNamtrik('mil.mp3 pik.mp3');
  /// ```
  Future<void> playAudioForMoneyNamtrik(String audiosNamtrik) async {
    // Detener cualquier audio previo
    await _audioService.stopAudio();

    // Separar la cadena de nombres de archivos de audio
    final audioFiles = audiosNamtrik.split(' ');

    // Reproducir cada archivo de audio en secuencia
    for (var audioFile in audioFiles) {
      final audioPath = 'audio/namtrik_numbers/$audioFile';
      await _audioService.playAudio(audioPath);

      // Esperar a que termine la reproducción antes de reproducir el siguiente
      await Future.delayed(const Duration(milliseconds: 700));
    }
  }

  /// Obtiene los modelos de denominaciones monetarias correspondientes a una lista de números identificadores.
  ///
  /// Útil para convertir listas de IDs (almacenados en JSON) en objetos completos
  /// que pueden mostrarse en la interfaz de usuario.
  ///
  /// Pasos:
  /// 1. Itera sobre cada número en la lista de entrada
  /// 2. Busca el modelo correspondiente usando [getMoneyItemByNumber]
  /// 3. Si encuentra coincidencia, lo añade al resultado
  ///
  /// [numbers] Lista de identificadores numéricos (ej: `[1, 3, 5]`)
  /// Retorna una lista de [NamtrikMoneyModel] correspondientes a los números proporcionados.
  List<NamtrikMoneyModel> getMoneyItemsByNumbers(List<int> numbers) {
    List<NamtrikMoneyModel> result = [];

    for (var number in numbers) {
      final item = getMoneyItemByNumber(number);
      if (item != null) {
        result.add(item);
      }
    }

    return result;
  }

  /// Genera cuatro opciones para el Nivel 2, incluyendo una correcta y tres incorrectas.
  ///
  /// Este método es central para el Nivel 2 "Escojamos el dinero correcto":
  /// 1. Asegura que los datos de denominaciones estén cargados
  /// 2. Crea la opción correcta basada en [NamtrikArticleModel.numberMoneyImages]
  /// 3. Genera tres opciones incorrectas con la misma cantidad de elementos
  /// 4. Verifica que las opciones incorrectas no sean duplicadas ni idénticas a la correcta
  /// 5. Mezcla aleatoriamente todas las opciones
  ///
  /// [article] El artículo seleccionado para el desafío, cuyo precio determina la opción correcta
  /// Retorna una lista de 4 listas de [NamtrikMoneyModel], donde una es la correcta.
  ///
  /// Ejemplo:
  /// ```dart
  /// final article = await activity4Service.getRandomArticle();
  /// final options = await activity4Service.generateOptionsForLevel2(article!);
  /// final correctIndex = activity4Service.findCorrectOptionIndex(options, article.numberMoneyImages);
  /// // Ahora puedes mostrar las 4 opciones y determinar cuál seleccionó el usuario
  /// ```
  Future<List<List<NamtrikMoneyModel>>> generateOptionsForLevel2(
      NamtrikArticleModel article) async {
    // Asegurarse de que los datos de dinero estén cargados
    if (_moneyItems.isEmpty) {
      await getLevelData(LevelModel(
          id: 1, title: 'Nivel 1', description: 'Descripción', difficulty: 1));
    }

    // La opción correcta basada en los números en numberMoneyImages
    final correctOption = getMoneyItemsByNumbers(article.numberMoneyImages);

    // Generar 3 opciones incorrectas
    List<List<NamtrikMoneyModel>> allOptions = [correctOption];

    // Continuar generando opciones hasta tener 4 en total
    while (allOptions.length < 4) {
      // Crear una nueva opción incorrecta
      List<NamtrikMoneyModel> newOption = [];
      final size = article.numberMoneyImages
          .length; // Mantener el mismo tamaño que la opción correcta

      // Obtener números disponibles (excluyendo los que ya están en la opción correcta)
      List<int> availableNumbers = List.generate(
              _moneyItems.length, (i) => i + 1)
          .where(
              (numberValue) => !article.numberMoneyImages.contains(numberValue))
          .toList();

      // Si no hay suficientes números disponibles, usar algunos de la opción correcta
      if (availableNumbers.length < size) {
        availableNumbers.addAll(article.numberMoneyImages
            .sublist(0, size - availableNumbers.length));
      }

      // Seleccionar aleatoriamente "size" números para la nueva opción
      availableNumbers.shuffle(_random);
      List<int> selectedNumbers = availableNumbers.take(size).toList();

      // Obtener los items correspondientes
      newOption = getMoneyItemsByNumbers(selectedNumbers);

      // Verificar que esta opción no sea igual a ninguna de las existentes
      bool isDuplicate = false;
      for (var option in allOptions) {
        if (_areOptionsEqual(option, newOption)) {
          isDuplicate = true;
          break;
        }
      }

      if (!isDuplicate && newOption.length == size) {
        allOptions.add(newOption);
      }
    }

    // Mezclar las opciones para que la correcta no esté siempre en la misma posición
    allOptions.shuffle();

    return allOptions;
  }

  /// Verifica si dos opciones de denominaciones monetarias son iguales comparando sus números.
  ///
  /// Método auxiliar interno utilizado por [generateOptionsForLevel2] para evitar
  /// generar opciones duplicadas.
  ///
  /// Algoritmo:
  /// 1. Compara las longitudes de ambas listas
  /// 2. Extrae los números identificadores de cada modelo
  /// 3. Ordena ambas listas para comparación posicional
  /// 4. Compara elemento por elemento
  ///
  /// [option1], [option2] Las dos listas de modelos a comparar
  /// Retorna true si las opciones son iguales, false en caso contrario.
  bool _areOptionsEqual(
      List<NamtrikMoneyModel> option1, List<NamtrikMoneyModel> option2) {
    if (option1.length != option2.length) return false;

    final numbers1 = option1.map((item) => item.number).toList()..sort();
    final numbers2 = option2.map((item) => item.number).toList()..sort();

    for (int i = 0; i < numbers1.length; i++) {
      if (numbers1[i] != numbers2[i]) return false;
    }

    return true;
  }

  /// Encuentra el índice de la opción correcta dentro de una lista de opciones.
  ///
  /// Compara cada opción en la lista con los números correctos, para determinar
  /// cuál opción corresponde exactamente a la respuesta correcta.
  ///
  /// Este método es crucial para validar las respuestas del usuario en el Nivel 2.
  ///
  /// [options] Lista de opciones generadas con [generateOptionsForLevel2]
  /// [correctNumbers] Lista de números que identifican la opción correcta
  /// Retorna el índice (0-3) de la opción correcta, o -1 si no encuentra coincidencia.
  int findCorrectOptionIndex(
      List<List<NamtrikMoneyModel>> options, List<int> correctNumbers) {
    for (int i = 0; i < options.length; i++) {
      List<int> optionNumbers = options[i].map((item) => item.number).toList()
        ..sort();
      List<int> correctSorted = List.from(correctNumbers)..sort();

      if (optionNumbers.length != correctSorted.length) continue;

      bool allMatch = true;
      for (int j = 0; j < optionNumbers.length; j++) {
        if (optionNumbers[j] != correctSorted[j]) {
          allMatch = false;
          break;
        }
      }

      if (allMatch) return i;
    }

    return -1; // No se encontró la opción correcta
  }

  /// Obtiene 4 imágenes aleatorias de dinero para el nivel 3
  Future<List<NamtrikMoneyModel>> getLevel3Data() async {
    // Asegurarse de que los datos de dinero estén cargados
    if (_moneyItems.isEmpty) {
      await getLevelData(LevelModel(
          id: 1, title: 'Nivel 1', description: 'Descripción', difficulty: 1));
    }

    // Cargar el archivo JSON específico para el nivel 3
    final String response =
        await rootBundle.loadString('assets/data/a4_l3_namuiwam_money.json');
    final data = await json.decode(response);

    // Obtener un elemento aleatorio del JSON
    final moneyL3List = data['money_l3']['namui_wam'] as List;
    final randomIndex = _random.nextInt(moneyL3List.length);
    final randomMoneyL3 = moneyL3List[randomIndex];

    // Obtener los números de las imágenes de dinero
    final List<int> numberMoneyImages =
        List<int>.from(randomMoneyL3['number_money_images']);

    // Obtener las monedas correspondientes a esos números
    List<NamtrikMoneyModel> result = [];
    for (var number in numberMoneyImages) {
      final item = getMoneyItemByNumber(number);
      if (item != null) {
        result.add(item);
      }
    }

    return result;
  }

  /// Obtiene el nombre total en Namtrik para el nivel 3
  Future<Map<String, dynamic>> getLevel3NamtrikNames() async {
    // Cargar el archivo JSON específico para el nivel 3
    final String response =
        await rootBundle.loadString('assets/data/a4_l3_namuiwam_money.json');
    final data = await json.decode(response);

    // Obtener un elemento aleatorio del JSON
    final moneyL3List = data['money_l3']['namui_wam'] as List;
    final randomIndex = _random.nextInt(moneyL3List.length);
    final randomMoneyL3 = moneyL3List[randomIndex];

    // Obtener el nombre total en Namtrik
    final String correctNamtrikName = randomMoneyL3['name_total_namtrik'];

    // Obtener otros 3 nombres aleatorios diferentes del correcto
    List<String> incorrectNames = [];
    List<int> usedIndices = [randomIndex];

    while (incorrectNames.length < 3) {
      int newIndex = _random.nextInt(moneyL3List.length);
      if (!usedIndices.contains(newIndex)) {
        usedIndices.add(newIndex);
        incorrectNames.add(moneyL3List[newIndex]['name_total_namtrik']);
      }
    }

    // Obtener los números de las imágenes de dinero
    final List<int> numberMoneyImages =
        List<int>.from(randomMoneyL3['number_money_images']);

    return {
      'correctName': correctNamtrikName,
      'incorrectNames': incorrectNames,
      'numberMoneyImages': numberMoneyImages,
      'randomIndex': randomIndex,
    };
  }

  /// Obtiene datos sincronizados para el nivel 3
  Future<Map<String, dynamic>> getSynchronizedLevel3Data() async {
    // Asegurarse de que los datos de dinero estén cargados
    if (_moneyItems.isEmpty) {
      await getLevelData(LevelModel(
          id: 1, title: 'Nivel 1', description: 'Descripción', difficulty: 1));
    }

    // Cargar el archivo JSON específico para el nivel 3
    final String response =
        await rootBundle.loadString('assets/data/a4_l3_namuiwam_money.json');
    final data = await json.decode(response);

    // Obtener un elemento aleatorio del JSON
    final moneyL3List = data['money_l3']['namui_wam'] as List;
    final randomIndex = _random.nextInt(moneyL3List.length);
    final randomMoneyL3 = moneyL3List[randomIndex];

    // Obtener el nombre total en Namtrik
    final String correctNamtrikName = randomMoneyL3['name_total_namtrik'];

    // Obtener otros 3 nombres aleatorios diferentes del correcto
    List<String> incorrectNames = [];
    List<int> usedIndices = [randomIndex];

    while (incorrectNames.length < 3) {
      int newIndex = _random.nextInt(moneyL3List.length);
      if (!usedIndices.contains(newIndex)) {
        usedIndices.add(newIndex);
        incorrectNames.add(moneyL3List[newIndex]['name_total_namtrik']);
      }
    }

    // Obtener los números de las imágenes de dinero
    final List<int> numberMoneyImages =
        List<int>.from(randomMoneyL3['number_money_images']);

    // Obtener las monedas correspondientes a esos números
    List<NamtrikMoneyModel> moneyItems = [];
    for (var number in numberMoneyImages) {
      final item = getMoneyItemByNumber(number);
      if (item != null) {
        moneyItems.add(item);
      }
    }

    return {
      'correctName': correctNamtrikName,
      'incorrectNames': incorrectNames,
      'moneyItems': moneyItems,
    };
  }

  /// Obtiene los nombres en namtrik para el nivel 3
  Future<List<String>> getNamtrikNames() async {
    await getArticlesData(); // Asegurarse de que los artículos estén cargados
    return _articleItems.map((article) => article.namePriceNamtrik).toList();
  }

  /// Obtiene todos los nombres únicos de dinero Namtrik del archivo JSON del Nivel 4.
  ///
  /// Lee el archivo `a4_l4_namuiwam_money.json` y extrae todos los valores
  /// de la clave `name_total_namtrik`, eliminando duplicados.
  ///
  /// Retorna una `List<String>` con los nombres únicos.
  Future<List<String>> getLevel4NamtrikNames() async {
    final String response = await rootBundle.loadString('assets/data/a4_l4_namuiwam_money.json');
    final data = json.decode(response);
    final List<dynamic> moneyData = data['money_l4']['namui_wam'];
    
    // Usar un Set para obtener nombres únicos y luego convertirlo a lista
    final Set<String> uniqueNames = moneyData.map((item) => item['name_total_namtrik'] as String).toSet();
    return uniqueNames.toList();
  }

  /// Obtiene el valor total y TODAS las combinaciones de imágenes válidas para un nombre Namtrik específico.
  ///
  /// Pasos:
  /// 1. Carga los datos del Nivel 4 desde el archivo JSON.
  /// 2. Busca la primera entrada que coincida con el `name` proporcionado para determinar el `total_money` objetivo.
  /// 3. Si no encuentra ninguna entrada, retorna null.
  /// 4. Vuelve a recorrer toda la lista de datos para encontrar TODAS las entradas que coincidan con el `total_money` objetivo.
  /// 5. Recopila cada `number_money_images` de estas entradas en una lista de listas (`List<List<int>>`).
  /// 6. Retorna un mapa que contiene el `total_money` y la lista de `valid_combinations`.
  ///
  /// [name] El nombre Namtrik del valor a buscar (ej: "Paishik").
  /// Retorna un `Map<String, dynamic>` o `null`.
  Future<Map<String, dynamic>?> getLevel4MoneyValuesForName(String name) async {
    final String response = await rootBundle.loadString('assets/data/a4_l4_namuiwam_money.json');
    final data = json.decode(response);
    final List<dynamic> moneyData = data['money_l4']['namui_wam'];

    // 1. Encontrar el `total_money` objetivo basado en el nombre
    final targetEntry = moneyData.firstWhere(
      (item) => item['name_total_namtrik'] == name,
      orElse: () => null,
    );

    if (targetEntry == null) {
      return null;
    }

    final int totalMoney = targetEntry['total_money'];

    // 2. Encontrar todas las combinaciones para ese `total_money`
    final List<List<int>> validCombinations = moneyData
        .where((item) => item['total_money'] == totalMoney)
        .map((item) => List<int>.from(item['number_money_images']))
        .toList();

    return {
      'total_money': totalMoney,
      'valid_combinations': validCombinations,
    };
  }

  /// Carga y retorna una lista de todas las imágenes de dinero disponibles para el Nivel 4.
  ///
  /// Este método obtiene los datos del Nivel 1 (que contiene todas las denominaciones)
  /// y extrae las rutas de sus imágenes. Se utiliza para construir la cuadrícula de selección.
  ///
  /// Retorna una `List<String>` con los nombres de archivo de las imágenes.
  Future<List<String>> getAllMoneyImages() async {
    if (_moneyItems.isEmpty) {
      await getLevelData(LevelModel(
          id: 1,
          title: 'Nivel 1',
          description: 'Descripción del nivel',
          difficulty: 1));
    }

    // Obtener solo las imágenes del lado A (primera imagen de cada par)
    final List<String> moneyImages = _moneyItems
        .map((item) => item.moneyImages.isNotEmpty ? item.moneyImages[0] : '')
        .where((image) => image.isNotEmpty)
        .toList();

    return moneyImages;
  }

  /// Obtiene todos los items de dinero para el nivel 4
  Future<List<NamtrikMoneyModel>> getAllMoneyItems() async {
    if (_moneyItems.isEmpty) {
      await getLevelData(LevelModel(
          id: 1, title: 'Nivel 1', description: 'Descripción', difficulty: 1));
    }

    return _moneyItems;
  }

  /// Reproduce un mensaje de audio de alerta para el nivel 4
  Future<void> playAlertAudio(String message) async {
    // Detener cualquier audio previo
    await _audioService.stopAudio();

    // Reproducir el audio de alerta
    final audioPath = 'audio/alerts/$message.wav';
    await _audioService.playAudio(audioPath);
  }

  /// Cambiar el nombre del parámetro 'num' a 'numberValue' para evitar conflicto con el tipo 'num'
  Future<String> getMoneyNameForValue(int numberValue) async {
    // Implementación pendiente
    return '';
  }
}
