enum LevelStatus {
  locked,
  unlocked,
  completed
}

extension LevelStatusExtension on LevelStatus {
  String toStorageString() => 'LevelStatus.${toString().split('.').last}';
  
  static LevelStatus fromStorageString(String value) {
    final enumName = value.replaceAll('LevelStatus.', '');
    return LevelStatus.values.firstWhere(
      (status) => status.toString().split('.').last == enumName,
      orElse: () => LevelStatus.locked
    );
  }
}

class LevelModel {
  final int id;
  final String title;
  final String description;
  final int difficulty;
  LevelStatus status;
  final Map<String, dynamic>? levelData;

  LevelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.status = LevelStatus.locked,
    this.levelData,
  });

  bool get isLocked => status == LevelStatus.locked;
  bool get isCompleted => status == LevelStatus.completed;
  
  void unlockLevel() {
    if (status == LevelStatus.locked) {
      status = LevelStatus.unlocked;
    }
  }

  void completeLevel() {
    status = LevelStatus.completed;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'difficulty': difficulty,
    'status': status.toStorageString(),
    'levelData': levelData,
  };

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    difficulty: json['difficulty'],
    status: LevelStatusExtension.fromStorageString(json['status']),
    levelData: json['levelData'],
  );
}