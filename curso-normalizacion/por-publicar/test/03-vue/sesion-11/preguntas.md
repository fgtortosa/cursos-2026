---
title: "Preguntas — Sesión 11: Componentes, comunicación y estado derivado"
description: "Banco de 16 preguntas tipo test sobre computed, props, emits, defineModel, watchers, lifecycle hooks y slots."
outline: [2, 2]
search: false
---

# Test de autoevaluación — Sesión 11: Componentes, comunicación y estado derivado

::: tip ALCANCE
Las preguntas cubren **solo** lo que se enseña en esta sesión: `computed`, comunicación padre↔hijo (`defineProps`, `defineEmits`, `withDefaults`, `defineModel`), watchers, hooks de ciclo de vida, slots y un primer contacto con `provide`/`inject`.

Los temas relacionados que se cubren en otras sesiones tienen su propio test:

- Estructura `.vue`, `ref`/`reactive` → [Sesión 9](../sesion-09/).
- Directivas, eventos y métodos de arrays → [Sesión 10](../sesion-10/).
- Composables, servicios y arquitectura Vista → Composable → Servicio → [Sesión 12](../sesion-12/).
:::

## Pregunta 1

¿Para qué sirve principalmente una `computed`?

a) Para declarar props

b) Para derivar un valor reactivo a partir de otro estado

c) Para lanzar peticiones HTTP

d) Para crear slots

## Pregunta 2

¿Qué ventaja ofrece `computed` frente a un método simple en muchos casos?

a) Se ejecuta solo en el backend

b) Se cachea según sus dependencias y solo se recalcula cuando alguna cambia

c) Permite modificar props directamente

d) Sustituye a `watch`

## Pregunta 3

¿Qué mecanismo pasa datos del padre al hijo?

a) `defineEmits`

b) `defineProps`

c) `defineStore`

d) `watchEffect`

## Pregunta 4

¿Qué afirmación es correcta sobre los props?

a) El hijo puede modificarlos libremente

b) Son de solo lectura en el hijo

c) Solo pueden ser strings

d) No admiten valores por defecto

## Pregunta 5

¿Qué mecanismo envía eventos del hijo al padre?

a) `defineProps`

b) `defineSlots`

c) `defineEmits`

d) `defineExpose`

## Pregunta 6

¿Qué herramienta simplifica el uso de `v-model` en un componente personalizado?

a) `defineModel`

b) `provide`

c) `withDefaults`

d) `reactiveModel`

## Pregunta 7

Cuando padre e hijo comparten un dato editable, ¿dónde suele vivir el estado fuente?

a) En el hijo por defecto

b) En el padre (la fuente única de verdad)

c) En cualquier slot

d) En el CSS del componente

## Pregunta 8

¿Para qué sirve `withDefaults` junto a `defineProps`?

a) Para declarar eventos

b) Para asignar valores por defecto a props opcionales

c) Para evitar tipado

d) Para transformar props en refs globales

## Pregunta 9

¿Cuándo conviene `watch`?

a) Para calcular totales que se muestran en pantalla

b) Para efectos secundarios: guardar en storage, logs, llamar a una API

c) Para definir interfaces

d) Para evitar usar `onMounted`

## Pregunta 10

¿Qué diferencia principal tiene `watchEffect` frente a `watch`?

a) No reacciona a cambios

b) Detecta dependencias automáticamente (no le indicas qué observar)

c) Solo sirve con Pinia

d) Obliga a usar `deep: true`

## Pregunta 11

¿Qué hook se usa normalmente para cargar datos iniciales al montar el componente?

a) `onHydrated`

b) `onMounted`

c) `onReady`

d) `onVisible`

## Pregunta 12

¿Qué es un slot?

a) Un hueco de contenido que el componente padre puede rellenar

b) Un evento especial del DOM

c) Una variante de `watch`

d) Un store compartido

## Pregunta 13

¿Para qué sirve `provide`/`inject` en esencia?

a) Para reemplazar siempre Props y Emits

b) Para compartir contexto sin pasar props por muchos niveles intermedios

c) Para crear formularios con `v-model`

d) Para hacer peticiones HTTP

## Pregunta 14

Si necesitas mostrar el total de gastos de una lista reactiva, ¿qué encaja mejor?

a) `computed`

b) `watch`

c) `defineEmits`

d) Un slot

## Pregunta 15

Si un hijo emite un clic de "guardar" al padre, ¿qué mecanismo encaja mejor?

a) `defineModel`

b) `defineEmits`

c) `withDefaults`

d) `provide`

## Pregunta 16

En un formulario reactivo, ¿qué patrón resulta más claro y mantenible?

a) Mezclar validación y guardado directamente en el template

b) Entrada (`ref`) + derivado (`computed` para validez/normalización) + acción (método para enviar)

c) Guardar todo en un `watch` para que sea automático

d) Usar solo `defineModel` para cualquier lógica
