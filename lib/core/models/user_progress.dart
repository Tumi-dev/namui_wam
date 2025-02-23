import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 0)
class UserProgress extends HiveObject {
  @HiveField(0)
  final int activityId;

  @HiveField(1)
  final int levelId;

  @HiveField(2)
  final int score;

  @HiveField(3)
  final DateTime completedAt;

  UserProgress({
    required this.activityId,
    required this.levelId,
    required this.score,
    required this.completedAt,
  });
}
