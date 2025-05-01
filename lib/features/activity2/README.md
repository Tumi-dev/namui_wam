# Actividad 2: Muntsikelan pөram kusrekun (Aprendamos a escribir los números)

## Objetivo

Esta actividad tiene como objetivo enseñar y practicar la escritura correcta de los nombres de los números en el idioma Namtrik.

## Descripción del Juego

1.  **Pantalla de Niveles:** Al igual que en la Actividad 1, el usuario selecciona un nivel desbloqueado desde `Activity2Screen`.
2.  **Pantalla de Juego (`Activity2LevelScreen`):**
    *   Se muestra un número en formato arábigo en la parte superior.
    *   Se presenta un campo de texto donde el usuario debe escribir el nombre correspondiente a ese número en Namtrik.
    *   Un botón "Validar" permite al usuario comprobar su respuesta.
3.  **Retroalimentación:**
    *   Si la escritura es correcta, se felicita al usuario, se otorgan puntos (si es la primera vez) y se desbloquea el siguiente nivel.
    *   Si la escritura es incorrecta, se notifica al usuario, se marca el campo de texto (temporalmente) y se descuenta un intento. El número de intentos es limitado.
    *   Se utiliza feedback háptico.

## Componentes Clave

*   **Pantallas:**
    *   `activity2_screen.dart`: Muestra la lista de niveles (hasta 7 implementados).
    *   `screens/activity2_level_screen.dart`: Contiene la lógica principal del juego: muestra el número arábigo, el campo de texto y maneja la validación.
*   **Servicios:**
    *   `services/activity2_service.dart`: Encapsula la lógica para obtener números aleatorios por nivel y verificar si la respuesta escrita por el usuario es correcta (comparándola con la palabra Namtrik esperada).
*   **Modelos:**
    *   Aunque no hay un modelo específico visible en el código analizado para esta actividad (parece usar `Map<String, dynamic>`), la lógica se basa en la asociación entre un número (`int`) y su representación escrita en Namtrik (`String`).
*   **Datos:**
    *   Utiliza datos, probablemente de `assets/data/namtrik_numbers.json` (a confirmar), para obtener la correspondencia número-palabra.
*   **Estado:**
    *   Similar a la Actividad 1, usa `ActivitiesState` y `GameState` (via `provider`) para el progreso general y los puntos.
    *   El estado local de `Activity2LevelScreen` maneja los intentos, el número actual y el contenido del `TextEditingController`.

## Estado Actual

*   ✅ Pantalla de selección de niveles implementada.
*   ✅ Lógica principal del juego (mostrar número arábigo, campo de texto, validación, intentos, puntuación) implementada en `Activity2LevelScreen` para los niveles 1 a 7.
*   ✅ Límite explícito a 7 niveles implementado.
*   🔄 **Pendiente:**
    *   Refinamiento de la interfaz de usuario (UI) y la experiencia de usuario (UX), especialmente en el manejo del teclado y la validación.
    *   Carga y validación completa del contenido para los 7 niveles.
    *   Considerar si se necesita un modelo de datos específico en lugar de `Map<String, dynamic>`.
