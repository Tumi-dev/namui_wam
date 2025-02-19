class NumberWord {
  final int number;
  final String word;
  final String audioFile;

  const NumberWord({
    required this.number,
    required this.word,
    required this.audioFile,
  });
}

class NumbersData {
  static const List<NumberWord> numbers = [
    NumberWord(number: 1, word: 'Kan', audioFile: '1.Kan.wav'),
    NumberWord(number: 2, word: 'Pa', audioFile: '2.Pa.wav'),
    NumberWord(number: 3, word: 'Pøn', audioFile: '3.Pøn.wav'),
    NumberWord(number: 4, word: 'Pip', audioFile: '4.Pip.wav'),
    NumberWord(number: 5, word: 'Trattrø', audioFile: '5.Trattrø.wav'),
    NumberWord(number: 6, word: 'Trattrø Kan', audioFile: '6.Trattrø_Kan.wav'),
    NumberWord(number: 7, word: 'Trattrø Pa', audioFile: '7.Trattrø_Pa.wav'),
    NumberWord(number: 8, word: 'Trattrø Pøn', audioFile: '8.Trattrø_Pøn.wav'),
    NumberWord(number: 9, word: 'Trattrø Pip', audioFile: '9.Trattrø_Pip.wav'),
  ];

  static NumberWord getRandomNumber() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return numbers[now % numbers.length];
  }
}