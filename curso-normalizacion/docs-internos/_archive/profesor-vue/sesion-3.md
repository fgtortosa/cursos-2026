# Guia del profesor — Sesion 8: Componentes y comunicacion

## Objetivo y material
- Duracion: 90 min
- Objetivo: Que el grupo entienda primero el valor de `computed`, despues la comunicacion entre componentes y por ultimo los efectos secundarios y hooks mas utiles para componentes reutilizables.
- Material alumno: sesion-3-componentes-estado/index.md
- Material de refuerzo: bloque "Test Sesion 3" y "Respuestas (desplegables)" dentro de sesion-3-componentes-estado/index.md
- Practicas base: Contador por componentes y Gestor de gastos
- Prerequisitos: Sesiones 1 y 2 completadas.

## Propuesta de ritmo

Distribucion sugerida:
- Teoria guiada: 55 min
- Practica: 20 min
- Test y correccion: 10 min
- Cierre: 5 min

### Bloque 3.1: Estado derivado con `computed` (~14 min)
Objetivo didactico:
Dar una regla sencilla y reutilizable: si un dato depende de otro y se pinta en pantalla, normalmente es `computed`, tambien en formularios.

Que mostrar:
- `computed` simple
- `computed` sobre arrays para filtrar o totalizar
- Diferencia con un metodo normal
- Patron entrada -> derivado -> accion en formularios (normalizar, habilitar boton, mensaje reactivo)

Mensajes clave:
- `computed` evita duplicar estado
- `computed` mejora legibilidad y suele ser la opcion correcta para listados y totales
- Metodo para acciones del usuario; `computed` para valor derivado sin efectos secundarios

Pregunta al grupo:
- Si tienes un total que depende de una lista reactiva, donde lo pondrias?

Respuesta esperada:
- En una `computed`.

### Bloque 3.2: Props y propiedad del estado (~10 min)
Objetivo didactico:
Explicar con claridad quien es dueno del dato y por que el hijo no debe modificar props.

Que mostrar:
- `defineProps`
- Valores por defecto con `withDefaults`
- Flujo padre -> hijo

Mensajes clave:
- El componente padre suele ser la fuente del estado compartido
- El hijo recibe datos para mostrarlos o trabajar con ellos, no para reescribirlos directamente

Error frecuente a vigilar:
- Intentar hacer `props.algo = ...` dentro del hijo.

### Bloque 3.3: Emits y `defineModel` (~12 min)
Objetivo didactico:
Mostrar dos mecanismos complementarios para que el hijo se comunique con el padre.

Que mostrar:
- `defineEmits` para eventos de negocio
- `defineModel` para componentes de formulario o sincronizacion de valor
- Ejemplo comparado de ambos enfoques

Mensajes clave:
- `defineEmits` expresa intencion
- `defineModel` reduce codigo repetitivo cuando realmente hay un `v-model`

Pregunta al grupo:
- Cuando te parece mas claro `defineEmits` y cuando `defineModel`?

Respuesta esperada:
- Emits para eventos o acciones; defineModel para sincronizar un valor bidireccional.

### Bloque 3.4: `watch`, `watchEffect` y `onMounted` (~11 min)
Objetivo didactico:
Separar mentalmente valores derivados de efectos secundarios.

Que mostrar:
- `watch` simple
- `watchEffect` para casos muy cortos
- `onMounted` para carga inicial

Mensajes clave:
- `watch` no sustituye a `computed`
- Si hay API, storage o alerta, seguramente hablamos de un efecto secundario
- Al cerrar este bloque, lanzar el Ejercicio 1 para consolidar Props/Emits/defineModel antes de continuar

Pregunta al grupo:
- Que problema aparece si usamos `watch` para calcular lo que podria ser una `computed`?

Respuesta esperada:
- Duplicamos logica, complicamos mantenimiento y hacemos el codigo menos claro.

### Bloque 3.5: Slots y nota sobre `provide/inject` (~10 min)
Objetivo didactico:
Dar contexto sobre reutilizacion visual sin cargar en exceso la sesion.

Que mostrar:
- Slot por defecto
- Slot nombrado
- `provide/inject` solo como mecanismo de contexto, no como foco practico

Mensajes clave:
- Los slots ayudan a construir componentes de layout reutilizables
- `provide/inject` existe, pero no debe competir con Props/Emits en una primera vuelta

## Practica guiada (~20 min)

Ejercicio 1 (justo tras 3.4), obligatorio:
1. Crear un contador hijo que reciba valor por Props.
2. Emitir cambios al padre.
3. Calcular en el padre una suma con `computed`.

Ejercicio 2 (cierre de practica):
1. Crear un gestor de gastos con `IClaseGasto`.
2. Calcular el total con `computed`.
3. Lanzar una alerta o log con `watch` al superar un umbral.

Checklist rapido:
- El estado fuente esta en el lugar correcto.
- No se modifican props en el hijo.
- `computed` se usa para derivados y `watch` para efectos.
- El grupo distingue claramente los tres patrones: Props, Emits y `defineModel`.

## Test de sesion y correccion (~10 min)

Propuesta:
1. Abrir el bloque "Test Sesion 3" de la sesion del alumno.
2. Resolver preguntas sobre `computed`, patron entrada -> derivado -> accion, props/emits, `defineModel`, `watch` y slots.
3. Corregir en grupo reforzando el criterio de eleccion de patron.

Objetivo:
- Comprobar que el flujo de datos padre-hijo queda claro antes de pasar a arquitectura por capas.

## Cierre y comprobacion (~5 min)

Preguntas de salida:
- Quien debe ser dueno del estado compartido entre padre e hijo?
- Cual es la diferencia practica entre `computed` y `watch`?
- Para que caso tipico te parece mas natural `defineModel`?

Criterio minimo de sesion superada:
- El alumnado sabe describir el flujo padre -> hijo -> padre.
- El alumnado puede justificar cuando usar `computed`.
- El alumnado identifica `watch` como herramienta de efectos secundarios.

## Si falta tiempo
1. Priorizar `computed`, Props y Emits.
2. Dejar slots y `provide/inject` como lectura guiada.

## Si sobra tiempo
1. Resolver varias preguntas del banco de la sesion en grupo.
2. Mostrar una extension con persistencia en `localStorage` para enlazar con la sesion 4.
