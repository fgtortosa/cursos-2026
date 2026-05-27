# Autoevaluación — Sesión 9

## Preguntas rápidas

1. ¿Cuáles son los tres bloques de un archivo `.vue` y qué contiene cada uno?
2. Tienes `const total = ref(0)`. ¿Cómo lees su valor en el `<script setup>`? ¿Y en el `<template>`?
3. ¿Cuál es la diferencia práctica entre `any` y `unknown` en TypeScript? ¿Cuándo usarías cada uno?
4. ¿Qué tipo de expresiones acepta <code v-pre>{{ }}</code> en un template Vue? Pon un ejemplo válido y uno inválido.
5. Pones `debugger;` en una función de tu componente y abres la app con las DevTools **cerradas**. ¿Qué ocurre?

## Respuestas esperadas

1. `<script setup lang="ts">` contiene la lógica (imports, variables reactivas, funciones); `<template>` contiene el HTML con directivas Vue; `<style scoped>` contiene el CSS encapsulado al componente.

2. En el script: `total.value` (obligatorio usar `.value`). En el template: <code v-pre>{{ total }}</code> (Vue desempaqueta el `ref` automáticamente; sin `.value`).

3. `any` desactiva la verificación de tipos y TypeScript no avisa si usas el valor de forma incorrecta. `unknown` también acepta cualquier valor, pero obliga a comprobar el tipo antes de usarlo (con `typeof`, `instanceof` o un type guard). En producción se evita `any`; `unknown` se usa cuando recibes datos externos y aún no conoces su forma.

4. Solo acepta **expresiones** (código que devuelve un valor). Válido: <code v-pre>{{ activo ? 'Sí' : 'No' }}</code>, <code v-pre>{{ edad * 12 }}</code>, <code v-pre>{{ nombre.toUpperCase() }}</code>. Inválido: <code v-pre>{{ if (activo) { ... } }}</code>, <code v-pre>{{ for (...) { ... } }}</code>, <code v-pre>{{ x = 5 }}</code>.

5. La sentencia `debugger` solo pausa la ejecución si las DevTools **ya están abiertas** en ese momento. Con DevTools cerradas, el navegador ignora la instrucción y la app continúa con normalidad.
