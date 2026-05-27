---
url: /curso-normalizacion/02-dotnet/test/sesion-07/preguntas.md
description: >-
  Banco de 22 preguntas tipo test sobre DTOs, [ApiController], verbos HTTP,
  routing y validación básica con DataAnnotations.
---

# Test de autoevaluación — Sesión 7: Modelos y primer API

::: tip ALCANCE
Las preguntas cubren **solo** lo que se enseña en esta sesión: DTOs, controladores `[ApiController]`, verbos HTTP, status codes, `ControladorBase`, `ActionResult<T>`, `[Produces]`, `[ProducesResponseType]` y validación básica con DataAnnotations.

Los temas relacionados que se cubren en otras sesiones tienen su propio test:

* `ProblemDetails` / `ValidationProblemDetails` detallados, `Result<T>`, `HandleResult` → [Sesión 16](../../../04-integracion/sesiones/sesion-16-errores/).
* FluentValidation con mensajes localizados → [Sesión 15](../../../04-integracion/sesiones/sesion-15-validacion/).
* `peticion<T>` / `llamadaAxios` / `useGestionFormularios` / toasts → [Sesión 14](../../../04-integracion/sesiones/sesion-14-api-autenticacion/).
* `[Columna]`, `[IgnorarMapeo]`, mapeo `'S'/'N'` ↔ `bool` y resolución de idioma de `ClaseOracleBD3` → [Sesión 8](../sesion-08/).
  :::

## Pregunta 1

¿Cuál es la diferencia principal entre un DTO y una entidad de base de datos?

a) El DTO contiene lógica de negocio y la entidad no
b) La entidad se usa solo en el frontend y el DTO solo en el backend
c) El DTO transporta datos entre capas sin lógica de negocio; la entidad representa una fila de la BD con mapeo directo
d) No hay diferencia, son términos intercambiables

## Pregunta 2

¿Qué hace el atributo `[ApiController]` en un controlador?

a) Registra automáticamente el controlador en el contenedor de inyección de dependencias
b) Genera documentación Swagger para todas las acciones
c) Valida automáticamente el ModelState y devuelve 400 si no es válido
d) Habilita la autenticación JWT en todas las acciones

## Pregunta 3

¿Cuál es la ruta HTTP resultante de este controlador?

```csharp
[Route("api/[controller]")]
[ApiController]
public class HerramientasController : ControllerBase
{
    [HttpGet("activas")]
    public IActionResult ListarActivas() { ... }
}
```

a) `/api/HerramientasController/activas`
b) `/api/Herramientas/activas`
c) `/api/controller/activas`
d) `/Herramientas/activas`

## Pregunta 4

¿Qué código HTTP devuelve el método `NotFound()` en un controlador?

a) 400
b) 401
c) 404
d) 500

## Pregunta 5

¿Qué verbo HTTP se usa para **crear** un recurso nuevo en una API REST?

a) GET
b) PUT
c) DELETE
d) POST

## Pregunta 6

En el siguiente código, ¿qué devuelve la acción si `id = 99` y no existe esa reserva en la lista?

```csharp
[HttpGet("{id}")]
public IActionResult ObtenerPorId(int id)
{
    var reserva = _reservas.FirstOrDefault(r => r.CodReserva == id);
    if (reserva == null)
        return NotFound();
    return Ok(reserva);
}
```

a) 200 OK con un objeto vacío
b) 204 No Content
c) 404 Not Found
d) 500 Internal Server Error

## Pregunta 7

¿De qué clase debe heredar un controlador API en el patrón UA?

a) `Controller`
b) `ApiController`
c) `ControllerBase`
d) `ControladorBase`

## Pregunta 8

¿Qué formato de respuesta devuelve `Problem(detail: "Error", statusCode: 500)` según la especificación?

a) Un string plano con el mensaje de error
b) Un JSON con formato `ProblemDetails` (RFC 9457)
c) Un HTML con la página de error del servidor
d) Un código de estado sin cuerpo de respuesta

## Pregunta 9

¿Qué ocurre si un DTO tiene `[Required]` en una propiedad string y enviamos ese campo como `null` con `[ApiController]` habilitado?

a) La acción del controlador recibe null y debe validarlo manualmente
b) .NET devuelve automáticamente un 400 Bad Request con `ValidationProblemDetails`
c) .NET lanza una `NullReferenceException`
d) El campo se rellena con un string vacío automáticamente

## Pregunta 10

¿Cuál es el error en este controlador?

```csharp
[Route("api/controller")]
[ApiController]
public class ReservasController : ControllerBase
{
    [HttpGet]
    public IActionResult Listar() => Ok("datos");
}
```

a) Falta el atributo `[HttpGet]`
b) La ruta debería ser `"api/[controller]"` con corchetes para usar el nombre del controlador
c) Debería heredar de `Controller` en vez de `ControllerBase`
d) Falta el atributo `[Produces("application/json")]`

## Pregunta 11

¿Qué atributo de DataAnnotations valida que un número esté entre 5 y 120?

a) `[MinLength(5), MaxLength(120)]`
b) `[Range(5, 120)]`
c) `[Between(5, 120)]`
d) `[NumericRange(min: 5, max: 120)]`

## Pregunta 12

Dado este DTO, ¿qué campo(s) son obligatorios?

```csharp
public class ClaseEcoUnidad
{
    [Required(ErrorMessage = "Obligatorio")]
    public string? NombreEs { get; set; }

    public string? NombreCa { get; set; }

    [Range(5, 120)]
    public int Granularidad { get; set; }

    [EmailAddress]
    public string? EmailContacto { get; set; }
}
```

a) Todos los campos son obligatorios
b) Solo `NombreEs`
c) `NombreEs` y `Granularidad`
d) `NombreEs` y `EmailContacto`

## Pregunta 13

¿Qué problema tiene este código?

```csharp
[HttpGet]
public IActionResult Listar()
{
    return _reservas;
}
```

a) Falta el atributo `[Produces("application/json")]`
b) El tipo de retorno es `IActionResult` pero se devuelve una lista directamente sin envolverla en `Ok()`
c) Debería usar `HttpPost` en vez de `HttpGet`
d) La lista `_reservas` no puede ser devuelta porque es privada

## Pregunta 14

¿Qué atributo se utiliza para indicar que el parámetro proviene del cuerpo de la petición HTTP?

a) `[FromQuery]`
b) `[FromRoute]`
c) `[FromBody]`
d) `[FromHeader]`

## Pregunta 15

¿Cuál es la diferencia entre `Ok()` y `NoContent()`?

a) `Ok()` devuelve 200 con datos y `NoContent()` devuelve 204 sin datos
b) `Ok()` devuelve 200 y `NoContent()` devuelve 404
c) No hay diferencia, ambos devuelven 200
d) `NoContent()` devuelve 200 con un body vacío

## Pregunta 16

En el patrón UA, ¿cómo se nombran los DTOs y en qué carpeta se ubican?

a) En `Controllers/` con prefijo `Dto` (ej: `DtoPermiso`)
b) En `Models/` con prefijo `Clase` (ej: `ClasePermiso`) y propiedades en PascalCase
c) En `Services/` con sufijo `Model` (ej: `PermisoModel`)
d) En `Entities/` con el nombre de la tabla Oracle

## Pregunta 17

¿Cuál es el error en este controlador?

```csharp
[Route("api/[controller]")]
[ApiController]
public class ReservasController
{
    [HttpGet]
    public IActionResult Listar()
    {
        return Ok(new[] { "Reserva 1" });
    }
}
```

a) Falta el atributo `[Produces]`
b) No hereda de `ControllerBase`, por lo que `Ok()` no está disponible
c) La ruta está mal definida
d) `new[]` no es un tipo válido para devolver

## Pregunta 18

¿Qué verbo HTTP se usa para **actualizar completamente** un recurso existente?

a) POST
b) PATCH
c) PUT
d) GET

## Pregunta 19

¿Cuál es la firma correcta para un endpoint que recibe un DTO por body y devuelve el mismo tipo?

a) `public ClaseEcoUnidad Eco(ClaseEcoUnidad dto)`
b) `public ActionResult<ClaseEcoUnidad> Eco([FromBody] ClaseEcoUnidad dto)`
c) `public IActionResult Eco([FromQuery] ClaseEcoUnidad dto)`
d) `public void Eco([FromBody] ClaseEcoUnidad dto)`

## Pregunta 20

¿Qué atributo de un controlador indica que las respuestas serán en formato JSON?

a) `[ContentType("json")]`
b) `[Produces("application/json")]`
c) `[ResponseFormat("json")]`
d) `[JsonResponse]`

## Pregunta 21

¿Qué hace `[ProducesResponseType(typeof(ProblemDetails), 500)]` en una acción del controlador?

a) Configura el controlador para devolver siempre 500
b) Documenta que la acción puede devolver un 500 con formato ProblemDetails (para OpenAPI/Scalar)
c) Intercepta los errores 500 y los convierte en ProblemDetails
d) Valida que todas las respuestas 500 tengan formato ProblemDetails

## Pregunta 22

¿Cuál es la forma correcta de devolver una lista filtrada en un endpoint GET?

```csharp
private static readonly List<ClaseReserva> _reservas = new() { ... };
```

a) `return _reservas.Where(r => r.Activo);`
b) `return Ok(_reservas.Where(r => r.Activo));`
c) `return Json(_reservas.Where(r => r.Activo));`
d) `return new JsonResult(_reservas.Where(r => r.Activo));`
