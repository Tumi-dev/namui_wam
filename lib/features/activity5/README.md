# Actividad 5: Muntsielan namtrikmai yunɵmarɵpik (Convertir números en letras)

## Objetivo

Esta actividad funciona como una herramienta de utilidad para convertir números arábigos (en el rango de 1 a 9,999,999) a su representación escrita completa en el idioma Namtrik. Facilita el aprendizaje y uso correcto de la escritura de números complejos.

## Jugabilidad / Funcionamiento

La interfaz presenta dos áreas principales:

1.  **Entrada Numérica:**
    *   Un campo de texto (`TextField`) donde el usuario puede ingresar un número utilizando el teclado numérico.
    *   Se aplican validaciones para permitir solo dígitos y limitar la longitud a 7 caracteres (hasta 9,999,999).
    *   Se valida que el número ingresado esté dentro del rango permitido (1 a 9,999,999). No se permite el 0.
2.  **Resultado en Namtrik:**
    *   Un contenedor de texto muestra la representación escrita del número ingresado en Namtrik.
    *   Si la entrada está vacía, es inválida (fuera de rango) o si ocurre un error al obtener la conversión, se muestra un mensaje indicativo.
    *   Mientras se procesa la conversión, se muestra un indicador de carga.

**Acciones Disponibles:**

*   **Escuchar:** Un botón con icono de volumen (`Icons.volume_up`) que se activa si existe audio disponible para el número convertido. Al presionarlo, reproduce la pronunciación del número en Namtrik.
*   **Copiar:** Un botón con icono de copiar (`Icons.content_copy`) que permite copiar el texto Namtrik resultante al portapapeles del dispositivo.
*   **Compartir:** Un botón con icono de compartir (`Icons.share`) que permite compartir el texto Namtrik resultante a través de otras aplicaciones (requiere integración con un plugin de compartición).

## Componentes

*   **`activity5_screen.dart`**: Implementa la interfaz de usuario completa, incluyendo el campo de entrada, el área de resultado y los botones de acción. Maneja el estado de la interfaz (entrada, resultado, carga, disponibilidad de audio, reproducción), la interacción del usuario y la comunicación con el servicio.
*   **`services/activity5_service.dart`**: Contiene la lógica para:
    *   Validar el número de entrada.
    *   Llamar a `NumberDataService` para obtener la representación Namtrik y los archivos de audio asociados al número.
    *   Interactuar con `AudioService` para reproducir y detener la pronunciación del número.

## Servicios Centrales Utilizados

*   **`NumberDataService`**: (Asumido) Servicio responsable de cargar y consultar los datos de `assets/data/namtrik_numbers.json` para obtener la escritura y los nombres de archivo de audio para un número dado.
*   **`AudioService`**: Servicio centralizado para la reproducción de archivos de audio.
*   **`FeedbackService`**: Para proporcionar retroalimentación háptica al interactuar con los botones.

## Fuentes de Datos

*   `assets/data/namtrik_numbers.json`: (Asumido) Archivo JSON que contiene el mapeo entre números arábigos, su escritura en Namtrik y los nombres de los archivos de audio correspondientes.
*   `assets/audio/namtrik_numbers/`: Directorio que contiene los archivos de audio (`.wav`) para la pronunciación de los números.

## Estado

Completo. La funcionalidad descrita está implementada.
