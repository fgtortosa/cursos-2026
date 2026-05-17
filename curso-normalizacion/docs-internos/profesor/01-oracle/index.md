---
title: Guías de profesor — Parte Oracle
description: Índice de las guías de impartición de las sesiones Oracle del curso de normalización.
outline: [2, 3]
---

# Guías de profesor — Parte Oracle

Guías de impartición para las dos sesiones del bloque Oracle. Cada guía incluye distribución del tiempo, puntos de énfasis, preguntas de reflexión, guion de práctica y errores comunes.

| Sesión | Título | Duración |
|--------|--------|----------|
| [Sesión 1](./sesion-1.md) | Fundamentos Oracle | 1 hora |
| [Sesión 2](./sesion-2.md) | Tablas, vistas y paquetes | 1 hora |

## Material de apoyo

| Página | Uso |
|--------|-----|
| [Diccionario del schema CURSONORMADM](./schema-cursonormadm.md) | Descripción detallada de tablas, DDL, relaciones, restricciones e índices para preparar las explicaciones del profesor |

## Preparación común a ambas sesiones

- Esquemas `CURSONORMADM` / `CURSONORMWEB` creados y con datos de muestra
- Tabla `TRES_TIPO_RECURSO`, vista `VRES_TIPO_RECURSO` y package `PKG_RES_TIPO_RECURSO` compilados y con `STATUS = VALID`
- Grants dados: `SELECT` sobre la vista y `EXECUTE` sobre el package a `CURSONORMWEB`
- Conexiones probadas desde DBeaver o SQL Developer para VS Code con ambos usuarios

