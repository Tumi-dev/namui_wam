# Actividad 3: Nөsik utөwan asam kusrekun (Aprendamos a ver la hora)

## Objetivo

Esta actividad está diseñada para enseñar a los usuarios a reconocer, interpretar y expresar la hora en idioma Namtrik. A diferencia de las Actividades 1 y 2 que se enfocan en números generales, esta actividad se especializa en el vocabulario y las estructuras relacionadas con las horas del día, fortaleciendo un aspecto específico y cotidiano del lenguaje.

## Funcionamiento

La actividad se estructura en tres niveles, cada uno correspondiente a una modalidad diferente de interacción con el concepto de la hora:

1. **Nivel 1: Utөwan lata marөp (Emparejar la hora)**
   * Se presentan 4 relojes con diferentes horas y sus correspondientes descripciones en Namtrik.
   * Los relojes y las descripciones aparecen en orden aleatorio.
   * El usuario debe tocar primero un reloj y luego la descripción que corresponde a esa hora.
   * Al completar los 4 emparejamientos correctamente, se completa el nivel.
   * Las selecciones incorrectas reducen el número de intentos disponibles.

2. **Nivel 2: Utөwan wetөpeñ (Adivina la hora)**
   * Se muestra un reloj con una hora específica en la parte superior.
   * Se presentan 4 opciones de texto en Namtrik como posibles descripciones de la hora.
   * El usuario debe seleccionar la opción que describe correctamente la hora mostrada.
   * La selección incorrecta reduce los intentos disponibles.

3. **Nivel 3: Utөwan malsrө (Coloca la hora)**
   * Se presenta una descripción de hora en Namtrik en la parte superior.
   * Se proporcionan dos selectores desplegables para ajustar la hora y los minutos.
   * El usuario debe configurar el reloj para que coincida con la descripción en Namtrik.
   * Cada configuración incorrecta reduce los intentos disponibles.

Los tres niveles utilizan una estética común con colores tierra/marrón que temáticamente distinguen esta actividad de las demás en la aplicación.

## Componentes

### Pantallas

* **`activity3_screen.dart`**: 
  * Pantalla principal que muestra la lista de los tres niveles disponibles.
  * Implementa la navegación hacia el nivel seleccionado.
  * Utiliza `Consumer<ActivitiesState>` para obtener el estado actualizado de los niveles.
  * Incluye un icono distintivo de reloj que identifica visualmente la temática de la actividad.
  * Utiliza colores específicos (marrón/tierra) para la identidad visual de esta actividad.

* **`screens/activity3_level_screen.dart`**: 
  * Contiene la lógica principal de los tres tipos de juego.
  * Hereda de `ScrollableLevelScreen` para mantener consistencia con otras actividades.
  * Implementa tres interfaces distintas según el nivel seleccionado:
    * Nivel 1: Interfaz de emparejamiento con dos columnas de elementos seleccionables.
    * Nivel 2: Interfaz de selección múltiple con una imagen de reloj y opciones de texto.
    * Nivel 3: Interfaz de configuración de reloj con selectores para horas y minutos.
  * Gestiona la carga de datos, la validación de respuestas y la actualización del progreso.
  * Proporciona retroalimentación visual y háptica según las interacciones del usuario.

### Servicios

* **`services/activity3_service.dart`**: 
  * Centraliza la lógica específica de la actividad:
    * Carga datos para cada nivel desde el archivo JSON de horas.
    * Selecciona elementos aleatorios apropiados para cada nivel.
    * Para el Nivel 1: Selecciona 4 pares de reloj-texto para emparejar.
    * Para el Nivel 2: Selecciona un reloj y 4 opciones de texto (1 correcta, 3 incorrectas).
    * Para el Nivel 3: Selecciona una descripción en Namtrik y extrae la hora y minuto correctos.
  * Utiliza `LoggerService` para registrar errores durante la ejecución.

### Widgets

* **`widgets/selectable_item.dart`**: 
  * Widget personalizado para representar elementos seleccionables (imágenes de relojes o textos).
  * Implementa distintos estados visuales (`SelectionState`):
    * `unselected`: Estado inicial, sin interacción.
    * `selected`: El elemento ha sido seleccionado por el usuario.
    * `matched`: El elemento ha formado un par correcto con otro.
    * `error`: El elemento formó un par incorrecto.
  * Proporciona transiciones animadas entre estados mediante `AnimatedContainer`.
  * Incluye soporte para accesibilidad mediante etiquetas semánticas.

### Datos

* **`data/activity3_levels.dart`**: 
  * Define los tres niveles de la actividad con sus títulos y descripciones.
  * Utiliza constantes desde `ActivityLevelDescriptions` para mantener consistencia.

* **`assets/data/namtrik_hours.json`**: 
  * Archivo JSON que contiene datos sobre horas en Namtrik, incluyendo:
    * Valores numéricos (horas, minutos).
    * Representaciones textuales en Namtrik.
    * Rutas a imágenes de relojes que muestran horas específicas.

## Servicios Centrales Utilizados

* **`ActivitiesState`**: Para gestionar el progreso y estado de bloqueo de los niveles.
* **`GameState`**: Para gestionar la puntuación y el registro de niveles completados.
* **`FeedbackService`**: Para proporcionar retroalimentación háptica durante las interacciones.
* **`LoggerService`**: Para registrar eventos y errores durante la ejecución.

## Estado Actual

* ✅ Pantalla principal (`activity3_screen.dart`) implementada, mostrando los tres niveles.
* ✅ Estructura de datos para los tres niveles definida en `activity3_levels.dart`.
* ✅ Implementación del Nivel 1 (Emparejar) completada con:
  * Selección aleatoria de relojes y descripciones.
  * Lógica de emparejamiento y validación.
  * Retroalimentación visual mediante cambios de estado y colores.
* ✅ Implementación del Nivel 2 (Adivinar) completada con:
  * Selección de un reloj y generación de opciones múltiples.
  * Validación de la respuesta seleccionada.
  * Feedback visual para respuestas correctas e incorrectas.
* ✅ Implementación del Nivel 3 (Colocar) completada con:
  * Selectores desplegables para horas y minutos.
  * Validación de la configuración del reloj.
  * Animaciones de éxito y error.
* ✅ Integración con el sistema central de progreso y puntuación.
* ✅ Retroalimentación visual y háptica en los tres niveles.

## Pendiente (Roadmap)

La funcionalidad principal de la actividad está completa. Futuras mejoras podrían incluir:

* Refinar la adaptabilidad de la interfaz para diferentes tamaños de pantalla.
* Mejorar la visualización de relojes, posiblemente con un widget de reloj analógico animado.
* Expandir la base de datos de horas para incluir expresiones más complejas y contextuales.

### Jugabilidad y Mecánicas (Común a los Sub-Niveles)

Aunque cada sub-nivel tiene una interacción específica, comparten algunas mecánicas:

- **Instrucciones Claras:** Cada nivel presenta una tarea específica al usuario.
- **Interacción:** El usuario interactúa seleccionando elementos, emparejando, o ajustando valores.
- **Retroalimentación Inmediata:** 
    - El sistema valida la acción del usuario y provee feedback visual (colores, animaciones) y háptico.
    - Se utilizan efectos de sonido (proporcionados por `SoundService`) para reforzar la retroalimentación de acierto o error en cada interacción evaluada.
- **Sistema de Intentos:** El jugador tiene un número limitado de intentos para completar la tarea correctamente.
- **Puntuación y Progreso:** Al superar un nivel, se otorgan puntos y se marca como completado, permitiendo el avance.
