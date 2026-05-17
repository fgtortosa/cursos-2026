# Guia del profesor — Sesion 6: Vue 3, TypeScript y primer componente

## Objetivo y material
- Duracion: 90 min
- Objetivo: Que el grupo comprenda la estructura de un componente Vue con Composition API, use TypeScript basico con criterio, domine la idea de reactividad y aplique una rutina minima de depuracion.
- Material alumno: sesion-1-vue-typescript-fundamentos/index.md
- Material de refuerzo: bloque "Test Sesion 1", "Preguntas (desplegables)" y "Respuestas (Autoevaluacion)" dentro de sesion-1-vue-typescript-fundamentos/index.md
- Ejercicio base: Tarjeta de Presentacion
- Prerequisitos: HTML basico, JavaScript basico y nocion general de componente.

## Propuesta de ritmo

Distribucion sugerida (alineada con la sesion del alumno):
- Teoria guiada: 45 min
- Practica: 25 min
- Test y correccion: 15 min
- Cierre: 5 min

### Bloque 1.1: Por que Vue 3 en la UA (~5 min)
Objetivo didactico:
Abrir la sesion con contexto de stack y criterio tecnico.

Que mostrar:
- Ventajas de Vue 3 en el entorno UA
- Relacion entre curva de aprendizaje, mantenimiento y tipado

Mensajes clave:
- Vue 3 + TypeScript es una decision practica, no solo academica
- Esta sesion construye la base para todo el modulo

Pregunta al grupo:
- Que ventaja te parece mas critica para un equipo grande: reactividad, tipado o estructura?

Respuesta esperada:
- Cualquiera de las tres, bien argumentada en contexto de equipo.

### Bloque 1.2: Estructura de un componente Vue (~10 min)
Objetivo didactico:
Que entiendan que un componente Vue combina logica, plantilla y estilo con responsabilidades distintas.

Que mostrar:
- Un ejemplo sencillo con `script setup`, `template` y `style scoped`
- Diferencia entre componente y vista
- Orden recomendado dentro de `script setup`

Mensajes clave:
- `script setup` concentra estado, tipos y funciones
- `template` refleja el estado reactivo
- `style scoped` evita fugas de estilos en ejemplos pequenos

Pregunta al grupo:
- Si cambia una variable reactiva en el script, donde se refleja ese cambio?

Respuesta esperada:
- En el template, gracias a la reactividad de Vue.

### Bloque 1.3: TypeScript minimo viable para Vue (~10 min)
Objetivo didactico:
Dar seguridad con los tipos sin convertir la sesion en una clase abstracta de TypeScript.

Que mostrar:
- Tipos primitivos mas habituales
- Inferencia de tipos
- Union types
- Diferencia entre `any` y `unknown`
- Diferencia operativa entre `let`, `const` y `var`
- Regla practica: `const` por defecto, `let` si hay reasignacion
- Nocion corta de `as const` y `readonly` (sin profundizar)

Mensajes clave:
- El tipado ayuda antes de ejecutar
- `any` debe ser la excepcion, no la norma
- En esta sesion basta con tipar bien datos simples y variables reactivas
- Evitar `var` en codigo moderno por alcance y legibilidad
- Entender `const` aqui evita confusiones posteriores en reactividad

Pregunta al grupo:
- Que gana un equipo cuando tipa bien sus datos desde el principio?

Respuesta esperada:
- Menos errores, contratos mas claros y mejor autocompletado.

Pregunta de control adicional:
- Cuando eliges `let` en lugar de `const`?

Respuesta esperada:
- Solo cuando necesitas reasignar la variable.

### Bloque 1.4: Reactividad con `ref` y `reactive` (~12 min)
Objetivo didactico:
Introducir la idea central del bloque Vue: el estado cambia y la interfaz responde sola.

Que mostrar:
- `ref` para valores simples
- `reactive` para objetos
- Uso de `.value` en script y ausencia de `.value` en template
- Por que usamos `const` al declarar variables reactivas

Mensajes clave:
- Lo que cambia es el valor interno, no la referencia
- `ref` sera la herramienta mas habitual al empezar
- Si el alumnado entiende bien `ref`, el resto del modulo fluye mejor

Pregunta al grupo:
- Por que `const contador = ref(0)` si luego el contador cambia?

Respuesta esperada:
- Porque no cambia la referencia; cambia `contador.value`.

Error frecuente a vigilar:
- Escribir `.value` en el template o olvidar `.value` dentro del script.

### Bloque 1.5: Interpolacion y primeras expresiones (~5 min)
Objetivo didactico:
Mostrar como presentar datos y pequenas transformaciones sin meter logica compleja en la vista.

Que mostrar:
- Interpolacion simple
- Expresiones cortas
- Template literals
- Condicional ternario muy basico
- Limite entre expresion simple y logica compleja

Mensajes clave:
- La plantilla puede transformar ligeramente los datos
- La logica compleja no debe vivir en la interpolacion
- En esta sesion aun no entramos en directivas como `v-if` o `v-for`

Pregunta al grupo:
- Que tipo de logica si pondrias en una interpolacion y cual no?

Respuesta esperada:
- Calculos simples si; reglas complejas o filtrados grandes no.

### Bloque 1.6: Depuracion basica (~5 min)

Objetivo didactico:
Instalar un habito minimo de verificacion antes de pasar a sesiones con mas carga tecnica, incluyendo uso inicial de DevTools y Vue Devtools.

Que mostrar:
- Apertura de DevTools (`F12`) y ubicacion de `Console` y `Elements`
- Instalacion previa de extension "Vue.js devtools" y recarga de la app
- Ejemplo corto con `console.log` antes/despues de cambiar un `ref`
- Revision del estado del componente en pestaña `Vue`
- Casos tipicos de "no aparece": variable no reactiva, `.value` ausente, handler inexistente, valor inicial vacio

Mensajes clave:
- Antes de tocar mas codigo, mirar consola y tipos
- Usar logs pequenos y con contexto (no logs masivos)
- Depurar temprano reduce bloqueos en la practica

Pregunta al grupo:
- Si un dato no se ve en pantalla, cual es tu primera comprobacion?

Respuesta esperada:
- Consola primero, estado reactivo despues (Vue Devtools).

Microdinamica recomendada (2-3 min):
1. Mostrar un boton que incrementa un `ref` con logs de "Antes/Despues".
2. Pedir al grupo que localice el valor en consola y en la pestaña Vue.
3. Simular un fallo rapido (quitar `.value` en script) y observar la pista de error.

## Practica guiada (~25 min)

Objetivo:
Construir una tarjeta de presentacion con varias propiedades reactivas simples, sin interfaces todavia.

Secuencia recomendada:
1. Crear el componente `TarjetaPresentacion.vue`.
2. Declarar `nombre`, `edad`, `ciudad`, `profesion`, `hobbies` y `activo` con `ref`.
3. Mostrar esos datos en el `template` con interpolacion y template literal.
4. Anadir expresiones derivadas (`2025 - edad` y mensaje con ternario).
5. Revisar en voz alta donde aparece `.value` y donde no.
6. Cerrar con una mini comprobacion de depuracion (consola + Vue Devtools + tipado).

Checklist rapido:
- No aparece `any` sin necesidad.
- Las variables reactivas estan bien tipadas.
- El alumnado distingue `script` de `template`.
- La solucion no depende de interfaces ni funciones avanzadas.
- El grupo puede detectar un fallo basico de enlace en menos de 2 minutos.

## Test de sesion y correccion (~15 min)

Propuesta:
1. Abrir el bloque "Test Sesion 1" dentro de la sesion del alumno.
2. Resolver una ronda corta (10-12 preguntas) por parejas o grupo.
3. Corregir inmediatamente usando "Respuestas (Autoevaluacion)" y el desplegable "Ver respuestas".
4. Si hay tiempo, completar las 16 preguntas para cierre completo.

Objetivo:
- Verificar comprension real de estructura, tipado, `ref`/`reactive`, interpolacion y depuracion minima antes de avanzar.

## Cierre y comprobacion (~5 min)

Preguntas de salida:
- Que bloque de un `.vue` contiene el estado?
- Cuando usamos `.value`?
- Que diferencia hay entre cambiar una variable normal y una reactiva?
- Si el dato no aparece en UI, que revisas primero?

Criterio minimo de sesion superada:
- El grupo puede leer un componente sencillo y explicar que hace cada bloque.
- El grupo sabe crear `ref` tipados y mostrarlos en pantalla.
- El grupo conoce el checklist minimo de depuracion.
- El grupo sabe abrir DevTools y localizar el estado basico de un componente en la pestaña Vue.

Transicion recomendada:
- Cerrar con el preview de la sesion 2 (interfaces, directivas y eventos) para conectar con el siguiente bloque.

## Si falta tiempo
1. Priorizar 1.2, 1.3 y 1.4 (estructura + tipado + reactividad).
2. Mantener una practica minima de tarjeta y una sola ronda de test.
3. Dejar 1.6 como checklist oral de 1 minuto (sin microdinamica).

## Si sobra tiempo
1. Comparar una misma solucion con varias `ref` frente a un `reactive`.
2. Resolver las 16 preguntas completas del test y comentar por que cada distractor es incorrecto.
3. Pedir un micro-refactor del ejercicio para mejorar nombres y legibilidad.
