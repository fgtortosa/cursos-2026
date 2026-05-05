---
title: Parte .NET Core 10 — Sesiones 3 a 5
description: Fundamentos de .NET Core 10 para el curso de normalización (sesiones 3-5 del temario global)
outline: deep
---

# Parte .NET Core 10

Esta sección cubre las **sesiones 3 a 5** del curso, dedicadas a los fundamentos de .NET. Continúa tras la [Parte Oracle](../parte-oracle/) y precede a la [Parte Vue](../parte-vue/).

## Objetivos del módulo

::: info CONTEXTO
Al finalizar este bloque, el alumno será capaz de:
- Entender la estructura de un proyecto ASP.NET Core con la plantilla UA
- Crear DTOs correctos para APIs
- Implementar controladores API REST con verbos HTTP y códigos de estado
- Conectar con Oracle usando ClaseOracleBD3
- Separar la lógica en capas: controlador, servicio e interfaz
:::

## Sesiones de este bloque

| Sesión | Título | Duración |
|--------|--------|----------|
| [Sesión 3: Introducción a .NET](./sesiones/sesion-0-introduccion-dotnet/) | Estructura del proyecto, Program.cs, inyección de dependencias, C# útil | ~45 min |
| [Sesión 4: Modelos y primer API](./sesiones/sesion-1-dtos-apis/) | DTOs, controladores API, verbos HTTP, códigos de estado | ~45 min |
| [Sesión 5: Servicios y acceso a Oracle](./sesiones/sesion-2-servicios-oracle/) | Capas, ClaseOracleBD3, mapeo automático, flujo completo | ~45 min |

::: tip CONTINUACIÓN EN INTEGRACIÓN
Los temas de validación, gestión de errores, DataTable y OpenAPI se cubren en las sesiones de **Integración full-stack** (sesiones 11-14), donde se ven de extremo a extremo con Oracle y Vue.

| Sesión integración | Contenido .NET relacionado |
|---|---|
| [Sesión 11: API y autenticación](../parte-integracion/sesiones/sesion-11-api-autenticacion/) | OpenAPI, Scalar |
| [Sesión 12: Validación](../parte-integracion/sesiones/sesion-12-validacion/) | DataAnnotations, FluentValidation, localización |
| [Sesión 13: Errores](../parte-integracion/sesiones/sesion-13-errores/) | Result\<T\>, ProblemDetails, IExceptionHandler |
| [Sesión 14: DataTable](../parte-integracion/sesiones/sesion-14-datatable/) | ClaseCrudUtils, CamposFiltros, paginación |
:::

## Flujo completo

```
Cliente (Vue)                    Servidor (.NET Core 10)
─────────────                    ───────────────────────
llamadaAxios ──────────────────► [ApiController] valida DTO
                                        │
gestionarError ◄───── 400/500 ──── ApiControllerBase.HandleResult
                                        │
avisarError ◄──── ProblemDetails ─── Servicio devuelve Result<T>
                                        │
data.value ◄──────── 200 OK ──── ClaseOracleBD3.ObtenerTodosMap
```

## Requisitos previos

::: warning IMPORTANTE
- Visual Studio 2022 con .NET 10 SDK
- Acceso al esquema Oracle `CURSONET`
- Proyecto creado desde la plantilla UA (PlantillaMVCCore)
- Node.js para el proyecto Vue

**Material de referencia:** Las sesiones antiguas 3-5 (.NET) siguen disponibles como material de consulta en sus directorios originales.
:::
