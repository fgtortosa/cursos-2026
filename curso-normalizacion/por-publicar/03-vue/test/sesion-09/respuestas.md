---
title: "Respuestas — Sesión 9: Vue 3, TypeScript y primer componente"
description: "Solucionario razonado del test de 21 preguntas de la Sesión 9."
outline: [2, 2]
search: false
---

# Respuestas — Test Sesión 9: Vue 3, TypeScript y primer componente

1. **c)** Tres bloques: `<script>`, `<template>` y `<style>`. El bloque `<script setup lang="ts">` contiene la lógica TypeScript; `<template>` el HTML con directivas Vue; `<style scoped>` el CSS encapsulado al componente. No existe un bloque `<router>` en los ficheros `.vue`.

2. **b)** `{{ mensaje }}`. Las llaves dobles son la forma principal de interpolación en Vue. La opción d) es técnicamente válida (`v-text` existe), pero es la forma secundaria y no la que se enseña como estándar en la sesión.

3. **c)** Limita los estilos al componente actual. Vue añade un atributo único al HTML generado y en los selectores CSS para que los estilos no "escapen" al resto del árbol. Sin `scoped`, un `.btn { color: red }` afectaría a todos los botones de la app.

4. **c)** Aviso en amarillo. `console.warn` está pensado para condiciones no fatales: deprecaciones, valores fuera de rango, configuraciones no recomendadas. `console.error` es el que pinta rojo con stack trace; `console.time`/`timeEnd` es el que mide tiempos.

5. **c)** Vue Devtools. Es una extensión del navegador que se instala aparte y añade una pestaña propia en DevTools. La pestaña Network muestra peticiones HTTP; Elements muestra el DOM renderizado; ninguna de las dos es específica de Vue.

6. **c)** `any`. Al declarar una variable como `any`, TypeScript deja de comprobar qué operaciones se hacen sobre ella. `unknown` también acepta cualquier valor, pero es más seguro porque obliga a verificar el tipo antes de usarlo. `never` representa un tipo que no puede tener ningún valor (funciones que siempre lanzan excepciones, etc.).

7. **c)** `const` por defecto; `let` solo si reasignas; nunca `var`. Esta regla la aplica también el linting de la UA. `var` tiene alcance de función y comportamientos confusos de hoisting que `const`/`let` (alcance de bloque) evitan. Usar `let` cuando no reasignas no es incorrecto, pero sí indica que el código no ha sido revisado.

8. **b)** Accedes al objeto `RefImpl`, no al valor. Un `ref` es un objeto envoltorio con una propiedad `.value` que Vue observa. Si escribes `contador` en el script sin `.value`, estás refiriéndote al envoltorio entero. En el template Vue aplica el desempaquetado automáticamente, por eso allí no hace falta `.value`.

9. **c)** El operador ternario `activo ? 'Activo' : 'Inactivo'`. El template de Vue solo acepta **expresiones** (código que se evalúa y produce un valor). Las sentencias `if`, `for` y las asignaciones (`x = ...`) no están permitidas dentro de `{{ }}`; para lógica condicional o iteración en el template se usan las directivas `v-if` y `v-for` (sesión 10).

10. **b)** Con `unknown` TypeScript te obliga a comprobar el tipo antes de operar. Ambos tipos aceptan cualquier valor, pero `unknown` es seguro: `dato.toUpperCase()` con tipo `unknown` da error de compilación hasta que compruebes `typeof dato === "string"`. La opción d) es falsa; la diferencia es sustancial y ambos existen en TypeScript desde hace años.

11. **c)** La ejecución continúa sin pausar. La sentencia `debugger` solo tiene efecto si las DevTools **ya están abiertas** en el momento en que el navegador llega a esa línea. Si están cerradas, el navegador ignora la instrucción. Por eso es importante abrir DevTools antes de reproducir el fallo, y no olvidar quitar los `debugger` antes de subir código.

12. **b)** `src/views/`. Las vistas son ficheros `.vue` asociados a rutas del router. Los componentes reutilizables van en `src/components/`. Las carpetas `pages/` y `layouts/` no forman parte de la estructura estándar del proyecto UA.

13. **b)** Las vistas tienen una ruta URL asociada; los componentes no. La regla práctica de la sesión es: si el usuario puede navegar directamente mediante una URL, es una Vista; si se usa como pieza dentro de otras páginas o componentes, es un Componente. Ambos usan el mismo lenguaje TypeScript y pueden usar `ref`/`reactive`.

14. **c)** Para objetos complejos donde prefieres acceso directo sin `.value`. La sesión recomienda `ref` en la mayoría de casos porque funciona con todo (primitivos, arrays, objetos) y tiene mejor soporte de TypeScript. `reactive` es una alternativa válida para objetos cuando el acceso directo a propiedades resulta más cómodo, pero no es obligatorio en ningún caso concreto.

15. **b)** Hay que usar `persona.value.edad = 30`. Aunque `persona` se declara con `const`, lo que protegemos es la referencia al objeto `RefImpl`, no su contenido. Para acceder al objeto que envuelve, es obligatorio pasar por `.value`. La opción a) es el distractor clásico: `ref` sí puede envolver objetos; no hay ninguna restricción que obligue a usar `reactive` con ellos.

16. **c)** `RefImpl { value: 5, dep: ..., __v_isRef: true, ... }`. Un `ref` en Vue 3 es un objeto de clase `RefImpl` con una propiedad `.value` observable. La opción a) es lo que esperaría cualquier programador que no conoce los internos de Vue; la opción b) es plausible porque Vue sí usa `Proxy` internamente para `reactive`, pero los `ref` de primitivos se implementan con `RefImpl`, no con `Proxy`.

17. **b)** `let activo: boolean = null`. Con `strictNullChecks` activado (comportamiento por defecto en la plantilla UA), `null` no es asignable al tipo `boolean`. La opción c) puede parecer igual de inválida porque también asigna `null`, pero es correcta porque el tipo declara explícitamente `string | null`, que sí incluye `null`.

18. **b)** En producción la app se despliega bajo una subruta. En el servidor de la UA, la aplicación se sirve bajo `/uareservas/`, no en la raíz `/`. Si escribes `<img src="/lola.jpg">`, en producción el navegador buscará `/lola.jpg` y obtendrá un 404. Usando `import.meta.env.BASE_URL`, Vite resuelve el prefijo correcto en cada entorno (`/` en dev, `/uareservas/` en producción). La opción c) es falsa: Vite sí copia los assets de `public/` al directorio final tal cual, sin procesarlos.

19. **b)** Fija el tipo como el literal `"activo"`. Sin `as const`, TypeScript infiere el tipo de `const estado = "activo"` como `string` (el tipo genérico). Con `as const`, el tipo pasa a ser el literal `"activo"`, lo que permite usarlo en comparaciones estrictas y uniones de literales (`tipo: "activo" | "inactivo"`). La opción c) es falsa porque `as const` no añade validación en tiempo de ejecución; opera exclusivamente en el sistema de tipos.

20. **c)** `$0`. DevTools actualiza esta variable especial cada vez que seleccionas un elemento en la pestaña **Elements**. Las opciones a) y d) son trampas: `$el` es la forma en que Vue referencia el nodo raíz de un componente (accesible desde el script), y `$ref` no es una variable de DevTools (los `ref` de template en Vue se acceden con `templateRef`).

21. **a)** Archivos que asocian cada línea del JavaScript compilado con la línea original del `.ts`/`.vue`. Vite genera ficheros `.map` junto al bundle JavaScript. DevTools los carga automáticamente para mostrarte tu código TypeScript en la pestaña Sources en lugar del JS transformado. Cuando ves un breakpoint detenido en tu fichero `.vue`, el navegador está ejecutando JS pero mostrando la fuente original gracias al source map. La opción b) describe el registro de la pestaña Network, no los source maps.
