# Modelos

Esta sección documenta los modelos de datos utilizados en la aplicación Namuiwam. Estos modelos representan entidades del dominio y estructuras de datos clave para la aplicación educativa.

## Modelos Centrales

Modelos fundamentales utilizados en diversas partes de la aplicación:

- **NamtrikNumber**: Representa un número en idioma Namtrik, con su valor numérico y representación textual.
- **UserProgress**: Almacena el progreso del usuario en una actividad y nivel específicos.
- **ActivityLevel**: Define un nivel dentro de una actividad, incluyendo su estado (bloqueado/desbloqueado).

## Modelos de Actividades

Modelos específicos para cada actividad:

### Actividad 1: Escoja el número correcto
- **NumberOption**: Representa una opción de número para seleccionar.
- **NumberQuestion**: Define una pregunta con opciones y respuesta correcta.

### Actividad 2: Aprendamos a escribir los números
- **WritingExercise**: Define un ejercicio de escritura con número a escribir y respuesta esperada.
- **KeyboardLayout**: Define la disposición de teclas para el teclado personalizado Namtrik.

### Actividad 3: Aprendamos a ver la hora
- **ClockTime**: Representa un tiempo en formato de reloj, con hora y minutos.
- **TimeQuestion**: Define una pregunta sobre lectura de tiempo en un reloj.

### Actividad 4: Aprendamos a usar el dinero
- **NamtrikCoin**: Representa una denominación de moneda Namtrik con su valor y características visuales.
- **ShoppingItem**: Representa un artículo con precio para las actividades de compras.
- **MoneyExercise**: Define un ejercicio relacionado con dinero (selección, identificación, etc.).

### Actividad 5: Convertir números en letras
- **NumberConversion**: Almacena un número y su conversión a texto Namtrik.

### Actividad 6: Diccionario
- **SemanticDomain**: Representa un dominio semántico (categoría) del diccionario.
- **DictionaryEntry**: Representa una entrada del diccionario con palabra en Namtrik, traducción e información adicional.
- **AudioVariant**: Almacena información sobre variantes de pronunciación para una palabra.

## Implementación

Los modelos en Namuiwam siguen estos principios:

- **Inmutabilidad**: La mayoría de los modelos son inmutables para prevenir estados inconsistentes.
- **Serialización**: Incluyen métodos `toJson` y constructores `fromJson` para serialización/deserialización.
- **Encapsulación**: Encapsulan lógica relacionada con sus datos cuando es apropiado.
- **Validación**: Incluyen validación de datos donde sea necesario.

## Ejemplo de Jerarquía

Algunos modelos siguen relaciones jerárquicas:

```
ActivityLevel
└── Contiene → UserProgress

SemanticDomain
└── Contiene → DictionaryEntry
    └── Puede tener → AudioVariant

NamtrikNumber
└── Utilizado por → NumberQuestion
    └── Contiene → NumberOption
``` 