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

- Entender la estructura de un proyecto ASP.NET Core 10 con la plantilla UA y arrancarlo localmente.
- Distinguir **entidad** y **DTO** y aplicar la convención UA de "varios DTOs por entidad" (lectura, creación, actualización).
- Implementar un controlador API REST con verbos HTTP, códigos de estado y `ProblemDetails`, y documentarlo bien para que aparezca correctamente en Scalar.
- Probar sus endpoints sin tocar Vue, usando **Chrome DevTools** (pestaña Network) y la UI de **Scalar**.
- Separar la lógica en capas (controlador delgado, servicio con `Result<T>`, acceso a Oracle).
- Conectar con Oracle usando **ClaseOracleBD3** tanto para lectura (vistas) como para escritura (paquetes PL/SQL con OUT params).
- Escribir su primer test xUnit "simulado" del controlador y un test "real" del servicio contra Oracle.
:::

## Sesiones de este bloque

| Sesión | Título | Duración |
| ------ | ------ | -------- |
| [Sesión 3: Introducción a .NET](./sesiones/sesion-0-introduccion-dotnet/) | Estructura del proyecto, Program.cs, inyección de dependencias, C# útil | ~1 h 30 |
| [Sesión 4: Modelos y primer API](./sesiones/sesion-1-dtos-apis/) | DTOs, controladores API, verbos HTTP, códigos de estado, Scalar, probar sin BD desde Chrome | ~1 h 30 |
| [Sesión 5: Servicios y acceso a Oracle](./sesiones/sesion-2-servicios-oracle/) | Capas, `Result<T>`/`HandleResult`, ClaseOracleBD3, llamada a paquetes PL/SQL, xUnit | ~1 h 30 |

::: tip CONTINUACIÓN EN INTEGRACIÓN
Los temas de validación avanzada, gestión de errores global, DataTable y consumo desde Vue se cubren en las sesiones de **Integración full-stack** (sesiones 11-14), donde se ven de extremo a extremo:

| Sesión integración | Contenido .NET relacionado |
| ------------------ | -------------------------- |
| [Sesión 11: API y autenticación](../parte-integracion/sesiones/sesion-11-api-autenticacion/) | OpenAPI, Scalar, claims, CAS+JWT cookies |
| [Sesión 12: Validación](../parte-integracion/sesiones/sesion-12-validacion/) | DataAnnotations, FluentValidation, localización de mensajes |
| [Sesión 13: Errores](../parte-integracion/sesiones/sesion-13-errores/) | `Result<T>`, `ProblemDetails`, `IExceptionHandler`, toasts |
| [Sesión 14: DataTable](../parte-integracion/sesiones/sesion-14-datatable/) | Paginación, filtros y ordenación en servidor |
:::

## Flujo completo en estas sesiones

```
Cliente (Chrome o Vue)                Servidor (.NET Core 10)             Oracle
──────────────────────                ───────────────────────             ────────
GET /api/Recursos                ──► [Authorize] middleware             
                                          │
                                     ControladorBase (claims, idioma)
                                          │
                                     IRecursosServicio
                                          │
                                     ObtenerTodosMapAsync<T>      ────► SELECT … FROM VRES_RECURSO
                                          │
                                     Result<T>.Success(...)
                                          │
                                     HandleResult ──► 200 + JSON
─────────────────────────────────────────────────────────────────────────────────
POST /api/Recursos               ──► [Authorize]
                                     IRecursosServicio.CrearAsync
                                          │
                                     EjecutarParamsAsync          ────► PKG_RES_RECURSO.CREAR
                                          │                              (valida, COMMIT,
                                          │                               P_CODIGO_ERROR OUT)
                                     Result<int> Success/Failure
                                          │
                                     HandleResult ──► 201 / 400 / 404 / 500
```

## Requisitos previos

::: warning IMPORTANTE
- Visual Studio 2022 con **.NET 10 SDK** instalado.
- Acceso al esquema Oracle **`CURSONORMADM`** (entorno `ORACTEST`) con el usuario de aplicación **`CURSONORMWEB`**.
- Proyecto base ya creado desde la plantilla UA (`PlantillaMVCCore.*`).
- `NuGet.Config` global apuntando al feed UA (ver `00-preparacion`).
- `dotnet user-secrets` configurado con `ConnectionStrings:oradb` en cada proyecto que vaya a abrir Oracle.
- Node.js y `pnpm` para que la parte Vue compile (aunque las sesiones 4 y 5 **no piden escribir Vue**: la página `Home.vue` ya trae botones que llaman a la API para que se pueda probar todo desde Chrome).
:::

::: info CONTEXTO — ejercicio transversal de sesiones 4 y 5
Durante estas dos sesiones el alumno trabajará sobre una entidad nueva, **`TRES_OBSERVACION_RESERVA`** (observaciones asociadas a una reserva, con texto multiidioma + `CODPER_AUTOR`). El SQL completo (tabla, vista `VRES_OBSERVACION_RESERVA` y paquete `PKG_RES_OBSERVACION_RESERVA` con `CREAR` y `ELIMINAR` por `ACTIVO='N'`) **se entrega ya hecho**. La sesión 4 pide que el alumno cree DTOs y la API que devuelva 200 OK con datos hardcodeados; la sesión 5 pide que conecte el servicio al paquete y escriba un test simulado.
:::
