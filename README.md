# Tsatsɵ Musik - Aplicación Educativa Namtrik

![Logo](assets/images/1.logo-colibri.png) <!-- Considerar actualizar a logo-colibri_v1.png si es la versión final -->

## Descripción
Tsatsɵ Musik es una aplicación móvil educativa e interactiva, desarrollada con Flutter, diseñada para facilitar el aprendizaje de conceptos básicos como números, vocabulario y más en el idioma Namtrik. La aplicación busca combinar contenido culturalmente relevante con actividades lúdicas y una interfaz atractiva para niños y estudiantes.

## Estado del Proyecto
- **Versión actual:** 1.0.0+1 (según `pubspec.yaml`)
- **Estado de desarrollo:** En desarrollo activo
- **Progreso estimado:** ~65-70% (Funcionalidad base de 5/6 actividades implementada, servicios core, estructura)

### Características Implementadas

*   **Servicios Principales:**
    *   Gestión de reproducción de audio (`AudioService`).
    *   Servicio de Sonido Centralizado (`SoundService`):
        *   Música de fondo continua con gestión de ciclo de vida (pausa/reanudación automática).
        *   Efectos de sonido para interacciones (e.g., correcto/incorrecto en actividades).
        *   Configuración de volumen independiente para música y efectos.
        *   Controles para habilitar/deshabilitar música y efectos.
        *   Persistencia de configuraciones de audio (volumen, habilitado/deshabilitado) usando Hive.
        *   Configuración de `AudioContext` para permitir la reproducción concurrente de música de fondo y otros sonidos de la app.
    *   Feedback háptico (`FeedbackService`).
    *   Gestión del estado del juego (puntos, niveles completados) (`GameState`).
    *   Gestión del estado de las actividades (`ActivitiesState`).
*   **Actividad 1: Muntsik mөik kөtasha sөl lau (Escoja el número correcto)** (Estado: Completo)
    *   Objetivo: Asociar palabras numéricas Namtrik con números arábigos.
    *   Jugabilidad: Muestra una palabra numérica en Namtrik; el usuario selecciona el número arábigo correspondiente entre varias opciones.
    *   Incluye efectos de sonido para respuestas correctas e incorrectas.
*   **Actividad 2: Muntsikelan pөram kusrekun (Aprendamos a escribir los números)** (Estado: Completo)
    *   Objetivo: Practicar la escritura de palabras numéricas Namtrik.
    *   Jugabilidad: Muestra un número arábigo; el usuario escribe la palabra Namtrik correspondiente usando un teclado personalizado.
    *   Incluye efectos de sonido para respuestas correctas e incorrectas.
*   **Actividad 3: Nөsik utөwan asam kusrekun (Aprendamos a ver la hora)** (Estado: Refactorización Pendiente)
    *   Objetivo: Aprender a decir la hora usando números Namtrik en relojes analógicos y digitales.
    *   *Implementación Actual:* Muestra niveles numerados, probablemente para asociar números con posiciones del reloj. Incluye efectos de sonido para respuestas correctas e incorrectas en la lógica de niveles existente.
    *   *Diseño Deseado:* Tres sub-actividades: 1) Emparejar hora digital con reloj analógico, 2) Adivinar la hora mostrada en un reloj analógico, 3) Poner las manecillas en un reloj analógico a una hora digital dada.
    *   *Estado:* Requiere una refactorización significativa para coincidir con el diseño deseado.
*   **Actividad 4: Anwan ashipelɵ kɵkun (Aprendamos a usar el dinero)** (Estado: Completo, con mejoras recientes)
    *   Objetivo: Aprender sobre la moneda Namtrik, sus valores y transacciones básicas.
    *   Jugabilidad: Consiste en cuatro sub-actividades (niveles):
        1.  **Conozcamos el dinero Namtrik:** Identificar imágenes de la moneda, escuchar sus nombres y ver sus valores.
        2.  **Escojamos el dinero correcto:** Seleccionar la combinación de dinero para igualar el precio de un artículo.
        3.  **Escojamos el nombre correcto:** Elegir el nombre Namtrik para el valor total de un grupo de dinero.
        4.  **Coloquemos el dinero correcto (Mejorado):** Dado un valor en Namtrik, el usuario selecciona billetes/monedas. La interfaz ahora incluye un recuadro con los ítems seleccionados (con opción a eliminarlos) y un botón de "Validar". La lógica de validación es flexible y acepta **cualquier combinación correcta** definida en los datos del juego, no solo una.
*   **Actividad 5: Muntsielan namtrikmai yunөmarөpik (Convertir números en letras)** (Estado: Completo)
    *   Objetivo: Convertir números arábigos a su forma escrita en Namtrik.
    *   Jugabilidad: El usuario ingresa un número (1-9,999,999), y la app muestra su escritura en Namtrik. Incluye opciones para escuchar la pronunciación, así como para copiar y compartir tanto el número ingresado como su texto Namtrik resultante.
*   **Actividad 6: Wammeran tulisha manchípik kui asamik pөrik (Diccionario)** (Estado: Funcionalidad Base Completa)
    *   Objetivo: Consultar un léxico básico de palabras Namtrik organizadas por categorías, con soporte visual y auditivo.
    *   Funcionalidad:
        *   Navegación por dominios semánticos: Asrumunchimera (partes del cuerpo), Ushamera (animales), Maintusrmera (plantas comestibles), Pisielɵ (colores), Namui kewa amɵneiklɵ (vestido), Srɵwammera (neologismos), Wamap amɵñikun (saludos).
        *   Visualización de entradas: Muestra la palabra en Namtrik, su traducción al español, y una imagen asociada.
        *   Reproducción de audio: Permite escuchar la pronunciación de la palabra Namtrik (y sus variantes si existen).
        *   Visor de imágenes: Permite ampliar y hacer zoom en la imagen asociada.
    *   *Estado:* La funcionalidad principal de consulta está implementada. Pendiente: Búsqueda/filtrado.

### Roadmap (Próximas Características)

*   **Refactorización Actividad 3:** Implementar las tres sub-actividades planeadas para decir la hora.
*   **Mejoras Actividad 6 (Diccionario):**
    *   Añadir funcionalidad de búsqueda/filtrado dentro de los dominios o en todo el diccionario.
    *   Posiblemente añadir ejercicios interactivos basados en el diccionario.
*   **Perfiles de Usuario y Seguimiento de Progreso:** Permitir múltiples usuarios y guardar el progreso individualmente.
*   **Configuraciones:** Opciones para volumen de sonido (música de fondo y efectos), habilitar/deshabilitar tipos de audio (implementado vía `SoundService`). Ajustes de dificultad.
*   **Mejoras de Accesibilidad:** Mejorar el soporte para lectores de pantalla y métodos de entrada alternativos.
*   **Optimización y Pruebas:** Mejorar el rendimiento, añadir pruebas unitarias y de integración.

## Capturas de Pantalla

<!-- Añadir aquí algunas capturas de pantalla o un GIF mostrando la app -->
<!-- Ejemplo: -->
<!-- ![Pantalla Principal](screenshots/main_screen.png?raw=true "Pantalla Principal") -->

## Requisitos Técnicos
- Flutter SDK: >=3.19.3 <4.0.0 <!-- Actualizado según pubspec.yaml implícito -->
- Dart SDK: >=3.3.1 <4.0.0 <!-- Actualizado según pubspec.yaml implícito -->
- Plataformas Destino: Android (iOS pendiente de configuración/pruebas)
- **Android:** `minSdkVersion 21` (Configurado en `android/app/build.gradle`)

## Estructura del Proyecto
```
namui_wam/
├── android/          # Código específico de Android
├── assets/           # Recursos estáticos (imágenes, audio, JSON)
│   ├── audio/
│   │   ├── dictionary/ # Audios categorizados del diccionario Namtrik
│   │   └── namtrik_numbers/ # Audios de números Namtrik
│   ├── data/         # Archivos de datos (JSON) para actividades
│   └── images/       # Imágenes (UI, iconos, contenido)
├── ios/              # Código específico de iOS
├── lib/              # Código fuente Dart
│   ├── core/         # Lógica central, servicios, modelos, utils, widgets base
│   ├── features/     # Módulos funcionales (pantallas/actividades)
│   │   ├── activity1/ - activity6/
│   │   └── home/     # Pantalla principal o de inicio
│   ├── shared/       # Widgets reutilizables entre features
│   └── main.dart     # Punto de entrada de la aplicación
├── test/             # Pruebas (a implementar)
├── pubspec.yaml      # Definición del proyecto y dependencias
└── README.md         # Esta documentación
```

## Documentación Detallada por Actividad
Para obtener información más detallada sobre la implementación, jugabilidad y componentes de cada actividad, consulta los siguientes archivos README:

*   [Actividad 1: Muntsik mөik kөtasha sөl lau (Escoja el número correcto)](docs/features/activity1_readme.md)
*   [Actividad 2: Muntsikelan pөram kusrekun (Aprendamos a escribir los números)](docs/features/activity2_readme.md)
*   [Actividad 3: Nөsik utөwan asam kusrekun (Aprendamos a ver la hora)](docs/features/activity3_readme.md)
*   [Actividad 4: Anwan ashipelɵ kɵkun (Aprendamos a usar el dinero)](docs/features/activity4_readme.md)
*   [Actividad 5: Muntsielan namtrikmai yunөmarөpik (Convertir números en letras)](docs/features/activity5_readme.md)
*   [Actividad 6: Wammeran tulisha manchípik kui asamik pөrik (Diccionario)](docs/features/activity6_readme.md)

## Recursos Clave y Dependencias
El proyecto utiliza varios recursos y paquetes de Flutter:
- **Assets:** Incluye una colección organizada de:
    - Archivos de audio (`.mp3`, `.wav`) para números y diccionario Namtrik.
    - Archivos de datos `.json` que estructuran el contenido de las actividades.
    - Imágenes (`.png`, `.jpg`) para la interfaz, iconos, logos y elementos visuales.
- **Dependencias Principales:**
    - `flutter/material`: Framework base de UI.
    - `provider`: Para la gestión del estado (uso actual limitado, planeado para estados complejos).
    - `audioplayers`: Reproducción de archivos de audio (integrado en `AudioPlayerService`).
    - `get_it`: Inyección de dependencias (Service Locator pattern implementado en `lib/core/di`).
    - `logger`: Para el registro de eventos y depuración (integrado en `LoggerService`).
    - `sqflite` / `path_provider`: Para la base de datos local del diccionario (Actividad 6).
    - `flutter_native_splash`: Para la pantalla de bienvenida.
- **Dependencias de Desarrollo:**
    - `flutter_lints`: Reglas de análisis estático.
    - `build_runner`: (Necesario si se usa `hive_generator` u otros generadores)
    - `flutter_launcher_icons`: Personalización del icono de la app.

## Instalación y Ejecución
1.  Asegúrate de tener Flutter (versión compatible, ver Requisitos Técnicos) instalado y configurado.
2.  Clona el repositorio:
    ```powershell
    git clone [URL-del-repositorio]
    cd namui_wam
    ```
3.  Instala las dependencias:
    ```powershell
    flutter pub get
    ```
4.  Ejecuta la aplicación (asegúrate de tener un emulador/dispositivo conectado):
    ```powershell
    flutter run
    ```

## Contribución
<!-- Opcional: Si el proyecto es abierto a contribuciones -->
Actualmente, el desarrollo es gestionado internamente. Si estás interesado en contribuir, por favor contacta a los mantenedores.

<!-- O si es abierto: -->
<!--
Para contribuir al proyecto:
1. Crea un fork del repositorio.
2. Crea una rama para tu función: `git checkout -b feature/nueva-funcion`
3. Realiza tus cambios y haz commit: `git commit -m 'Añade nueva función'`
4. Asegúrate de que el código pase el linter: `flutter analyze`
5. Envía tus cambios: `git push origin feature/nueva-funcion`
6. Crea un Pull Request detallando los cambios.
-->

## Licencia
<!-- Especificar la licencia aquí -->
Ejemplo: Licencia MIT

```
Copyright (c) 2025 Tsatsɵ Musik Developers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

O

**Propiedad Intelectual:** El contenido cultural (idioma Namtrik, imágenes, audios) pertenece a la comunidad Namtrik. El código fuente de la aplicación está licenciado bajo Licencia MIT, pero el contenido cultural tiene sus propias restricciones de uso y distribución que deben ser respetadas.

## Contacto
Para más información o soporte:
- Email: contacto@tsatsomusik.dev
- Website/Organización: https://tsatsomusik.dev

## Documentación

### Documentación de Código (DartDoc)

La aplicación utiliza dartdoc para generar documentación automática del código. Para generar la documentación:

1. Asegúrate de tener dartdoc instalado (o usa la versión del proyecto con el siguiente comando):
   ```powershell
   dart pub global activate dartdoc
   ```

2. Genera la documentación desde la raíz del proyecto usando el comando recomendado:
   ```powershell
   dart run dartdoc
   ```

3. La documentación generada estará disponible en la carpeta `doc/api/`. Puedes abrirla en un navegador:
   ```powershell
   start doc/api/index.html   # Windows
   open doc/api/index.html    # macOS
   xdg-open doc/api/index.html  # Linux
   ```

### Estándares de Documentación

El proyecto sigue los estándares de documentación definidos en [guía de estilo de DartDoc](docs/DARTDOC_STYLE_GUIDE.md). Este documento contiene las guías y ejemplos para mantener una documentación consistente en todo el código.

La documentación está organizada en las siguientes categorías principales:
- **Actividades**: Documentación de las 6 actividades educativas.
- **Servicios**: Servicios para la lógica de negocio y acceso a datos.
- **Widgets**: Componentes de UI reutilizables.
- **Modelos**: Modelos de datos y entidades del dominio.

### Recursos Adicionales

- [Documentación Oficial de Dart](https://dart.dev/guides/language/effective-dart/documentation)
- [Guía de dartdoc](https://dart.dev/tools/dartdoc)
