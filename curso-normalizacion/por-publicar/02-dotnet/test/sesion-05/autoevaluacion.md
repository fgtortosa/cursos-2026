# Autoevaluación — Sesión 5

## Preguntas rápidas

### 1. ¿Qué diferencia práctica hay entre Swagger UI y Scalar?

::: details Respuesta
Ambos visualizan documentación OpenAPI y permiten probar endpoints. **Scalar** es una alternativa moderna más ligera que no requiere Swashbuckle: se integra directamente con `AddOpenApi()` nativo de .NET 9+. Swagger UI es el estándar clásico, más extendido pero más pesado.
:::

### 2. ¿Qué ventaja tiene el patrón `GET comprobación` + `POST ejecución`?

::: details Respuesta
Evita ejecuciones inválidas o accidentales. El GET comprueba si la operación es posible (permisos, dependencias, estado) y devuelve un token. El POST usa ese token para ejecutar, garantizando que la comprobación previa se realizó. Mejora la UX y la consistencia en operaciones críticas como eliminaciones.
:::

### 3. ¿Cómo documentas respuestas en OpenAPI para 200/400/404?

::: details Respuesta
Con atributos `[ProducesResponseType]` en cada método del controlador:
- `[ProducesResponseType(typeof(ClaseUnidad), 200)]` — respuesta exitosa con modelo
- `[ProducesResponseType(typeof(ValidationProblemDetails), 400)]` — errores de validación
- `[ProducesResponseType(typeof(ProblemDetails), 404)]` — recurso no encontrado

Scalar y OpenAPI usan esta información para mostrar los esquemas de respuesta.
:::

### 4. ¿Dónde configuras camelCase o PascalCase en ASP.NET Core?

::: details Respuesta
En `Program.cs` con `AddJsonOptions` (para controladores MVC) y `ConfigureHttpJsonOptions` (para minimal APIs). El default de .NET es camelCase. Para PascalCase: `PropertyNamingPolicy = null`. Para ProblemDetails personalizado: `AddProblemDetails()` + un `IProblemDetailsWriter` propio.
:::

### 5. ¿Por qué los tests de integración usan `WebApplicationFactory` en lugar de conectar a un servidor real?

::: details Respuesta
`WebApplicationFactory<Program>` arranca la app **en memoria** sin necesidad de un servidor real. Esto permite ejecutar tests en CI/CD sin depender de puertos, servidores o infraestructura externa. El factory controla el entorno (ej: `UseEnvironment("Staging")`) y crea un `HttpClient` que se comunica directamente con la app.
:::
