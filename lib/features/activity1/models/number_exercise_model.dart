class NumberExercise {
  final int correctNumber;
  final String numberInText;
  final String audioPath;
  final List<int> options;
  
  NumberExercise({
    required this.correctNumber,
    required this.numberInText,
    required this.audioPath,
    required this.options,
  });

  bool isCorrectOption(int selected) => selected == correctNumber;
}