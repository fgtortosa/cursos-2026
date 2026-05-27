---
title: "Práctica IA-fix — Sesión 9"
description: "Componente Vue con 5 errores típicos de estructura, reactividad y TypeScript para corregir con IA."
outline: deep
---

# Práctica IA-fix — Sesión 9

## Objetivo

Pide a Copilot (o al asistente IA que uses) que corrija el siguiente componente Vue con **5 errores** relacionados con estructura, reactividad, TypeScript e interpolación. **Antes de aceptar la solución**, comprueba que la IA ha arreglado los cinco puntos sin introducir otros nuevos.

## Componente con errores

```vue
<script setup lang="ts">
import { ref } from "vue";

// ERROR 1: var en lugar de const para una variable reactiva.
var contador = ref<number>(0);

// ERROR 2: any como tipo del nombre.
const nombre = ref<any>("Ana García");

function incrementar() {
  // ERROR 3: olvido de .value al modificar el ref en el script.
  contador++;
  console.log("Contador:", contador);
}
</script>

<template>
  <div>
    <!-- ERROR 4: .value innecesario en el template. -->
    <p>Nombre: {{ nombre.value }}</p>

    <!-- ERROR 5: sentencia if en lugar de expresión ternaria. -->
    <p>Estado: {{ if (contador > 0) { "Positivo" } else { "Cero" } }}</p>

    <p>Contador: {{ contador }}</p>
    <button @click="incrementar">+1</button>
  </div>
</template>

<style scoped>
p {
  margin: 0.5rem 0;
}
</style>
```

## Errores que debe detectar la IA

| #   | Problema                                                        | Corrección esperada                                                                                                                                 |
| --- | --------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `var contador` en lugar de `const` para una referencia reactiva | Cambiar a `const contador = ref<number>(0)`. Las referencias reactivas se declaran con `const`; no se reasigna la referencia sino su `.value`.      |
| 2   | Tipo `any` en `ref<any>`                                        | Cambiar a `ref<string>("Ana García")`. El tipo debe ser el real; `any` desactiva todas las comprobaciones de TypeScript.                            |
| 3   | `contador++` en el script sin `.value`                          | Cambiar a `contador.value++`. Sin `.value`, se intenta incrementar el objeto `RefImpl` entero, no su valor numérico interno.                        |
| 4   | `nombre.value` en el template                                   | Cambiar a `{{ nombre }}`. Vue desempaqueta los `ref` automáticamente en el template; añadir `.value` hace que Vue intente acceder a `.value.value`. |
| 5   | Sentencia `if` dentro de `{{ }}`                                | Cambiar a una expresión ternaria: `{{ contador > 0 ? 'Positivo' : 'Cero' }}`. El template solo acepta expresiones, no sentencias.                   |

## Solución de referencia

```vue
<script setup lang="ts">
import { ref } from "vue";

const contador = ref<number>(0); // 1: const, no var
const nombre = ref<string>("Ana García"); // 2: tipo string, no any

function incrementar() {
  contador.value++; // 3: .value obligatorio en el script
  console.log("Contador:", contador.value);
}
</script>

<template>
  <div>
    <p>Nombre: {{ nombre }}</p>
    <!-- 4: sin .value en template -->
    <p>Estado: {{ contador > 0 ? "Positivo" : "Cero" }}</p>
    <!-- 5: ternario, no if -->
    <p>Contador: {{ contador }}</p>
    <button @click="incrementar">+1</button>
  </div>
</template>

<style scoped>
p {
  margin: 0.5rem 0;
}
</style>
```
