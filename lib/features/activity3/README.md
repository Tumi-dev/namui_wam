# Actividad 3: Nөsik utөwan asam kusrekun (Aprendamos a ver la hora)

## Objetivo General

Enseñar a los usuarios a leer, interpretar y escribir la hora en el idioma Namtrik utilizando diferentes formatos interactivos.

## Descripción Deseada

La actividad está diseñada para tener una pantalla principal (`Activity3Screen`) que presente tres sub-actividades distintas:

1.  **Utөwan lata marөp (Emparejar la hora):** Mostrar relojes con horas específicas y las horas correspondientes escritas en Namtrik de forma desordenada. El usuario debe emparejar correctamente cada reloj con su descripción.
2.  **Utөwan wetөpeñ (Adivina la hora):** Mostrar un reloj con una hora determinada. El usuario debe seleccionar la descripción correcta en Namtrik entre cuatro opciones.
3.  **Utөwan malsrө (Coloca la hora):** Mostrar una hora escrita en Namtrik. El usuario debe ajustar las manecillas de un reloj analógico para que coincidan con la hora descrita.

Esta actividad no se basa en niveles incrementales, sino en completar un número mínimo de ejercicios correctos dentro de cada sub-actividad para obtener una recompensa.

## Implementación Actual

*   **Pantalla Principal (`activity3_screen.dart`):**
    *   Actualmente, esta pantalla **no muestra las tres sub-actividades descritas**. En su lugar, sigue el patrón de las Actividades 1 y 2, mostrando una lista de **niveles numerados** (1, 2, 3...). Las descripciones de estos niveles actuales son genéricas ("Nivel 1", "Nivel 2", etc.) y no corresponden a las sub-actividades.
    *   Al seleccionar uno de estos "niveles", navega a `Activity3LevelScreen`.
*   **Pantalla de Nivel (`screens/activity3_level_screen.dart`):**
    *   Existe una pantalla genérica de nivel. Su contenido actual no está definido y no implementa la lógica específica de ninguna de las tres sub-actividades deseadas.

## Componentes Clave (Actuales)

*   **Pantallas:**
    *   `activity3_screen.dart`: Muestra la lista de "niveles" numerados.
    *   `screens/activity3_level_screen.dart`: Pantalla destino genérica, lógica de juego no implementada.
*   **Servicios:**
    *   `services/activity3_service.dart`: Existe, pero su funcionalidad específica no está definida en el código analizado.
*   **Modelos:**
    *   Utiliza `LevelModel` para la lista en `activity3_screen.dart`.
*   **Datos:**
    *   Probablemente necesitará datos de `assets/data/namtrik_hours.json` (a confirmar) para la lógica de las horas.
*   **Widgets:**
    *   La carpeta `widgets/` sugiere que podría haber widgets específicos para esta actividad (ej. un widget de reloj), pero su contenido no ha sido analizado.

## Estado Actual y Discrepancia

*   ✅ Pantalla principal (`activity3_screen.dart`) existe, pero muestra una **estructura de niveles incorrecta** en lugar de las tres sub-actividades deseadas.
*   ❌ La lógica de juego para las sub-actividades (Emparejar, Adivinar, Colocar) **no está implementada**.
*   🔄 **Pendiente (Refactorización Mayor):**
    *   Modificar `activity3_screen.dart` para que muestre botones o tarjetas que representen las tres sub-actividades (Emparejar, Adivinar, Colocar).
    *   Crear pantallas separadas o modificar `activity3_level_screen.dart` para implementar la lógica específica de cada una de las tres sub-actividades.
    *   Implementar la lógica de juego sin niveles, basada en completar un número mínimo de ejercicios.
    *   Definir y cargar los datos necesarios (horas, descripciones Namtrik).
