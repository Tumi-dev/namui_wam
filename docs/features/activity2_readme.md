# Actividad 2: Muntsikelan pөram kusrekun (Aprendamos a escribir los números)

## Objetivo

Esta actividad está diseñada para ayudar a los usuarios a practicar la escritura correcta de los nombres de los números en el idioma Namtrik. A diferencia de la Actividad 1 que se centra en el reconocimiento, esta actividad enfoca la producción activa del lenguaje, requiriendo que los estudiantes recuerden y escriban correctamente las palabras Namtrik.

## Funcionamiento

La actividad se estructura de la siguiente manera:

1. **Pantalla de Niveles (`Activity2Screen`):** 
   * Muestra una lista de niveles, organizados por rango numérico:
     * Nivel 1: Números del 1 al 9
     * Nivel 2: Números del 10 al 99
     * Nivel 3: Números del 100 al 999
     * Nivel 4: Números del 1,000 al 9,999
     * Nivel 5: Números del 10,000 al 99,999
     * Nivel 6: Números del 100,000 al 999,999
     * Nivel 7: Números del 1,000,000 al 9,999,999
   * Los niveles se desbloquean progresivamente según el avance del usuario.
   * El primer nivel siempre está desbloqueado.

2. **Pantalla de Juego (`Activity2LevelScreen`)**:
   * Al seleccionar un nivel, se muestra:
     * Un número en formato arábigo en la parte superior (ej. "42").
     * Un campo de texto donde el usuario debe escribir el nombre correspondiente en Namtrik.
     * Un botón "Validar" para verificar la respuesta ingresada.
   * El usuario debe escribir correctamente el nombre del número en Namtrik.
   * Cada nivel presenta un número aleatorio dentro del rango correspondiente.
   * El usuario tiene tres intentos para acertar.

3. **Validación de Respuestas**:
   * El sistema verifica si la respuesta del usuario coincide con:
     * La forma principal de la palabra en Namtrik.
     * Composiciones alternativas de la palabra (por ejemplo, formas descompuestas).
     * Variaciones dialectales o de escritura.
   * La validación ignora mayúsculas/minúsculas y espacios extra.

4. **Retroalimentación**:
   * **Respuesta correcta**: 
     * Se muestra un diálogo de felicitación.
     * Se actualiza el progreso en `ActivitiesState` y `GameState`.
     * Se ganan 5 puntos (solo en la primera vez que se completa el nivel).
     * Se desbloquea el siguiente nivel automáticamente.
   * **Respuesta incorrecta**: 
     * El borde del campo de texto cambia temporalmente a rojo.
     * Se reduce el número de intentos restantes.
     * Se muestra un mensaje indicando que la respuesta es incorrecta.
     * Al agotar los intentos, se permite reiniciar con un nuevo número.
   * Se utiliza feedback háptico (vibración) para reforzar las interacciones.

## Componentes

### Pantallas

* **`activity2_screen.dart`**: 
  * Pantalla principal que muestra la lista de niveles disponibles.
  * Implementa la navegación hacia el nivel seleccionado.
  * Utiliza `Consumer<ActivitiesState>` para obtener el estado actualizado de los niveles.
  * Muestra cada nivel como una tarjeta con indicación visual de su estado (bloqueado/desbloqueado).
  * Utiliza colores específicos para esta actividad (dorados/ocres) para una identidad visual distintiva.

* **`screens/activity2_level_screen.dart`**: 
  * Contiene la lógica principal del juego para un nivel específico.
  * Hereda de `BaseLevelScreen` para mantener consistencia con otras actividades.
  * Gestiona:
    * La carga de números aleatorios para el nivel actual.
    * La interfaz del campo de texto y validación de entrada.
    * La verificación de respuestas mediante `Activity2Service`.
    * El manejo de intentos, errores y actualización del progreso.
    * La retroalimentación visual y háptica.

### Servicios

* **`services/activity2_service.dart`**: 
  * Centraliza la lógica específica de la actividad:
    * Obtiene números aleatorios para cada nivel desde `NumberDataService`.
    * Define los rangos numéricos para cada nivel de dificultad.
    * Implementa la validación de respuestas con tolerancia a variaciones.
    * Compara la respuesta del usuario con diferentes formas válidas (principal, composiciones, variaciones).
  * Proporciona métodos públicos como `getRandomNumberForLevel`, `getNumbersForLevel` e `isAnswerCorrect`.
  * Utiliza `LoggerService` para registrar errores durante la ejecución.

### Datos

* **`assets/data/namuiwam_numbers.json`**: 
  * Archivo JSON que contiene todos los números en Namtrik, incluyendo:
    * Representación numérica
    * Palabra principal Namtrik
    * Composiciones alternativas
    * Variaciones dialectales o de escritura
  * Organizado para facilitar el acceso por rango numérico.

### Modelos Utilizados

La actividad utiliza principalmente estructuras de datos genéricas (`Map<String, dynamic>`) para representar los números, en lugar de un modelo específico. Estos mapas contienen:

* `number`: El valor numérico (ej. 42).
* `namtrik`: La representación principal en Namtrik (ej. "pik kan ɵntrɵ metrik pala").
* `compositions`: Formas alternativas compuestas.
* `variations`: Variaciones dialectales o de escritura aceptables.

## Servicios Centrales Utilizados

* **`NumberDataService`**: Para el acceso y procesamiento de los datos de números desde el JSON.
* **`FeedbackService`**: Para proporcionar retroalimentación háptica durante las interacciones.
* **`LoggerService`**: Para registrar eventos y errores durante la ejecución.
* **`ActivitiesState`**: Para gestionar el progreso general y los puntos.

## Estado Actual

* ✅ Pantalla de selección de niveles completamente implementada.
* ✅ Lógica de juego implementada: 
  * Generación de números aleatorios por nivel.
  * Campo de texto con validación.
  * Verificación de respuestas con tolerancia a variaciones.
  * Gestión de intentos.
* ✅ Integración con el sistema central de progreso y puntuación.
* ✅ Retroalimentación visual y háptica.
* ✅ Implementación completa para los niveles 1 a 7.

## Pendiente (Roadmap)

* 🔄 Refinamiento de la UX del teclado (posición, comportamiento, sugerencias).
* 🔄 Implementación de ayudas visuales para facilitar el aprendizaje.
* 🔄 Posible conversión de la estructura de datos genérica a un modelo específico.
* 🔄 Animaciones adicionales para reforzar el feedback visual.
* 🔄 Tutoriales interactivos para usuarios principiantes.

### Jugabilidad y Mecánicas

- **Presentación del Problema:** Se muestra un número en formato arábigo (ej. "42").
- **Entrada del Usuario:** El usuario debe escribir la representación correcta de ese número en idioma Namtrik utilizando un campo de texto. Puede hacer uso de un teclado estándar o, si está implementado, un teclado Namtrik personalizado.
- **Validación:** Al presionar un botón de "Validar" o similar:
    - El sistema compara la respuesta ingresada con las formas correctas conocidas para ese número (puede haber múltiples variaciones válidas en Namtrik).
    - Se proporciona retroalimentación inmediata.
    - Se utilizan efectos de sonido (proporcionados por `SoundService`) para reforzar la retroalimentación de acierto o error.
- **Intentos:** El usuario tiene un número limitado de intentos (usualmente 3) para escribir correctamente el número.
- **Puntuación y Progreso:** Al acertar, el usuario gana puntos y, si es la primera vez que completa el nivel, este se marca como superado, potencialmente desbloqueando el siguiente.
