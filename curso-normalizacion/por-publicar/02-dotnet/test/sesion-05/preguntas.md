# Test de autoevaluacion — Sesion 5: OpenAPI y Scalar

## Pregunta 1

¿Cual es el metodo nativo de .NET 9+ para registrar el soporte OpenAPI en `Program.cs`?

a) `builder.Services.AddSwaggerGen()`
b) `builder.Services.AddOpenApi()`
c) `builder.Services.AddScalar()`
d) `builder.Services.AddApiDocumentation()`

## Pregunta 2

Dado el siguiente codigo en `Program.cs`, ¿que URL expone el documento OpenAPI?

```csharp
app.MapOpenApi().AllowAnonymous();
app.MapScalarApiReference("/scalar").AllowAnonymous();
```

a) `/swagger/v1/swagger.json`
b) `/api/openapi.json`
c) `/openapi/v1.json`
d) `/scalar/openapi.json`

## Pregunta 3

¿Que paquete NuGet necesitas para usar `MapScalarApiReference` en tu proyecto?

a) `Swashbuckle.AspNetCore`
b) `NSwag.AspNetCore`
c) `Scalar.AspNetCore`
d) `Microsoft.OpenApi.UI`

## Pregunta 4

¿Que ocurre si configuras OpenAPI y Scalar sin la condicion de entorno?

```csharp
// Sin if (app.Environment.IsDevelopment() || ...)
app.MapOpenApi().AllowAnonymous();
app.MapScalarApiReference("/scalar").AllowAnonymous();
```

a) La app no compila
b) Los endpoints OpenAPI y Scalar estaran disponibles en produccion, revelando la estructura interna de la API
c) Scalar no funcionara porque necesita el entorno Development
d) OpenAPI generara un documento vacio

## Pregunta 5

¿Que atributo usamos para indicar a OpenAPI que un endpoint puede devolver un error 500 con `ProblemDetails`?

a) `[Produces(typeof(ProblemDetails))]`
b) `[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]`
c) `[ResponseType(500, typeof(ProblemDetails))]`
d) `[ApiResponse(500, Type = typeof(ProblemDetails))]`

## Pregunta 6

Observa este endpoint. ¿Que falta para que OpenAPI documente correctamente todas sus respuestas posibles?

```csharp
[HttpPost]
[ProducesResponseType(typeof(int), StatusCodes.Status200OK)]
public ActionResult Guardar([FromBody] ClaseGuardarUnidad dto)
{
    var resultado = _unidades.Guardar(dto);
    return HandleResult(resultado);
}
```

a) Falta `[ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]` y `[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]`
b) Falta `[ProducesResponseType(typeof(NotFoundResult), StatusCodes.Status404NotFound)]`
c) Falta `[Consumes("application/json")]`
d) No falta nada, OpenAPI infiere automaticamente los tipos de error

## Pregunta 7

En el patron GET comprobacion + POST ejecucion, ¿cual es la funcion del `TokenOperacion`?

a) Es un token JWT para autenticacion del usuario
b) Es un identificador unico que vincula la comprobacion previa con la ejecucion, evitando operaciones accidentales
c) Es un token CSRF obligatorio en .NET Core
d) Es un hash del objeto que se va a eliminar

## Pregunta 8

¿Que devuelve el GET de comprobacion cuando la operacion NO esta permitida?

```csharp
[HttpGet("{id:int}/puede-eliminar")]
[ProducesResponseType(typeof(ClaseComprobacionOperacion), StatusCodes.Status200OK)]
[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
public ActionResult<ClaseComprobacionOperacion> PuedeEliminar(int id)
{
    var unidad = _unidades.ObtenerPorId(id);
    if (unidad.Value?.Id == 0)
        return Ok(new ClaseComprobacionOperacion
            { Permitido = false, Razon = "Unidad no encontrada" });
    // ...
}
```

a) Devuelve 404 Not Found
b) Devuelve 200 OK con `Permitido = false` y una razon explicativa
c) Devuelve 400 Bad Request con ValidationProblemDetails
d) Lanza una excepcion MantenimientoException

## Pregunta 9

¿Que codigo HTTP corresponde a un error de validacion (`ErrorType.Validation`) segun el contrato UA?

a) 200 OK
b) 400 Bad Request
c) 404 Not Found
d) 422 Unprocessable Entity

## Pregunta 10

En la validacion en dos capas, ¿que capa valida que un campo obligatorio no este vacio?

```csharp
// Capa 1
public sealed class ClaseConfirmarOperacionValidator
    : AbstractValidator<ClaseConfirmarOperacion>
{
    public ClaseConfirmarOperacionValidator()
    {
        RuleFor(x => x.TokenOperacion)
            .NotEmpty().WithMessage("El token es obligatorio");
    }
}

// Capa 2 (en el servicio)
if (!RepositorioTokens.EsValido(dto.TokenOperacion, id))
    return Result<bool>.Failure(new Error("Unidad.TokenInvalido",
        "El token no es valido", ErrorType.Validation));
```

a) La capa 2 (servicio), porque es logica de negocio
b) La capa 1 (FluentValidation del DTO), porque es validacion de formato y estructura
c) Ambas capas validan lo mismo
d) Ninguna, lo valida el modelo con DataAnnotations

## Pregunta 11

¿Que propiedad de `JsonSerializerOptions` debes poner a `null` para serializar en PascalCase?

```csharp
builder.Services.AddControllers().AddJsonOptions(o =>
{
    o.JsonSerializerOptions.PropertyNamingPolicy = ???;
});
```

a) `JsonNamingPolicy.CamelCase`
b) `JsonNamingPolicy.PascalCase`
c) `null`
d) `JsonNamingPolicy.SnakeCaseLower`

## Pregunta 12

Si la propiedad en C# se llama `NombreEs` y usas la politica por defecto de .NET (camelCase), ¿como aparecera en el JSON de respuesta?

a) `NombreEs`
b) `nombreEs`
c) `nombre_es`
d) `NOMBRE_ES`

## Pregunta 13

¿Que interfaz implementa `ApiTimingFilter`?

```csharp
public class ApiTimingFilter : ???
{
    public void OnActionExecuting(ActionExecutingContext context) { ... }
    public void OnActionExecuted(ActionExecutedContext context) { ... }
}
```

a) `IAuthorizationFilter`
b) `IExceptionFilter`
c) `IActionFilter`
d) `IResultFilter`

## Pregunta 14

¿Como se registra `ApiTimingFilter` para que se aplique a TODOS los endpoints?

a) `builder.Services.AddScoped<ApiTimingFilter>()`
b) `builder.Services.AddControllers(options => { options.Filters.Add<ApiTimingFilter>(); })`
c) `[ServiceFilter(typeof(ApiTimingFilter))]` en cada controlador
d) `app.UseMiddleware<ApiTimingFilter>()`

## Pregunta 15

En `ApiTimingFilter`, ¿en que metodo se inicia el `Stopwatch`?

```csharp
public class ApiTimingFilter : IActionFilter
{
    private Stopwatch? _sw;

    public void OnActionExecuting(ActionExecutingContext context)
    {
        _sw = Stopwatch.StartNew();
    }

    public void OnActionExecuted(ActionExecutedContext context)
    {
        _sw?.Stop();
        _logger.LogInformation("Action {Action} tardo {ElapsedMs}ms",
            context.ActionDescriptor.DisplayName, _sw?.ElapsedMilliseconds ?? 0);
    }
}
```

a) En `OnActionExecuted`, despues de ejecutarse la accion
b) En `OnActionExecuting`, antes de ejecutarse la accion
c) En el constructor de `ApiTimingFilter`
d) En `OnResultExecuting`

## Pregunta 16

¿Que clase se usa para crear tests de integracion que arrancan la app en memoria?

a) `TestServer`
b) `WebApplicationFactory<Program>`
c) `HttpClientFactory`
d) `MockHttpServer`

## Pregunta 17

¿Por que `CursoAppFactory` usa `UseEnvironment("Staging")` en los tests?

```csharp
public class CursoAppFactory : WebApplicationFactory<Program>
{
    protected override IHost CreateHost(IHostBuilder builder)
    {
        builder.UseEnvironment("Staging");
        return base.CreateHost(builder);
    }
}
```

a) Porque Staging tiene mejor rendimiento para tests
b) Porque OpenAPI y Scalar solo se activan en Development y Staging, y necesitamos que existan para testearlos
c) Porque Production no soporta `WebApplicationFactory`
d) Porque la base de datos de test solo esta en Staging

## Pregunta 18

¿Que valida este test de integracion?

```csharp
[Fact]
public async Task OpenApiEndpoint_Disponible_EnEntornoStaging()
{
    using var client = _factory.CreateClient();
    var response = await GetFirstSuccessful(client,
        "/openapi/v1.json",
        "/CursoNormalizacionApps/openapi/v1.json");

    Assert.True(response.IsSuccessStatusCode);
    var content = await response.Content.ReadAsStringAsync();
    Assert.Contains("openapi", content, StringComparison.OrdinalIgnoreCase);
}
```

a) Que la API devuelve datos de unidades correctamente
b) Que el documento OpenAPI JSON esta disponible y contiene la cadena "openapi"
c) Que Scalar renderiza la interfaz correctamente
d) Que el servidor responde en menos de 1 segundo

## Pregunta 19

¿Que content-type espera el test de Scalar para validar que la UI esta disponible?

```csharp
[Fact]
public async Task ScalarUi_Disponible_EnEntornoStaging()
{
    using var client = _factory.CreateClient();
    var response = await GetFirstSuccessful(client, "/scalar", ...);

    Assert.True(response.IsSuccessStatusCode);
    var contentType = response.Content.Headers.ContentType?.MediaType ?? string.Empty;
    Assert.Contains("text/html", contentType, StringComparison.OrdinalIgnoreCase);
}
```

a) `application/json`
b) `text/html`
c) `application/xml`
d) `text/plain`

## Pregunta 20

¿Para que sirve el helper `GetFirstSuccessful` en los tests de integracion?

```csharp
private static async Task<HttpResponseMessage> GetFirstSuccessful(
    HttpClient client, params string[] paths)
{
    HttpResponseMessage? last = null;
    foreach (var path in paths)
    {
        var response = await client.GetAsync(path);
        if (response.IsSuccessStatusCode) return response;
        last = response;
    }
    return last!;
}
```

a) Para ejecutar peticiones en paralelo y devolver la mas rapida
b) Para probar varias rutas posibles (con y sin base path) y devolver la primera que responde 2xx
c) Para reintentar la misma peticion si falla
d) Para verificar que todas las rutas devuelven 200

## Pregunta 21

¿Cual es el comando para instalar httpRepl globalmente?

a) `npm install -g httprepl`
b) `dotnet tool install -g Microsoft.dotnet-httprepl`
c) `dotnet add package httprepl`
d) `Install-Package Microsoft.dotnet-httprepl`

## Pregunta 22

Una vez conectado con `httprepl https://localhost:5001`, ¿como navegas al recurso Unidades?

a) `navigate api/Unidades`
b) `cd api/Unidades`
c) `use api/Unidades`
d) `set endpoint api/Unidades`

## Pregunta 23

¿Que ocurre si un servicio devuelve `Result<bool>.Failure(new Error("...", "...", ErrorType.Failure))`?

a) El controlador devuelve 400 Bad Request
b) El controlador devuelve 200 OK con el error en el body
c) El controlador devuelve 500 Internal Server Error con ProblemDetails generico
d) El controlador lanza una excepcion no controlada

## Pregunta 24

Observa este codigo. ¿Cual es el error?

```csharp
builder.Services.AddControllers().AddJsonOptions(o =>
{
    o.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
});

builder.Services.ConfigureHttpJsonOptions(o =>
{
    o.SerializerOptions.PropertyNamingPolicy = null;
});
```

a) No se puede llamar a `AddJsonOptions` y `ConfigureHttpJsonOptions` a la vez
b) Las politicas de naming son inconsistentes: controladores usan camelCase pero Minimal APIs usan PascalCase
c) `ConfigureHttpJsonOptions` no existe en .NET 9
d) Falta registrar `AddOpenApi()` para que funcione la serializacion

## Pregunta 25

¿Que clase se usa para personalizar la serializacion de `ProblemDetails` a PascalCase?

```csharp
builder.Services.AddTransient<???, PascalCaseProblemDetailsWriter>();
builder.Services.AddProblemDetails();
```

a) `IExceptionHandler`
b) `IProblemDetailsWriter`
c) `IProblemDetailsService`
d) `IJsonSerializer`

## Pregunta 26

¿Que devuelve `HandleResult` cuando el `Result<T>` contiene un error de tipo `ErrorType.Validation` con `ValidationErrors`?

a) 200 OK con el error en el body
b) 500 Internal Server Error con ProblemDetails
c) 400 Bad Request con ValidationProblemDetails incluyendo errores por campo
d) 404 Not Found

## Pregunta 27

Observa este endpoint. ¿Cuantos `[ProducesResponseType]` deberia tener como minimo un POST que usa FluentValidation y `HandleResult`?

```csharp
[HttpPost]
public ActionResult Guardar([FromBody] ClaseGuardarUnidad dto)
{
    var resultado = _unidades.Guardar(dto);
    return HandleResult(resultado);
}
```

a) 1 (solo 200)
b) 2 (200 y 500)
c) 3 (200, 400 y 500)
d) 4 (200, 400, 404 y 500)

## Pregunta 28

¿Que interfaz usa `IClassFixture<T>` en los tests de integracion?

```csharp
public class OpenApiAndScalarIntegrationTests
    : IClassFixture<CursoAppFactory>
{
    private readonly CursoAppFactory _factory;
    public OpenApiAndScalarIntegrationTests(CursoAppFactory factory)
        => _factory = factory;
}
```

a) Crea una nueva instancia de `CursoAppFactory` para cada test
b) Comparte una unica instancia de `CursoAppFactory` entre todos los tests de la clase
c) Ejecuta los tests en paralelo
d) Inyecta dependencias del contenedor DI de la app

## Pregunta 29

¿Cual es la diferencia entre `AddJsonOptions` y `ConfigureHttpJsonOptions`?

a) Son identicos, solo cambia el nombre
b) `AddJsonOptions` configura controladores MVC; `ConfigureHttpJsonOptions` configura Minimal APIs
c) `ConfigureHttpJsonOptions` es para .NET 8 y `AddJsonOptions` para .NET 9
d) `AddJsonOptions` solo afecta a la deserializacion, no a la serializacion

## Pregunta 30

¿Que metodo del helper `GetFirstSuccessful` devuelve cuando ninguna ruta responde con exito?

a) `null`
b) Lanza una excepcion `HttpRequestException`
c) La ultima respuesta recibida (con el codigo de error)
d) Una respuesta vacia con status 0

## Pregunta 31

Dado este flujo de validacion, ¿en que orden se ejecutan las capas?

```
Frontend → POST /api/unidades/5/eliminar { tokenOperacion: "abc123" }
         → FluentValidation (DTO) → Servicio (negocio) → BD → 200
```

a) BD → Servicio → FluentValidation → Controlador
b) Controlador → BD → FluentValidation → Servicio
c) FluentValidation (formato DTO) → Servicio (reglas de negocio) → BD → Respuesta
d) Servicio → FluentValidation → BD → Controlador

## Pregunta 32

¿Que tipo de respuesta devuelve el endpoint de comprobacion `puede-eliminar` cuando la unidad SI se puede eliminar?

```csharp
return Ok(new ClaseComprobacionOperacion
{
    Permitido = true,
    Razon = "La unidad se puede eliminar",
    TokenOperacion = Guid.NewGuid().ToString("N")
});
```

a) 200 OK con `Permitido = true` y un token generado con GUID
b) 204 No Content
c) 200 OK con solo `{ "permitido": true }`
d) 302 Redirect al POST de eliminacion

## Pregunta 33

¿Que error tiene este codigo de `PascalCaseProblemDetailsWriter`?

```csharp
public sealed class PascalCaseProblemDetailsWriter : IProblemDetailsWriter
{
    public bool CanWrite(ProblemDetailsContext context) => false;

    public async ValueTask WriteAsync(ProblemDetailsContext context)
    {
        var options = new JsonSerializerOptions(JsonSerializerDefaults.Web)
        {
            PropertyNamingPolicy = null
        };
        context.HttpContext.Response.ContentType = "application/problem+json";
        await context.HttpContext.Response.WriteAsJsonAsync(
            context.ProblemDetails, options);
    }
}
```

a) Falta el `using System.Text.Json`
b) `CanWrite` devuelve `false`, por lo que nunca se usara este writer
c) `JsonSerializerDefaults.Web` no es compatible con `PropertyNamingPolicy = null`
d) `WriteAsJsonAsync` no acepta `JsonSerializerOptions`

## Pregunta 34

¿Que comando de httpRepl ejecuta un GET al endpoint `/api/Unidades/1`?

a) `fetch api/Unidades/1`
b) `get 1` (estando ya en `cd api/Unidades`)
c) `curl /api/Unidades/1`
d) `request get /api/Unidades/1`

## Pregunta 35

¿Que formato usa OpenAPI 3.1 para el documento de especificacion?

a) Solo XML
b) Solo YAML
c) JSON o YAML
d) Solo Protobuf

## Pregunta 36

¿Que ocurre si intentas acceder a `/openapi/v1.json` en un entorno de produccion (con la configuracion correcta del curso)?

a) Devuelve el documento OpenAPI normalmente
b) Devuelve 401 Unauthorized
c) La ruta no existe (404) porque `MapOpenApi()` solo se registra en Development/Staging
d) Devuelve 500 Internal Server Error

## Pregunta 37

¿Cual de estos es el flujo correcto de una operacion de eliminacion con el patron GET+POST?

a) POST `/eliminar` → si falla, GET `/puede-eliminar` → reintentar POST
b) GET `/puede-eliminar` → recibir token → POST `/eliminar` con token → resultado
c) POST `/eliminar` con el id directamente → resultado
d) GET `/puede-eliminar` → POST `/eliminar` sin token → resultado

## Pregunta 38

¿Que propiedad tiene `ClaseComprobacionOperacion` para indicar si la operacion se puede realizar?

```csharp
public class ClaseComprobacionOperacion
{
    public bool Permitido { get; set; }
    public string Razon { get; set; } = "";
    public string TokenOperacion { get; set; } = "";
}
```

a) `Estado`
b) `EsValido`
c) `Permitido`
d) `Aprobado`

## Pregunta 39

¿Que paquete NuGet es NECESARIO en el `.csproj` para que `AddOpenApi()` funcione en .NET 9+?

```xml
<PackageReference Include="???" Version="..." />
```

a) `Swashbuckle.AspNetCore`
b) `Microsoft.AspNetCore.OpenApi`
c) `NSwag.AspNetCore`
d) `Microsoft.OpenApi`

## Pregunta 40

Si el servicio lanza una `BDException` no controlada y el proyecto tiene configurado `IExceptionHandler`, ¿que devuelve la API?

a) 200 OK con el error en el body
b) 400 Bad Request con detalles de la excepcion
c) 500 Internal Server Error con `ProblemDetails` generico (sin revelar detalles internos) y un `traceId`
d) El proceso se cae sin respuesta

## Pregunta 41

Observa este registro de filtro. ¿Que problema tiene?

```csharp
builder.Services.AddControllers(options =>
{
    options.Filters.Add(new ApiTimingFilter());
});
```

a) No hay problema, es correcto
b) Al instanciar directamente con `new`, el filtro no puede recibir dependencias por inyeccion (como `ILogger`)
c) `Filters.Add` no acepta instancias, solo tipos genericos
d) Los filtros no se pueden registrar en `AddControllers`

## Pregunta 42

¿Que indica `AllowAnonymous()` en la configuracion de OpenAPI?

```csharp
app.MapOpenApi().AllowAnonymous();
app.MapScalarApiReference("/scalar").AllowAnonymous();
```

a) Que cualquier usuario puede modificar la especificacion OpenAPI
b) Que los endpoints de documentacion no requieren autenticacion para ser accedidos
c) Que los endpoints de la API documentados no requieren autenticacion
d) Que se desactiva la autenticacion globalmente en la app

## Pregunta 43

En el contrato de error UA, si un recurso no se encuentra, ¿que debe devolver la API?

a) 404 Not Found con ProblemDetails
b) 200 OK con un objeto vacio (Id=0) y el frontend valida ese caso
c) 400 Bad Request con ValidationProblemDetails
d) 204 No Content

## Pregunta 44

¿Que version de OpenAPI genera `AddOpenApi()` de .NET 9+?

a) OpenAPI 2.0 (Swagger)
b) OpenAPI 3.0
c) OpenAPI 3.1
d) OpenAPI 4.0

## Pregunta 45

¿Cual es la diferencia entre `ProblemDetails` y `ValidationProblemDetails`?

a) Son la misma clase con diferente nombre
b) `ValidationProblemDetails` hereda de `ProblemDetails` y anade la propiedad `Errors` con errores por campo
c) `ProblemDetails` es para APIs y `ValidationProblemDetails` es para MVC
d) `ValidationProblemDetails` incluye el stack trace de la excepcion

## Pregunta 46

¿Que resultado da este codigo si la propiedad C# es `FlgActiva` y la politica de naming es la por defecto?

```csharp
builder.Services.AddControllers().AddJsonOptions(o =>
{
    o.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
});
```

a) `FlgActiva`
b) `flgActiva`
c) `flg_activa`
d) `FLGACTIVA`

## Pregunta 47

¿Que error tiene este test de integracion?

```csharp
[Fact]
public async Task TestOpenApi()
{
    var client = new HttpClient();
    var response = await client.GetAsync("https://localhost:5001/openapi/v1.json");
    Assert.Equal(200, (int)response.StatusCode);
}
```

a) Falta el `await` en `GetAsync`
b) No usa `WebApplicationFactory`, sino que conecta a un servidor real hardcoded; ademas no verifica el contenido de la respuesta
c) `Assert.Equal` no funciona con codigos de estado
d) La URL deberia ser HTTP, no HTTPS

## Pregunta 48

¿Donde se selecciona el idioma para los mensajes de error localizados con `IStringLocalizer`?

```csharp
return Result<bool>.Failure(new Error(
    "Unidad.TokenInvalido",
    _L["UnidadTokenInvalido"],
    ErrorType.Validation));
```

a) Se pasa como parametro al metodo `Failure`
b) Se obtiene del claim del usuario autenticado (`ObtenerIdiomaClaimUsuario()`), el middleware de localizacion establece la cultura y `IStringLocalizer` selecciona el `.resx` correcto
c) Se configura en `appsettings.json` de forma fija
d) El frontend envia el idioma en la cabecera `Accept-Language` y el backend lo lee directamente

## Pregunta 49

¿Que metodo de `ApiControllerBase` mapea un `Result<T>` a la respuesta HTTP adecuada?

a) `MapResult()`
b) `HandleResult()`
c) `ProcessResult()`
d) `ReturnResult()`

## Pregunta 50

Observa esta configuracion. ¿Que problema hay si quieres PascalCase en toda la API incluyendo ProblemDetails?

```csharp
builder.Services.AddControllers().AddJsonOptions(o =>
{
    o.JsonSerializerOptions.PropertyNamingPolicy = null;
});
```

a) No hay ningun problema, ProblemDetails tambien usara PascalCase automaticamente
b) Falta configurar `ConfigureHttpJsonOptions` y registrar un `IProblemDetailsWriter` personalizado, porque ProblemDetails usa su propia serializacion
c) `PropertyNamingPolicy = null` no es valido
d) Los controladores no se ven afectados por `AddJsonOptions`
