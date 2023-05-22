**¿Cuáles son las diferencias entre las clases de interfaz y abstractas?

**En ABAP, tanto una clase abstracta como una interfaz son mecanismos que se utilizan para definir comportamientos y características en la programación orientada a objetos. 
**Sin embargo, hay algunas diferencias clave entre ellos en términos de su implementación y uso. A continuación, te presento las diferencias principales:
*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**Implementación de métodos: 
**En una clase abstracta, puedes definir métodos con implementaciones concretas y también métodos abstractos sin implementación. Los métodos abstractos 
**solo proporcionan la firma del método, sin definir su implementación.

**Por otro lado, en una interfaz, solo puedes definir la firma de los métodos, es decir, la declaración del método, pero no puedes proporcionar una implementación.
*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**Herencia: 
**Una clase abstracta en ABAP puede ser heredada por otras clases mediante la declaración INHERITING FROM. Esto significa que una clase hija 
**puede extender y especializar la clase abstracta, implementando los métodos abstractos y heredando los métodos concretos. 

**Por otro lado, una interfaz en ABAP se implementa en una clase con la declaración IMPLEMENTATION. Una clase puede implementar 
**múltiples interfaces y proporcionar la implementación de todos los métodos definidos en esas interfaces.
*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**Construcción de objetos: 
**Puedes crear instancias de una clase concreta basada en una clase abstracta en ABAP. Sin embargo, no puedes crear instancias directas de una interfaz.

**Las interfaces se utilizan como contratos para asegurar que las clases que las implementen proporcionen ciertos métodos y funcionalidades.
*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**Flexibilidad:
**Las interfaces proporcionan una mayor flexibilidad en comparación con las clases abstractas. Una clase puede implementar múltiples interfaces, 
**lo que permite una mayor modularidad y reutilización del código. Además, las interfaces permiten la implementación múltiple, lo que significa que 
**una clase puede implementar diferentes interfaces con métodos de mismo nombre pero con implementaciones diferentes.
*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**En resumen: 
**una clase abstracta en ABAP se utiliza para definir una clase base que puede ser especializada por clases hijas y proporciona una implementación
**predeterminada de ciertos métodos. 
**Por otro lado, una interfaz en ABAP define un contrato que una clase debe cumplir, especificando los métodos 
**que la clase debe implementar, sin proporcionar una implementación concreta.
*-------------------------------------------------------------------------------------------------------------------------------------------------------------*

**Ejemplos:

*&---------------------------------------------------------------------*
*& Report ZEJEMPLO_ABAP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Clase abstracta: Animal
*&---------------------------------------------------------------------*
CLASS Animal ABSTRACT PUBLIC.                   "Clase publica abstracta
  PUBLIC SECTION.
    METHODS:
      abstract_method IMPORTING i_name TYPE string,
      concrete_method.
ENDCLASS.

METHOD abstract_method.
  WRITE: / 'Soy un', i_name, ' abstracto'.
ENDMETHOD.

METHOD concrete_method.
  WRITE: / 'Soy un animal concreto'.
ENDMETHOD.

*&---------------------------------------------------------------------*
*& Interfaz: Comestible
*&---------------------------------------------------------------------*
INTERFACE Comestible.
  METHODS:
    eat.
ENDINTERFACE.

*&---------------------------------------------------------------------*
*& Clase: Perro
*&---------------------------------------------------------------------*
CLASS Perro DEFINITION INHERITING FROM Animal IMPLEMENTATION. "subclase de la clase Animal
  PUBLIC SECTION.
    METHODS:
      abstract_method REDEFINITION,
      eat REDEFINITION.
ENDCLASS.

CLASS Perro IMPLEMENTATION.
  METHOD abstract_method.
    WRITE: / 'Soy un perro abstracto'.
  ENDMETHOD.

  METHOD eat.
    WRITE: / 'El perro está comiendo'.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*& Programa principal
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: animal TYPE REF TO Animal,
        perro TYPE REF TO Perro.

  CREATE OBJECT animal TYPE Perro.
  animal->abstract_method('perro').
  animal->concrete_method().

  CREATE OBJECT perro.
  perro->abstract_method('perro').
  perro->concrete_method().
  perro->eat().
  
**En este ejemplo, se define una clase abstracta llamada Animal que tiene un método abstracto (abstract_method) y un método concreto (concrete_method).
**La clase abstracta no puede ser instanciada directamente, sino que debe ser heredada por una clase concreta.

**Luego, se define una interfaz llamada Comestible que tiene un método (eat). La interfaz no proporciona ninguna implementación y solo define la firma del método.

**Después, se define una clase llamada Perro que hereda de la clase abstracta Animal e implementa la interfaz Comestible. 
**Esta clase redefine el método abstracto abstract_method y el método eat.

**En el programa principal, se crean instancias de la clase Perro tanto a través de la clase abstracta Animal como directamente. 
**Se llaman a los métodos correspondientes y se muestra la salida.

**La salida del programa será:
**Soy un perro abstracto
**Soy un animal concreto
**Soy un perro abstracto
**Soy un animal concreto
**El perro está comiendo

*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**Ventajas de las clases abstractas:

** 1)Proporcionan una estructura de base para la herencia: Las clases abstractas permiten definir métodos abstractos que deben ser implementados 
**por las clases hijas. Esto facilita la creación de una jerarquía de clases y promueve la reutilización de código.

**2)Pueden contener métodos concretos: Además de los métodos abstractos, las clases abstractas pueden contener métodos con implementaciones concretas. 
Esto permite definir un comportamiento predeterminado que las clases hijas pueden heredar y, si es necesario, redefinir.

**3)Pueden tener atributos y propiedades: Las clases abstractas pueden contener atributos y propiedades que pueden ser heredados por las clases hijas.
**Esto permite definir características comunes y compartir datos entre las clases de la jerarquía.
*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**Desventajas de las clases abstractas:

**Limitación de la herencia múltiple: ABAP no admite la herencia múltiple de clases, lo que significa que una clase solo puede heredar de una 
**única clase abstracta. Esto puede restringir la flexibilidad si se necesitan heredar características de múltiples fuentes.
*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**Ventajas de las interfaces:

**1) Permiten la implementación múltiple: Una clase en ABAP puede implementar múltiples interfaces, lo que proporciona una mayor flexibilidad y 
**modularidad en el diseño de clases. Esto permite que una clase cumpla con varios contratos y adquiera múltiples comportamientos.

**2)Favorecen la composición sobre la herencia: Las interfaces promueven el diseño basado en la composición, lo que significa que 
**una clase puede implementar múltiples interfaces para obtener funcionalidades específicas. Esto evita las limitaciones de la herencia única y 
**facilita la reutilización de código.

**3)Ayudan a definir contratos claros: Las interfaces definen un conjunto de métodos que deben ser implementados por las clases que las implementan. 
**Esto establece un contrato claro y mejora la comprensión de las responsabilidades y las funcionalidades esperadas de una clase.
*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**Desventajas de las interfaces:

**1)No pueden contener atributos o propiedades: A diferencia de las clases abstractas, las interfaces en ABAP no pueden contener atributos o propiedades.
**Se centran exclusivamente en definir la firma de los métodos.

**2)No pueden proporcionar implementaciones predeterminadas: Las interfaces no pueden contener implementaciones concretas de métodos. 
Esto significa que todas las implementaciones deben estar presentes en las clases que implementan la interfaz.

*-------------------------------------------------------------------------------------------------------------------------------------------------------------*
**Conclusion final:
**Es importante considerar estas ventajas y desventajas al decidir entre el uso de clases abstractas e interfaces en tu diseño de clases en ABAP. 
**La elección dependerá de los requisitos específicos de tu aplicación y del diseño de la jerarquía de clases.
