# Servicios

Esta sección documenta los servicios principales que utiliza la aplicación Namuiwam. Los servicios son responsables de la lógica de negocio, acceso a datos y funcionalidades compartidas entre diferentes partes de la aplicación.

## Servicios Core

Los servicios fundamentales que proporcionan funcionalidades básicas a toda la aplicación:

- **AudioService**: Gestiona la reproducción de archivos de audio en la aplicación.
- **FeedbackService**: Proporciona retroalimentación háptica y visual al usuario.
- **LoggerService**: Servicio de registro para depuración y seguimiento de eventos.
- **StorageService**: Gestiona el almacenamiento local persistente utilizando Hive.
- **NumberDataService**: Carga y proporciona acceso a los datos de números en Namtrik.

## Servicios de Actividades

Servicios específicos para cada actividad que encapsulan la lógica de negocio particular:

- **Activity1Service**: Gestiona los datos y la lógica para la actividad "Escoja el número correcto".
- **Activity2Service**: Gestiona los datos y la lógica para la actividad "Aprendamos a escribir los números".
- **Activity3Service**: Gestiona los datos y la lógica para la actividad "Aprendamos a ver la hora".
- **Activity4Service**: Gestiona los datos y la lógica para la actividad "Aprendamos a usar el dinero".
- **Activity5Service**: Gestiona los datos y la lógica para la actividad "Convertir números en letras".
- **Activity6Service**: Gestiona los datos y la lógica para el "Diccionario" Namtrik.

## Servicios de Estado

Servicios que gestionan el estado global de la aplicación:

- **GameState**: Gestiona el estado del juego, incluyendo puntos y niveles completados.
- **ActivitiesState**: Gestiona el estado de las actividades, incluyendo niveles desbloqueados.

## Patrones Implementados

Los servicios en Namuiwam implementan principalmente los siguientes patrones de diseño:

- **Singleton**: La mayoría de los servicios son instancias únicas gestionadas a través de GetIt.
- **Service Locator**: Implementado con GetIt para la inyección de dependencias.
- **Repository**: Para la capa de acceso a datos en algunos servicios. 