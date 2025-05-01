# Actividad 1: Muntsik mөik kөtasha sөl lau (Escoja el número correcto)

## Objetivo

Esta actividad está diseñada para ayudar a los usuarios a reconocer y asociar los nombres de los números en Namtrik con sus correspondientes numerales arábigos.

## Descripción del Juego

1.  **Pantalla de Niveles:** Al iniciar la actividad, el usuario ve una lista de niveles (`Activity1Screen`). Los niveles pueden estar bloqueados o desbloqueados según el progreso del usuario.
2.  **Pantalla de Juego (`Activity1LevelScreen`):**
    *   Al seleccionar un nivel, se muestra una palabra que representa un número en Namtrik en la parte superior de la pantalla.
    *   Se proporciona un botón para escuchar la pronunciación del número en Namtrik.
    *   En la parte inferior, se presentan cuatro opciones numéricas (arábigas).
    *   El usuario debe seleccionar la opción numérica que corresponde a la palabra Namtrik mostrada.
3.  **Retroalimentación:**
    *   Si la respuesta es correcta, el usuario recibe una felicitación, gana puntos (si es la primera vez que completa el nivel) y se desbloquea el siguiente nivel.
    *   Si la respuesta es incorrecta, se le notifica al usuario y se descuenta un intento. El usuario tiene un número limitado de intentos por nivel.
    *   Se utiliza feedback háptico para reforzar las interacciones.

## Componentes Clave

*   **Pantallas:**
    *   `activity1_screen.dart`: Muestra la lista de niveles y maneja la navegación hacia el nivel seleccionado.
    *   `screens/activity1_level_screen.dart`: Contiene la lógica principal del juego para un nivel específico.
*   **Servicios:**
    *   `services/activity1_service.dart`: Encapsula la lógica para obtener los datos del nivel (números, opciones), reproducir audio y posiblemente manejar la carga de datos desde el JSON.
*   **Modelos:**
    *   `models/number_word.dart`: Representa la estructura de datos para un número, incluyendo su valor numérico, su representación en palabra Namtrik y la ruta a su archivo de audio.
*   **Datos:**
    *   La actividad probablemente utiliza datos de `assets/data/namtrik_numbers.json` (a confirmar) para obtener la lista de números, palabras y rutas de audio.
*   **Estado:**
    *   Utiliza `ActivitiesState` (gestionado por `provider`) para rastrear el progreso general entre actividades y niveles.
    *   `GameState` (también `provider`) para gestionar puntos globales y niveles completados.
    *   El estado local de `Activity1LevelScreen` maneja los intentos restantes, el número actual, las opciones y el estado de reproducción de audio.

## Estado Actual

*   ✅ Pantalla de selección de niveles implementada.
*   ✅ Lógica principal del juego (mostrar palabra, opciones, verificación, audio, intentos, puntuación) implementada en `Activity1LevelScreen`.
*   🔄 **Pendiente:**
    *   Refinamiento de la interfaz de usuario (UI) y la experiencia de usuario (UX).
    *   Carga y validación completa del contenido para todos los niveles definidos (actualmente hasta 7 niveles previstos).
    *   Posibles animaciones o efectos visuales adicionales.
