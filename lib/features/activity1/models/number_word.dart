/// {@template number_word}
/// Representa la asociación entre un número, su representación escrita en Namtrik,
/// los archivos de audio correspondientes y el nivel de dificultad al que pertenece.
///
/// Usado principalmente en la Actividad 1 para mostrar y reproducir los números.
/// {@endtemplate}
class NumberWord {
  /// El valor numérico (ej. 1, 2, 10).
  final int number;
  /// La representación escrita del número en Namtrik (ej. "tãã", "sam", "guasam").
  final String word;
  /// Lista de rutas a los archivos de audio asociados con este número/palabra.
  /// Puede incluir diferentes pronunciaciones o contextos.
  final List<String> audioFiles;
  /// El nivel de dificultad o agrupación al que pertenece este número.
  final int level;

  /// {@macro number_word}
  const NumberWord({
    required this.number,
    required this.word,
    required this.audioFiles,
    required this.level,
  });
}
