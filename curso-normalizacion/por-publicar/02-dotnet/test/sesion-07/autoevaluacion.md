# Autoevaluación — Sesión 1

## Preguntas rápidas

1. ¿Qué diferencia hay entre DTO y entidad?
2. ¿Qué hace `[ApiController]` cuando falla una DataAnnotation?
3. ¿Qué código HTTP usarías para una creación correcta?
4. ¿Qué ventaja tiene `ControladorBase` (UA) frente a `ControllerBase`?
5. ¿Qué formato de error estándar devuelve ASP.NET Core en validación?
6. ¿Qué hace `HandleResult()` cuando el servicio devuelve un `Result<T>` de error?
7. ¿Para qué sirve Scalar en esta sesión?

## Respuestas esperadas

1. DTO transporta datos entre capas sin lógica de negocio; entidad modela datos de persistencia.
2. Devuelve `400 BadRequest` automáticamente con `ValidationProblemDetails`.
3. `201 Created`. En REST, una creación siempre devuelve 201, nunca 200.
4. Añade propiedades del usuario autenticado (`CodPer`, `Idioma`, `NombrePersona`, `Roles`) listas para usar en cualquier acción sin repetir código.
5. `ProblemDetails` / `ValidationProblemDetails` (RFC 9457).
6. Convierte el `Result<T>` en la respuesta HTTP correcta: `400` si es error de validación, `404` si no existe, `500` si es error técnico.
7. Proporciona una interfaz web interactiva para probar la API directamente desde el navegador, sin Postman ni SwaggerUI.
