# Test de autoevaluacion -- Sesion 1: DTOs y APIs

## Pregunta 1
¿Cual es la diferencia principal entre un DTO y una entidad de base de datos?

a) El DTO contiene logica de negocio y la entidad no
b) La entidad se usa solo en el frontend y el DTO solo en el backend
c) El DTO transporta datos entre capas sin logica de negocio; la entidad representa una fila de la BD con mapeo directo
d) No hay diferencia, son terminos intercambiables

## Pregunta 2
Dado el siguiente DTO, ¿que columna Oracle corresponde a la propiedad `FechaNacimiento`?

```csharp
public class ClasePersona
{
    public int CodPersona { get; set; }
    public string FechaNacimiento { get; set; }
}
```

a) `FECHANACIMIENTO`
b) `Fecha_Nacimiento`
c) `FECHA_NACIMIENTO`
d) `fechaNacimiento`

## Pregunta 3
¿Que atributo se usa en un DTO cuando la columna Oracle NO sigue la convencion SNAKE_CASE?

a) `[Column("NOMBRE_REAL")]`
b) `[Columna("NOMBRE_REAL")]`
c) `[MapTo("NOMBRE_REAL")]`
d) `[DatabaseField("NOMBRE_REAL")]`

## Pregunta 4
¿Que hace el atributo `[ApiController]` en un controlador?

a) Registra automaticamente el controlador en el contenedor de inyeccion de dependencias
b) Genera documentacion Swagger para todas las acciones
c) Valida automaticamente el ModelState y devuelve 400 si no es valido
d) Habilita la autenticacion JWT en todas las acciones

## Pregunta 5
¿Cual es la ruta HTTP resultante de este controlador?

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

## Pregunta 6
¿Que codigo HTTP devuelve el metodo `NotFound()` en un controlador?

a) 400
b) 401
c) 404
d) 500

## Pregunta 7
¿Que verbo HTTP se usa para **crear** un recurso nuevo en una API REST?

a) GET
b) PUT
c) DELETE
d) POST

## Pregunta 8
En el siguiente codigo, ¿que devuelve la accion si `id = 99` y no existe esa reserva en la lista?

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

a) 200 OK con un objeto vacio
b) 204 No Content
c) 404 Not Found
d) 500 Internal Server Error

## Pregunta 9
¿De que clase debe heredar un controlador API basico en el patron UA?

a) `Controller`
b) `ApiController`
c) `ControllerBase`
d) `BaseApiController`

## Pregunta 10
¿Que formato de respuesta devuelve `Problem(detail: "Error", statusCode: 500)` segun la especificacion?

a) Un string plano con el mensaje de error
b) Un JSON con formato `ProblemDetails` (RFC 7807)
c) Un HTML con la pagina de error del servidor
d) Un codigo de estado sin cuerpo de respuesta

## Pregunta 11
¿Que ocurre si un DTO tiene `[Required]` en una propiedad string y enviamos ese campo como `null` con `[ApiController]` habilitado?

a) La accion del controlador recibe null y debe validarlo manualmente
b) .NET devuelve automaticamente un 400 Bad Request con `ValidationProblemDetails`
c) .NET lanza una `NullReferenceException`
d) El campo se rellena con un string vacio automaticamente

## Pregunta 12
¿Cual es el error en este controlador?

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
b) La ruta deberia ser `"api/[controller]"` con corchetes para usar el nombre del controlador
c) Deberia heredar de `Controller` en vez de `ControllerBase`
d) Falta el atributo `[Produces("application/json")]`

## Pregunta 13
¿Que atributo de DataAnnotations valida que un numero este entre 5 y 120?

a) `[MinLength(5), MaxLength(120)]`
b) `[Range(5, 120)]`
c) `[Between(5, 120)]`
d) `[NumericRange(min: 5, max: 120)]`

## Pregunta 14
Dado este DTO, ¿que campo(s) son obligatorios?

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

## Pregunta 15
¿Que expresion regular valida correctamente emails de `@ua.es` o `@alu.ua.es`?

a) `@"@ua.es|@alu.ua.es"`
b) `@"^[^@]+@(ua\.es|alu\.ua\.es)$"`
c) `@".*@ua\.es$"`
d) `@"^.+@ua.es$"`

## Pregunta 16
¿Que devuelve esta accion si enviamos `{ "nombreEs": null }` y `NombreEs` tiene `[Required]`?

```csharp
[HttpPost("validar")]
public ActionResult<ClaseEcoUnidad> Validar([FromBody] ClaseEcoUnidad dto)
{
    return Ok(dto);
}
```

a) 200 OK con el DTO tal como se envio
b) 400 Bad Request con `ValidationProblemDetails` generado automaticamente por `[ApiController]`
c) 500 Internal Server Error
d) 204 No Content

## Pregunta 17
En Vue, ¿que funcion de `vueua-useaxios` se usa para realizar una llamada HTTP?

a) `fetchAxios`
b) `axiosRequest`
c) `llamadaAxios`
d) `httpCall`

## Pregunta 18
¿Cual es el error en este codigo Vue?

```typescript
llamadaAxios("Eco/validar", verbosAxios.GET, formulario)
  .then(({ data }) => {
    respuesta.value = data.value;
  })
```

a) Falta el `.catch()` para gestionar errores
b) El verbo deberia ser `verbosAxios.POST` ya que envia datos en el body
c) `data.value` deberia ser `data`
d) Falta indicar el tipo de contenido JSON

## Pregunta 19
¿Como se accede a los errores de validacion campo a campo en la respuesta de un 400 en Vue?

a) `error.response.data.message`
b) `error.response.data.errors`
c) `error.response.data.validationErrors`
d) `error.response.errors`

## Pregunta 20
¿Que tipo de dato Oracle `VARCHAR2 'S'/'N'` se mapea automaticamente en C# a traves de ClaseOracleBD3?

a) `string`
b) `int`
c) `bool`
d) `char`

## Pregunta 21
¿Que problema tiene este codigo?

```csharp
[HttpGet]
public IActionResult Listar()
{
    return _reservas;
}
```

a) Falta el atributo `[Produces("application/json")]`
b) El tipo de retorno es `IActionResult` pero se devuelve una lista directamente sin envolverla en `Ok()`
c) Deberia usar `HttpPost` en vez de `HttpGet`
d) La lista `_reservas` no puede ser devuelta porque es privada

## Pregunta 22
¿Que atributo se utiliza para indicar que el parametro proviene del cuerpo de la peticion HTTP?

a) `[FromQuery]`
b) `[FromRoute]`
c) `[FromBody]`
d) `[FromHeader]`

## Pregunta 23
¿Cual es la diferencia entre `Ok()` y `NoContent()`?

a) `Ok()` devuelve 200 con datos y `NoContent()` devuelve 204 sin datos
b) `Ok()` devuelve 200 y `NoContent()` devuelve 404
c) No hay diferencia, ambos devuelven 200
d) `NoContent()` devuelve 200 con un body vacio

## Pregunta 24
En el ciclo Rojo-Verde-Refactor, ¿que representa la fase "Rojo"?

a) El codigo ya esta validado y funciona correctamente
b) Se refactoriza el codigo para mejorar su calidad
c) Se identifica que el codigo no tiene validaciones y acepta datos invalidos
d) Se despliega la aplicacion en produccion

## Pregunta 25
¿Que ocurre en la fase "Verde" del ciclo Rojo-Verde-Refactor del EcoController?

a) Se eliminan todas las validaciones del DTO
b) Se anaden atributos `[Required]` y .NET rechaza automaticamente datos vacios con 400
c) Se optimiza el rendimiento de las consultas
d) Se agregan tests unitarios

## Pregunta 26
¿Cual es el error en este DTO?

```csharp
public class ClaseEcoUnidad
{
    [Required]
    [StringLength(200)]
    public string? NombreEs { get; set; }
}
```

a) No se puede usar `[Required]` con tipos nullable
b) Falta `ErrorMessage` en `[Required]` y falta `MinimumLength` en `[StringLength]`, por lo que acepta strings de 1 caracter y muestra mensajes en ingles
c) `[StringLength]` no es compatible con `[Required]`
d) El tipo deberia ser `string` sin `?`

## Pregunta 27
¿Que estructura tiene un `ValidationProblemDetails` devuelto por .NET?

```json
{
  "type": "...",
  "title": "...",
  "status": ???,
  "errors": { ... }
}
```

a) `status: 200` y `errors` contiene un string con todos los errores
b) `status: 400` y `errors` es un diccionario donde la clave es el nombre del campo y el valor es un array de mensajes
c) `status: 500` y `errors` es un array de strings
d) `status: 400` y `errors` contiene un unico mensaje de error global

## Pregunta 28
En el patron UA, ¿como se nombran los DTOs y en que carpeta se ubican?

a) En `Controllers/` con prefijo `Dto` (ej: `DtoPermiso`)
b) En `Models/` con prefijo `Clase` (ej: `ClasePermiso`) y propiedades en PascalCase
c) En `Services/` con sufijo `Model` (ej: `PermisoModel`)
d) En `Entities/` con el nombre de la tabla Oracle

## Pregunta 29
¿Que hace la propiedad calculada en este DTO?

```csharp
public class ClaseHerramientaIA
{
    public string Nombre { get; set; }
    public string Url { get; set; }
    public string NombreConUrl => $"{Nombre} ({Url})";
}
```

a) Inserta el nombre y la URL en la base de datos
b) Es una propiedad de solo lectura que concatena Nombre y Url sin almacenarse en BD
c) Sobrescribe el valor de Nombre con la URL
d) Genera una URL valida a partir del nombre

## Pregunta 30
¿Que atributo se debe usar en una propiedad calculada del DTO para que ClaseOracleBD3 no intente mapearla a Oracle?

a) `[NotMapped]`
b) `[Computed]`
c) `[IgnorarMapeo]`
d) `[JsonIgnore]`

## Pregunta 31
¿Que codigo HTTP devuelve `BadRequest("Error en la peticion")`?

a) 401
b) 404
c) 400
d) 500

## Pregunta 32
¿Cual es el error en este controlador?

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
b) No hereda de `ControllerBase`, por lo que `Ok()` no esta disponible
c) La ruta esta mal definida
d) `new[]` no es un tipo valido para devolver

## Pregunta 33
¿Que verbo HTTP se usa para **actualizar completamente** un recurso existente?

a) POST
b) PATCH
c) PUT
d) GET

## Pregunta 34
En Vue, ¿como se distingue un error de validacion (400) de otros errores en el `.catch()`?

```typescript
.catch((error) => {
    // ¿Como distinguir?
});
```

a) Comprobando `error.type === "validation"`
b) Comprobando `error.response?.status === 400 && error.response?.data?.errors`
c) Comprobando `error.isValidation === true`
d) No se puede distinguir, todos los errores se tratan igual

## Pregunta 35
¿Que hace `gestionarError` de `vueua-useaxios`?

a) Envia el error al servidor para loggearlo
b) Muestra un modal con los detalles tecnicos del error
c) Gestiona el error de forma centralizada mostrando un toast automatico
d) Reintenta la llamada HTTP automaticamente

## Pregunta 36
¿Que pasa si enviamos este JSON al endpoint `/api/Eco/validar` con las validaciones del refactor completas?

```json
{
  "nombreEs": "AB",
  "nombreCa": "Unitat",
  "nombreEn": "Unit",
  "granularidad": 3,
  "emailContacto": "user@gmail.com"
}
```

a) 200 OK porque todos los campos tienen valor
b) 400 con errores en `NombreEs` (longitud minima 3), `Granularidad` (minimo 5) y `EmailContacto` (dominio no permitido)
c) 400 solo con error en `EmailContacto`
d) 500 Internal Server Error

## Pregunta 37
¿Cual es la firma correcta para un endpoint que recibe un DTO por body y devuelve el mismo tipo?

a) `public ClaseEcoUnidad Eco(ClaseEcoUnidad dto)`
b) `public ActionResult<ClaseEcoUnidad> Eco([FromBody] ClaseEcoUnidad dto)`
c) `public IActionResult Eco([FromQuery] ClaseEcoUnidad dto)`
d) `public void Eco([FromBody] ClaseEcoUnidad dto)`

## Pregunta 38
En el siguiente codigo Vue, ¿que clase CSS se aplica cuando hay errores de validacion en el campo `NombreEs`?

```vue
<input
  v-model="formulario.nombreEs"
  type="text"
  class="form-control"
  :class="{ 'is-invalid': errores?.NombreEs }"
/>
```

a) `form-control-error`
b) `is-invalid`
c) `has-error`
d) `validation-error`

## Pregunta 39
¿Que atributo se usa para validar que un string tenga formato de email segun RFC?

a) `[Email]`
b) `[MailAddress]`
c) `[EmailAddress]`
d) `[ValidEmail]`

## Pregunta 40
¿Que problema tiene este codigo de controlador?

```csharp
[HttpGet("{id}")]
public IActionResult ObtenerPorId(string id)
{
    var reserva = _reservas.FirstOrDefault(r => r.CodReserva == id);
    return Ok(reserva);
}
```

a) Solo que el tipo de `id` deberia ser `int`, no `string`
b) El tipo de `id` deberia ser `int` Y no se comprueba si `reserva` es null (deberia devolver `NotFound()`)
c) Deberia usar `[HttpPost]` en vez de `[HttpGet]`
d) Falta el atributo `[FromRoute]`

## Pregunta 41
¿Que metodo de .NET devuelve un codigo HTTP 204?

a) `Ok()`
b) `NoContent()`
c) `NotFound()`
d) `Accepted()`

## Pregunta 42
¿Que propiedad del `ValidationProblemDetails` contiene los errores agrupados por campo?

a) `detail`
b) `title`
c) `errors`
d) `extensions`

## Pregunta 43
¿Que ocurre si definimos `[StringLength(200, MinimumLength = 3)]` y enviamos un string de 2 caracteres?

a) Se acepta porque MinimumLength no es obligatorio
b) Se devuelve un 400 con el mensaje de error de StringLength
c) Se trunca automaticamente a 3 caracteres
d) Se lanza una excepcion en el servidor

## Pregunta 44
En el DTO multiidioma del patron UA, ¿como resuelve ClaseOracleBD3 los sufijos de idioma?

```csharp
public class ClaseHerramientaIA
{
    public string Nombre { get; set; }      // ¿Que columna?
    public string Descripcion { get; set; } // ¿Que columna?
}
```

a) Siempre mapea a `NOMBRE` y `DESCRIPCION` sin sufijo
b) Automaticamente resuelve `NOMBRE_ES`, `NOMBRE_CA` o `NOMBRE_EN` segun el idioma pasado al metodo
c) El desarrollador debe crear tres propiedades separadas: `NombreEs`, `NombreCa`, `NombreEn`
d) Usa un fichero de configuracion XML para el mapeo de idiomas

## Pregunta 45
¿Cual es el error en este codigo Vue para enviar datos al endpoint de validacion?

```typescript
const enviarValidar = () => {
  llamadaAxios("Eco/validar", verbosAxios.GET, formulario)
    .then(({ data }) => {
      respuesta.value = data.value;
    })
    .catch((error) => {
      errores.value = error.response.data;
    });
};
```

a) Solo que falta limpiar `errores` y `respuesta` antes de la llamada
b) Solo que el verbo deberia ser POST
c) El verbo deberia ser POST, falta limpiar errores anteriores, y los errores de validacion estan en `error.response.data.errors` no en `error.response.data`
d) Solo que `error.response.data` deberia ser `error.response.data.errors`

## Pregunta 46
¿Que atributo de un controlador indica que las respuestas seran en formato JSON?

a) `[ContentType("json")]`
b) `[Produces("application/json")]`
c) `[ResponseFormat("json")]`
d) `[JsonResponse]`

## Pregunta 47
¿Que hace `[ProducesResponseType(typeof(ProblemDetails), 500)]` en una accion del controlador?

a) Configura el controlador para devolver siempre 500
b) Documenta que la accion puede devolver un 500 con formato ProblemDetails (para OpenAPI/Swagger)
c) Intercepta los errores 500 y los convierte en ProblemDetails
d) Valida que todas las respuestas 500 tengan formato ProblemDetails

## Pregunta 48
¿Cual es la forma correcta de devolver una lista filtrada en un endpoint GET?

```csharp
private static readonly List<ClaseReserva> _reservas = new() { ... };
```

a) `return _reservas.Where(r => r.Activo);`
b) `return Ok(_reservas.Where(r => r.Activo));`
c) `return Json(_reservas.Where(r => r.Activo));`
d) `return new JsonResult(_reservas.Where(r => r.Activo));`

## Pregunta 49
En la fase Refactor del EcoController, ¿pueden acumularse varios errores de validacion en un mismo campo?

```csharp
[EmailAddress(ErrorMessage = "Formato invalido")]
[RegularExpression(@"^[^@]+@(ua\.es|alu\.ua\.es)$",
    ErrorMessage = "Debe ser @ua.es o @alu.ua.es")]
public string? EmailContacto { get; set; }
```

a) No, solo se devuelve el primer error encontrado
b) Si, un campo puede tener multiples mensajes de error en el array de `errors`
c) No, los DataAnnotations se detienen en el primer error
d) Si, pero solo si se usa FluentValidation

## Pregunta 50
¿Que funcion de Vue UA se usa para mostrar un toast de error personalizado con titulo y mensaje?

a) `gestionarError`
b) `mostrarError`
c) `avisarError`
d) `notificarError`
