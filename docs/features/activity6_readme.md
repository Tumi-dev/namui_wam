# Actividad 6: Wammeran tulisha manchípik kui asamik pөrik (Diccionario)

## Objetivo

Esta actividad proporciona un diccionario bilingüe Namtrik-Español organizado por categorías semánticas, permitiendo a los usuarios consultar el significado, pronunciación y representación visual de palabras fundamentales en Namtrik. Su propósito es servir como herramienta de referencia y aprendizaje del vocabulario básico, facilitando la adquisición léxica sin necesidad de contexto gramatical complejo.

## Funcionamiento

El diccionario implementa una navegación intuitiva estructurada en tres niveles jerárquicos:

1. **Pantalla de Dominios Semánticos:**
   * Muestra una cuadrícula interactiva con los dominios disponibles:
     - **Asrumunchimera** (partes del cuerpo)
     - **Ushamera** (animales)
     - **Maintusrmera** (plantas comestibles)
     - **Pisielɵ** (colores)
     - **Namui kewa amɵneiklɵ** (vestido)
     - **Srɵwammera** (neologismos)
     - **Wamap amɵñikun** (saludos)
   * Cada tarjeta de dominio está diseñada para maximizar el uso del espacio y tiene un espaciado reducido con las tarjetas adyacentes. Incluye:
     - Una imagen representativa del dominio, ubicada en la parte superior de la tarjeta.
     - El nombre del dominio en Namtrik, ubicado debajo de la imagen, centrado y mostrando el texto completo.
     - Reproducción automática del audio del nombre del dominio al seleccionar.
     - Retroalimentación háptica al tocar.

2. **Pantalla de Lista de Entradas:**
   * Presenta todas las entradas del dominio seleccionado en un formato de lista desplazable.
   * Cada elemento de la lista tiene un diseño adaptado al dominio:
     * **Para el dominio "Wamap amɵñikun" (saludos):**
       - No se muestra imagen.
       - Los textos para la pregunta y la respuesta (Namtrik y Español) se muestran en un tamaño más grande.
       - Los botones de reproducción de audio para la pregunta y la respuesta son más grandes y se ubican a la derecha de los bloques de texto.
     * **Para todos los demás dominios:**
       - La columna de texto (palabra en Namtrik destacada y traducción al español, con tamaño original) se muestra a la izquierda.
       - Un botón de reproducción de audio (tamaño grande) se ubica a la izquierda de la imagen.
       - La imagen (si está disponible) se muestra a la derecha del botón de audio.
       - Se incluye un indicador visual si la entrada tiene imagen o audio (implícito por la presencia de los mismos).

3. **Pantalla de Detalle de Entrada:**
   * Proporciona la información completa de la palabra seleccionada:
     - Término en Namtrik con su traducción
     - Imagen ilustrativa (si disponible)
     - Reproductor de audio para escuchar la pronunciación
     - Variantes de la palabra (en el caso de pares pregunta-respuesta)
     - Información adicional específica según el tipo de entrada

## Componentes Principales

### Pantallas

* **`activity6_screen.dart`**: 
  - Contenedor principal que carga el gradiente de fondo y configura la AppBar.
  - Delega la visualización del contenido a `DictionaryDomainScreen`.

* **`screens/dictionary_domain_screen.dart`**: 
  - Implementa la cuadrícula de dominios semánticos.
  - Gestiona la carga asíncrona de datos desde `Activity6Service`.
  - Controla la reproducción de audio y navegación al seleccionar un dominio.

* **`screens/dictionary_entries_screen.dart`**: 
  - Muestra la lista filtrada de entradas para el dominio seleccionado.
  - Implementa un diseño adaptativo para diferentes tipos de entradas (especialmente para el dominio "Saludos").
  - Maneja la navegación hacia el detalle de cada entrada.

* **`shared/widgets/zoomable_image_viewer.dart`**: 
  - Proporciona una vista ampliada de las imágenes con capacidad de zoom.
  - Se utiliza como diálogo modal al tocar las imágenes en los detalles.

### Modelos

* **`models/semantic_domain.dart`**: 
  - Define la estructura de datos para los dominios semánticos.
  - Contiene: identificador, nombre y ruta de imagen.
  - Implementa métodos de serialización/deserialización.

* **`models/dictionary_entry.dart`**: 
  - Representa una entrada individual del diccionario.
  - Maneja la complejidad de diferentes tipos de datos según el dominio:
    * Términos simples: palabra y traducción
    * Pares pregunta-respuesta: dos términos relacionados
    * Composiciones: términos con componentes adicionales
  - Incluye lógica para normalizar rutas de recursos según dominio.

### Servicios

* **`services/activity6_service.dart`**: 
  - Centraliza la lógica de acceso y manipulación de datos del diccionario.
  - Implementa:
    * Carga eficiente desde JSON con sistema de caché
    * Filtrado de entradas por dominio
    * Búsqueda por ID o texto
    * Normalización de rutas para recursos (imágenes/audio)
    * Manejo de excepciones y logging
    * Transformación de datos para diferentes dominios

## Integración con Servicios Core

* **`AudioPlayerService`**: 
  - Gestiona la reproducción de audio para los nombres de dominio y las pronunciaciones de palabras.
  - Controla la parada automática del audio al navegar entre pantallas.

* **`FeedbackService`**: 
  - Proporciona retroalimentación háptica durante las interacciones del usuario.
  - Mejora la experiencia táctil al seleccionar dominios y entradas.

* **`LoggerService`**: 
  - Facilita el registro de eventos y errores durante la operación del diccionario.
  - Ayuda en el diagnóstico de problemas de carga de datos o recursos.

## Estructura de Datos

* **Archivo Principal:**
  ```json
  {
    "dictionary": {
      "namui_wam": [
        {
          "Ushamera": [
            {
              "animal_namtrik": "kallum",
              "animal_spanish": "gallina",
              "animal_image": "assets/images/dictionary/ushamera/kallum.jpg",
              "animal_audio": "assets/audio/dictionary/ushamera/kallum.mp3"
            },
            // Más entradas...
          ],
          "Pisielɵ": [
            // Entradas de colores...
          ]
          // Más dominios...
        }
      ]
    }
  }
  ```

* **Estructura de carpetas de recursos:**
  ```
  assets/
  ├── images/
  │   └── dictionary/
  │       ├── ushamera/
  │       ├── pisielɵ/
  │       └── ...
  └── audio/
      └── dictionary/
          ├── ushamera/
          ├── pisielɵ/
          └── ...
  ```

## Características de Diseño

* **Consistencia Visual:**
  - Usa el color coral (0xFFFF7F50) como temático para esta actividad
  - Mantiene el gradiente de fondo común a todas las actividades
  - Aplica Cards elevadas para cada elemento interactivo

* **Usabilidad:**
  - Navegación jerárquica intuitiva (dominios → entradas → detalle)
  - Feedback multisensorial (visual, auditivo, háptico)
  - Elementos interactivos claramente identificables
  - Ampliación de imágenes para mejor visualización

* **Rendimiento:**
  - Carga eficiente de datos con sistema de caché
  - Carga asíncrona de recursos para mantener la fluidez
  - Limpieza de recursos al navegar entre pantallas

## Consideraciones Técnicas

* El diccionario implementa un complejo sistema de normalización de nombres para manejar caracteres especiales del Namtrik (como 'ɵ') en las rutas de archivos.
* Utiliza un modelo flexible para adaptarse a diferentes estructuras de datos según el dominio semántico.
* Se han implementado múltiples mecanismos de fallback para manejar datos faltantes o incorrectos.

## Trabajo Futuro

* **Búsqueda y Filtrado**: Implementar una funcionalidad de búsqueda en todo el diccionario.
* **Favoritos**: Permitir a los usuarios marcar entradas como favoritas para acceso rápido.
* **Pronunciación por TTS**: Añadir soporte para Text-to-Speech como alternativa a archivos de audio predefinidos.
* **Exportación**: Permitir exportar subconjuntos del diccionario para uso offline o compartir.
