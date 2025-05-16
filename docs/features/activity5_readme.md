# Actividad 5: Muntsielan namtrikmai yunɵmarɵpik (Convertir números en letras)

## Objetivo

Esta actividad funciona como una herramienta de utilidad para convertir números arábigos (en el rango de 1 a 9,999,999) a su representación escrita completa en el idioma Namtrik. Facilita el aprendizaje y uso correcto de la escritura de números complejos en el contexto cultural Namtrik.

## Funcionamiento

A diferencia de las actividades anteriores basadas en niveles, la Actividad 5 proporciona una interfaz de herramienta única con las siguientes características:

1. **Entrada Numérica:**
   * Campo de texto (`TextField`) con validación para aceptar solo dígitos numéricos.
   * Restricciones:
     - Rango de entrada válido: 1 a 9,999,999
     - No se permite el número 0
     - Máximo 7 dígitos permitidos
   * Retroalimentación visual (borde rojo) cuando la entrada es inválida.

2. **Visualización del Resultado:**
   * Contenedor que muestra en tiempo real la representación escrita del número en Namtrik.
   * Estados de visualización:
     - Placeholder cuando no hay entrada ("Ingresa un número para ver su representación en Namtrik")
     - Mensaje de error para entradas inválidas
     - Indicador de carga durante el procesamiento
     - Texto completo en Namtrik cuando la conversión es exitosa

3. **Acciones Disponibles:**
   * **Escuchar:** Reproduce la pronunciación del número en Namtrik (solo disponible si existe el audio correspondiente).
   * **Copiar:** Copia el número arábigo ingresado y su representación escrita en Namtrik al portapapeles del dispositivo.
   * **Compartir:** Permite compartir el número arábigo ingresado y su representación escrita en Namtrik a través de otras aplicaciones.

## Componentes Principales

### Pantallas

* **`activity5_screen.dart`**: 
  - Implementa la interfaz de usuario completa, incluyendo:
    * Campo de texto con validación numérica
    * Área de visualización del resultado
    * Botones de acción (escuchar, copiar, compartir)
    * Gestión de estados de interfaz (carga, error, resultado)
  - Mantiene estado de:
    * Número actual ingresado
    * Texto Namtrik resultante
    * Disponibilidad de audio
    * Estado de reproducción de audio
    * Visibilidad del teclado
    * Estado de validación de la entrada

### Servicios

* **`activity5_service.dart`**: 
  - Centraliza la lógica de negocio de la actividad:
    * Validación del rango de números permitidos
    * Consulta a la base de datos de números Namtrik
    * Gestión de la reproducción secuencial de archivos de audio
    * Manejo de errores y registro de eventos

## Integración con Servicios Core

* **`NumberDataService`**: Consulta la base de datos con los mapeos entre números, representaciones en Namtrik y rutas de audio.
* **`AudioService`**: Controla la reproducción y detención de archivos de audio.
* **`LoggerService`**: Registra errores y eventos durante la operación.
* **`FeedbackService`**: Proporciona retroalimentación háptica al interactuar con los botones.

## Estructura de Datos

* **Base de Datos de Números:**
  ```json
  {
    "number": 42,
    "namtrik": "pik pa tap",
    "audio_files": "pik.wav pa.wav tap.wav"
  }
  ```
  - `number`: Valor numérico en arábigo
  - `namtrik`: Representación escrita en Namtrik
  - `audio_files`: Lista de archivos de audio (separados por espacios) para pronunciación secuencial

## Características de Diseño

* **Adaptabilidad:**
  - Ajuste automático cuando el teclado está visible
  - Diseño responsivo para diferentes tamaños de pantalla y orientaciones

* **Accesibilidad:**
  - Feedback visual para errores de validación
  - Indicadores claros para estados de carga y disponibilidad de audio
  - Opciones múltiples para consumir el contenido (visual, auditivo, compartir)

* **UX Mejorada:**
  - Validación en tiempo real mientras el usuario escribe
  - Selección automática del texto al focalizarse en el campo de entrada
  - Retroalimentación háptica en las interacciones principales
  - Detención automática del audio cuando la aplicación pasa a segundo plano

## Recursos Asociados

* **Archivos de Audio:**
  - Ubicación: `assets/audio/namtrik_numbers/`
  - Formato: archivos .wav individuales para cada componente numérico
  - Nombrado: corresponde a las partes individuales de cada número en Namtrik

* **Datos:**
  - `assets/data/namuiwam_numbers.json`: Mapeo completo entre números arábigos y sus representaciones en Namtrik

## Estado

Completo. La funcionalidad descrita está implementada.
