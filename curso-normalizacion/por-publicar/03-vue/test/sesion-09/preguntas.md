---
title: "Preguntas — Sesión 9: Vue 3, TypeScript y primer componente"
description: "Banco de 21 preguntas tipo test sobre estructura .vue, TypeScript básico, reactividad, interpolación y depuración."
outline: [2, 2]
search: false
---

# Test de autoevaluación — Sesión 9: Vue 3, TypeScript y primer componente

::: tip ALCANCE
Las preguntas cubren **solo** lo que se enseña en esta sesión: estructura de un componente `.vue`, TypeScript básico (`const`/`let`, tipos, union types, `any`/`unknown`, `as const`), reactividad con `ref` y `reactive`, interpolación en el template y depuración con DevTools.

Los temas relacionados que se cubren en otras sesiones tienen su propio test:

- Interfaces, `v-if`, `v-for`, `v-model`, eventos y métodos de arrays → [Sesión 10](../sesion-10/).
- Props, Emits, `defineModel`, `computed`, `watch` y slots → [Sesión 11](../sesion-11/).
- Composables, servicios y arquitectura Vista → Composable → Servicio → [Sesión 12](../sesion-12/).
- Componentes internos UA (`vueua-autocomplete`, `vueua-dialogmodal`, Teleport) → [Sesión 13](../sesion-13/).
  :::

## Pregunta 1

¿Cuántos bloques principales tiene un fichero `.vue`?

a) Uno (solo el `<template>`)

b) Dos (`<script>` y `<template>`)

c) Tres (`<script>`, `<template>` y `<style>`)

d) Cuatro (`<script>`, `<template>`, `<style>` y `<router>`)

## Pregunta 2

¿Cómo se muestra el valor de una variable reactiva `mensaje` en el `<template>`?

a) `@mensaje`

b) `{{ mensaje }}`

c) `[mensaje]`

d) Solo con `v-text="mensaje"`; las llaves dobles no funcionan con refs

## Pregunta 3

¿Qué hace el atributo `scoped` en `<style scoped>`?

a) Carga los estilos de forma asíncrona para mejorar el rendimiento

b) Aplica los estilos a toda la aplicación de forma global

c) Limita los estilos al componente actual sin afectar a otros componentes

d) Activa la compilación SCSS automáticamente

## Pregunta 4

¿Para qué sirve `console.warn()`?

a) Para mostrar un mensaje en rojo con su stack trace completo

b) Para pausar la ejecución igual que la sentencia `debugger`

c) Para mostrar un aviso en amarillo: algo no es óptimo pero la app no se rompe

d) Para medir el tiempo transcurrido entre dos puntos del código

## Pregunta 5

¿Qué herramienta del navegador permite ver el árbol de componentes Vue, sus `ref` y sus props en tiempo real sin modificar el código?

a) Redux DevTools

b) Pestaña **Network** de DevTools

c) Vue Devtools (extensión del navegador)

d) Pestaña **Elements** de DevTools

## Pregunta 6

¿Qué tipo TypeScript desactiva completamente la verificación de tipos para una variable?

a) `unknown`

b) `never`

c) `any`

d) `object`

## Pregunta 7

¿Cuál es la regla práctica recomendada en la sesión para elegir entre `const`, `let` y `var`?

a) `var` por defecto; `let` y `const` solo dentro de funciones

b) `let` siempre porque permite tanto asignación como reasignación

c) `const` por defecto; `let` solo si necesitas reasignar; nunca `var`

d) `const` solo para primitivos; `let` para objetos y arrays

## Pregunta 8

¿Qué ocurre si dentro de `<script setup>` escribes `contador` en lugar de `contador.value` para leer un `ref`?

a) TypeScript lanza un error de compilación y el proyecto no arranca

b) Accedes al objeto `RefImpl` completo en lugar del valor que contiene

c) Vue desempaqueta el valor automáticamente igual que en el template

d) La variable devuelve `undefined` porque sin `.value` el ref no existe

## Pregunta 9

¿Cuál de las siguientes expresiones es válida dentro de `{{ }}` en el template?

a) `{{ if (activo) { return 'Sí' } }}`

b) `{{ for (let i of items) { ... } }}`

c) `{{ activo ? 'Activo' : 'Inactivo' }}`

d) `{{ x = nombre + ' García' }}`

## Pregunta 10

¿Cuál es la diferencia clave entre `unknown` y `any` en TypeScript?

a) `unknown` acepta solo tipos primitivos; `any` acepta cualquier valor incluyendo objetos

b) Con `unknown` TypeScript te obliga a comprobar el tipo antes de usarlo; con `any` no

c) `any` lanza un error en tiempo de ejecución; `unknown` lo hace en compilación

d) Son equivalentes en comportamiento; solo cambia el nombre según la versión de TypeScript

## Pregunta 11

Tienes la sentencia `debugger;` en tu código. ¿Qué ocurre si ejecutas la app con las DevTools del navegador **cerradas**?

a) La app lanza un error y se detiene abruptamente

b) Se abre automáticamente la ventana de DevTools

c) La ejecución continúa sin pausar, como si `debugger` no existiese

d) La función actual se cancela y devuelve `undefined`

## Pregunta 12

Según la arquitectura del proyecto UA, ¿en qué carpeta se colocan los ficheros de página completa asociados a rutas URL?

a) `src/components/`

b) `src/views/`

c) `src/pages/`

d) `src/layouts/`

## Pregunta 13

¿Cuál es la diferencia principal entre una Vista y un Componente en un proyecto Vue de la UA?

a) Las vistas se escriben en JavaScript; los componentes en TypeScript

b) Las vistas tienen una ruta URL asociada en el router; los componentes no tienen ruta propia

c) Los componentes pueden usar `ref`; las vistas solo pueden usar `reactive`

d) Las vistas no pueden recibir props; los componentes sí

## Pregunta 14

Según la sesión, ¿cuándo tiene sentido usar `reactive` en lugar de `ref`?

a) Siempre que el valor pueda ser `null` o `undefined`

b) Exclusivamente para arrays de objetos que superan los 10 elementos

c) Para objetos complejos en los que prefieres acceso directo a las propiedades sin usar `.value`

d) Cuando necesitas pasar el valor como prop a un componente hijo

## Pregunta 15

Dado este fragmento de código, ¿cuál es el problema?

```typescript
const persona = ref({ nombre: "Ana", edad: 27 });
persona.edad = 30;
```

a) No se puede usar `ref` con objetos; en ese caso hay que usar `reactive`

b) Hay que acceder a través de `.value`: `persona.value.edad = 30`

c) `persona.edad` funciona pero no dispara la reactividad de Vue

d) `persona` debería declararse con `let` para poder modificar sus propiedades internas

## Pregunta 16

Si tienes `const contador = ref(5)` y ejecutas `console.log(contador)` (sin `.value`), ¿qué aparece en la consola del navegador?

a) `5`

b) `Proxy { value: 5 }`

c) `RefImpl { value: 5, dep: ..., __v_isRef: true, ... }`

d) `{ _value: 5 }`

## Pregunta 17

¿Cuál de las siguientes declaraciones TypeScript produce error de compilación con `strictNullChecks` activado?

a) `let id: number | string = "A-101"`

b) `let activo: boolean = null`

c) `let nombre: string | null = null`

d) `let items: string[] = []`

## Pregunta 18

¿Por qué el proyecto UA usa `import.meta.env.BASE_URL` como prefijo para referenciar assets de la carpeta `public/`?

a) Es un requisito de la extensión Vue - Official para que el linter no marque error

b) En producción la app se despliega bajo una subruta (`/uareservas/`) y la ruta directa `/imagen.jpg` fallaría

c) Vite no copia los assets de `public/` al bundle final y hay que referenciarlos con la URL completa

d) El navegador bloquea las rutas relativas sin dominio por política CORS

## Pregunta 19

¿Qué efecto tiene exactamente `as const` en `const estado = "activo" as const`?

a) Convierte `estado` en un objeto `readonly` con todas sus propiedades protegidas

b) Fija el tipo de `estado` como el literal `"activo"` en lugar del tipo genérico `string`

c) Equivale a escribir `const estado: string = "activo"` con validación adicional en tiempo de ejecución

d) Activa el modo estricto de TypeScript para esa expresión concreta

## Pregunta 20

Tienes un elemento HTML seleccionado en la pestaña **Elements** de DevTools. ¿Cómo lo referencias directamente desde la **Console** sin usar `document.querySelector`?

a) `$el`

b) `this`

c) `$0`

d) `$ref`

## Pregunta 21

¿Qué son los **source maps** que Vite genera al compilar un proyecto Vue con TypeScript?

a) Archivos que asocian cada línea del JavaScript compilado con la línea original del `.ts` o `.vue`

b) Registros de red que DevTools usa para trazar las peticiones HTTP de la aplicación

c) Ficheros de configuración del router de Vue que mapean rutas URL a componentes

d) Imágenes y recursos estáticos que Vite copia desde `src/assets/` al directorio de salida
