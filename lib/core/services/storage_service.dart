import 'package:hive_flutter/hive_flutter.dart';
import 'package:namui_wam/core/models/user_progress.dart';
import 'package:namui_wam/core/services/logger_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _logger = LoggerService();
  late Box<UserProgress> _progressBox;
  
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProgressAdapter());
    _progressBox = await Hive.openBox<UserProgress>('user_progress');
    _logger.info('Storage service initialized');
  }

  Future<void> saveProgress(UserProgress progress) async {
    try {
      final key = '${progress.activityId}_${progress.levelId}';
      await _progressBox.put(key, progress);
      _logger.info('Progress saved for activity ${progress.activityId}, level ${progress.levelId}');
    } catch (e, stackTrace) {
      _logger.error('Error saving progress', e, stackTrace);
      rethrow;
    }
  }

  UserProgress? getProgress(int activityId, int levelId) {
    try {
      final key = '${activityId}_${levelId}';
      return _progressBox.get(key);
    } catch (e, stackTrace) {
      _logger.error('Error getting progress', e, stackTrace);
      return null;
    }
  }

  List<UserProgress> getAllProgress() {
    try {
      return _progressBox.values.toList();
    } catch (e, stackTrace) {
      _logger.error('Error getting all progress', e, stackTrace);
      return [];
    }
  }

  Future<void> clearProgress() async {
    try {
      await _progressBox.clear();
      _logger.info('All progress cleared');
    } catch (e, stackTrace) {
      _logger.error('Error clearing progress', e, stackTrace);
      rethrow;
    }
  }
}
