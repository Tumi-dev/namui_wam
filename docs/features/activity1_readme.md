# Actividad 1: Muntsik mөik kөtasha sөl lau (Escoja el número correcto)

## Objetivo

Esta actividad está diseñada para ayudar a los usuarios a reconocer y asociar los nombres de los números en Namtrik con sus correspondientes numerales arábigos. Es una actividad de reconocimiento y comprensión auditiva, donde los estudiantes deben identificar el número correcto al escuchar y leer su forma en idioma Namtrik, cubriendo números hasta 9,999,999 mediante composición dinámica para el rango superior.

## Funcionamiento

La actividad se estructura de la siguiente manera:

1. **Pantalla de Niveles (`Activity1Screen`):** 
   * Muestra una lista de niveles, organizados por rango numérico:
     * Nivel 1: Números del 1 al 9
     * Nivel 2: Números del 10 al 99
     * Nivel 3: Números del 100 al 999
     * Nivel 4: Números del 1,000 al 9,999
     * Nivel 5: Números del 10,000 al 99,999
     * Nivel 6: Números del 100,000 al 999,999
     * Nivel 7: Números del 1,000,000 al 9,999,999 (soporte completo, incluyendo números compuestos dinámicamente)
   * Los niveles pueden estar bloqueados o desbloqueados según el progreso del usuario.
   * El primer nivel siempre está desbloqueado.
   * Al completar un nivel, se desbloquea el siguiente.

2. **Pantalla de Juego (`Activity1LevelScreen`)**:
   * Al seleccionar un nivel, se muestra:
     * Una palabra en Namtrik que representa un número en la parte superior.
     * Un botón de audio para escuchar la pronunciación del número.
     * Cuatro opciones numéricas (en dígitos arábigos).
   * El usuario debe seleccionar la opción numérica que corresponde a la palabra Namtrik mostrada.
   * Cada nivel presenta un número aleatorio dentro del rango apropiado. Para el Nivel 7, esto incluye números entre 1,000,000 y 9,999,999 que pueden ser generados dinámicamente si no existen explícitamente en los datos base (ej. 1,000,001).
   * El usuario tiene tres intentos para acertar.

3. **Retroalimentación**:
   * **Respuesta correcta**: 
     * Se muestra un diálogo de felicitación.
     * Se actualiza el progreso en `ActivitiesState` y `GameState`.
     * Se ganan 5 puntos (solo en la primera vez que se completa el nivel).
     * Se desbloquea el siguiente nivel automáticamente.
   * **Respuesta incorrecta**: 
     * Se reduce el número de intentos restantes.
     * Se muestra un mensaje indicando que la respuesta es incorrecta.
     * Al agotar los intentos, se permite reiniciar el nivel.
   * Se utiliza feedback háptico (vibración) para reforzar las interacciones.
   * La reproducción de audio para números compuestos es secuencial y clara, evitando solapamientos.

## Componentes

### Pantallas

* **`activity1_screen.dart`**: 
  * Pantalla principal que muestra la lista de niveles disponibles.
  * Implementa la navegación hacia el nivel seleccionado.
  * Utiliza `Consumer<ActivitiesState>` para obtener el estado actualizado de los niveles.
  * Muestra cada nivel como una tarjeta con indicación visual de su estado (bloqueado/desbloqueado).

* **`screens/activity1_level_screen.dart`**: 
  * Contiene la lógica principal del juego para un nivel específico.
  * Muestra el número en Namtrik y las opciones numéricas.
  * Gestiona la reproducción de audio, la verificación de respuestas, y la actualización del progreso.
  * Hereda de `ScrollableLevelScreen` para mantener un diseño consistente con otras actividades.
  * Implementa `WidgetsBindingObserver` para manejar el ciclo de vida de la aplicación (detener audio cuando la app pasa a segundo plano).

### Servicios

* **`services/activity1_service.dart`**: 
  * Centraliza la lógica específica de la actividad:
    * Obtiene un número aleatorio para el nivel actual. Para el Nivel 7, esto incluye la capacidad de generar números en todo el rango de 1,000,000 a 9,999,999, utilizando `NumberDataService` para obtener datos compuestos.
    * Genera opciones alternativas (distractores) para cada pregunta, asegurando que para el Nivel 7 los distractores también puedan ser números compuestos válidos dentro del rango.
    * Maneja la reproducción secuencial de archivos de audio (utilizando `AudioService.playAudioAndWait`) con pausas apropiadas según el nivel, asegurando una reproducción clara y sin solapamientos.
    * Gestiona el tratamiento de errores y proporciona opciones de fallback.
  * Trabaja con `AudioService` para reproducir los archivos de audio de manera secuencial y clara.
  * Utiliza `LoggerService` para registrar errores y eventos durante la ejecución.

### Modelos

* **`models/number_word.dart`**: 
  * Representa la estructura de datos para un número en Namtrik.
  * Almacena:
    * El valor numérico (ej. 42 o 1,234,567).
    * La representación en palabra Namtrik (ej. "Piptsi Pa" o una combinación más larga para números compuestos).
    * La lista de rutas a los archivos de audio asociados (pueden ser múltiples para números compuestos).
    * El nivel al que pertenece.

* **`models/game_state.dart`**: 
  * Gestiona el estado específico de la Actividad 1 (implementación de respaldo/legacy).
  * Utiliza el patrón Singleton para mantener una única instancia.
  * Rastreaba el progreso y puntuación antes de la implementación centralizada con `ActivitiesState`.
  * Mantiene la compatibilidad con posibles referencias existentes.

### Datos

* **`assets/data/namuiwam_numbers.json`**: 
  * Archivo JSON que contiene números base en Namtrik (principalmente hasta 999,999 y millones exactos).
  * Incluye: representación numérica, palabra(s) Namtrik, composiciones, rutas a archivos de audio.
  * Utilizado por `NumberDataService` para consulta directa y como base para la composición dinámica de números más grandes.

* **`assets/audio/numbers/`**: 
  * Directorio que contiene los archivos de audio para las pronunciaciones de los números.
  * Incluye componentes individuales (unidades, decenas, etc.) para números complejos.

## Servicios Centrales Utilizados

* **`AudioService`**: Para la reproducción secuencial y clara (sin solapamientos) de los archivos de audio de los números en Namtrik, mediante el método `playAudioAndWait`.
* **`NumberDataService`**: Para el acceso y procesamiento de los datos de números desde el JSON, y para la **composición dinámica de números de 7 dígitos** que no están explícitamente en el JSON.
* **`FeedbackService`**: Para proporcionar retroalimentación háptica durante las interacciones.
* **`LoggerService`**: Para registrar eventos y errores durante la ejecución.

## Estado Actual

* ✅ Pantalla de selección de niveles completamente implementada.
* ✅ Lógica de juego implementada para todos los niveles (1-7):
  * Generación de números aleatorios por nivel, **incluyendo el rango completo 1,000,000-9,999,999 para el Nivel 7 mediante composición dinámica**.
  * Opciones de selección múltiple, con distractores válidos para el Nivel 7.
  * Verificación de respuestas.
  * Reproducción de audio secuencial mejorada (sin solapamientos).
  * Gestión de intentos.
* ✅ Integración con el sistema central de progreso y puntuación.
* ✅ Retroalimentación visual y háptica.

## Pendiente (Roadmap)

La funcionalidad principal de la actividad está completa. Futuras mejoras podrían incluir:

* Refinamiento de la interfaz de usuario para mejorar la accesibilidad.
* Animaciones adicionales para reforzar el feedback visual.
* Expansión de contenido con ejemplos contextuales de uso de números en Namtrik.

### Jugabilidad y Mecánicas

- **Presentación del Problema:** Se muestra al usuario una palabra numérica escrita en Namtrik.
- **Opciones de Respuesta:** Se presentan varias opciones de números arábigos, una de las cuales corresponde a la palabra Namtrik mostrada.
- **Interacción del Usuario:** El usuario debe tocar o seleccionar el número arábigo que considera correcto.
- **Retroalimentación:** 
    - El sistema indica inmediatamente si la selección fue correcta o incorrecta.
    - Se utilizan efectos de sonido (proporcionados por `SoundService`) para reforzar la retroalimentación de acierto o error.
    - Se actualiza el contador de intentos restantes.
- **Intentos:** El usuario dispone de un número limitado de intentos (generalmente 3) para acertar.
- **Puntuación:** Al seleccionar la respuesta correcta, el usuario gana puntos que se suman a su progreso global.
- **Avance:** Al completar el nivel (responder correctamente), se desbloquea el siguiente nivel dentro de la actividad (si aplica) y el usuario puede continuar.
