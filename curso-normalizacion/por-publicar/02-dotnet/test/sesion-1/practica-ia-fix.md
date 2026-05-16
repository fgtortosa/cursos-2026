# Práctica IA-fix — Sesión 1

## Objetivo

Pide a Copilot que corrija el siguiente controlador. Antes de aceptar la solución, comprueba que la IA haya aplicado los cuatro patrones vistos en la sesión: **`ControladorBase`**, **`Result<T>`**, **`HandleResult`** y **`CreatedAtAction`**.

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

| #   | Problema                                                         | Corrección esperada                                                                           |
| --- | ---------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| 1   | Hereda de `ControllerBase`, no de `ControladorBase`              | Cambiar a `ControladorBase`                                                                   |
| 2   | Comprobación manual de `null` redundante                         | `[ApiController]` ya gestiona el `ModelState`; eliminar el bloque                             |
| 3   | Devuelve `StatusCode(500, ...)` a mano, ignorando el `Result<T>` | `return HandleResult(resultado)`                                                              |
| 4   | Una creación devuelve `200 Ok`, no `201 Created`                 | `return CreatedAtAction(nameof(ObtenerPorId), new { id = resultado.Value }, resultado.Value)` |

## Solución de referencia

```csharp
[HttpPost]
[ProducesResponseType<int>(StatusCodes.Status201Created)]
[ProducesResponseType<ValidationProblemDetails>(StatusCodes.Status400BadRequest)]
public async Task<ActionResult> Crear([FromBody] TipoRecursoCrearDto dto)
{
    var resultado = await _servicio.CrearAsync(dto);
    if (!resultado.IsSuccess) return HandleResult(resultado);

    return CreatedAtAction(nameof(ObtenerPorId), new { id = resultado.Value }, resultado.Value);
}
```

> `HandleResult` está disponible en `ControladorBase` (vía `ApiControllerBase`) y traduce el `Result<T>` al código HTTP correcto: `400` para errores de validación, `404` para no encontrado y `500` para errores técnicos.
