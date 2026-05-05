# Test de autoevaluacion -- Sesion 3: Validacion y errores

## Pregunta 1

En el siguiente DTO, cual es el problema con la validacion de `Granularidad`?

```csharp
public class ClaseGuardarUnidad
{
    [Required]
    [StringLength(200)]
    public string NombreEs { get; set; }

    [Range(0, 120)]
    public int Granularidad { get; set; }
}
```

a) `[Range]` no se puede aplicar a `int`
b) El rango permite el valor 0, que no es valido para una granularidad (minimo deberia ser 5)
c) Falta el atributo `[Required]` en `Granularidad`
d) `[Range]` necesita un `ErrorMessage` obligatorio

## Pregunta 2

Que devuelve automaticamente .NET cuando un DTO decorado con DataAnnotations no pasa la validacion en un controlador con `[ApiController]`?

a) `200 OK` con un objeto vacio
b) `500 Internal Server Error` con `ProblemDetails`
c) `400 Bad Request` con `ValidationProblemDetails`
d) Una excepcion `ValidationException` que hay que capturar manualmente

## Pregunta 3

Dado el siguiente validador FluentValidation, que regla se esta aplicando?

```csharp
RuleFor(x => x)
    .Must(x => !int.TryParse(x.DuracionMax, out var durMax)
                || x.Granularidad <= durMax)
    .WithName("Granularidad")
    .WithMessage("La granularidad no puede superar la duracion maxima");
```

a) Valida que `DuracionMax` sea un numero entero valido
b) Valida que `Granularidad` sea positivo
c) Valida que la granularidad no supere la duracion maxima, si esta es un entero valido
d) Valida que ambos campos sean obligatorios

## Pregunta 4

En la UA, cuando un recurso no se encuentra en la base de datos, que debe devolver la API?

a) `404 Not Found` con `ProblemDetails`
b) `204 No Content`
c) `200 OK` con un objeto vacio (Id = 0), y el frontend valida ese caso
d) `409 Conflict` con un mensaje explicativo

## Pregunta 5

Cual es el orden correcto de ejecucion en la cadena de validacion de la UA?

a) FluentValidation -> DataAnnotations -> HandleResult -> IExceptionHandler
b) DataAnnotations (automatico) -> FluentValidation -> Servicio con Result\<T\> -> HandleResult
c) Servicio con Result\<T\> -> DataAnnotations -> FluentValidation -> HandleResult
d) HandleResult -> DataAnnotations -> FluentValidation -> Servicio

## Pregunta 6

Que metodo de `ApiControllerBase` traduce un `Result<T>` a la respuesta HTTP correspondiente?

```csharp
public abstract class ApiControllerBase : ControllerBase
{
    protected ActionResult ________<T>(Result<T> result)
    {
        if (result.IsSuccess)
            return Ok(result.Value);
        // ...
    }
}
```

a) `MapResult`
b) `HandleResult`
c) `ProcessResult`
d) `TranslateResult`

## Pregunta 7

Cual es el mapeo correcto de `ErrorType` a codigo HTTP segun el contrato UA?

a) `Validation` -> 400, `Failure` -> 404
b) `Validation` -> 422, `Failure` -> 500
c) `Validation` -> 400, `Failure` -> 500
d) `Validation` -> 400, `Failure` -> 409

## Pregunta 8

En el siguiente codigo, que tipo de respuesta genera el caso `Validation`?

```csharp
return result.Error!.Type switch
{
    ErrorType.Validation => ValidationProblem(
        new ValidationProblemDetails(result.Error.ValidationErrors!)
        {
            Detail = result.Error.Message,
            Status = 400
        }),
    _ => Problem(detail: result.Error.Message, statusCode: 500)
};
```

a) Un `ProblemDetails` con campo `errors`
b) Un `ValidationProblemDetails` con diccionario de errores por campo y status 400
c) Un JSON plano con solo el campo `message`
d) Una excepcion `HttpResponseException`

## Pregunta 9

En FluentValidation, como se inyectan los mensajes localizados en un validador?

```csharp
public sealed class CrearReservaValidador : AbstractValidator<ClaseCrearReserva>
{
    public CrearReservaValidador(________ L)
    {
        RuleFor(x => x.Descripcion)
            .NotEmpty().WithMessage(L["RequiredField"]);
    }
}
```

a) `ILocalizationService`
b) `IStringLocalizer<SharedResources>`
c) `ResourceManager`
d) `IOptions<LocalizationOptions>`

## Pregunta 10

Que ficheros `.resx` soporta la configuracion de localizacion de la UA?

a) `SharedResources.resx`, `SharedResources.fr.resx`, `SharedResources.de.resx`
b) `SharedResources.resx`, `SharedResources.ca.resx`, `SharedResources.en.resx`
c) `App.resx`, `App.es.resx`, `App.en.resx`
d) `Messages.es-ES.resx`, `Messages.ca-ES.resx`, `Messages.en-US.resx`

## Pregunta 11

Que atributo DataAnnotations limita la longitud de una cadena con minimo y maximo?

```csharp
[_________(200, MinimumLength = 5, ErrorMessage = "Entre 5 y 200 caracteres")]
public string Descripcion { get; set; }
```

a) `Range`
b) `MaxLength`
c) `StringLength`
d) `Length`

## Pregunta 12

Que problema tiene este validador FluentValidation?

```csharp
RuleFor(x => x.Granularidad)
    .GreaterThan(0).WithMessage("Granularidad no valida");
```

a) `GreaterThan` no existe en FluentValidation
b) No limita el valor maximo, deberia usar `InclusiveBetween(5, 120)`
c) Falta el `.WithName()`
d) No se puede validar un campo `int` con FluentValidation

## Pregunta 13

Que nivel de Serilog se recomienda para errores de validacion de negocio en la UA?

a) `Information`
b) `Warning`
c) `Error`
d) `Fatal`

## Pregunta 14

Que nivel de Serilog se recomienda para excepciones tecnicas no esperadas?

a) `Debug`
b) `Warning`
c) `Information`
d) `Error`

## Pregunta 15

Cual es la forma correcta de registrar un log con Serilog segun las buenas practicas UA?

a) `_logger.LogInformation("Unidad " + id + " guardada");`
b) `_logger.LogInformation($"Unidad {id} guardada");`
c) `_logger.LogInformation("Unidad {Id} guardada", id);`
d) `_logger.LogInformation(string.Format("Unidad {0} guardada", id));`

## Pregunta 16

En el `IExceptionHandler` de la UA, que debe hacer con la excepcion?

```csharp
public async ValueTask<bool> TryHandleAsync(
    HttpContext context, Exception ex, CancellationToken ct)
{
    // ...
}
```

a) Devolver `ex.Message` y `ex.StackTrace` al cliente para facilitar la depuracion
b) Registrar la excepcion completa en Serilog y devolver un `ProblemDetails` generico al cliente
c) Relanzar la excepcion para que la maneje el middleware siguiente
d) Ignorar la excepcion y devolver `200 OK`

## Pregunta 17

Que campos son obligatorios en una respuesta `ProblemDetails` segun el estandar UA (basado en RFC 7807)?

a) `code`, `message`, `stackTrace`, `timestamp`
b) `type`, `title`, `status`, `detail`
c) `error`, `description`, `httpCode`
d) `status`, `message`

## Pregunta 18

Cual es la convencion UA para nombrar un DTO de lectura?

a) `UnidadDTO`
b) `ClaseUnidad`
c) `UnidadModel`
d) `DtoUnidad`

## Pregunta 19

Cual es la convencion UA para nombrar un servicio que gestiona unidades?

a) `ClaseUnidad`
b) `UnidadService`
c) `ClaseUnidades`
d) `UnidadesManager`

## Pregunta 20

Que patron sigue la UA para transportar errores de negocio sin lanzar excepciones?

a) `Try/Catch` con `BusinessException`
b) `Result<T>` con `Error` record y `ErrorType` enum
c) Codigos de retorno numericos
d) `Tuple<bool, string>` con el mensaje de error

## Pregunta 21

Como se registra FluentValidation en `Program.cs` para que detecte automaticamente los validadores?

a) `builder.Services.AddScoped<IValidator, CrearReservaValidador>();`
b) `builder.Services.AddValidatorsFromAssemblyContaining<CrearReservaValidador>();`
c) `builder.Services.AddFluentValidation();`
d) `builder.Services.AddSingleton(typeof(IValidator<>), typeof(AbstractValidator<>));`

## Pregunta 22

En el siguiente `ValidationProblemDetails`, que representa la clave `"Descripcion"` dentro de `errors`?

```json
{
  "type": "https://tools.ietf.org/html/rfc7807",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Descripcion": ["La descripcion es obligatoria"],
    "Aforo": ["El aforo debe estar entre 1 y 100"]
  }
}
```

a) El nombre de la tabla en la base de datos
b) El nombre del campo del DTO que tiene el error de validacion
c) La clave del recurso de localizacion
d) El nombre del metodo del controlador

## Pregunta 23

Si el servicio `ClaseUnidades.Guardar()` devuelve `Result<int>.Failure(new Error("Unidad.Duplicada", "Error al guardar", ErrorType.Failure))`, que codigo HTTP genera `HandleResult`?

a) 400
b) 404
c) 409
d) 500

## Pregunta 24

Que regla de FluentValidation usamos para validar que un campo `Aforo` este entre 1 y 100 (ambos incluidos)?

a) `RuleFor(x => x.Aforo).Between(1, 100);`
b) `RuleFor(x => x.Aforo).InclusiveBetween(1, 100);`
c) `RuleFor(x => x.Aforo).Range(1, 100);`
d) `RuleFor(x => x.Aforo).GreaterThan(0).LessThan(101);`

## Pregunta 25

En el siguiente codigo Vue, que falta en el `catch` para gestionar correctamente los errores?

```typescript
llamadaAxios("Unidades", verbosAxios.POST, unidad)
  .then(({ data }) => {
    avisarExito("Guardada");
  })
  .catch((error) => {
    avisarError("Error", error.message);
  });
```

a) Falta un `try/catch` adicional
b) Falta distinguir entre error 400 (validacion con `error.response.data.errors`) y error 500 (generico con `gestionarError`)
c) Falta convertir el error a JSON
d) Falta comprobar `error.code === "NETWORK_ERROR"`

## Pregunta 26

Que diferencia hay entre `ProblemDetails` y `ValidationProblemDetails`?

a) Son identicos, solo cambia el nombre
b) `ValidationProblemDetails` hereda de `ProblemDetails` y anade el campo `errors` (diccionario campo -> mensajes)
c) `ProblemDetails` es para APIs y `ValidationProblemDetails` es para MVC
d) `ValidationProblemDetails` usa XML y `ProblemDetails` usa JSON

## Pregunta 27

En la configuracion de Serilog, que hace `"Override": { "Microsoft": "Warning" }`?

```json
{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning"
      }
    }
  }
}
```

a) Establece el nivel minimo global a Warning
b) Solo registra logs de nivel Warning o superior provenientes de namespaces de Microsoft
c) Desactiva todos los logs de Microsoft
d) Redirige los logs de Microsoft a un fichero separado

## Pregunta 28

Cual es la forma correcta de configurar los idiomas soportados en `Program.cs`?

a) `builder.Services.AddLocalization("es-ES", "ca-ES", "en-US");`
b) Crear `RequestLocalizationOptions` con `SetDefaultCulture("es-ES")` y usar `AddSupportedCultures` y `AddSupportedUICultures`
c) `app.UseLanguages(new[] { "es", "ca", "en" });`
d) `builder.Services.Configure<CultureInfo>(c => c.Name = "es-ES");`

## Pregunta 29

Que ocurre si un validador FluentValidation usa `RuleFor(x => x.FechaFin).GreaterThan(x => x.FechaInicio)`?

a) Error de compilacion: no se puede referenciar otro campo
b) Valida que `FechaFin` sea estrictamente mayor que `FechaInicio`
c) Valida que `FechaFin` sea mayor o igual que `FechaInicio`
d) Valida que ambas fechas no sean null

## Pregunta 30

En la convencion UA para error codes, cual es el formato correcto?

a) `"ERROR-500-GUARDAR-UNIDAD"`
b) `"Unidad.SaveError"`
c) `"unidad_save_error"`
d) `"UNIDAD_ERROR"`

## Pregunta 31

Que hace `builder.Services.AddFluentValidationAutoValidation()` en `Program.cs`?

a) Registra los validadores como Singleton
b) Genera validadores automaticamente a partir de DataAnnotations
c) Integra FluentValidation en el pipeline de validacion automatica del modelo de ASP.NET Core
d) Desactiva la validacion de DataAnnotations

## Pregunta 32

En el siguiente servicio, por que se devuelve un objeto con `CodReserva = 0` en vez de un 404?

```csharp
public Result<ClaseReserva> ObtenerPorId(int id)
{
    var reserva = _bd.ObtenerPrimeroMap<ClaseReserva>(sql, new { id });
    return Result<ClaseReserva>.Success(reserva ?? new ClaseReserva { CodReserva = 0 });
}
```

a) Porque ObtenerPrimeroMap no puede devolver null
b) Porque el contrato UA solo usa 400 y 500; si no existe, se devuelve 200 OK con objeto vacio y el frontend valida
c) Porque 404 no esta soportado en ASP.NET Core
d) Porque el frontend no puede manejar respuestas 404

## Pregunta 33

Que atributo DataAnnotations valida que un campo contenga un email con formato correcto?

a) `[Email]`
b) `[MailAddress]`
c) `[EmailAddress]`
d) `[RegularExpression(@"\w+@\w+")]`

## Pregunta 34

Como se registra el `GlobalExceptionHandler` en `Program.cs`?

```csharp
builder.Services._________________;
app._________________;
```

a) `AddSingleton<GlobalExceptionHandler>()` / `UseMiddleware<GlobalExceptionHandler>()`
b) `AddExceptionHandler<GlobalExceptionHandler>()` / `UseExceptionHandler()`
c) `AddTransient<IExceptionHandler, GlobalExceptionHandler>()` / `UseErrorHandler()`
d) `AddScoped<GlobalExceptionHandler>()` / `UseExceptionHandlerMiddleware()`

## Pregunta 35

Que problema de seguridad tiene este `IExceptionHandler`?

```csharp
public async ValueTask<bool> TryHandleAsync(
    HttpContext context, Exception ex, CancellationToken ct)
{
    var problem = new ProblemDetails
    {
        Status = 500,
        Title = "Error",
        Detail = ex.Message + "\n" + ex.StackTrace
    };
    context.Response.StatusCode = 500;
    await context.Response.WriteAsJsonAsync(problem, ct);
    return true;
}
```

a) No hay problema, es correcto para produccion
b) Expone `ex.Message` y `ex.StackTrace` al cliente, lo que revela rutas, SQL, clases internas y es un riesgo de seguridad
c) Falta el `return false` al final
d) No se puede usar `WriteAsJsonAsync` en un `IExceptionHandler`

## Pregunta 36

En la cadena de validacion, que pasa si las DataAnnotations del DTO fallan?

a) Se ejecuta igualmente FluentValidation
b) Se ejecuta la accion del controlador con `ModelState.IsValid = false`
c) .NET devuelve automaticamente 400 sin ejecutar la accion ni FluentValidation
d) Se lanza una excepcion `ModelValidationException`

## Pregunta 37

Que convencion UA se usa para nombrar un DTO de escritura (creacion/actualizacion)?

a) `UnidadCreateDTO`
b) `ClaseCrearUnidad` o `ClaseGuardarUnidad`
c) `SaveUnidadRequest`
d) `UnidadWriteModel`

## Pregunta 38

En Serilog, que hace `app.UseSerilogRequestLogging()`?

a) Registra cada request HTTP como un log estructurado (metodo, path, status, duracion)
b) Escribe todos los request bodies en el log
c) Desactiva el logging de Microsoft por defecto
d) Solo registra los requests que fallan

## Pregunta 39

Dado este codigo, que clave de localizacion se usa para el mensaje de error de `FechaInicio`?

```csharp
RuleFor(x => x.FechaInicio)
    .GreaterThan(DateTime.Now).WithMessage(L["FutureDateRequired"]);
```

a) `"FechaInicio"`
b) `"GreaterThan"`
c) `"FutureDateRequired"`
d) `"DateTime.Now"`

## Pregunta 40

Que tipo de objetos contiene el campo `errors` de un `ValidationProblemDetails`?

a) Una lista de strings con los mensajes de error
b) Un diccionario `IDictionary<string, string[]>` donde la clave es el nombre del campo y el valor es un array de mensajes
c) Un objeto con propiedades `code` y `message`
d) Un array de objetos `ValidationError`

## Pregunta 41

Cual es el proposito de `.WithName("Granularidad")` en esta regla?

```csharp
RuleFor(x => x)
    .Must(x => !int.TryParse(x.DuracionMax, out var durMax)
                || x.Granularidad <= durMax)
    .WithName("Granularidad")
    .WithMessage("La granularidad no puede superar la duracion maxima");
```

a) Renombra la propiedad `Granularidad` en el DTO
b) Indica el nombre del campo al que se asocia el error en el `ValidationProblemDetails`, ya que la regla valida todo el objeto
c) Crea un alias para usar en los logs
d) Define el nombre de la columna en la base de datos

## Pregunta 42

Que configuracion de Serilog establece rotacion diaria de ficheros con retencion de 30 dias?

a) `"rollingInterval": "Day", "retainedFileCountLimit": 30`
b) `"rotation": "daily", "keepDays": 30`
c) `"fileRotation": "1d", "maxFiles": 30`
d) `"interval": "Day", "retention": "30d"`

## Pregunta 43

Si el controlador hereda de `ApiControllerBase` y el servicio devuelve `Result<T>.Success(valor)`, que respuesta HTTP genera `HandleResult`?

a) `201 Created` con el valor
b) `200 OK` con el valor
c) `204 No Content`
d) `202 Accepted`

## Pregunta 44

Que problema tiene este codigo Vue para manejar errores de validacion?

```typescript
.catch((error) => {
    if (error.response?.status === 400) {
        const errores = error.response.data.detail;
        avisarError("Error", errores);
    }
});
```

a) No hay problema, es correcto
b) Accede a `.detail` en vez de `.errors`; los errores de validacion campo a campo estan en `error.response.data.errors`
c) Falta un `JSON.parse()` antes de acceder a `data`
d) Deberia usar `error.status` en vez de `error.response.status`

## Pregunta 45

Que convencion UA se usa para las claves de los ficheros `.resx` de localizacion?

a) snake_case en espanol: `campo_obligatorio`
b) PascalCase en ingles: `RequiredField`, `UnexpectedError`
c) SCREAMING_CASE: `REQUIRED_FIELD`
d) camelCase en espanol: `campoObligatorio`

## Pregunta 46

En FluentValidation, que diferencia hay entre `NotEmpty()` y `NotNull()`?

a) Son identicos
b) `NotEmpty()` valida que no sea null, cadena vacia ni solo espacios; `NotNull()` solo valida que no sea null
c) `NotNull()` es para tipos valor y `NotEmpty()` es para strings
d) `NotEmpty()` no existe, solo `NotNull()`

## Pregunta 47

Que sucede si un servicio lanza una excepcion no controlada (ej. `NullReferenceException`) y existe un `IExceptionHandler` configurado?

a) La aplicacion se detiene con un crash
b) Se devuelve automaticamente un 400 con los detalles de la excepcion
c) El `IExceptionHandler` la captura, registra en Serilog y devuelve un `ProblemDetails` generico con status 500
d) Se devuelve un 404 Not Found

## Pregunta 48

En el siguiente codigo, por que se usa `When` en FluentValidation?

```csharp
RuleFor(x => x.EmailContacto)
    .EmailAddress().WithMessage(L["InvalidEmail"])
    .When(x => !string.IsNullOrEmpty(x.EmailContacto));
```

a) Para validar siempre el email
b) Para aplicar la regla de formato email solo cuando el campo no este vacio (es opcional)
c) Para desactivar la validacion del email
d) Para validar el email solo en produccion

## Pregunta 49

Segun las buenas practicas UA, donde se registra un servicio como `ClaseUnidades` para inyeccion de dependencias?

a) Directamente en `Program.cs` con `builder.Services.AddScoped<ClaseUnidades>()`
b) En `ServicesExtensionsApp.cs` con `AddScoped`
c) En el constructor del controlador
d) En `appsettings.json` bajo `Services`

## Pregunta 50

Cual es la estructura correcta del checklist que debe cumplir una API completa en la UA?

a) DTO con validacion, controlador con try/catch, servicio que lanza excepciones
b) DTO con DataAnnotations, servicio que devuelve `Result<T>`, controlador con `HandleResult`, `IExceptionHandler` configurado, mensajes localizados con `IStringLocalizer`
c) Controlador que valida manualmente, servicio con codigos de error numericos, sin localizacion
d) DTO sin validacion, servicio con excepciones personalizadas, controlador con filtros globales
