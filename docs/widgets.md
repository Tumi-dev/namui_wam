# Widgets

Esta sección documenta los widgets reutilizables de la aplicación Namuiwam. Estos widgets encapsulan elementos de interfaz de usuario comunes que se utilizan en varias partes de la aplicación.

## Widgets Core

Widgets fundamentales que proporcionan funcionalidades básicas de UI:

- **InfoBar**: Barra de información que muestra intentos restantes y puntos globales.
- **ProgressIndicatorWidget**: Barra de progreso con indicadores de pasos discretos.
- **GameDescriptionWidget**: Widget para mostrar descripciones de juegos o actividades.

## Widgets de Actividades

Widgets específicos para cada actividad:

### Actividad 1: Escoja el número correcto
- **OptionTile**: Muestra opciones numéricas seleccionables.
- **NumberCard**: Muestra un número en formato especial.

### Actividad 2: Aprendamos a escribir los números
- **KeyboardWidget**: Teclado personalizado para escribir palabras en Namtrik.
- **WordInputField**: Campo de entrada para palabras Namtrik con validación.

### Actividad 3: Aprendamos a ver la hora
- **ClockWidget**: Muestra un reloj analógico interactivo.
- **TimeDisplay**: Muestra la hora en formato digital y Namtrik.

### Actividad 4: Aprendamos a usar el dinero
- **CoinWidget**: Representa una moneda Namtrik visual e interactiva.
- **PriceDisplay**: Muestra precios en formato Namtrik.

### Actividad 5: Convertir números en letras
- **NumberInput**: Campo para ingresar números arábigos.
- **ConversionResult**: Muestra el resultado de la conversión a Namtrik.

### Actividad 6: Diccionario
- **DomainCard**: Tarjeta para mostrar un dominio semántico.
- **DictionaryEntryTile**: Muestra una entrada del diccionario con palabra, traducción e imagen.

## Widgets Compartidos

Widgets utilizados en múltiples partes de la aplicación:

- **AudioButton**: Botón para reproducir archivos de audio.
- **ZoomableImageViewer**: Visor de imágenes con funcionalidad de zoom y paneo.
- **CustomButton**: Botón estilizado según el tema de la aplicación.
- **FeedbackOverlay**: Superpone efectos visuales para retroalimentación al usuario.

## Patrones y Buenas Prácticas

Los widgets en Namuiwam siguen estos principios de diseño:

- **Componentes Pequeños**: Los widgets se diseñan para realizar una función específica.
- **Reutilización**: Se promueve la reutilización mediante parametrización.
- **Separación de Responsabilidades**: Los widgets de presentación se separan de la lógica de negocio.
- **Accesibilidad**: Se implementan consideraciones de accesibilidad como semántica y tamaños adecuados. 