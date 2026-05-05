# Autoevaluación — Sesión 3

## Preguntas rápidas

1. ¿Qué validación va en DataAnnotations y cuál en FluentValidation?
2. ¿Qué capa decide el código HTTP final de un error?
3. ¿Cómo se localiza un mensaje de error en servicio?
4. ¿Qué devuelve `[ApiController]` al fallar modelo?
5. ¿Qué nivel de log usarías para error de validación?

## Respuestas esperadas

1. DataAnnotations: sintaxis/campo; Fluent: reglas complejas/campos cruzados.
2. `ApiControllerBase` o `IExceptionHandler` (pipeline HTTP).
3. `IStringLocalizer` + claves en `resx`.
4. `400` con `ValidationProblemDetails`.
5. `Warning`.
