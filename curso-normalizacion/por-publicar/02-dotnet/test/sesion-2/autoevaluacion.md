# Autoevaluación — Sesión 2

## Preguntas rápidas

1. ¿Qué ventaja tiene `Result<T>` frente a excepciones para negocio?
2. ¿Por qué usamos vistas `VCTS_*` para lectura?
3. ¿Dónde se hace el mapeo `Result<T>` -> HTTP?
4. ¿Qué devuelve `HandleResult` cuando el error NO es de validación?
5. ¿Qué inyecta un servicio UA además de `ClaseOracleBd`?

## Respuestas esperadas

1. Flujo explícito, mejor rendimiento y menor complejidad de control.
2. Por permisos: usuario web normalmente solo `SELECT` en vistas.
3. En `ApiControllerBase.HandleResult`.
4. `500` con `ProblemDetails` genérico (no damos pistas al cliente).
5. `ILogger<T>` para trazabilidad.
