---
title: Profesor
description: Material de coordinación y guías docentes del curso de normalización
outline: [2, 2]
search: false
---

# Profesor

Espacio reservado para el material de coordinación y las guías docentes que **no forman parte del recorrido del alumnado**. Aquí encontrarás guion de impartición, distribución del tiempo, puntos de énfasis, errores frecuentes y material de referencia para preparar las sesiones.

::: info CONTEXTO
Este espacio queda fuera del sidebar principal del curso. Solo aparece cuando navegas dentro de `/profesor/`. Si has llegado por error, vuelve a la [portada del curso](../).
:::

## Bloques

<a class="landing-card" href="./01-oracle/">
  <span class="landing-card__eyebrow">Bloque 1</span>
  <strong class="landing-card__title">Oracle</strong>
  <span class="landing-card__description">Guías de impartición de las sesiones Oracle (fundamentos, tablas/vistas/paquetes), diccionario del schema <code>CURSONORMADM</code> y soluciones de los ejercicios entregables.</span>
  <span class="landing-card__link">Abrir guías de Oracle →</span>
</a>

<a class="landing-card" href="../02-dotnet/guia-profesor/">
  <span class="landing-card__eyebrow">Bloque 2</span>
  <strong class="landing-card__title">.NET</strong>
  <span class="landing-card__description">Guías de impartición y material de referencia de las sesiones .NET: introducción, modelos, servicios con Oracle, validación y errores, DataTable server-side, OpenAPI y pruebas.</span>
  <span class="landing-card__link">Abrir guías de .NET →</span>
</a>

<a class="landing-card" href="../03-vue/guia-profesor/">
  <span class="landing-card__eyebrow">Bloque 3</span>
  <strong class="landing-card__title">Vue</strong>
  <span class="landing-card__description">Guías de impartición de las sesiones Vue: fundamentos de Vue 3 y TypeScript, directivas, componentes, comunicación, arquitectura y servicios.</span>
  <span class="landing-card__link">Abrir guías de Vue →</span>
</a>

## Coordinación

<a class="landing-card" href="./guia-organizacion-repositorio.md">
  <strong class="landing-card__title">Guía de organización del repositorio</strong>
  <span class="landing-card__description">Convenciones de carpetas y ficheros, criterios de versionado del material y reglas de publicación bajo <code>por-publicar/</code>.</span>
  <span class="landing-card__link">Abrir guía →</span>
</a>

## Cómo se mantiene este espacio aislado

- El generador de sidebar (`scripts/generate-sidebar.mjs`) detecta la carpeta `profesor/` y cualquier subcarpeta `guia-profesor/` anidada en otros bloques (`02-dotnet/guia-profesor/`, `03-vue/guia-profesor/`) y las **excluye** del sidebar principal del curso.
- Ese mismo generador construye una entrada de sidebar adicional bajo la clave `/curso-normalizacion/profesor/` que agrupa todo el material docente. VitePress aplica automáticamente ese sidebar cuando la URL empieza por `/profesor/`.
- Para añadir una guía nueva: crea el `.md` (en `profesor/<bloque>/`, `02-dotnet/guia-profesor/` o `03-vue/guia-profesor/`) y vuelve a ejecutar `node scripts/generate-sidebar.mjs`.
