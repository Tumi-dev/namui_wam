import 'package:get_it/get_it.dart';
import 'package:namui_wam/core/services/audio_service.dart';
import 'package:namui_wam/core/services/logger_service.dart';
import 'package:namui_wam/core/services/storage_service.dart';
import 'package:namui_wam/core/services/feedback_service.dart';
import 'package:namui_wam/core/services/number_data_service.dart';
import 'package:namui_wam/features/activity1/services/activity1_service.dart';
import 'package:namui_wam/features/activity2/services/activity2_service.dart';
import 'package:namui_wam/features/activity3/services/activity3_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  getIt.registerSingleton<LoggerService>(LoggerService());
  getIt.registerSingleton<AudioService>(AudioService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<FeedbackService>(FeedbackService());
  getIt.registerSingleton<NumberDataService>(NumberDataService());
  
  // Activity Services
  getIt.registerSingleton<Activity1Service>(Activity1Service(
    getIt<NumberDataService>(),
    getIt<AudioService>(),
  ));
  getIt.registerSingleton<Activity2Service>(Activity2Service(getIt<NumberDataService>()));
  getIt.registerSingleton<Activity3Service>(Activity3Service(
    getIt<NumberDataService>(),
    getIt<AudioService>(),
  ));
  
  // Initialize services that require async initialization
  final storageService = getIt<StorageService>();
  await storageService.init();
  
  // Initialize the NumberDataService
  final numberDataService = getIt<NumberDataService>();
  await numberDataService.initialize();
  
  getIt.get<LoggerService>().info('Service locator initialized');
}
