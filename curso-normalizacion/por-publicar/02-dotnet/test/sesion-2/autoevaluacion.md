# Autoevaluación — Sesión 2

## Preguntas rápidas

1. ¿Qué ventaja tiene `Result<T>` frente a excepciones para negocio?
2. ¿Por qué usamos vistas `VCTS_*` para lectura?
3. ¿Dónde se hace el mapeo `Result<T>` -> HTTP?
4. ¿Qué devuelve `HandleResult` según el tipo de error?
5. ¿Qué inyecta un servicio UA además de `ClaseOracleBd`?

## Respuestas esperadas

1. Flujo explícito, mejor rendimiento y menor complejidad de control.
2. Por permisos: usuario web normalmente solo `SELECT` en vistas.
3. En `ApiControllerBase.HandleResult`.
4. Depende del `ErrorType`: `NotFound` -> `404` con `ProblemDetails`; cualquier otro error (`Failure`, etc.) -> `500` con `ProblemDetails` genérico.
5. `ILogger<T>` para trazabilidad.
