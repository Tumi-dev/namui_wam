class NumberWord {
  final int number;
  final String word;

  const NumberWord({
    required this.number,
    required this.word,
  });
}

class NumbersData {
  static const List<NumberWord> numbers = [
    NumberWord(number: 1, word: 'Kan'),
    NumberWord(number: 2, word: 'Pa'),
    NumberWord(number: 3, word: 'Pøn'),
    NumberWord(number: 4, word: 'Pip'),
    NumberWord(number: 5, word: 'Trattrø'),
    NumberWord(number: 6, word: 'Trattrø Kan'),
    NumberWord(number: 7, word: 'Trattrø Pa'),
    NumberWord(number: 8, word: 'Trattrø Pøn'),
    NumberWord(number: 9, word: 'Trattrø Pip')
  ];

  static NumberWord getRandomNumber() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return numbers[now % numbers.length];
  }
}
