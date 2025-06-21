/// {@template activity_instructions}
/// Clase utilitaria que centraliza las instrucciones de todas las actividades educativas.
///
/// Proporciona descripciones detalladas para cada actividad, incluyendo objetivos
/// y pasos específicos para completar cada ejercicio en lengua namtrik.
///
/// Esta clase utiliza el patrón Factory para retornar las instrucciones apropiadas
/// según el número de actividad solicitado, garantizando consistencia en toda la aplicación.
///
/// Ejemplo de uso:
/// ```dart
/// String instructions = ActivityInstructions.getInstructionForActivity(1);
/// print(instructions); // Muestra las instrucciones de la Actividad 1
/// ```
/// {@endtemplate}
class ActivityInstructions {
  // Constructor privado para prevenir instanciación accidental
  ActivityInstructions._();

  // Constantes para validación y mantenibilidad
  static const int _minActivityNumber = 1;
  static const int _maxActivityNumber = 6;
  static const String _defaultMessage =
      'No hay instrucciones disponibles para esta actividad.';

  // Instrucciones específicas organizadas como constantes privadas
  static const String _activity1Instructions =
      'Actividad 1: Reconocimiento de números\n\n'
      'Selecciona el número en sistema arábigo que corresponde al número '
      'expresado en lengua namtrik, entre cuatro opciones disponibles.';

  static const String _activity2Instructions =
      'Actividad 2: Escritura de números en namtrik\n\n'
      'Escribe en namtrik el número que aparece en pantalla, utilizando la '
      'ortografía adecuada.';

  static const String _activity3Instructions =
      'Actividad 3: Lectura y escritura de la hora\n\n'
      '• Ejercicio 1: Empareja correctamente la hora en formato digital con su '
      'correspondiente expresión en lengua namtrik.\n'
      '• Ejercicio 2: Selecciona, entre cuatro opciones, la hora correcta que '
      'corresponde a la mostrada en un reloj analógico.\n'
      '• Ejercicio 3: Escribe la hora indicada, colocando los valores correctos '
      'en las casillas correspondientes a horas y minutos.';

  static const String _activity4Instructions =
      'Actividad 4: Manejo del dinero en contexto namtrik\n\n'
      '• Ejercicio 1: Identifica las monedas y sus respectivos nombres en lengua namtrik.\n'
      '• Ejercicio 2: Selecciona el precio correcto del artículo que aparece en '
      'pantalla, entre cuatro opciones posibles.\n'
      '• Ejercicio 3: Indica la cantidad de dinero representada por las monedas '
      'mostradas en el recuadro superior.\n'
      '• Ejercicio 4: Selecciona la combinación adecuada de monedas para '
      'representar el número expresado en namtrik.';

  static const String _activity5Instructions =
      'Actividad 5: Convertidor numérico\n\n'
      'Utiliza esta herramienta para convertir números del sistema arábigo al '
      'sistema numérico en lengua namtrik.';

  static const String _activity6Instructions =
      'Actividad 6: Minidiccionario por campos semánticos\n\n'
      'Consulta un diccionario ilustrado organizado por temas. Puedes ampliar '
      'cada imagen y escuchar su pronunciación correspondiente en lengua namtrik.';

  // Mapa de instrucciones para acceso más eficiente
  static const Map<int, String> _instructions = {
    1: _activity1Instructions,
    2: _activity2Instructions,
    3: _activity3Instructions,
    4: _activity4Instructions,
    5: _activity5Instructions,
    6: _activity6Instructions,
  };

  /// Obtiene las instrucciones detalladas para una actividad específica.
  ///
  /// Este método proporciona las instrucciones completas y formateadas para
  /// cualquier actividad educativa disponible en la aplicación.
  ///
  /// [activityNumber] Número identificador de la actividad (debe estar entre 1 y 6)
  ///
  /// Retorna las instrucciones formateadas como [String] o un mensaje de error
  /// para números de actividad inválidos o fuera del rango permitido.
  ///
  /// Ejemplo:
  /// ```dart
  /// String help = ActivityInstructions.getInstructionForActivity(1);
  /// // Retorna las instrucciones de reconocimiento de números
  /// ```
  static String getInstructionForActivity(int activityNumber) {
    // Validación explícita del rango de entrada
    if (activityNumber < _minActivityNumber ||
        activityNumber > _maxActivityNumber) {
      return _defaultMessage;
    }

    // Retorno seguro usando el operador null-aware
    return _instructions[activityNumber] ?? _defaultMessage;
  }

  /// Obtiene la lista de todos los números de actividad disponibles.
  ///
  /// Útil para validaciones o para generar interfaces dinámicas.
  ///
  /// Retorna una [List<int>] con todos los números de actividad válidos.
  static List<int> getAvailableActivityNumbers() {
    return List.generate(
      _maxActivityNumber - _minActivityNumber + 1,
      (index) => _minActivityNumber + index,
    );
  }

  /// Verifica si un número de actividad es válido.
  ///
  /// [activityNumber] Número a validar
  ///
  /// Retorna `true` si el número está en el rango válido, `false` en caso contrario.
  static bool isValidActivityNumber(int activityNumber) {
    return activityNumber >= _minActivityNumber &&
        activityNumber <= _maxActivityNumber;
  }
}
