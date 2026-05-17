# Guia del profesor — Sesion 7: Directivas, eventos y datos

## Objetivo y material
- Duracion: 90 min
- Objetivo: Que el grupo aprenda a modelar datos con interfaces, escribir funciones tipadas utiles para Vue y dominar las directivas, eventos y transformaciones de listas mas importantes para UI reactiva.
- Material alumno: sesion-2-directivas-eventos/index.md
- Material de refuerzo: bloque "Test Sesion 2" y "Respuestas (desplegables)" dentro de sesion-2-directivas-eventos/index.md
- Ejercicio base: Lista de Tareas
- Prerequisitos: Sesion 1 completada.

## Propuesta de ritmo

Distribucion sugerida:
- Teoria guiada: 55 min
- Practica: 20 min
- Test y correccion: 10 min
- Cierre: 5 min

### Bloque 2.1: Interfaces como contratos de datos (~10 min)
Objetivo didactico:
Que el alumnado entienda por que una lista de objetos necesita estructura clara antes de pintarse o modificarse.

Que mostrar:
- Interface local para una tarea
- Convencion `IClaseNombre`
- Cuando una interface vive dentro del componente y cuando conviene moverla a `src/interfaces`

Mensajes clave:
- Las interfaces describen la forma de los datos, no crean datos
- Tipar bien la estructura evita errores en `v-for`, formularios y funciones

Pregunta al grupo:
- Que problema evitamos si tipamos una tarea desde el principio?

Respuesta esperada:
- Errores de propiedades inexistentes o tipos incorrectos al pintar y modificar datos.

### Bloque 2.2: Funciones tipadas aplicadas a Vue (~10 min)
Objetivo didactico:
Introducir funciones con tipos claros, centradas en handlers y pequenas utilidades reales.

Que mostrar:
- Parametros y retorno tipados
- `void` cuando una funcion actua pero no devuelve dato util
- Parametros opcionales y valores por defecto si salen en ejemplo corto

Mensajes clave:
- En Vue muchas funciones seran handlers de eventos o pequeñas reglas de negocio
- Tipar funciones mejora legibilidad y evita errores tontos

Pregunta al grupo:
- Cuando tiene sentido que una funcion devuelva `void`?

Respuesta esperada:
- Cuando solo actualiza estado o lanza una accion y no necesitamos un valor de vuelta.

### Bloque 2.3: Directivas esenciales para mostrar y editar datos (~15 min)
Objetivo didactico:
Dar el bloque de herramientas que permite construir interfaces dinamicas basicas.

Que mostrar:
- `v-if`, `v-else-if`, `v-else`
- `v-show`
- `v-for` y `:key`
- `v-bind`
- `v-model`

Mensajes clave:
- `v-if` crea y destruye; `v-show` solo oculta
- `:key` estable evita renderizados confusos
- `v-model` conecta formulario y estado reactivo con muy poco codigo

Errores frecuentes a vigilar:
- Usar `index` como `key` en listas dinamicas
- Mezclar `v-if` y `v-for` en el mismo nodo

Pregunta al grupo:
- Cuando elegirias `v-show` en lugar de `v-if`?

Respuesta esperada:
- Cuando la visibilidad cambia a menudo y no interesa recrear el DOM cada vez.

### Bloque 2.4: Eventos y flujo de formulario (~10 min)
Objetivo didactico:
Conectar la interfaz con acciones concretas del usuario.

Que mostrar:
- `@click`, `@input`, `@submit`
- `.prevent`, `.stop`, `.once`
- Separacion entre evento y funcion de negocio

Mensajes clave:
- La plantilla dispara eventos; la logica debe vivir en funciones claras
- Si se toca `event.target`, conviene tipar el evento con cuidado

### Bloque 2.5: Arrays y acceso seguro a datos (~10 min)
Objetivo didactico:
Dar las transformaciones que mas apareceran en listados y filtros.

Que mostrar:
- `map`, `filter`, `find`, `reduce`
- `some` y `every`
- `spread`, destructuring, `?.` y `??`

Mensajes clave:
- `filter` y `map` aparecen continuamente en interfaces de negocio
- `sort` muta el array original; si se usa, clonar primero
- `??` es mas seguro que `||` cuando `0` o cadena vacia son validos
- En esta sesion no profundizamos en `computed`; dejamos ese criterio para la sesion 3

## Practica guiada (~20 min)

Objetivo:
Montar una lista de tareas en la que converjan interface, funciones tipadas, directivas, eventos y transformacion de arrays.

Secuencia recomendada:
1. Crear `IClaseTarea`.
2. Declarar un array reactivo con varias tareas.
3. Crear una funcion para anadir tarea desde un `input` con `v-model`.
4. Pintar la lista con `v-for` y `:key`.
5. Eliminar tareas con `filter`.
6. Mostrar un contador de pendientes y un mensaje vacio.

Checklist rapido:
- La `key` es estable y unica.
- La logica de anadir/eliminar no esta escrita directamente en la plantilla.
- Se usan directivas adecuadas para cada caso.
- El grupo entiende por que la interface mejora la lectura del componente.

## Test de sesion y correccion (~10 min)

Propuesta:
1. Abrir el bloque "Test Sesion 2" dentro de la sesion del alumno.
2. Resolver preguntas representativas de interfaces, directivas y arrays.
3. Corregir en grupo y comentar por que las opciones incorrectas fallan.

Objetivo:
- Consolidar criterio tecnico antes de entrar en comunicacion entre componentes.

## Cierre y comprobacion (~5 min)

Preguntas de salida:
- Que diferencia practica hay entre `v-if` y `v-show`?
- Por que `v-model` ahorra codigo frente a manejar manualmente el `input`?
- Que ventaja tiene `filter` frente a manipular el DOM a mano?

Criterio minimo de sesion superada:
- El alumnado puede leer una lista renderizada con `v-for`.
- El alumnado sabe modelar una entidad simple con interface.
- El alumnado puede conectar formulario y estado con `v-model` y un handler tipado.

## Si falta tiempo
1. Priorizar interfaces, `v-for`, `v-model` y `@click`.
2. Dejar `some`, `every` y detalles de objetos como refuerzo de lectura.

## Si sobra tiempo
1. Resolver 3 o 4 preguntas del banco de la sesion.
2. Mejorar la UX del formulario con `:disabled`, `v-if` y mensajes de validacion simples (sin introducir `computed` en profundidad).
