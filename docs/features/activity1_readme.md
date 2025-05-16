# Actividad 1: Muntsik mөik kөtasha sөl lau (Escoja el número correcto)

## Objetivo

Esta actividad está diseñada para ayudar a los usuarios a reconocer y asociar los nombres de los números en Namtrik con sus correspondientes numerales arábigos. Es una actividad de reconocimiento y comprensión auditiva, donde los estudiantes deben identificar el número correcto al escuchar y leer su forma en idioma Namtrik.

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
     * Nivel 7: Números del 1,000,000 al 9,999,999
   * Los niveles pueden estar bloqueados o desbloqueados según el progreso del usuario.
   * El primer nivel siempre está desbloqueado.
   * Al completar un nivel, se desbloquea el siguiente.

2. **Pantalla de Juego (`Activity1LevelScreen`)**:
   * Al seleccionar un nivel, se muestra:
     * Una palabra en Namtrik que representa un número en la parte superior.
     * Un botón de audio para escuchar la pronunciación del número.
     * Cuatro opciones numéricas (en dígitos arábigos).
   * El usuario debe seleccionar la opción numérica que corresponde a la palabra Namtrik mostrada.
   * Cada nivel presenta un número aleatorio dentro del rango apropiado para ese nivel.
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
    * Obtiene un número aleatorio para el nivel actual desde `NumberDataService`.
    * Genera opciones alternativas (distractores) para cada pregunta.
    * Maneja la reproducción de archivos de audio con pausas apropiadas según el nivel.
    * Gestiona el tratamiento de errores y proporciona opciones de fallback.
  * Trabaja con `AudioService` para reproducir los archivos de audio de manera secuencial.
  * Utiliza `LoggerService` para registrar errores y eventos durante la ejecución.

### Modelos

* **`models/number_word.dart`**: 
  * Representa la estructura de datos para un número en Namtrik.
  * Almacena:
    * El valor numérico (ej. 42).
    * La representación en palabra Namtrik (ej. "pik kan ɵntrɵ metrik pala").
    * La lista de rutas a los archivos de audio asociados.
    * El nivel al que pertenece.

* **`models/game_state.dart`**: 
  * Gestiona el estado específico de la Actividad 1 (implementación de respaldo/legacy).
  * Utiliza el patrón Singleton para mantener una única instancia.
  * Rastreaba el progreso y puntuación antes de la implementación centralizada con `ActivitiesState`.
  * Mantiene la compatibilidad con posibles referencias existentes.

### Datos

* **`assets/data/namuiwam_numbers.json`**: 
  * Archivo JSON que contiene todos los números en Namtrik, incluyendo:
    * Representación numérica
    * Palabra(s) Namtrik
    * Rutas a archivos de audio
  * Organizado para facilitar el acceso por rango numérico.

* **`assets/audio/numbers/`**: 
  * Directorio que contiene los archivos de audio para las pronunciaciones de los números.
  * Incluye componentes individuales (unidades, decenas, etc.) para números complejos.

## Servicios Centrales Utilizados

* **`AudioService`**: Para la reproducción de los archivos de audio de los números en Namtrik.
* **`NumberDataService`**: Para el acceso y procesamiento de los datos de números desde el JSON.
* **`FeedbackService`**: Para proporcionar retroalimentación háptica durante las interacciones.
* **`LoggerService`**: Para registrar eventos y errores durante la ejecución.

## Estado Actual

* ✅ Pantalla de selección de niveles completamente implementada.
* ✅ Lógica de juego implementada: 
  * Generación de números aleatorios por nivel.
  * Opciones de selección múltiple.
  * Verificación de respuestas.
  * Reproducción de audio.
  * Gestión de intentos.
* ✅ Integración con el sistema central de progreso y puntuación.
* ✅ Retroalimentación visual y háptica.

## Pendiente (Roadmap)

* 🔄 Refinamiento de la interfaz de usuario para mejorar la accesibilidad.
* 🔄 Animaciones adicionales para reforzar el feedback visual.
* 🔄 Posibles tutoriales interactivos para los primeros usuarios.
* 🔄 Expansión de contenido con ejemplos contextuales de uso de números en Namtrik.
