# Guía de Estilo de Documentación (Dartdoc) - Namuiwam

Esta guía define los estándares para documentar el código fuente del proyecto Namuiwam utilizando dartdoc.

## Principios Generales

1. **Completitud**: Documentar todas las clases, métodos y propiedades públicas.
2. **Claridad**: Usar lenguaje claro y directo. Evitar jerga innecesaria.
3. **Consistencia**: Mantener un estilo uniforme en todo el código.
4. **Contextualización**: Explicar el propósito y el contexto, no solo la funcionalidad.
5. **Ejemplos**: Incluir ejemplos de uso cuando sea posible.

## Formato de Documentación para Clases

```dart
/// {@template nombre_clase}
/// Descripción breve que explique el propósito de la clase en una línea.
///
/// Descripción detallada que incluya:
/// - Propósito y funcionalidad
/// - Relación con otros componentes
/// - Responsabilidades principales
/// - Casos de uso típicos
/// {@endtemplate}
class MiClase {
  // Implementación...
}
```

### Para Constructores:

```dart
/// {@macro nombre_clase}
///
/// Ejemplo de uso:
/// ```dart
/// final miInstancia = MiClase(
///   parametro1: 'valor1',
///   parametro2: 42,
/// );
/// ```
MiClase({
  required this.parametro1,
  required this.parametro2,
});
```

## Formato para Propiedades

```dart
/// Descripción clara y concisa de la propiedad.
///
/// Detalles adicionales si son necesarios, incluyendo:
/// - Valores posibles/esperados
/// - Comportamiento cuando es nulo
/// - Impacto en otros componentes
final String propiedad;
```

## Formato para Métodos

```dart
/// Descripción del propósito y funcionalidad del método.
///
/// Flujo típico o lógica importante del método.
/// Condiciones especiales o casos límite a considerar.
///
/// [parametro1] Descripción del primer parámetro.
/// [parametro2] Descripción del segundo parámetro.
///
/// Retorna un [TipoRetorno] que representa... (explicar el significado del valor retornado).
///
/// Lanza [ExcepcionEspecifica] si las condiciones X o Y no se cumplen.
///
/// Ejemplo:
/// ```dart
/// final resultado = objeto.miMetodo('valorParametro1', 42);
/// print(resultado); // Salida esperada
/// ```
TipoRetorno miMetodo(String parametro1, int parametro2) {
  // Implementación...
}
```

## Uso de Templates y Macros

Usar templates y macros para reutilizar documentación:

1. **Definir template**:
```dart
/// {@template nombre_identificativo}
/// Documentación que se quiere reutilizar.
/// {@endtemplate}
```

2. **Usar macro para reutilizar**:
```dart
/// {@macro nombre_identificativo}
```

## Documentación Específica por Tipo de Componente

### Widgets

```dart
/// {@template nombre_widget}
/// Widget que [acción principal] para [propósito].
///
/// Detalles sobre:
/// - Comportamiento visual
/// - Interactividad
/// - Integración con otros widgets
/// - Restricciones o limitaciones
/// {@endtemplate}
class MiWidget extends StatelessWidget {
  /// El título a mostrar en el widget.
  final String titulo;

  /// El color de fondo del widget.
  ///
  /// Por defecto es [Colors.white].
  final Color backgroundColor;

  /// {@macro nombre_widget}
  ///
  /// Ejemplo:
  /// ```dart
  /// MiWidget(
  ///   titulo: 'Título del Widget',
  ///   backgroundColor: Colors.blue,
  /// )
  /// ```
  const MiWidget({
    required this.titulo,
    this.backgroundColor = Colors.white,
  });
  
  // Implementación...
}
```

### Servicios

```dart
/// {@template nombre_servicio}
/// Servicio responsable de [funcionalidad principal].
///
/// Este servicio:
/// - [Funcionalidad 1]
/// - [Funcionalidad 2]
/// - [Funcionalidad 3]
///
/// Forma parte del módulo [nombre del módulo o feature].
/// {@endtemplate}
class MiServicio {
  // Implementación...
}
```

### Modelos

```dart
/// {@template nombre_modelo}
/// Modelo de datos que representa [concepto del dominio].
///
/// Contiene información sobre:
/// - [Propiedad 1]: [significado]
/// - [Propiedad 2]: [significado]
///
/// Se utiliza en [contextos o lugares donde se usa].
/// {@endtemplate}
class MiModelo {
  // Implementación...
}
```

## Ejemplos de Código Específicos del Proyecto

### Ejemplo de Documentación para Actividades

```dart
/// {@template nombre_actividad_screen}
/// Pantalla principal para la Actividad X: "[Nombre en Namtrik] ([Traducción])".
///
/// Esta actividad permite a los usuarios [objetivo educativo].
/// Implementa [mecánica o jugabilidad] como método de aprendizaje.
///
/// Esta pantalla gestiona:
/// - [Responsabilidad 1]
/// - [Responsabilidad 2]
/// {@endtemplate}
class ActividadXScreen extends StatefulWidget {
  // Implementación...
}
```

### Ejemplo de Documentación para Servicios de Actividades

```dart
/// {@template nombre_servicio_actividad}
/// Servicio para la Actividad X: "[Nombre en Namtrik] ([Traducción])".
///
/// Responsable de:
/// - Cargar datos desde [fuente]
/// - Gestionar [lógica específica]
/// - Proporcionar [funcionalidad]
///
/// Interactúa con [otros servicios o componentes relacionados].
/// {@endtemplate}
```

## Consideraciones Adicionales

1. **Documentación de Excepciones**: Documentar todas las excepciones que un método puede lanzar y en qué circunstancias.

2. **Enlaces a Otras Clases**: Usar corchetes `[]` para referenciar otras clases, métodos o propiedades documentadas.

3. **Reglas de Estilo**:
   - Usar oraciones completas con puntuación adecuada.
   - Comenzar descripciones con mayúscula y terminar con punto.
   - Usar voz activa en lugar de pasiva.
   - Ser consistente con la terminología en toda la documentación.

4. **Para métodos @override**: No es necesario documentar exhaustivamente los métodos sobrescritos si la documentación de la clase padre es suficiente. En este caso, usar:
   ```dart
   /// @override
   @override
   void metodoSobrescrito() {
     // Implementación...
   }
   ```

## Generación de la Documentación

Para generar la documentación HTML basada en estos comentarios:

1. Instalar dartdoc (si no está incluido en el SDK):
   ```
   dart pub global activate dartdoc
   ```

2. Generar la documentación:
   ```
   dart doc .
   ```

3. Ver la documentación:
   ```
   Abrir doc/api/index.html en un navegador
   ``` 