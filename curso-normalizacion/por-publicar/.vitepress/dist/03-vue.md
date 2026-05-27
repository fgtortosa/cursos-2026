---
url: /curso-normalizacion/03-vue.md
description: >-
  Fundamentos de Vue 3 con TypeScript para el curso de normalización (sesiones 9
  a 13 del temario global).
---

# Parte Vue 3 con TypeScript

Esta sección cubre las **sesiones 9 a 13** del curso, dedicadas a Vue 3 con TypeScript. Continúa tras la [Parte .NET](../02-dotnet/) y precede a la [Integración full-stack](../04-integracion/).

## Objetivos del módulo

::: info CONTEXTO
Al finalizar este bloque, el alumno será capaz de:

* Crear componentes Vue 3 con TypeScript y Composition API.
* Trabajar con reactividad, directivas y eventos.
* Comunicar componentes mediante Props, Emits y `defineModel`.
* Aplicar propiedades computadas y watchers.
* Estructurar aplicaciones con la arquitectura Vista → Composable → Servicio.
* Utilizar componentes internos de la UA (`@vueua/components`).
  :::

## Sesiones de este bloque

| Sesión | Título | Duración |
|--------|--------|----------|
| [Sesión 9: Vue 3, TypeScript y primer componente](./sesiones/sesion-09-vue-typescript-fundamentos/) | Estructura `.vue`, TypeScript básico, reactividad e interpolación | 1 h 30 min |
| [Sesión 10: Directivas, eventos y datos](./sesiones/sesion-10-directivas-eventos/) | Interfaces, directivas, `v-model`, eventos y métodos de arrays | 1 h 30 min |
| [Sesión 11: Componentes y comunicación](./sesiones/sesion-11-componentes-estado/) | `computed`, Props, Emits, `defineModel`, watchers, lifecycle, slots | 1 h 30 min |
| [Sesión 12: Arquitectura de componentes y servicios](./sesiones/sesion-12-arquitectura-apis/) | Composables vs Servicios, Vista → Composable → Servicio, depuración | 1 h 30 min |
| [Sesión 13: Otros componentes internos](./sesiones/sesion-13-componentes-ua/) | `@vueua/components` — modales, toasts, BotonLoading, Teleport | 1 h 30 min |

::: tip CONTINUACIÓN EN INTEGRACIÓN
Los temas de llamadas a la API (`useAxios`), validación de formularios (`useGestionFormularios`) y estado global (Pinia) se cubren en las sesiones de **Integración full-stack** (14-17) y **Sesiones avanzadas** (18-25), donde se ven de extremo a extremo con .NET y Oracle.
:::

## Requisitos previos

::: warning IMPORTANTE

* Visual Studio Code con la extensión **Vue - Official**.
* Node.js 18+ y **pnpm 10.22.0** (recomendado vía Corepack).
* Proyecto creado desde la **plantilla UA** (`PlantillaMVCCore`).
* Conocimientos básicos de HTML y CSS.
  :::

## Material de apoyo

* [Tests y evaluación](./test/) — Banco de preguntas, autoevaluación y práctica IA-fix por sesión.
