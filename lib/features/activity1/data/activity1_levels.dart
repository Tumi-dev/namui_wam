import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/constants/level_descriptions.dart';

final List<LevelModel> activity1Levels = [
  LevelModel(
    id: 1,
    title: 'Nivel 1',
    description: LevelDescriptions.level1,
    difficulty: 1,
    levelData: {
      'sounds': ['do', 're', 'mi'],
    }
  ),
  LevelModel(
    id: 2,
    title: 'Nivel 2',
    description: LevelDescriptions.level2,
    difficulty: 2,
    levelData: {
      'sounds': ['do', 're', 'mi', 'fa'],
    }
  ),
  LevelModel(
    id: 3,
    title: 'Nivel 3',
    description: LevelDescriptions.level3,
    difficulty: 3,
    levelData: {
      'sounds': ['do', 're', 'mi', 'fa', 'sol'],
    }
  ),
  LevelModel(
    id: 4,
    title: 'Nivel 4',
    description: LevelDescriptions.level4,
    difficulty: 4,
    levelData: {
      'sounds': ['do', 're', 'mi', 'fa', 'sol', 'la'],
    }
  ),
  LevelModel(
    id: 5,
    title: 'Nivel 5',
    description: LevelDescriptions.level5,
    difficulty: 5,
    levelData: {
      'sounds': ['do', 're', 'mi', 'fa', 'sol', 'la', 'si'],
    }
  ),
  LevelModel(
    id: 6,
    title: 'Nivel 6',
    description: LevelDescriptions.level6,
    difficulty: 6,
    levelData: {
      'sounds': ['do', 're', 'mi', 'fa', 'sol', 'la', 'si', 'do_alto'],
    }
  ),
  LevelModel(
    id: 7,
    title: 'Nivel 7',
    description: LevelDescriptions.level7,
    difficulty: 7,
    levelData: {
      'sounds': ['do', 're', 'mi', 'fa', 'sol', 'la', 'si', 'do_alto'],
    }
  ),
];