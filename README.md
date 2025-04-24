# Namui Wam - Aplicación Educativa Namtrik

![Logo](assets/images/1.logo-colibri.png)

## Descripción
Namui Wam es una aplicación móvil educativa e interactiva, desarrollada con Flutter, diseñada para facilitar el aprendizaje de los números y otros conceptos básicos en el idioma Namtrik. La aplicación busca combinar contenido culturalmente relevante con actividades lúdicas y una interfaz atractiva para niños y estudiantes.

## Estado del Proyecto
- **Versión actual:** 1.0.0+1 (según `pubspec.yaml`)
- **Estado de desarrollo:** En desarrollo activo
- **Progreso estimado:** ~25% (Interfaz base y estructura implementadas)

### Características Implementadas
- ✅ Estructura modular del proyecto (Core, Features).
- ✅ Sistema de temas y diseño visual inicial.
- ✅ Pantalla de bienvenida (Splash Screen) y navegación básica.
- ✅ Definición de 6 módulos de actividades (`activity1` a `activity6`).
- ✅ Interfaz de usuario base para las actividades.
- ✅ Integración inicial de assets (imágenes, audio, datos JSON).

### Próximas Características / Roadmap
- 🔄 Desarrollo completo de la lógica y contenido de las 6 actividades:
    1.  Actividad 1: [Definir objetivo, ej: Reconocimiento de números Namtrik]
    2.  Actividad 2: [Definir objetivo, ej: Conteo básico]
    3.  Actividad 3: [Definir objetivo, ej: Asociación número-cantidad]
    4.  Actividad 4: [Definir objetivo, ej: Conceptos de dinero/hora]
    5.  Actividad 5: [Definir objetivo, ej: Diccionario interactivo]
    6.  Actividad 6: [Definir objetivo, ej: Mini-juegos/Evaluación]
- 🔄 Implementación robusta del reproductor de audio (`audioplayers`) para pronunciaciones.
- 🔄 Sistema de gestión de estado (`provider`) para manejar el flujo de datos.
- 🔄 Persistencia de datos (progreso del usuario) usando `shared_preferences`, `hive` o `sqflite`.
- 🔄 Refinamiento de animaciones y efectos sonoros.
- 🔄 Pruebas unitarias y de widgets.

## Requisitos Técnicos
- Flutter SDK: >=3.1.3 <4.0.0
- Dart SDK: >=3.1.3 <4.0.0
- Plataformas Destino: Android, iOS

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
│   │   ├── activity1/
│   │   ├── ...
│   │   └── home/     # Pantalla principal o de inicio
│   └── main.dart     # Punto de entrada de la aplicación
├── test/             # Pruebas (a implementar)
├── pubspec.yaml      # Definición del proyecto y dependencias
└── README.md         # Esta documentación
```

## Recursos Clave y Dependencias
El proyecto utiliza varios recursos y paquetes de Flutter:
- **Assets:** Incluye una colección organizada de:
    - Archivos de audio `.wav` para números y diccionario Namtrik.
    - Archivos de datos `.json` que estructuran el contenido de las actividades (números, dinero, horas, diccionario, artículos).
    - Imágenes `.png` para la interfaz, iconos, logos y elementos visuales de las actividades.
- **Dependencias Principales:**
    - `flutter/material`: Framework base de UI.
    - `provider`: Para la gestión del estado.
    - `audioplayers`: Reproducción de archivos de audio.
    - `shared_preferences`, `hive`, `sqflite`, `path_provider`: Opciones para almacenamiento local.
    - `get_it`: Inyección de dependencias (Service Locator).
    - `logger`: Para el registro de eventos y depuración.
- **Dependencias de Desarrollo:**
    - `flutter_lints`: Reglas de análisis estático.
    - `build_runner`, `hive_generator`: Generación de código.
    - `flutter_launcher_icons`, `flutter_native_splash`: Personalización del icono y splash screen.

## Instalación y Ejecución
1.  Asegúrate de tener Flutter (versión compatible) instalado y configurado.
2.  Clona el repositorio:
    ```bash
    git clone [URL-del-repositorio]
    cd namui_wam
    ```
3.  Instala las dependencias:
    ```bash
    flutter pub get
    ```
4.  Ejecuta la aplicación (asegúrate de tener un emulador/dispositivo conectado):
    ```bash
    flutter run
    ```

## Contribución
Para contribuir al proyecto:
1. Crea un fork del repositorio
2. Crea una rama para tu función: `git checkout -b feature/nueva-funcion`
3. Realiza tus cambios y haz commit: `git commit -m 'Añade nueva función'`
4. Envía tus cambios: `git push origin feature/nueva-funcion`
5. Crea un Pull Request

## Licencia
Este proyecto está bajo la Licencia [Especificar tipo de licencia]

## Contacto
Para más información o soporte:
- Email: [Correo de contacto]
- Website: [Sitio web del proyecto]
