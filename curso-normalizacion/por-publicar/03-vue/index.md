---
title: Parte Vue 3 con TypeScript — Sesiones 6 a 10
description: Fundamentos de Vue 3 con TypeScript para el curso de normalización (sesiones 6-10 del temario global)
outline: deep
---

# Parte Vue 3 con TypeScript

Esta sección cubre las **sesiones 6 a 10** del curso, dedicadas a Vue 3 con TypeScript. Continúa tras la [Parte .NET](../parte-dotnet/) y precede a la [Integración full-stack](../parte-integracion/).

## Objetivos del módulo

::: info CONTEXTO
Al finalizar este bloque, el alumno será capaz de:
- Crear componentes Vue 3 con TypeScript y Composition API
- Trabajar con reactividad, directivas y eventos
- Comunicar componentes mediante Props, Emits y `defineModel`
- Aplicar propiedades computadas y watchers
- Estructurar aplicaciones con la arquitectura Vista → Composable → Servicio
- Utilizar componentes internos de la UA (`vueua-autocomplete`, `vueua-dialogmodal`)
:::

## Sesiones de este bloque

| Sesión | Título | Duración |
|--------|--------|----------|
| [Sesión 6: Vue 3, TypeScript y primer componente](./jl-manrique/sesiones/sesion-1-vue-typescript-fundamentos/) | Estructura `.vue`, TypeScript básico, reactividad e interpolación | ~90 min |
| [Sesión 7: Directivas, eventos y datos](./jl-manrique/sesiones/sesion-2-directivas-eventos/) | Interfaces, directivas, `v-model`, eventos y métodos de arrays | ~90 min |
| [Sesión 8: Componentes y comunicación](./jl-manrique/sesiones/sesion-3-componentes-estado/) | `computed`, Props, Emits, `defineModel`, watchers, lifecycle, slots | ~90 min |
| [Sesión 9: Arquitectura de componentes y servicios](./jl-manrique/sesiones/sesion-4-arquitectura-apis/) | Composables vs Servicios, Vista → Composable → Servicio, depuración | ~90 min |
| [Sesión 10: Otros componentes internos](./jl-manrique/sesiones/sesion-5-componentes-ua/) | `vueua-autocomplete`, `vueua-dialogmodal`, Teleport | ~90 min |

::: tip CONTINUACIÓN EN INTEGRACIÓN
Los temas de llamadas a la API (`useAxios`), validación de formularios (`useGestionFormularios`) y estado global (Pinia) se cubren en las sesiones de **Integración full-stack** y **Sesiones avanzadas**, donde se ven de extremo a extremo con .NET y Oracle.
:::

## Flujo completo

```
Navegador                     Servidor .NET
─────────                     ─────────────
Vista.vue
  └─ useComposable.ts ──────► useServicio.ts
	  │                           │
	  │ ref, computed, watch      │ llamadaAxios(url, verbo)
	  │                           │
	  ▼                           ▼
  <template>              Controllers/Apis/
  renderiza datos         XxxController.cs
						 │
						 ▼
					 ClaseOracleBD3 ──► Oracle BD
```

## Requisitos previos

::: warning IMPORTANTE
- Visual Studio Code con la extensión **Vue - Official**
- Node.js 18+ y **pnpm 10.22.0** (recomendado vía Corepack)
- Proyecto creado desde la **plantilla UA** (PlantillaMVCCore)
- Conocimientos básicos de HTML y CSS
:::

## Material de apoyo

- [Guía del profesor](./jl-manrique/guia-profesor/)
- [Evaluación y repaso](./jl-manrique/test/)


