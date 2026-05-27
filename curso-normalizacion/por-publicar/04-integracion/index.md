---
title: Integración full-stack — Sesiones 14 a 17
description: Sesiones de integración donde cada tema se cubre de extremo a extremo (Oracle → .NET → Vue).
outline: deep
---

# Integración full-stack

Esta sección cubre las **sesiones 14 a 17** del curso. Cada sesión trata un tema transversal de extremo a extremo, conectando Oracle, .NET y Vue en un flujo completo.

## Requisitos previos

::: warning IMPORTANTE
Estas sesiones asumen que se han completado las partes anteriores:
- [Parte Oracle](../01-oracle/) (sesiones 1-5).
- [Parte .NET](../02-dotnet/) (sesiones 6-8).
- [Parte Vue](../03-vue/) (sesiones 9-13).
:::

## Sesiones de este bloque

| Sesión | Título | Duración |
|--------|--------|----------|
| [Sesión 14: Llamadas a la API y autenticación](./sesiones/sesion-14-api-autenticacion/) | Cómo Vue habla con .NET, CAS/JWT, OpenAPI y Scalar | 1 h 30 min |
| [Sesión 15: Validación en todas las capas](./sesiones/sesion-15-validacion/) | DataAnnotations, FluentValidation, ModelState y errores en Vue | 1 h 30 min |
| [Sesión 16: Gestión de errores de extremo a extremo](./sesiones/sesion-16-errores/) | `Result<T>`, `ProblemDetails`, `IExceptionHandler`, toasts y modales | 1 h 30 min |
| [Sesión 17: DataTable de extremo a extremo](./sesiones/sesion-17-datatable/) | `ClaseCrudUtils` en .NET + `@vueua/components` DataTable en Vue | 1 h 30 min |

## Flujo de integración

```
Oracle BD                    .NET Core 10                  Vue 3
─────────                    ────────────                  ─────
Tablas + Vistas ──────────► ClaseOracleBD3 ──────────────► useAxios / HttpApi
Paquetes CRUD  ──────────► Servicios + Result<T> ────────► Composables
p_codigo_error ──────────► ProblemDetails (RFC 7807) ────► Toasts / Errores form
LISTAR paginado ─────────► ClaseCrudUtils ───────────────► vueua-datatable
```

