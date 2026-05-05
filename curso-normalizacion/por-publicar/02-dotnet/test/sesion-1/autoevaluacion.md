# Autoevaluación — Sesión 1

## Preguntas rápidas

1. ¿Qué diferencia hay entre DTO y entidad?
2. ¿Qué hace `[ApiController]` cuando falla una DataAnnotation?
3. ¿Qué código HTTP usarías para una creación correcta?
4. ¿Qué ventaja tiene `ControllerBase` para APIs?
5. ¿Qué formato de error estándar devuelve ASP.NET Core en validación?

## Respuestas esperadas

1. DTO transporta datos entre capas; entidad modela datos de persistencia.
2. Devuelve `400 BadRequest` automáticamente con `ValidationProblemDetails`.
3. `201 Created` (o `200 OK` según diseño del endpoint).
4. Helpers API (`Ok`, `BadRequest`, `Problem`, etc.) sin capa de vistas.
5. `ProblemDetails` / `ValidationProblemDetails` (RFC 7807).
