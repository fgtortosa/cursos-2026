---
title: "Respuestas — Sesión 5: Modelos y primer API"
description: "Solucionario razonado del test de 22 preguntas de la Sesión 5."
outline: [2, 2]
search: false
---

# Respuestas — Test Sesión 5: Modelos y primer API

1. **c)** El DTO transporta datos entre capas sin lógica de negocio; la entidad representa una fila de la BD con mapeo directo. Los DTOs son objetos planos con solo propiedades, sin métodos de acceso a datos ni lógica de negocio.

2. **c)** Valida automáticamente el ModelState y devuelve 400 si no es válido. Con `[ApiController]`, si un DTO tiene DataAnnotations y los datos no son válidos, .NET devuelve un `ValidationProblemDetails` sin escribir código de validación en la acción.

3. **b)** `/api/Herramientas/activas`. El placeholder `[controller]` se reemplaza por el nombre del controlador sin el sufijo "Controller", y `"activas"` es la subruta del `[HttpGet]`.

4. **c)** 404. El método `NotFound()` de `ControllerBase` devuelve un HTTP 404 Not Found.

5. **d)** POST. En REST, POST se usa para crear recursos nuevos, mientras que PUT se usa para actualizar recursos existentes.

6. **c)** 404 Not Found. `FirstOrDefault` devuelve null si no encuentra el elemento, y el `if` comprueba null para devolver `NotFound()`.

7. **d)** `ControladorBase`. Es la clase base UA que extiende `ControllerBase` (y `ApiControllerBase`) y agrega `HandleResult`, `CodPer`, `Idioma`, `Roles` y `NombrePersona`. `ControllerBase` es la clase estándar de ASP.NET Core, pero el patrón UA requiere la subclase `ControladorBase`.

8. **b)** Un JSON con formato `ProblemDetails` (RFC 9457). El método `Problem()` genera una respuesta estándar con campos `type`, `title`, `status` y `detail`. (El detalle completo del flujo `Result<T>` → `ProblemDetails` se ve en la sesión 16.)

9. **b)** .NET devuelve automáticamente un 400 Bad Request con `ValidationProblemDetails`. El atributo `[ApiController]` intercepta el ModelState inválido antes de que se ejecute la acción del controlador.

10. **b)** La ruta debería ser `"api/[controller]"` con corchetes para usar el nombre del controlador. Sin corchetes, la ruta literal sería `/api/controller` en vez de `/api/Reservas`.

11. **b)** `[Range(5, 120)]`. Este atributo valida que el valor numérico esté entre el mínimo y máximo indicados. `[MinLength]`/`[MaxLength]` son para longitud de strings o colecciones.

12. **b)** Solo `NombreEs`. Es el único campo con `[Required]`. `Granularidad` tiene `[Range]` pero no `[Required]` (aunque al ser `int` no puede ser null, el valor 0 pasaría sin `[Range]`). `EmailContacto` valida formato solo si tiene valor.

13. **b)** El tipo de retorno es `IActionResult` pero se devuelve una lista directamente sin envolverla en `Ok()`. Se necesita `return Ok(_reservas);` para que se serialice correctamente con código 200.

14. **c)** `[FromBody]`. Este atributo indica que el parámetro se deserializa del cuerpo de la petición HTTP (típicamente JSON). `[FromQuery]` es para parámetros de URL y `[FromRoute]` para segmentos de la ruta.

15. **a)** `Ok()` devuelve 200 con datos y `NoContent()` devuelve 204 sin datos. El 204 se usa cuando la operación fue exitosa pero no hay contenido que devolver (ej: un `DELETE` o un `PUT` exitosos).

16. **b)** En `Models/` con prefijo `Clase` (ej: `ClasePermiso`) y propiedades en PascalCase. Es la convención UA: nombres en español, prefijo `Clase`, carpeta `Models/` organizada por entidad.

17. **b)** No hereda de `ControllerBase`, por lo que `Ok()` no está disponible. Sin la herencia, el método `Ok()` y otros métodos helper de HTTP no están accesibles en el controlador.

18. **c)** PUT. En REST, PUT se usa para reemplazar completamente un recurso existente. PATCH se usa para actualizaciones parciales.

19. **b)** `public ActionResult<ClaseEcoUnidad> Eco([FromBody] ClaseEcoUnidad dto)`. Usa `ActionResult<T>` para tipar la respuesta y `[FromBody]` para deserializar el body JSON al DTO.

20. **b)** `[Produces("application/json")]`. Este atributo declara el content-type de las respuestas y es útil para la documentación OpenAPI/Scalar.

21. **b)** Documenta que la acción puede devolver un 500 con formato `ProblemDetails` (para OpenAPI/Scalar). Es un atributo declarativo para la generación de documentación, no afecta al comportamiento en runtime.

22. **b)** `return Ok(_reservas.Where(r => r.Activo));`. Se envuelve el resultado filtrado en `Ok()` para devolver un 200 con la lista serializada como JSON. Las opciones a), c) y d) no usan el patrón estándar de `IActionResult` en el patrón UA.
