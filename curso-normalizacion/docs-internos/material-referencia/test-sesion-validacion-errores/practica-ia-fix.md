# Práctica IA-fix — Sesión 3

## Objetivo

Corregir un validador y el tratamiento de errores en controlador.

```csharp
public class ClaseGuardarUnidadValidator : AbstractValidator<ClaseGuardarUnidad>
{
    public ClaseGuardarUnidadValidator()
    {
        RuleFor(x => x.Granularidad).GreaterThan(0); // BUG: falta rango y mensaje claro
    }
}

[HttpPost]
public ActionResult Guardar(ClaseGuardarUnidad dto)
{
    var r = _servicio.Guardar(dto);
    if (!r.IsSuccess) throw new Exception(r.Error?.Message); // BUG: no usar excepciones de negocio
    return Ok(r);
}
```

## Qué debe arreglar la IA

1. Añadir reglas completas con mensajes localizables.
2. Sustituir `throw` por `HandleResult(r)`.
3. Mantener `ProblemDetails` homogéneo.
