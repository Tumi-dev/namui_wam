import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/services/audio_service.dart';
import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/features/activity5/models/namtrik_money_model.dart';
import 'package:namui_wam/features/activity5/models/namtrik_article_model.dart';

class Activity5Service {
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
    final String response = await rootBundle.loadString('assets/data/namtrik_money.json');
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
    final String response = await rootBundle.loadString('assets/data/namtrik_articles.json');
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
}
