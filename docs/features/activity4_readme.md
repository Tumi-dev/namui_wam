# Actividad 4: Anwan ashipelɵ kɵkun (Aprendamos a usar el dinero)

## Objetivo

Esta actividad está diseñada para familiarizar a los usuarios con el sistema monetario utilizado en la cultura Namui Wam a través del idioma Namtrik. Los usuarios aprenderán a identificar diferentes denominaciones de billetes y monedas, comprender sus valores, asociarlos con sus nombres en Namtrik y utilizarlos en transacciones simuladas básicas.

## Funcionamiento

La actividad se estructura en cuatro niveles progresivos, cada uno enfocado en un aspecto específico del manejo del dinero en Namtrik:

1. **Nivel 1: Conozcamos el dinero Namtrik**
   * Se presentan las diferentes denominaciones de billetes y monedas a través de un paginador horizontal.
   * Cada página muestra una imagen de la denominación, su nombre en Namtrik y un botón de audio para escuchar la pronunciación.
   * El usuario puede tocar la imagen para ver su reverso (cuando está disponible).
   * No hay un objetivo de juego específico; es una etapa introductoria de familiarización y aprendizaje.

2. **Nivel 2: Escojamos el dinero correcto**
   * Se muestra la imagen de un artículo junto con su precio escrito en Namtrik.
   * Debajo se presentan cuatro opciones, cada una con diferentes combinaciones de billetes y monedas.
   * El usuario debe seleccionar la opción cuyo valor total coincida exactamente con el precio del artículo.
   * Las selecciones incorrectas reducen el número de intentos disponibles.

3. **Nivel 3: Escojamos el nombre correcto**
   * Se muestra un conjunto de billetes y monedas Namtrik en la parte superior.
   * Debajo se presentan cuatro opciones de nombres en Namtrik.
   * El usuario debe seleccionar el nombre que describe correctamente el valor total de las denominaciones mostradas.
   * Las selecciones incorrectas reducen el número de intentos disponibles.

4. **Nivel 4: Coloquemos el dinero correcto**
   * Se presenta un valor monetario total en texto Namtrik.
   * Debajo hay una cuadrícula con todas las posibles denominaciones de billetes y monedas.
   * El usuario debe seleccionar las denominaciones que, en conjunto, suman exactamente el valor objetivo.
   * Un contador muestra el valor acumulado de las selecciones actuales.
   * Las combinaciones incorrectas reducen el número de intentos disponibles.

Los cuatro niveles utilizan una estética común con colores rojizos terrosos que temáticamente distinguen esta actividad de las demás en la aplicación.

## Componentes

### Pantallas

* **`activity4_screen.dart`**: 
  * Pantalla principal que muestra la lista de los cuatro niveles disponibles.
  * Implementa la navegación hacia el nivel seleccionado.
  * Utiliza `Consumer<ActivitiesState>` para obtener el estado actualizado de los niveles.
  * Incluye un icono distintivo de dinero (attach_money) que identifica visualmente la temática de la actividad.
  * Utiliza colores específicos (rojo terroso, `0xFFCD5C5C`) para la identidad visual de esta actividad.

* **`screens/activity4_level_screen.dart`**: 
  * Contiene la lógica principal de los cuatro tipos de juego.
  * Hereda de `ScrollableLevelScreen` para mantener consistencia con otras actividades.
  * Implementa cuatro interfaces distintas según el nivel seleccionado:
    * Nivel 1: Interfaz de exploración con PageView para navegar entre denominaciones.
    * Nivel 2: Interfaz de selección de opciones con imagen de artículo y cuatro conjuntos de dinero.
    * Nivel 3: Interfaz de selección de nombres con imagen de dinero y cuatro opciones de texto.
    * Nivel 4: Interfaz de selección múltiple con cuadrícula de denominaciones y contador de valor.
  * Gestiona la carga de datos, la validación de respuestas y la actualización del progreso.
  * Proporciona retroalimentación visual y háptica según las interacciones del usuario.

### Servicios

* **`services/activity4_service.dart`**: 
  * Centraliza la lógica específica de la actividad:
    * Carga datos desde múltiples archivos JSON (dinero, artículos, combinaciones predefinidas).
    * Genera opciones para los diferentes niveles, asegurando que exista una opción correcta.
    * Proporciona métodos de validación para verificar respuestas.
    * Gestiona la reproducción secuencial de archivos de audio para nombres compuestos.
    * Calcula totales y determina equivalencias entre denominaciones y valores.
  * Mantiene un estado compartido entre los diferentes niveles para evitar recargar datos.
  * Utiliza métodos auxiliares para generar opciones aleatorias pero consistentes.

### Modelos

* **`models/namtrik_money_model.dart`**: 
  * Modelo de datos que representa una denominación de dinero (billete o moneda).
  * Propiedades:
    * `number`: Identificador único de la denominación.
    * `moneyImages`: Lista de rutas a imágenes (anverso y reverso cuando existe).
    * `moneyNamtrik`: Nombre o descripción en Namtrik.
    * `valueMoney`: Valor numérico de la denominación.
    * `audiosNamtrik`: Ruta al archivo de audio con la pronunciación.
  * Incluye métodos para serialización/deserialización desde JSON.

* **`models/namtrik_article_model.dart`**: 
  * Modelo de datos que representa un artículo con su precio.
  * Propiedades:
    * `number`: Identificador único del artículo.
    * `imageArticle`: Ruta a la imagen del artículo.
    * `priceArticle`: Precio numérico.
    * `namePriceNamtrik`: Nombre/descripción del precio en Namtrik.
    * `numberMoneyImages`: Lista de identificadores de denominaciones que componen el precio.
  * Incluye métodos para serialización/deserialización desde JSON.

### Datos

Los datos utilizados por la actividad se almacenan en varios archivos JSON:

* **`assets/data/namtrik_money.json`**: 
  * Define todas las denominaciones monetarias disponibles en Namtrik.
  * Incluye rutas a imágenes, nombres, valores y archivos de audio.
  * Utilizado en todos los niveles como referencia principal.

* **`assets/data/namtrik_articles.json`**: 
  * Define los artículos disponibles para el Nivel 2.
  * Incluye imágenes, precios y las denominaciones requeridas para pagarlos.

* **`assets/data/a4_l3_namuiwam_money.json`**: 
  * Define combinaciones predefinidas de dinero y sus valores en Namtrik para el Nivel 3.
  * Incluye opciones incorrectas para generar desafíos consistentes.

* **`assets/data/a4_l4_namuiwam_money.json`**: 
  * Define valores objetivo en Namtrik y las denominaciones que los componen para el Nivel 4.
  * Garantiza que existan combinaciones válidas para cada desafío.

## Servicios Centrales Utilizados

* **`ActivitiesState`**: Para gestionar el progreso y estado de bloqueo de los niveles.
* **`GameState`**: Para gestionar la puntuación y el registro de niveles completados.
* **`FeedbackService`**: Para proporcionar retroalimentación háptica durante las interacciones.
* **`AudioService`**: Para reproducir secuencialmente archivos de audio con nombres de denominaciones.

## Estado Actual

* ✅ Pantalla principal (`activity4_screen.dart`) implementada, mostrando los cuatro niveles.
* ✅ Estructura de datos para los cuatro niveles definida.
* ✅ Implementación del Nivel 1 (Exploración) completada con:
  * Paginación horizontal de denominaciones.
  * Visualización de anverso/reverso mediante tap.
  * Reproducción de audio con nombres en Namtrik.
* ✅ Implementación del Nivel 2 (Seleccionar dinero) completada con:
  * Generación aleatoria de artículos y opciones.
  * Validación de la opción seleccionada.
  * Feedback visual para respuestas correctas e incorrectas.
* ✅ Implementación del Nivel 3 (Seleccionar nombre) completada con:
  * Generación de conjuntos de denominaciones con valor conocido.
  * Opciones de texto con nombres en Namtrik.
  * Validación de la selección y retroalimentación.
* ✅ Implementación del Nivel 4 (Colocar dinero) completada con:
  * Selección múltiple de denominaciones desde una cuadrícula.
  * Cálculo dinámico del valor acumulado.
  * Validación contra el valor objetivo.
* ✅ Integración con el sistema central de progreso y puntuación.
* ✅ Retroalimentación visual y háptica en los cuatro niveles.

## Pendiente (Roadmap)

* 🔄 Añadir animaciones más elaboradas para las transiciones entre estados de juego.
* 🔄 Implementar un modo de práctica con mayor variedad de desafíos monetarios.
* 🔄 Mejorar la adaptabilidad de la interfaz para diferentes dispositivos y orientaciones.
* 🔄 Añadir tutoriales interactivos para cada nivel.
* 🔄 Expandir la base de datos de artículos para incluir más elementos culturalmente relevantes.
