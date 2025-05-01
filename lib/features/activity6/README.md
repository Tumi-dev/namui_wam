# Actividad 6: Wammeran tulisha manchípik kui asamik pөrik (Diccionario)

## Objetivo

Esta actividad proporciona un diccionario básico Namtrik-Español, organizado por categorías semánticas. El objetivo es permitir a los usuarios consultar el significado, la pronunciación y la representación visual de palabras Namtrik fundamentales, seleccionadas por ser comprensibles sin necesidad de contexto gramatical adicional.

## Funcionamiento

La actividad se estructura de la siguiente manera:

1.  **Pantalla Principal (Selección de Dominio):**
    *   Muestra una lista de los dominios semánticos disponibles:
        *   Asrumunchimera (partes del cuerpo)
        *   Ushamera (animales)
        *   Maintusrmera (plantas comestibles)
        *   Pisielɵ (colores)
        *   Namui kewa amɵneiklɵ (vestido)
        *   Srɵwammera (neologismos)
        *   Wamap amɵñikun (saludos)
    *   Cada dominio tiene un icono representativo y un botón de audio para escuchar el nombre del dominio en Namtrik.
    *   Al seleccionar un dominio, se navega a la pantalla de lista de entradas.

2.  **Pantalla de Lista de Entradas:**
    *   Muestra las palabras pertenecientes al dominio semántico seleccionado.
    *   Cada entrada en la lista muestra la palabra en Namtrik y su traducción al español.
    *   Al seleccionar una entrada, se navega a la pantalla de detalle.

3.  **Pantalla de Detalle de Entrada:**
    *   Muestra la información completa de la palabra seleccionada:
        *   Palabra en Namtrik.
        *   Traducción al español.
        *   Una imagen representativa.
        *   Un botón de audio para escuchar la pronunciación de la palabra Namtrik (y sus variantes, si las tiene).
    *   La imagen se puede tocar para abrir un visor que permite ampliarla y hacer zoom.

## Componentes

*   **`activity6_screen.dart`**: Pantalla principal que muestra la lista de dominios semánticos.
*   **`screens/domain_entries_screen.dart`**: Pantalla que muestra la lista de entradas para un dominio seleccionado.
*   **`screens/entry_detail_screen.dart`**: Pantalla que muestra los detalles de una entrada específica (palabra, traducción, imagen, audio).
*   **`widgets/image_viewer_dialog.dart`**: Diálogo reutilizable para mostrar la imagen ampliada con capacidad de zoom.
*   **`services/dictionary_service.dart`**: Servicio que maneja la carga de datos del diccionario desde el archivo JSON, la obtención de dominios, entradas por dominio y detalles de entrada.
*   **`models/dictionary_domain.dart`**: Modelo de datos para un dominio semántico.
*   **`models/dictionary_entry.dart`**: Modelo de datos para una entrada del diccionario.

## Servicios Centrales Utilizados

*   **`AudioService`**: Para la reproducción de los nombres de dominio y las pronunciaciones de las palabras.
*   **`FeedbackService`**: Para retroalimentación háptica.

## Fuentes de Datos

*   `assets/data/a6_namuiwam_dictionary.json`: Archivo JSON que contiene toda la información del diccionario, estructurada por dominios y entradas, incluyendo palabras, traducciones, nombres de imágenes y nombres de archivos de audio.
*   `assets/images/dictionary/`: Directorio que contiene los archivos de imagen asociados a las entradas del diccionario.
*   `assets/audio/dictionary/`: Directorio que contiene los archivos de audio para las pronunciaciones de las palabras y los nombres de dominio.

## Estado

Funcionalidad Base Completa. La consulta y visualización de dominios y entradas, junto con la reproducción de audio y visualización de imágenes, está implementada. Funcionalidades pendientes como búsqueda/filtrado están listadas en el Roadmap del `README.md` principal.
