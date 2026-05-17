---
title: "Material de referencia: Validación, errores y buenas prácticas"
description: DataAnnotations, FluentValidation, localización y gestión centralizada de errores en APIs .NET
outline: deep
---

# Material de referencia: Validación, errores y buenas prácticas

::: danger CONTENIDO SUPERSEDIDO — VER SESIÓN 12
Este contenido ha sido reemplazado por **[Sesión 12 — Validación en todas las capas](../../parte-integracion/sesiones/sesion-12-validacion/)**.

Los patrones descritos aquí están **obsoletos**:

| Patrón de este documento | Reemplazado por |
|--------------------------|-----------------|
| `Result<T>` para transportar errores de negocio | `AppException` / `BDException` + `ErrorHandlerMiddleware` |
| `ApiControllerBase.HandleResult` | `ApiControllerUA.ProblemaValidacion()` |
| `gestionarError` (Vue) | `useGestionFormularios({ aislado: true })` + `adaptarProblemDetails()` |
| `BadRequest(ClaseErroresWebAPI.Generar(ModelState))` | `ProblemaValidacion()` (`ValidationProblemDetails` RFC 7807) |

Este fichero se conserva como referencia histórica. **No aplicar estos patrones en proyectos nuevos.**
:::

[[toc]]

## 3.1 Práctica guiada: Rojo-Verde-Refactor con ClaseGuardarUnidad

Repetimos el ciclo RGR pero ahora con el DTO real de Unidades, combinando DataAnnotations y FluentValidation.

### Paso 1: ROJO — POST sin validación

Si el DTO `ClaseGuardarUnidad` no tuviera ninguna validación, podríamos enviar datos basura:

```json
// POST /api/Unidades
{
  "nombreEs": "",
  "nombreCa": "",
  "nombreEn": "",
  "granularidad": -5,
  "duracionMax": "",
  "numCitasSimultaneas": 0
}

// Respuesta: 200 OK → ¡datos basura guardados en la BD!
```

::: danger ESTO ES ROJO
Sin validación, la API acepta una granularidad negativa, nombres vacíos y 0 citas simultáneas. Estos datos llegarían a la base de datos Oracle y provocarían problemas.
:::

### Paso 2: VERDE — DataAnnotations

Añadimos `[Required]`, `[StringLength]` y `[Range]` al DTO:

```csharp
[Required(ErrorMessage = "El nombre en español es obligatorio")]
[StringLength(200, ErrorMessage = "Máximo 200 caracteres")]
public string NombreEs { get; set; }

[Range(5, 120, ErrorMessage = "La granularidad debe estar entre 5 y 120 minutos")]
public int Granularidad { get; set; }

[Range(1, 50, ErrorMessage = "Las citas simultáneas deben estar entre 1 y 50")]
public int NumCitasSimultaneas { get; set; }
```

Ahora el mismo POST devuelve **400 Bad Request** automáticamente.

### Paso 3: REFACTOR — FluentValidation para reglas cruzadas

DataAnnotations valida cada campo individualmente. Pero, ¿qué pasa si la granularidad es mayor que la duración máxima? Eso es una regla que depende de **dos campos** y necesita FluentValidation:

```csharp
// Models/Unidad/ClaseGuardarUnidadValidator.cs
RuleFor(x => x)
    .Must(x => !int.TryParse(x.DuracionMax, out var durMax)
                || x.Granularidad <= durMax)
    .WithName("Granularidad")
    .WithMessage("La granularidad no puede superar la duración máxima");
```

::: tip COMBINAMOS AMBOS
**DataAnnotations** se ejecutan primero (validación automática del `[ApiController]`). Si pasan, **FluentValidation** se ejecuta después (registrado con `AddValidatorsFromAssemblyContaining`). Así, las reglas simples las ponemos en el DTO y las complejas en el validador.
:::

### Cadena completa de validación en sesión

En esta sesión usamos siempre la misma cadena end-to-end:

1. **DTO con DataAnnotations** (`ClaseGuardarUnidad`) para validar formato y rangos.
2. **Servicio con `Result<T>`** para transportar errores de negocio sin lanzar excepciones de dominio.
3. **`ApiControllerBase.HandleResult`** para traducir `ErrorType` a código HTTP: 400 (validación) o 500 (resto).
4. **`gestionarError` en Vue** para presentar el error al usuario final de forma consistente.

```text
Vue (llamadaAxios + gestionarError)
        │
        ▼
[ApiController] valida DataAnnotations (400 automático si falla)
        │
        ▼
Servicio (ClaseUnidades) devuelve Result<T> con ErrorType
        │
        ▼
ApiControllerBase.HandleResult => 200 / 400 / 500
        │
        ▼
Vue muestra errores por campo (400) o mensaje genérico (500)
```

::: info ALTERNATIVA EN ORACLE (SIN IMPLEMENTAR EN ESTE MÓDULO)
Como alternativa, algunos procedimientos almacenados exponen `p_codigo_error` y `p_mensaje_error` como parámetros OUT. En ese modelo, el servicio .NET traduce esos códigos Oracle a `Result<T>.Failure(...)` con `ErrorType.Failure` antes de pasar por `HandleResult`.
:::

## 3.2 DataAnnotations: validación declarativa

Las DataAnnotations son atributos que añadimos directamente en las propiedades del DTO. El `[ApiController]` las valida automáticamente antes de ejecutar la acción:

```csharp
// Models/Reserva/ClaseCrearReserva.cs
public class ClaseCrearReserva
{
    [Required(ErrorMessage = "La descripción es obligatoria")]
    [StringLength(200, MinimumLength = 5, ErrorMessage = "Entre 5 y 200 caracteres")]
    public string Descripcion { get; set; }

    [Required(ErrorMessage = "La sala es obligatoria")]
    [StringLength(50)]
    public string Sala { get; set; }

    [Required]
    public DateTime FechaInicio { get; set; }

    [Required]
    public DateTime FechaFin { get; set; }

    [Range(1, 100, ErrorMessage = "El aforo debe estar entre 1 y 100")]
    public int Aforo { get; set; }

    [EmailAddress(ErrorMessage = "El email no es válido")]
    public string? EmailContacto { get; set; }
}
```

| Atributo                             | Uso               | Ejemplo                  |
| ------------------------------------ | ----------------- | ------------------------ |
| `[Required]`                         | Campo obligatorio | Descripción, Sala        |
| `[StringLength(max, MinimumLength)]` | Longitud de texto | Entre 5 y 200 caracteres |
| `[Range(min, max)]`                  | Rango numérico    | Aforo entre 1 y 100      |
| `[EmailAddress]`                     | Formato email     | EmailContacto            |
| `[RegularExpression]`                | Patrón regex      | Código postal, teléfono  |

### Validación automática con [ApiController]

Cuando un DTO no pasa las validaciones, .NET devuelve automáticamente un `400 Bad Request` con un `ValidationProblemDetails` (RFC 7807):

```json
{
  "type": "https://tools.ietf.org/html/rfc7807",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Descripcion": ["La descripción es obligatoria"],
    "Aforo": ["El aforo debe estar entre 1 y 100"]
  }
}
```

::: info CONTEXTO
**Novedad .NET 10:** La validación con DataAnnotations es ~3x más rápida que en .NET 9 gracias al nuevo generador de código fuente. No necesitamos cambiar nada en nuestro código para beneficiarnos de esta mejora.
:::

### Ver errores de validación en Vue

```typescript
llamadaAxios("Reservas", verbosAxios.POST, nuevaReserva)
  .then(({ data }) => {
    // Reserva creada correctamente
  })
  .catch((error) => {
    if (error.response?.status === 400 && error.response.data?.errors) {
      // Errores de validación
      const errores = error.response.data.errors;
      // errores = { "Descripcion": ["La descripción es obligatoria"], ... }
      Object.values(errores)
        .flat()
        .forEach((msg) => avisarError("Validación", msg as string));
    } else {
      gestionarError(error, "Error al crear la reserva");
    }
  });
```

## 3.3 Validación con FluentValidation

::: info CONTEXTO
**¿Cuándo usar FluentValidation vs DataAnnotations?**

- **DataAnnotations**: validaciones sencillas (required, length, range). Son suficientes para la mayoría de DTOs.
- **FluentValidation**: validaciones complejas, condicionales, con mensajes localizados o que dependen de varios campos.

En la UA usamos **DataAnnotations por defecto** y FluentValidation cuando la validación lo requiera.
:::

```csharp
// Validators/CrearReservaValidador.cs
public sealed class CrearReservaValidador : AbstractValidator<ClaseCrearReserva>
{
    public CrearReservaValidador(IStringLocalizer<SharedResources> L)
    {
        RuleFor(x => x.Descripcion)
            .NotEmpty().WithMessage(L["RequiredField"])
            .MaximumLength(200).WithMessage(L["MaxLength"]);

        RuleFor(x => x.FechaInicio)
            .GreaterThan(DateTime.Now).WithMessage(L["FutureDateRequired"]);

        RuleFor(x => x.FechaFin)
            .GreaterThan(x => x.FechaInicio).WithMessage(L["EndDateAfterStart"]);

        RuleFor(x => x.Aforo)
            .InclusiveBetween(1, 100).WithMessage(L["RangeError"]);
    }
}
```

### Integración con IStringLocalizer

FluentValidation recibe el `IStringLocalizer` por inyección de dependencias, lo que permite mensajes localizados en español, catalán e inglés:

```csharp
// Program.cs
builder.Services.AddValidatorsFromAssemblyContaining<CrearReservaValidador>();
builder.Services.AddFluentValidationAutoValidation();
```

## 3.4 Localización de mensajes de error

### Archivos .resx (SharedResources)

```
Resources/
  SharedResources.resx         ← Idioma por defecto (español)
  SharedResources.ca.resx      ← Catalán
  SharedResources.en.resx      ← Inglés
```

Claves estándar en los ficheros `.resx`:

| Clave                | Español                  | Catalán                  | Inglés                  |
| -------------------- | ------------------------ | ------------------------ | ----------------------- |
| `RequiredField`      | Campo obligatorio        | Camp obligatori          | Required field          |
| `MaxLength`          | Longitud máxima superada | Longitud màxima superada | Maximum length exceeded |
| `UserNotFound`       | Usuario no encontrado    | Usuari no trobat         | User not found          |
| `InvalidCredentials` | Credenciales no válidas  | Credencials no vàlides   | Invalid credentials     |
| `UnexpectedError`    | Error inesperado         | Error inesperat          | Unexpected error        |

### Configuración en Program.cs

```csharp
// Program.cs
builder.Services.AddLocalization();

var supportedCultures = new[] { "es-ES", "ca-ES", "en-US" };
var localizationOptions = new RequestLocalizationOptions()
    .SetDefaultCulture("es-ES")
    .AddSupportedCultures(supportedCultures)
    .AddSupportedUICultures(supportedCultures);

app.UseRequestLocalization(localizationOptions);
```

### IStringLocalizer en servicios y validadores

```csharp
// En un servicio
public class Reservas
{
    private readonly IClaseOracleBd _bd;
    private readonly IStringLocalizer<SharedResources> _L;

    public Reservas(IClaseOracleBd bd, IStringLocalizer<SharedResources> L)
    {
        _bd = bd;
        _L = L;
    }

    public Result<ClaseReserva> ObtenerPorId(int id)
    {
        const string sql = "SELECT * FROM RESERVAS WHERE COD_RESERVA = :id";
        var reserva = _bd.ObtenerPrimeroMap<ClaseReserva>(sql, new { id });

        // Si no existe, devolvemos objeto vacío con Id=0
        return Result<ClaseReserva>.Success(reserva ?? new ClaseReserva { CodReserva = 0 });
    }
}
```

::: warning IMPORTANTE
**Claves estándar UA:** Usa siempre las claves definidas en los ficheros `SharedResources.resx` compartidos. No inventes claves nuevas sin consultar con el equipo. Las claves deben ser en inglés y descriptivas: `UserNotFound`, `RequiredField`, `InvalidDateRange`.
:::

## 3.5 Gestión centralizada de errores

### ControladorBase y ApiControllerBase

En la plantilla UA tenemos dos clases base:

```csharp
// Controllers/ControladorBase.cs
// Base para controladores MVC y API - proporciona utilidades comunes
public abstract class ControladorBase : Controller
{
    // Obtiene el código de persona del usuario autenticado
    protected int ObtenerCodPer()
    {
        // Extrae del token JWT validado
        return int.Parse(User.FindFirst("codper")?.Value ?? "0");
    }

    // Obtiene el idioma del usuario desde el token
    protected string ObtenerIdioma()
    {
        return User.FindFirst("idioma")?.Value ?? "ES";
    }
}
```

```csharp
// Controllers/ApiControllerBase.cs
// Base para controladores API - hereda de ControllerBase y añade HandleResult
public abstract class ApiControllerBase : ControllerBase
{
    protected ActionResult HandleResult<T>(Result<T> result)
    {
        if (result.IsSuccess)
            return Ok(result.Value);

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
    }
}
```

### IExceptionHandler para excepciones no controladas

Para excepciones que no esperamos (la BD se cae, un `NullReferenceException`), usamos un manejador global:

```csharp
// Middleware/GlobalExceptionHandler.cs
public class GlobalExceptionHandler : IExceptionHandler
{
    private readonly ILogger<GlobalExceptionHandler> _logger;

    public GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger)
        => _logger = logger;

    public async ValueTask<bool> TryHandleAsync(
        HttpContext context, Exception ex, CancellationToken ct)
    {
        _logger.LogError(ex, "Excepción no controlada: {Message}", ex.Message);

        var problem = new ProblemDetails
        {
            Status = 500,
            Title = "Error del servidor",
            Detail = "Ha ocurrido un error inesperado. Contacta con soporte."
            // ⚠️ NUNCA incluir ex.Message o ex.StackTrace
        };

        context.Response.StatusCode = 500;
        await context.Response.WriteAsJsonAsync(problem, ct);
        return true;
    }
}
```

```csharp
// Program.cs
builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
app.UseExceptionHandler();
```

::: danger ZONA PELIGROSA
**Nunca exponer stack traces al cliente.** El `IExceptionHandler` debe:

- Registrar la excepción completa en Serilog (con stack trace, para nosotros)
- Devolver al cliente un mensaje genérico sin detalles internos
- Incluir siempre un `traceId` para que soporte pueda buscar el log
  :::

## 3.6 Buenas prácticas UA

### Tabla resumen: ErrorType → HTTP → Serilog → Tests

| ErrorType      | HTTP  | Acción Serilog | Qué verificar en tests                        |
| -------------- | ----- | -------------- | --------------------------------------------- |
| `Validation`   | `400` | `Warning`      | `ValidationProblemDetails` con campo `errors` |
| `Failure`      | `500` | `Error`        | `ProblemDetails` genérico, `traceId` presente, sin stack trace |

::: tip BUENA PRÁCTICA
Solo dos códigos de error en la API: **400** para validación y **500** para todo lo demás. Si un recurso no se encuentra, devolvemos `200 OK` con un objeto vacío (`Id = 0`) y el frontend valida ese caso. No damos pistas al cliente sobre errores internos.
:::

### ProblemDetails estándar UA

Todas las respuestas de error siguen el estándar RFC 7807 con campos adicionales UA:

```json
{
  "type": "https://tools.ietf.org/html/rfc9110#section-15.6.1",
  "title": "An error occurred while processing your request.",
  "status": 500,
  "detail": "Error al procesar la petición"
}
```

| Campo      | Obligatorio   | Descripción                           |
| ---------- | ------------- | ------------------------------------- |
| `type`     | Sí            | URI estable de categoría de error     |
| `title`    | Sí            | Resumen legible del error             |
| `status`   | Sí            | Código HTTP                           |
| `detail`   | Sí            | Mensaje explicativo para el cliente   |
| `instance` | Recomendado   | Endpoint afectado                     |
| `traceId`  | Recomendado   | Correlación para soporte              |
| `errors`   | En validación | Diccionario campo → lista de mensajes |

### Convenciones de nombrado

| Elemento            | Convención                        | Ejemplo                                     |
| ------------------- | --------------------------------- | ------------------------------------------- |
| Modelo (DTO)        | Singular, prefijo `Clase`         | `ClaseReserva`                              |
| Modelo de escritura | Singular, prefijo `Clase` + verbo | `ClaseCrearReserva`, `ClaseGrabarPermiso`   |
| Servicio            | Plural                            | `Reservas`, `HerramientasIA`                |
| Controlador API     | Plural + Controller               | `ReservasController`                        |
| Error code          | Entidad.Tipo                      | `"Reserva.Error"`, `"Usuario.SaveError"` |
| Clave localización  | PascalCase inglés                 | `RequiredField`, `UnexpectedError`          |

::: tip CHECKLIST DE API COMPLETA
Antes de dar por terminada una API, verifica:

- [ ] DTO con DataAnnotations para validación básica
- [ ] Servicio que devuelve `Result<T>` (nunca lanza excepciones de negocio)
- [ ] Controlador hereda de `ApiControllerBase` y usa `HandleResult`
- [ ] `IExceptionHandler` configurado para errores no controlados
- [ ] Mensajes de error localizados con `IStringLocalizer`
- [ ] Registrado en `ServicesExtensionsApp.cs` con `AddScoped`
- [ ] Probado desde Vue con `llamadaAxios` + `gestionarError`
      :::

## 3.7 Logging estructurado con Serilog

En esta sesión añadimos logging como parte de la gestión de errores.

### Configuración recomendada (Console + File)

```json
{
  "Serilog": {
    "Using": ["Serilog.Sinks.Console", "Serilog.Sinks.File"],
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning"
      }
    },
    "WriteTo": [
      { "Name": "Console" },
      {
        "Name": "File",
        "Args": {
          "path": "logs/app-.log",
          "rollingInterval": "Day",
          "retainedFileCountLimit": 30
        }
      }
    ]
  }
}
```

```csharp
// Program.cs
builder.Host.UseSerilog((context, services, configuration) => configuration
    .ReadFrom.Configuration(context.Configuration)
    .ReadFrom.Services(services)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .WriteTo.File("logs/app-.log", rollingInterval: RollingInterval.Day));

app.UseSerilogRequestLogging();
```

### Buenas prácticas de mensajes

::: tip BUENA PRÁCTICA

- Usa placeholders con nombre: `_logger.LogInformation("Unidad {Id} guardada", id);`
- Evita concatenar strings en logs.
- Incluye contexto útil (`UserId`, `Path`, `ActionName`) mediante middleware.
  :::

### Niveles recomendados

| Nivel         | Cuándo usar                                    |
| ------------- | ---------------------------------------------- |
| `Information` | Flujo normal (altas, lecturas, fin de proceso) |
| `Warning`     | Errores esperados de negocio/validación        |
| `Error`       | Excepciones o fallos técnicos no esperados     |

## Preguntas de repaso

### Pregunta 1

**¿Qué atributo DataAnnotations usamos para limitar un campo numérico entre 5 y 120?**

a) `[StringLength(5, 120)]`
b) `[Range(5, 120)]`
c) `[MinLength(5), MaxLength(120)]`
d) `[Between(5, 120)]`

::: details Respuesta
**b)** `[Range(min, max)]` se usa para valores numéricos. `[StringLength]` y `[MinLength]/[MaxLength]` son para la longitud de cadenas de texto. `[Between]` no existe en DataAnnotations.
:::

### Pregunta 2

**¿Qué ocurre cuando un DTO con `[ApiController]` no pasa las DataAnnotations?**

a) Se ejecuta la acción del controlador y se devuelve null
b) Se lanza una excepción que hay que capturar con try/catch
c) .NET devuelve automáticamente un `400 Bad Request` con `ValidationProblemDetails`
d) Se ejecuta la acción pero `ModelState.IsValid` es false

::: details Respuesta
**c)** El atributo `[ApiController]` activa la validación automática. Si el DTO no pasa las DataAnnotations, .NET intercepta la petición **antes** de ejecutar la acción y devuelve un `400` con los errores en formato `ValidationProblemDetails` (RFC 7807).
:::

### Pregunta 3

**¿Cuándo debemos usar FluentValidation en lugar de DataAnnotations?**

a) Siempre, DataAnnotations está obsoleto
b) Solo para validaciones complejas, condicionales o que dependen de varios campos
c) Solo para APIs, no para controladores MVC
d) Nunca, la UA solo permite DataAnnotations

::: details Respuesta
**b)** En la UA usamos **DataAnnotations por defecto** (campos obligatorios, longitud, rango). FluentValidation se usa cuando la validación es compleja: depende de varios campos (ej. granularidad <= duración máxima), es condicional, o necesita mensajes localizados con `IStringLocalizer`.
:::

### Pregunta 4

**¿Cómo recibe un validador FluentValidation los mensajes localizados?**

a) Lee directamente los archivos `.resx`
b) Usa `Thread.CurrentCulture` para traducir
c) Recibe `IStringLocalizer<SharedResources>` por inyección de dependencias
d) Se configuran en `appsettings.json`

::: details Respuesta
**c)** El constructor del validador recibe `IStringLocalizer<SharedResources>` por inyección de dependencias. Las claves (ej. `L["RequiredField"]`) se resuelven automáticamente según el idioma de la petición (`es-ES`, `ca-ES`, `en-US`).
:::

### Pregunta 5

**¿Por qué el `IExceptionHandler` NO debe incluir `ex.Message` ni `ex.StackTrace` en la respuesta?**

a) Porque son demasiado largos para una respuesta HTTP
b) Porque exponen detalles internos del servidor (rutas, clases, SQL) que son un riesgo de seguridad
c) Porque .NET no permite serializar excepciones a JSON
d) Porque el frontend no sabe interpretarlos

::: details Respuesta
**b)** Los mensajes de excepción y stack traces pueden contener rutas del servidor, nombres de tablas, queries SQL, versiones de frameworks, etc. Esta información es valiosa para un atacante. El `IExceptionHandler` registra todo en Serilog (para nosotros) y devuelve un mensaje genérico al cliente.
:::

### Pregunta 6

**¿Cómo diferenciamos en Vue un error de validación (400) de un error genérico (500)?**

a) No se puede, todos los errores son iguales
b) Por `error.response.status`: 400 tiene `.errors` (campos), 500 tiene `.detail` genérico
c) Por el texto del mensaje de error
d) Por el método HTTP usado (GET vs POST)

::: details Respuesta
**b)** Un 400 de validación incluye `error.response.data.errors` con un diccionario campo → mensajes. Un 500 indica error interno sin detalles para el cliente. Ambos siguen el formato `ProblemDetails`.
:::

### Pregunta 7

**En la convención UA, ¿cuál es la forma correcta de nombrar un Error code?**

a) `"ERROR_500_UNIDAD"`
b) `"unidad-error-guardar"`
c) `"Unidad.SaveError"`
d) `"UnidadSaveErrorException"`

::: details Respuesta
**c)** La convención UA para error codes es `Entidad.Tipo` en PascalCase: `"Unidad.SaveError"`, `"Reserva.Error"`, `"Usuario.Validation"`. Es descriptivo y sigue un patrón consistente.
:::

### Pregunta 8

**¿Qué campos debe incluir SIEMPRE una respuesta de error según el estándar UA (basado en RFC 7807)?**

a) Solo `status` y `message`
b) `type`, `title`, `status` y `detail`
c) `code`, `message` y `stackTrace`
d) `error`, `description` y `timestamp`

::: details Respuesta
**b)** El estándar UA exige: `type` (URI de categoría), `title` (resumen legible), `status` (código HTTP), `detail` (mensaje para el cliente). Adicionalmente se recomienda `instance` (endpoint) y `traceId` (correlación para soporte).
:::

## Ejercicio Sesión 3

**Objetivo:** Añadir validación completa al flujo de unidades y gestionar todos los errores hasta Vue.

1. Añadir DataAnnotations al DTO `ClaseGuardarUnidad`:
   - `NombreEs`, `NombreCa`, `NombreEn`: obligatorios, máximo 200 caracteres
   - `Granularidad`: entre 5 y 120 minutos
   - `DuracionMax`: obligatorio
   - `NumCitasSimultaneas`: entre 1 y 50
2. Añadir FluentValidation con regla de negocio:
   - La granularidad no puede superar la duración máxima
3. En el servicio, gestionar los errores de Oracle con `Result<T>.Failure` y `ErrorType.Failure`
4. En Vue:
   - Mostrar errores de validación campo a campo (respuesta 400)
   - Mantener `gestionarError` como fallback para errores del servidor (500)

::: details Solución

**DTO con DataAnnotations:**

```csharp
// Models/Unidad/ClaseGuardarUnidad.cs
public class ClaseGuardarUnidad
{
    public int? Id { get; set; }

    [Required(ErrorMessage = "El nombre en español es obligatorio")]
    [StringLength(200, ErrorMessage = "El nombre no puede superar los 200 caracteres")]
    public string NombreEs { get; set; }

    [Required(ErrorMessage = "El nombre en catalán es obligatorio")]
    [StringLength(200)]
    public string NombreCa { get; set; }

    [Required(ErrorMessage = "El nombre en inglés es obligatorio")]
    [StringLength(200)]
    public string NombreEn { get; set; }

    public bool FlgActiva { get; set; }

    [Range(5, 120, ErrorMessage = "La granularidad debe estar entre 5 y 120 minutos")]
    public int Granularidad { get; set; }

    [Required(ErrorMessage = "La duración máxima es obligatoria")]
    public string DuracionMax { get; set; }

    public bool FlgRequiereConfirmacion { get; set; }

    [Range(1, 50, ErrorMessage = "Las citas simultáneas deben estar entre 1 y 50")]
    public int NumCitasSimultaneas { get; set; }

    public int CodPer { get; set; }
    public string Ip { get; set; }
}
```

**Validador FluentValidation:**

```csharp
// Models/Unidad/ClaseGuardarUnidadValidator.cs
public class ClaseGuardarUnidadValidator : AbstractValidator<ClaseGuardarUnidad>
{
    public ClaseGuardarUnidadValidator()
    {
        RuleFor(x => x.NombreEs)
            .NotEmpty().WithMessage("El nombre en español es obligatorio")
            .MaximumLength(200);

        RuleFor(x => x.NombreCa)
            .NotEmpty().WithMessage("El nom en català és obligatori")
            .MaximumLength(200);

        RuleFor(x => x.NombreEn)
            .NotEmpty().WithMessage("The English name is required")
            .MaximumLength(200);

        RuleFor(x => x.Granularidad)
            .InclusiveBetween(5, 120)
            .WithMessage("La granularidad debe estar entre {From} y {To} minutos");

        RuleFor(x => x.NumCitasSimultaneas)
            .InclusiveBetween(1, 50);

        // Regla de negocio: granularidad no puede superar duración máxima
        RuleFor(x => x) // [!code highlight]
            .Must(x => !int.TryParse(x.DuracionMax, out var durMax)
                        || x.Granularidad <= durMax) // [!code highlight]
            .WithName("Granularidad")
            .WithMessage("La granularidad no puede superar la duración máxima");
    }
}
```

**Servicio con validación de negocio:**

```csharp
// Services/Unidades.cs
public Result<int> Guardar(ClaseGuardarUnidad dto)
{
    // Validación de negocio: nombre duplicado
    const string sqlCheck = @"
        SELECT COUNT(*) FROM TCTS_UNIDADES
        WHERE NOMBRE_ES = :nombre AND (:id IS NULL OR ID != :id)";

    var existe = _bd.ObtenerPrimeroMap<int>(sqlCheck,
        new { nombre = dto.NombreEs, id = dto.Id });

    if (existe > 0)
        return Result<int>.Failure(
            new Error("Unidad.Duplicada",
                "Error al guardar la unidad",
                ErrorType.Failure));

    var parametros = new DynamicParameters();
    parametros.Add("pid", dto.Id, direction: ParameterDirection.InputOutput);
    // ... resto de parámetros ...

    _bd.EjecutarParams("PKG_CITAS.GUARDA_UNIDAD", parametros);
    return Result<int>.Success((int)parametros.Get("pid"));
}
```

**Vue con gestión de errores completa:**

```vue
<script setup lang="ts">
import { ref, reactive } from "vue";
import {
  llamadaAxios,
  verbosAxios,
  gestionarError,
} from "vueua-useaxios/services/useAxios";
import { avisarError, avisarExito } from "vueua-usetoast/services/useToast";

const erroresValidacion = ref<Record<string, string[]>>({});

const unidad = reactive({
  nombreEs: "",
  nombreCa: "",
  nombreEn: "",
  flgActiva: true,
  granularidad: 15,
  duracionMax: "60",
  flgRequiereConfirmacion: false,
  numCitasSimultaneas: 1,
});

const guardarUnidad = () => {
  erroresValidacion.value = {};

  llamadaAxios("Unidades", verbosAxios.POST, unidad)
    .then(({ data }) => {
      avisarExito("Unidad guardada", `ID: ${data.value}`);
    })
    .catch((error) => {
      if (error.response?.status === 400 && error.response.data?.errors) {
        // Errores de validación → mostrar campo a campo
        erroresValidacion.value = error.response.data.errors;
      } else {
        // Cualquier otro error (500) → mensaje genérico
        gestionarError(error, "Error al guardar la unidad");
      }
    });
};
</script>

<template>
  <form @submit.prevent="guardarUnidad">
    <div class="mb-3">
      <label class="form-label">Nombre (español)</label>
      <input
        v-model="unidad.nombreEs"
        class="form-control"
        :class="{ 'is-invalid': erroresValidacion.NombreEs }"
      />
      <div class="invalid-feedback" v-if="erroresValidacion.NombreEs">
        {{ erroresValidacion.NombreEs[0] }}
      </div>
    </div>

    <div class="mb-3">
      <label class="form-label">Granularidad (minutos)</label>
      <input
        v-model.number="unidad.granularidad"
        type="number"
        class="form-control"
        :class="{ 'is-invalid': erroresValidacion.Granularidad }"
      />
      <div class="invalid-feedback" v-if="erroresValidacion.Granularidad">
        {{ erroresValidacion.Granularidad[0] }}
      </div>
    </div>

    <button type="submit" class="btn btn-primary">Guardar unidad</button>
  </form>
</template>
```

:::

::: details Código con fallos para Copilot

```csharp
// ⚠️ CÓDIGO CON FALLOS - Usa Copilot para encontrar y arreglar los errores
public class ClaseGuardarUnidadValidator : AbstractValidator<ClaseGuardarUnidad>
{
    public ClaseGuardarUnidadValidator()
    {
        // 🐛 NotEmpty no valida longitud máxima - falta MaximumLength(200)
        RuleFor(x => x.NombreEs)
            .NotEmpty().WithMessage("Obligatorio");

        // 🐛 Falta validar NombreCa y NombreEn

        // 🐛 GreaterThan(0) no limita el máximo - debería ser InclusiveBetween(5, 120)
        RuleFor(x => x.Granularidad)
            .GreaterThan(0).WithMessage("Granularidad no válida");

        // 🐛 Falta la regla de negocio: granularidad <= duración máxima
        // 🐛 Falta validar NumCitasSimultaneas (1-50)
    }
}
```

```vue
<!-- ⚠️ CÓDIGO VUE CON FALLOS - Usa Copilot para arreglarlo -->
<script setup lang="ts">
const guardarUnidad = () => {
  // 🐛 Usa verbosAxios.GET en vez de verbosAxios.POST
  llamadaAxios("Unidades", verbosAxios.GET, unidad)
    .then(({ data }) => {
      avisarExito("Guardada");
    })
    .catch((error) => {
      // 🐛 No distingue entre errores de validación (400) y conflicto (409)
      avisarError("Error", error.message);
      // 🐛 Accede a error.message en vez de error.response.data.errors/.detail
    });
};
</script>
```

:::

---

## Resumen y Siguientes Pasos

### Recapitulación

| Sesión                                      | Conceptos clave                                          | Resultado                          |
| ------------------------------------------- | -------------------------------------------------------- | ---------------------------------- |
| **[Sesión 1](./sesion-1-dtos-apis)**        | DTOs, controladores API, verbos HTTP, códigos de estado  | API funcionando sin BD + Vista Vue |
| **[Sesión 2](./sesion-2-servicios-oracle)** | `Result<T>`, ClaseOracleBD3, mapeo automático, servicios | API con datos reales de Oracle     |
| **Sesión 3**                                | DataAnnotations, FluentValidation, localización, errores | Validación completa end-to-end     |

### Lo que hemos aprendido

```
Cliente (Vue)                    Servidor (.NET Core 10)
─────────────                    ───────────────────────
llamadaAxios ──────────────────► [ApiController] valida DTO
                                        │
gestionarError ◄───── 400/404 ──── ApiControllerBase.HandleResult
                                        │
avisarError ◄──── ProblemDetails ─── Servicio devuelve Result<T>
                                        │
data.value ◄──────── 200 OK ──── ClaseOracleBD3.ObtenerTodosMap
```

### Siguientes pasos

Estos temas se cubren en otros módulos del curso:

- **Seguridad**: Autenticación con CAS, autorización con Claims/Roles, políticas
- **Serilog**: Logging estructurado a Oracle, consola y email
- **Pruebas unitarias**: xUnit para controladores y servicios con mocks
- **Ficheros**: Subida y descarga de archivos con la API

---

## Tests y práctica IA

- [Ver tests y práctica de la sesión](../../test/sesion-3/)
- [Autoevaluación sesión 3](../../test/sesion-3/autoevaluacion.md)
- [Preguntas de test sesión 3](../../test/sesion-3/preguntas.md)
- [Respuestas del test sesión 3](../../test/sesion-3/respuestas.md)
- [Práctica IA-fix sesión 3](../../test/sesion-3/practica-ia-fix.md)

---

**Anterior:** [Sesión 2: Servicios, Oracle y ClaseOracleBD3](../sesion-2-servicios-oracle/) | **Siguiente:** [Sesión 4: DataTable server-side](../sesion-4-datatable-clasecrud/) | **Inicio:** [APIs en .NET Core 10](../../index.md)
