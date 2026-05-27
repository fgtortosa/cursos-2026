---
url: /curso-normalizacion/02-dotnet/test/sesion-03/practica-ia-fix.md
description: >-
  Corregir un Program.cs con 5 errores típicos de inyección de dependencias y
  orden del pipeline.
---

# Práctica IA-fix — Sesión 3

## Objetivo

Pide a Copilot (o al asistente IA que uses) que corrija el siguiente `Program.cs` con **5 errores** de inyección de dependencias y pipeline. **Antes de aceptar la solución**, comprueba que la IA ha arreglado los cinco puntos sin introducir otros nuevos.

## Código con errores

```csharp
var builder = WebApplication.CreateBuilder(args);

// ERROR 1: Singleton para un servicio que usa conexion a BD (captive dependency).
builder.Services.AddSingleton<IClaseUnidades, ClaseUnidades>();

// ERROR 2: Falta registrar los controladores (sin esto los [HttpGet] no se ven).
builder.Services.AddOpenApi();

var app = builder.Build();

// ERROR 3: UseAuthorization ANTES de UseRouting (no sabe que endpoint proteger).
app.UseAuthorization();
app.UseRouting();

// ERROR 4: UseAuthentication DESPUES de UseAuthorization (autoriza sin saber quien es).
app.UseAuthentication();

// ERROR 5: Falta MapControllers (los endpoints no quedan enganchados al pipeline).
app.Run();
```

## Errores que debe detectar la IA

| # | Problema | Corrección esperada |
| --- | --- | --- |
| 1 | Servicio con conexión a BD registrado como `Singleton` (captive dependency con `ClaseOracleBd`, que es `Scoped`) | Cambiar a `AddScoped<IClaseUnidades, ClaseUnidades>()`. Una instancia por petición HTTP, conexión Oracle que vive lo justo. |
| 2 | Falta `AddControllers()` / `AddControllersWithViews()` | Añadir `builder.Services.AddControllers()` antes de `builder.Build()`. Sin esto los controladores no se descubren ni se enganchan al pipeline. |
| 3 | `UseAuthorization()` antes de `UseRouting()` | El orden correcto es `UseRouting` → `UseAuthentication` → `UseAuthorization`. Sin routing primero, la autorización no sabe qué endpoint evaluar. |
| 4 | `UseAuthentication()` después de `UseAuthorization()` | Mismo orden de arriba. Sin autenticar antes, la autorización no conoce la identidad del usuario y deniega todo. |
| 5 | Falta `app.MapControllers()` | Añadir `app.MapControllers()` antes de `app.Run()`. Sin esta línea los `[HttpGet]`/`[HttpPost]` quedan registrados pero nunca se invocan. |

## Solución de referencia

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();                                   // 2
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();         // 1 (Scoped, no Singleton)
builder.Services.AddOpenApi();

var app = builder.Build();

app.UseRouting();           // 3
app.UseAuthentication();    // 4 (antes que Authorization)
app.UseAuthorization();
app.MapControllers();       // 5
app.Run();
```

::: tip BUENA PRÁCTICA
El orden del pipeline es **convención fija**, no estilo personal: `UseRouting → UseAuthentication → UseAuthorization → MapControllers`. Si alguien lo cambia, romperá la autorización en silencio (todas las rutas se devolverán `401` o ninguna, según el caso).
:::

::: warning OJO CON LA IA
Es habitual que Copilot te proponga `AddSingleton` para "mejorar el rendimiento" sin saber que la dependencia interna es `Scoped`. En .NET 6+ esto se detecta solo en modo desarrollo con una excepción al construir el host (`InvalidOperationException: Cannot consume scoped service`). En producción puede colar y dar problemas raros de conexiones colgadas. **Por defecto, todo servicio con acceso a BD es `Scoped`**.
:::
