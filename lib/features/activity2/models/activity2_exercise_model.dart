class Activity2Exercise {
  final int number;
  final String numberInText;
  final List<int> options;
  
  Activity2Exercise({
    required this.number,
    required this.numberInText,
    required this.options,
  });

  bool isCorrectOption(int selected) => selected == number;

  factory Activity2Exercise.generateForRange(List<int> range) {
    // TODO: Implementar la lógica de generación de ejercicios
    // Esta función se utilizará para crear ejercicios dentro del rango especificado
    return Activity2Exercise(
      number: range[0],
      numberInText: 'pendiente',
      options: [range[0], range[0] + 1, range[1]],
    );
  }
}