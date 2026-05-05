# Práctica IA-fix — Sesión 1

## Objetivo

Pedir a Copilot/ChatGPT que corrija el siguiente controlador API.

```csharp
[HttpPost]
public ActionResult Crear([FromBody] ClaseUnidad dto)
{
    if (dto == null)
        return Ok(); // BUG: debería ser 400

    if (string.IsNullOrEmpty(dto.Nombre))
        return StatusCode(500, "Nombre requerido"); // BUG: código incorrecto

    return Ok(dto); // BUG: debería devolver CreatedAtAction o 201
}
```

## Qué debe arreglar la IA

1. Códigos HTTP correctos (`400` en validación, `201` en creación).
2. Uso de `ProblemDetails` o `ValidationProblemDetails`.
3. Mensajes de error sin texto hardcodeado si hay localización.
