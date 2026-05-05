---
title: Integración full-stack — Sesiones 11 a 14
description: Sesiones de integración donde cada tema se cubre de extremo a extremo (Oracle → .NET → Vue)
outline: deep
---

# Integración full-stack

Esta sección cubre las **sesiones 11 a 14** del curso. Cada sesión trata un tema transversal de extremo a extremo, conectando Oracle, .NET y Vue en un flujo completo.

## Requisitos previos

::: warning IMPORTANTE
Estas sesiones asumen que se han completado las partes anteriores:
- [Parte Oracle](../parte-oracle/) (sesiones 1-2)
- [Parte .NET](../parte-dotnet/) (sesiones 3-5)
- [Parte Vue](../parte-vue/) (sesiones 6-10)
:::

## Sesiones

| Sesión | Título | Enfoque |
|--------|--------|---------|
| [Sesión 11: Llamadas a la API y autenticación](./sesiones/sesion-11-api-autenticacion/) | Cómo Vue habla con .NET, CAS/JWT, OpenAPI y Scalar | API + Auth |
| [Sesión 12: Validación en todas las capas](./sesiones/sesion-12-validacion/) | DataAnnotations, FluentValidation, ModelState y errores en Vue | Validación |
| [Sesión 13: Gestión de errores de extremo a extremo](./sesiones/sesion-13-errores/) | Result\<T\>, ProblemDetails, IExceptionHandler, toasts y modales | Errores |
| [Sesión 14: DataTable de extremo a extremo](./sesiones/sesion-14-datatable/) | ClaseCrudUtils en .NET + vueua-datatable en Vue | DataTable |

## Flujo de integración

```
Oracle BD                    .NET Core 10                  Vue 3
─────────                    ────────────                  ─────
Tablas + Vistas ──────────► ClaseOracleBD3 ──────────────► useAxios / HttpApi
Paquetes CRUD  ──────────► Servicios + Result<T> ────────► Composables
p_codigo_error ──────────► ProblemDetails (RFC 7807) ────► Toasts / Errores form
LISTAR paginado ─────────► ClaseCrudUtils ───────────────► vueua-datatable
```

## Material de referencia

Las sesiones de integración reutilizan y amplían contenido de las partes anteriores:

| Sesión integración | Material de referencia (.NET) |
|---|---|
| Sesión 11 | [Ref: OpenAPI y Scalar](../parte-dotnet/sesiones/sesion-5-openapi-scalar/) |
| Sesión 12 | [Ref: Validación y errores](../parte-dotnet/sesiones/sesion-3-validacion-errores/) |
| Sesión 13 | [Ref: Validación y errores](../parte-dotnet/sesiones/sesion-3-validacion-errores/) |
| Sesión 14 | [Ref: DataTable server-side](../parte-dotnet/sesiones/sesion-4-datatable-clasecrud/) |
