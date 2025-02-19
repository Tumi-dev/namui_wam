import 'package:namui_wam/core/models/level_model.dart';
import 'package:namui_wam/core/constants/level_descriptions.dart';

final List<LevelModel> activity2Levels = [
  LevelModel(
    id: 1,
    title: 'Nivel 1',
    description: LevelDescriptions.level1,
    difficulty: 1,
    levelData: {
      'numberRange': [10, 20],
      'exercisesPerLevel': 5,
      'categoryName': 'decenas',
    }
  ),
  LevelModel(
    id: 2,
    title: 'Nivel 2',
    description: LevelDescriptions.level2,
    difficulty: 2,
    levelData: {
      'numberRange': [21, 30],
      'exercisesPerLevel': 5,
      'categoryName': 'veintenas',
    }
  ),
  LevelModel(
    id: 3,
    title: 'Nivel 3',
    description: LevelDescriptions.level3,
    difficulty: 2,
    levelData: {
      'numberRange': [31, 40],
      'exercisesPerLevel': 5,
      'categoryName': 'treintenas',
    }
  ),
  LevelModel(
    id: 4,
    title: 'Nivel 4',
    description: LevelDescriptions.level4,
    difficulty: 3,
    levelData: {
      'numberRange': [41, 50],
      'exercisesPerLevel': 5,
      'categoryName': 'cuarentenas',
    }
  ),
  LevelModel(
    id: 5,
    title: 'Nivel 5',
    description: LevelDescriptions.level5,
    difficulty: 3,
    levelData: {
      'numberRange': [51, 60],
      'exercisesPerLevel': 5,
      'categoryName': 'cincuentenas',
    }
  ),
  LevelModel(
    id: 6,
    title: 'Nivel 6',
    description: LevelDescriptions.level6,
    difficulty: 4,
    levelData: {
      'numberRange': [61, 70],
      'exercisesPerLevel': 5,
      'categoryName': 'sesentenas',
    }
  ),
  LevelModel(
    id: 7,
    title: 'Nivel 7',
    description: LevelDescriptions.level7,
    difficulty: 4,
    levelData: {
      'numberRange': [71, 99],
      'exercisesPerLevel': 5,
      'categoryName': 'setentenas+',
    }
  ),
];