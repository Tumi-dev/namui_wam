import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:namuiwam/core/services/audio_service.dart';
import 'package:namuiwam/core/models/level_model.dart';
import 'package:namuiwam/features/activity4/models/namtrik_money_model.dart';
import 'package:namuiwam/features/activity4/models/namtrik_article_model.dart';

class Activity4Service {
  final _audioService = GetIt.instance<AudioService>();
  List<NamtrikMoneyModel> _moneyItems = [];
  List<NamtrikArticleModel> _articleItems = [];
  final _random = Random();

  /// Carga los datos del nivel desde el archivo JSON
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

  /// Carga los datos de artículos desde el archivo JSON
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

  /// Obtiene un artículo aleatorio para mostrar
  Future<NamtrikArticleModel?> getRandomArticle() async {
    final articles = await getArticlesData();
    if (articles.isEmpty) return null;

    return articles[_random.nextInt(articles.length)];
  }

  /// Obtiene la ruta de la imagen de un artículo
  String getArticleImagePath(String imageName) {
    return 'assets/images/articles/$imageName';
  }

  /// Obtiene la imagen completa del dinero en Namtrik
  String getMoneyImagePath(String imageName) {
    return 'assets/images/money/$imageName';
  }

  /// Obtiene los datos de un elemento específico por su número
  NamtrikMoneyModel? getMoneyItemByNumber(int number) {
    try {
      return _moneyItems.firstWhere((item) => item.number == number);
    } catch (e) {
      return null;
    }
  }

  /// Reproduce secuencialmente los archivos de audio para un valor monetario en namtrik
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

  /// Obtiene las monedas correspondientes a los números especificados
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

  /// Genera opciones para el nivel 2, incluyendo una opción correcta y tres incorrectas
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

  /// Verifica si dos opciones son iguales comparando sus números
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

  /// Encuentra el índice de la opción correcta en la lista de opciones
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

  /// Carga los datos del nivel 4 desde el archivo JSON
  Future<List<String>> getLevel4NamtrikNames() async {
    // Cargar el archivo JSON
    final String response =
        await rootBundle.loadString('assets/data/a4_l4_namuiwam_money.json');
    final data = await json.decode(response);

    // Extraer los nombres en namtrik del JSON
    final List<String> namtrikNames = (data['money_l4']['namui_wam'] as List)
        .map((item) => item['name_total_namtrik'] as String)
        .toList();

    return namtrikNames;
  }

  /// Obtiene todas las imágenes de dinero (solo lado A) para el nivel 4
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

  /// Obtiene los valores objetivo del dinero para el nombre seleccionado en el nivel 4
  Future<Map<String, dynamic>?> getLevel4MoneyValuesForName(
      String namtrikName) async {
    // Cargar el archivo JSON
    final String response =
        await rootBundle.loadString('assets/data/a4_l4_namuiwam_money.json');
    final data = await json.decode(response);

    // Buscar el elemento con el nombre coincidente
    final moneyL4List = data['money_l4']['namui_wam'] as List;

    for (var item in moneyL4List) {
      if (item['name_total_namtrik'] == namtrikName) {
        return {
          'number_money_images': item['number_money_images'],
          'total_money': item['total_money'],
        };
      }
    }

    return null;
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
