import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/services/audio_service.dart';
import 'package:namui_wam/core/services/logger_service.dart';
import 'package:namui_wam/core/services/storage_service.dart';
import 'package:namui_wam/core/services/feedback_service.dart';
import 'package:namui_wam/core/services/number_data_service.dart';
import 'package:namui_wam/features/activity1/services/activity1_service.dart';
import 'package:namui_wam/features/activity2/services/activity2_service.dart';
import 'package:namui_wam/features/activity3/services/activity3_service.dart';
import 'package:namui_wam/features/activity4/services/activity4_service.dart';
import 'package:namui_wam/features/activity5/services/activity5_service.dart';
import 'package:namui_wam/features/activity6/services/activity6_service.dart';
import 'package:namui_wam/core/services/audio_player_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  getIt.registerSingleton<LoggerService>(LoggerService());
  getIt.registerSingleton<AudioService>(AudioService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<FeedbackService>(FeedbackService());
  getIt.registerLazySingleton<NumberDataService>(() => NumberDataService());
  
  // Activity Services
  getIt.registerLazySingleton<Activity1Service>(() => Activity1Service(
    getIt<NumberDataService>(),
    getIt<AudioService>(),
  ));
  getIt.registerLazySingleton<Activity2Service>(() => Activity2Service(getIt<NumberDataService>()));
  getIt.registerSingleton<Activity6Service>(Activity6Service(
    getIt<NumberDataService>(),
    getIt<AudioService>(),
  ));
  getIt.registerLazySingleton<Activity3Service>(() => Activity3Service());
  getIt.registerLazySingleton<Activity4Service>(() => Activity4Service());
  getIt.registerLazySingleton<Activity5Service>(() => Activity5Service());
  
  // Register AudioPlayerService
  getIt.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());

  // Initialize services that require async initialization
  final storageService = getIt<StorageService>();
  await storageService.init();
  
  // Initialize the NumberDataService
  final numberDataService = getIt<NumberDataService>();
  await numberDataService.initialize();
  
  getIt.get<LoggerService>().info('Service locator initialized');
}
