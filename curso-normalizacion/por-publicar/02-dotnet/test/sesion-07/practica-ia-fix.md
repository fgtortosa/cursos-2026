---
title: "Práctica IA-fix — Sesión 7"
description: "Corregir un controlador POST que no respeta los patrones de la sesión 7 (ControladorBase, Result<T>, CreatedAtAction)."
outline: deep
---

# Práctica IA-fix — Sesión 7

## Objetivo

Pide a Copilot (o al asistente IA que uses) que corrija el siguiente controlador. **Antes de aceptar la solución**, comprueba que la IA haya aplicado los tres patrones canónicos de la sesión:

1. Heredar de **`ControladorBase`** (no de `ControllerBase`).
2. Devolver **`Result<T>`** desde el servicio y traducirlo con **`HandleResult`** cuando falla.
3. Para un `POST` que crea un recurso, devolver **`201 Created` con `CreatedAtAction(...)`** y cabecera `Location` en el camino feliz.

## Código con errores

```csharp
using Microsoft.AspNetCore.Mvc;
using uaReservas.Models.Reservas;
using uaReservas.Services.Reservas;

[Route("api/[controller]")]
[ApiController]
public class TipoRecursosController : ControllerBase       // ERROR 1
{
    private readonly ITiposRecursoServicio _servicio;

    public TipoRecursosController(ITiposRecursoServicio servicio)
    {
        _servicio = servicio;
    }

    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] TipoRecursoCrearDto dto)
    {
        if (dto == null)                                    // ERROR 2
            return Ok();

        var resultado = await _servicio.CrearAsync(dto);
        if (!resultado.IsSuccess)
            return StatusCode(500, resultado.Error);        // ERROR 3

        return Ok(resultado.Value);                         // ERROR 4
    }
}
```

## Errores que debe detectar la IA

| #   | Problema                                                          | Corrección esperada                                                                                                                                                                                     |
| --- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Hereda de `ControllerBase`, no de `ControladorBase`               | Cambiar a `ControladorBase` (provee `Idioma`, `CodPer`, `Roles`, `ValidationProblemLocalizado`, …).                                                                                                     |
| 2   | Comprobación manual de `null` redundante                          | `[ApiController]` ya valida el modelo y devuelve `400` automático; eliminar el bloque.                                                                                                                  |
| 3   | Devuelve `StatusCode(500, ...)` a mano ignorando el `Result<T>`   | Delegar en `HandleResult(resultado)` para que la respuesta sea el `ProblemDetails` correcto según `ErrorType` (`400` validación, `404` no encontrado, `500` técnico).                                   |
| 4   | Una creación devuelve `200 Ok`, no `201 Created` y sin `Location` | Devolver `CreatedAtAction(nameof(ObtenerPorId), new { id = resultado.Value }, resultado.Value)` para que el cliente reciba el `201` con cabecera `Location: /api/TipoRecursos/{id}` y el id en el body. |

## Solución de referencia (patrón en crudo)

```csharp
[HttpPost]
[ProducesResponseType<int>(StatusCodes.Status201Created)]
[ProducesResponseType<ValidationProblemDetails>(StatusCodes.Status400BadRequest)]
public async Task<ActionResult> Crear([FromBody] TipoRecursoCrearDto dto)
{
    var resultado = await _servicio.CrearAsync(dto);

    // Failure → ProblemDetails (400 / 404 / 500 segun ErrorType).
    if (!resultado.IsSuccess) return HandleResult(resultado);

    // Exito → 201 Created con cabecera Location y body = id.
    return CreatedAtAction(
        nameof(ObtenerPorId),
        new { id = resultado.Value },
        resultado.Value);
}
```

::: tip BUENA PRÁCTICA
El patrón cortafuegos es siempre el mismo: primero `if (!resultado.IsSuccess) return HandleResult(resultado);` y a continuación el verbo HTTP que toca (`Ok`, `CreatedAtAction`, `NoContent`). Verás esto **en cada acción** del proyecto. Más adelante, en [sesión 13](../../../04-integracion/sesiones/sesion-13-validacion/) y [sesión 14](../../../04-integracion/sesiones/sesion-14-errores/#handleresult), se introducen helpers (`HandleCreated`, `HandleNoContent`) que encapsulan estos one-liners — pero entender el patrón en crudo primero es lo importante.
:::

::: warning OJO CON LA IA
Es muy posible que Copilot te proponga `return Created("/api/TipoRecursos/" + resultado.Value, resultado.Value);` con la URL **concatenada a mano**. No lo aceptes: usa **siempre** `CreatedAtAction(nameof(...), ...)` para que un rename del método GET rompa la compilación en vez de dejar la cabecera `Location` apuntando a una URL inexistente en silencio.
:::
