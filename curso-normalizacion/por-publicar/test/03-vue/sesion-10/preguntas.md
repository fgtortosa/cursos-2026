---
title: "Preguntas — Sesión 10: Directivas, eventos y datos"
description: "Banco de 18 preguntas tipo test sobre interfaces, directivas Vue (v-if/v-show/v-for/v-bind/v-model/v-on), modificadores, métodos de arrays y acceso seguro a propiedades (?. y ??)."
outline: [2, 2]
search: false
---

# Test de autoevaluación — Sesión 10: Directivas, eventos y datos

::: tip ALCANCE
Las preguntas cubren **solo** lo que se enseña en esta sesión: interfaces y funciones tipadas, directivas (`v-if`/`v-show`/`v-for`/`v-bind`/`v-model`/`v-on`), modificadores de evento, métodos de arrays (`.filter`/`.map`/`.find`/`.reduce`/`.sort`) y acceso seguro a datos (`?.`, `??`, spread, destructuring).

Los temas relacionados que se cubren en otras sesiones tienen su propio test:

- Estructura `.vue`, `ref`/`reactive`, TypeScript básico → [Sesión 9](../sesion-09/).
- Props, Emits, `computed`, `watch` y slots → [Sesión 11](../sesion-11/).
- Composables, servicios y arquitectura → [Sesión 12](../sesion-12/).
:::

## Pregunta 1

¿Qué describe una `interface` en TypeScript?

a) Un componente visual

b) Un evento del DOM

c) La forma o contrato de un objeto (qué propiedades tiene y de qué tipo)

d) Un tipo de directiva

## Pregunta 2

¿Dónde suele colocarse una interface reutilizable según la convención del curso?

a) `src/styles/`

b) `src/router/`

c) `src/assets/`

d) `src/interfaces/`

## Pregunta 3

¿Qué significa que una función esté tipada como `void`?

a) Que no devuelve un valor útil (sirve para handlers y efectos secundarios)

b) Que devuelve siempre `null`

c) Que no puede recibir parámetros

d) Que solo se usa dentro de componentes Vue

## Pregunta 4

¿Qué directiva crea o elimina nodos del DOM según una condición?

a) `v-bind`

b) `v-model`

c) `v-show`

d) `v-if`

## Pregunta 5

¿Qué directiva encaja mejor cuando una zona se muestra y oculta con mucha frecuencia (modales, tabs)?

a) `v-show`

b) `v-for`

c) `v-slot`

d) `v-pre`

## Pregunta 6

¿Qué directiva se usa para iterar una lista?

a) `v-list`

b) `v-repeat`

c) `v-for`

d) `v-map`

## Pregunta 7

¿Cuál es la mejor `:key` en un `v-for` si cada objeto tiene `id`?

a) `objeto.id`

b) El índice del array (`index`)

c) `Math.random()`

d) El texto visible del elemento

## Pregunta 8

¿Qué atajo representa `v-bind`?

a) `@`

b) `:`

c) `#`

d) `$`

## Pregunta 9

¿Qué directiva conecta un input con una variable reactiva de forma bidireccional?

a) `v-html`

b) `v-once`

c) `v-if`

d) `v-model`

## Pregunta 10

¿Qué modificador evita el comportamiento por defecto de un formulario al enviarlo (`<form @submit…>`)?

a) `.stop`

b) `.prevent`

c) `.once`

d) `.capture`

## Pregunta 11

¿Qué método devuelve un nuevo array con solo los elementos que cumplen una condición?

a) `.find`

b) `.filter`

c) `.reduce`

d) `.some`

## Pregunta 12

¿Qué método devuelve el primer elemento que cumple una condición (o `undefined` si no lo hay)?

a) `.every`

b) `.map`

c) `.find`

d) `.filter`

## Pregunta 13

¿Qué método **modifica** el array original?

a) `.filter`

b) `.map`

c) `.find`

d) `.sort`

## Pregunta 14

¿Qué operador usa un valor por defecto **solo** cuando el de la izquierda es `null` o `undefined` (sin caer con `0`, `''` o `false`)?

a) `&&`

b) `||`

c) `??`

d) `?.`

## Pregunta 15

Tienes un `v-for` de tareas con un checkbox por fila y usas `:key="index"`. Marcas la fila 2 y eliminas la fila 1. ¿Qué ocurre?

a) Vue lanza un error en consola y la lista deja de renderizarse

b) Vue reutiliza los `<input>` por posición y la fila ahora visible aparece marcada por error (estado heredado de la borrada)

c) No ocurre nada, `:key="index"` es la opción recomendada para listas mutables

d) Vue elimina automáticamente todas las filas con el checkbox marcado

## Pregunta 16

Dado este código, ¿qué afirmación es correcta tras ejecutarlo?

```ts
const productos = [3, 1, 2]
const ordenados = productos.sort((a, b) => a - b)
```

a) `productos` sigue siendo `[3, 1, 2]` porque `.sort` no muta

b) `productos` queda `[3, 1, 2]` y `ordenados` es `[1, 2, 3]` (array nuevo)

c) `productos` y `ordenados` valen ambos `[1, 2, 3]` y son la misma referencia

d) Lanza error: `.sort` solo funciona con arrays de strings

## Pregunta 17

¿Qué imprime el `console.log` siguiente?

```ts
interface IClaseUsuario {
  nombre: string
  direccion?: { ciudad: string }
}
const u: IClaseUsuario = { nombre: 'Ana' }
console.log(u.direccion?.ciudad ?? 'Sin ciudad')
```

a) `undefined`

b) `''` (cadena vacía)

c) `'Sin ciudad'`

d) Lanza `Cannot read property 'ciudad' of undefined`

## Pregunta 18

Tras ejecutar este código, ¿qué contiene `resultado` y qué pasa con `numeros`?

```ts
const numeros = [1, 2, 3, 4]
const resultado = numeros.map(n => n * 2)
```

a) `resultado = [2, 4, 6, 8]` y `numeros` sigue siendo `[1, 2, 3, 4]`

b) `resultado = [2, 4, 6, 8]` y `numeros` ahora vale `[2, 4, 6, 8]`

c) `resultado = [2, 4]` (solo los pares); `numeros` intacto

d) `resultado = 20` (suma de los dobles)
