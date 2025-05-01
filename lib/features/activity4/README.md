# Actividad 4: Anwan ashipelɵ kɵkun (Aprendamos a usar el dinero)

## Objetivo

Esta actividad tiene como fin familiarizar a los usuarios con el sistema monetario Namtrik utilizado en la cultura Namui Wam. Cubre la identificación de diferentes denominaciones, la comprensión de sus valores, la asociación con sus nombres en Namtrik y su uso en transacciones simuladas básicas.

## Jugabilidad

La Actividad 4 se divide en cuatro niveles secuenciales (sub-actividades):

1.  **Nivel 1: Conozcamos el dinero Namtrik**
    *   **Meta:** Identificar diferentes monedas y billetes Namtrik.
    *   **Mecánica:** Muestra imágenes de cada pieza monetaria una por una. Los usuarios pueden tocar la imagen para ver el reverso (si está disponible). Se muestra el nombre en Namtrik del valor de la pieza y un botón de audio permite escuchar la pronunciación. Los usuarios navegan por todas las denominaciones usando un paginador.
2.  **Nivel 2: Escojamos el dinero correcto**
    *   **Meta:** Seleccionar la cantidad correcta de dinero requerida para pagar un artículo.
    *   **Mecánica:** Se muestra una imagen de un artículo junto con su precio escrito en Namtrik. Se presentan cuatro opciones, cada una conteniendo una combinación de imágenes de dinero. El usuario debe seleccionar la opción cuyo valor total coincida con el precio del artículo. Se proporciona retroalimentación (correcto/incorrecto) y se rastrean los intentos.
3.  **Nivel 3: Escojamos el nombre correcto**
    *   **Meta:** Asociar un grupo de piezas monetarias con el nombre Namtrik correcto para su valor total.
    *   **Mecánica:** Se muestra una colección de imágenes de dinero Namtrik. Cuatro cuadros de texto muestran diferentes nombres de números/valores en Namtrik. El usuario debe seleccionar el cuadro que contiene el nombre Namtrik correcto para el valor total del dinero mostrado. Se incluye retroalimentación y seguimiento de intentos.
4.  **Nivel 4: Coloquemos el dinero correcto**
    *   **Meta:** Formar un valor total específico usando las piezas monetarias disponibles.
    *   **Mecánica:** Se presenta un valor total objetivo en texto Namtrik. Una cuadrícula muestra todas las denominaciones de dinero Namtrik disponibles. El usuario selecciona piezas de la cuadrícula. El sistema calcula el total acumulado de las piezas seleccionadas. El usuario envía su selección cuando crea que coincide con el valor objetivo. Se da retroalimentación basada en si el total seleccionado es correcto. Se rastrean los intentos.

## Componentes

*   **`activity4_screen.dart`**: La pantalla de entrada principal para la actividad, mostrando las cuatro opciones de nivel.
*   **`screens/activity4_level_screen.dart`**: Implementa la interfaz de usuario y la lógica para los cuatro niveles, adaptándose según el `level.id`. Maneja la interacción del usuario, la gestión del estado (pieza actual, selecciones, retroalimentación) y la comunicación con el servicio.
*   **`services/activity4_service.dart`**: Maneja la carga de datos desde archivos JSON, la recuperación de datos específicos de dinero/artículos, la generación de opciones para los niveles 2 y 3, el cálculo de valores, la provisión de rutas de imágenes y la gestión de la reproducción de audio para los nombres de las monedas.
*   **`models/namtrik_money_model.dart`**: Modelo de datos que representa una única pieza monetaria Namtrik (moneda/billete), incluyendo su ID, imágenes (anverso/reverso), nombre Namtrik, valor numérico y archivos de audio asociados.
*   **`models/namtrik_article_model.dart`**: Modelo de datos que representa un artículo, incluyendo su ID, imagen, precio numérico, precio en texto Namtrik y la lista de números de piezas monetarias requeridas para pagarlo.

## Fuentes de Datos

*   `assets/data/namtrik_money.json`: Contiene definiciones para todas las denominaciones monetarias Namtrik (imágenes, nombres, valores, audio). Usado en todos los niveles.
*   `assets/data/namtrik_articles.json`: Contiene definiciones para artículos (imagen, precio, nombre del precio en Namtrik, dinero requerido). Usado en el Nivel 2.
*   `assets/data/a4_l3_namuiwam_money.json`: Contiene grupos predefinidos de piezas monetarias y su valor total correspondiente en texto Namtrik. Usado en el Nivel 3.
*   `assets/data/a4_l4_namuiwam_money.json`: Contiene valores totales predefinidos en texto Namtrik y la lista correspondiente de piezas monetarias necesarias para alcanzar ese total. Usado en el Nivel 4.
*   `assets/images/money/`: Directorio que contiene archivos de imagen para las piezas monetarias.
*   `assets/images/articles/`: Directorio que contiene archivos de imagen para los artículos.
*   `assets/audio/namtrik_numbers/`: Directorio que contiene archivos de audio para las pronunciaciones de números/valores Namtrik.

## Estado

Completo. Las cuatro sub-actividades están implementadas según la lógica descrita.
