/// {@template number_word}
/// Representa la asociación entre un número, su representación escrita en Namtrik,
/// los archivos de audio correspondientes y el nivel de dificultad al que pertenece.
///
/// Este modelo se utiliza principalmente en la Actividad 1 para:
/// - Mostrar la representación textual del número en la interfaz de usuario
/// - Proporcionar las rutas a los archivos de audio para su reproducción
/// - Vincular el valor numérico con su representación en idioma Namtrik
///
/// La estructura permite manejar números complejos que pueden requerir múltiples
/// archivos de audio para su correcta pronunciación, especialmente en niveles
/// avanzados donde los números tienen componentes como miles o millones.
///
/// Ejemplo:
/// ```dart
/// final numberWord = NumberWord(
///   number: 42,
///   word: "piptsi pa",
///   audioFiles: ['assets/audio/numbers/pip.wav', 'assets/audio/numbers/pip.wav',
///                'assets/audio/numbers/tsi.wav', 'assets/audio/numbers/tsi.wav',
///                'assets/audio/numbers/pa.wav', 'assets/audio/numbers/pa.wav'],
///   level: 2,
/// );
/// ```
/// {@endtemplate}
class NumberWord {
  /// El valor numérico representado (por ejemplo: 1, 2, 10, 42, 1000).
  ///
  /// Se utiliza para:
  /// - Verificar si la selección del usuario es correcta
  /// - Mostrar este número como una de las opciones en la interfaz
  /// - Generar opciones alternativas para el juego
  final int number;
  
  /// La representación escrita del número en idioma Namtrik.
  ///
  /// Ejemplos:
  /// - 1: "kan"
  /// - 2: "pa"
  /// - 10: "kantsi"
  /// - 100: "kansrel"
  /// - 1000: "kanishik"
  ///
  /// Se muestra en la pantalla para que el usuario aprenda la palabra Namtrik
  /// correspondiente al número.
  final String word;
  
  /// Lista de rutas a los archivos de audio asociados con este número/palabra.
  ///
  /// Para números simples suele contener una sola ruta, pero para números complejos
  /// puede incluir múltiples archivos que se reproducen secuencialmente para formar
  /// la pronunciación completa del número.
  ///
  /// Ejemplo para "42" (piptsi pa):
  /// `['assets/audio/numbers/pip.wav', 'assets/audio/numbers/pip.wav',
  ///  'assets/audio/numbers/tsi.wav', 'assets/audio/numbers/tsi.wav',
  ///  'assets/audio/numbers/pa.wav', 'assets/audio/numbers/pa.wav']`
  final List<String> audioFiles;
  
  /// El nivel de dificultad o agrupación al que pertenece este número.
  ///
  /// Corresponde al nivel de la actividad:
  /// - Nivel 1: Números del 1 al 9
  /// - Nivel 2: Números del 10 al 99
  /// - Nivel 3: Números del 100 al 999
  /// - Nivel 4: Números del 1,000 al 9,999
  /// - Etc.
  ///
  /// Se utiliza para clasificar los números y establecer la dificultad
  /// apropiada en cada nivel del juego.
  final int level;

  /// {@macro number_word}
  ///
  /// [number] El valor numérico representado.
  /// [word] La representación escrita en idioma Namtrik.
  /// [audioFiles] Lista de rutas a los archivos de audio.
  /// [level] El nivel de dificultad al que pertenece.
  const NumberWord({
    required this.number,
    required this.word,
    required this.audioFiles,
    required this.level,
  });
}
