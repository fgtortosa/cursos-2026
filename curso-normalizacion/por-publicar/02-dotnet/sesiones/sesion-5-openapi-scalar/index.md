---
title: "Material de referencia: OpenAPI, Scalar y testing API"
description: Documentar APIs con OpenAPI, explorar con Scalar, patrones GET/POST, naming JSON, filtros, tests de integración y httpRepl
outline: deep
---

# Material de referencia: OpenAPI, Scalar y testing API

::: warning REORGANIZACIÓN DEL TEMARIO
Este contenido se ha dividido entre dos sesiones de integración:
- **Sesión 11 — Llamadas a la API y autenticación**: OpenAPI, Scalar, exploración de la API
- **Sesión 18 — Tests y calidad de código**: WebApplicationFactory, httpRepl, ActionFilters, naming JSON

Este fichero se mantiene como material de consulta y referencia.
:::

[[toc]]

## 5.1 ¿Por qué documentar la API?

::: info CONTEXTO
Hasta ahora hemos creado endpoints (sesiones 1-4) que funcionan correctamente. Pero el equipo de frontend (o cualquier consumidor de la API) necesita saber:

- **Qué endpoints existen** y qué hace cada uno
- **Qué parámetros** acepta cada endpoint y de qué tipo
- **Qué códigos HTTP** puede devolver (200, 400, 404, 500…)
- **Qué estructura** tiene la respuesta en cada caso

Sin documentación, el frontend tiene que adivinar o leer el código fuente. **OpenAPI** es el estándar para documentar APIs REST automáticamente.
:::

### ¿Qué es OpenAPI?

OpenAPI (antes Swagger Specification) es un formato estándar (JSON/YAML) que describe una API REST:

```json
// /openapi/v1.json (generado automáticamente)
{
  "openapi": "3.1.0",
  "info": { "title": "CursoNormalizacionApps", "version": "1.0.0" },
  "paths": {
    "/api/Unidades": {
      "get": {
        "summary": "Listar unidades activas",
        "parameters": [
          { "name": "idioma", "in": "query", "schema": { "type": "string" } }
        ],
        "responses": {
          "200": { "description": "Lista de unidades" },
          "500": { "description": "Error interno" }
        }
      }
    }
  }
}
```

### Visualizadores: Swagger UI vs Scalar

| | Swagger UI | Scalar |
|-|-----------|--------|
| **Aspecto** | Clásico, estándar de facto | Moderno, limpio, minimalista |
| **Dependencia** | Requiere NuGet `Swashbuckle` | NuGet `Scalar.AspNetCore` (más ligero) |
| **Funcionalidad** | Probar endpoints, ver esquemas | Probar endpoints, ver esquemas, buscar |
| **En el curso** | No lo usamos | **Sí lo usamos** |

::: tip DECISIÓN DEL CURSO
Usamos **Scalar** porque es más ligero, no requiere Swashbuckle, y se integra directamente con `AddOpenApi()` nativo de .NET 9+.
:::

## 5.2 Configuración de OpenAPI + Scalar

### En `Program.cs`

```csharp
using Scalar.AspNetCore;                                         // [!code highlight]

var builder = WebApplication.CreateBuilder(args);

// 1. Registrar OpenAPI (nativo .NET 9+)
builder.Services.AddOpenApi();                                   // [!code highlight]

var app = builder.Build();

// 2. Activar endpoints solo en Development/Staging
if (app.Environment.IsDevelopment() || app.Environment.IsStaging())
{
    app.MapOpenApi().AllowAnonymous();                           // [!code highlight]
    app.MapScalarApiReference("/scalar").AllowAnonymous();       // [!code highlight]
}
```

### URLs disponibles

| URL | Contenido |
|-----|-----------|
| `/openapi/v1.json` | Documento OpenAPI en JSON (consumible por herramientas) |
| `/scalar` | Interfaz visual Scalar para explorar y probar la API |

::: warning SOLO EN DESARROLLO
OpenAPI y Scalar se activan **solo** en `Development` y `Staging`. En producción no se exponen para evitar revelar la estructura interna de la API.
:::

### NuGet necesarios

```xml
<!-- En el .csproj -->
<PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="..." />
<PackageReference Include="Scalar.AspNetCore" Version="..." />
```

## 5.3 Documentar respuestas con `ProducesResponseType`

Para que OpenAPI muestre qué devuelve cada endpoint, usamos atributos:

```csharp
[HttpGet("{id:int}")]
[ProducesResponseType(typeof(ClaseUnidad), StatusCodes.Status200OK)]          // [!code highlight]
[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)] // [!code highlight]
public ActionResult ObtenerPorId(int id, [FromQuery] string idioma = "ES")
{
    var resultado = _unidades.ObtenerPorId(id, idioma);
    return HandleResult(resultado);
}
```

### Qué documenta cada atributo

| Atributo | Qué dice a OpenAPI |
|----------|-------------------|
| `ProducesResponseType(typeof(ClaseUnidad), 200)` | "Si todo va bien, devuelve un `ClaseUnidad` (Id=0 si no existe)" |
| `ProducesResponseType(typeof(ValidationProblemDetails), 400)` | "Si hay errores de validación, devuelve errores por campo" |
| `ProducesResponseType(typeof(ProblemDetails), 500)` | "Si hay error interno, devuelve `ProblemDetails` genérico" |

### Ejemplo completo: endpoint de comprobación

Un patrón útil es separar **comprobar** (GET) de **ejecutar** (POST):

```csharp
// DTO de comprobación
public class ClaseComprobacionOperacion
{
    public bool Permitido { get; set; }
    public string Razon { get; set; } = "";
    public string TokenOperacion { get; set; } = "";
}

// GET: ¿Se puede eliminar?
[HttpGet("{id:int}/puede-eliminar")]
[ProducesResponseType(typeof(ClaseComprobacionOperacion), StatusCodes.Status200OK)]
[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
public ActionResult<ClaseComprobacionOperacion> PuedeEliminar(int id)
{
    var unidad = _unidades.ObtenerPorId(id);
    if (unidad.Value?.Id == 0)
        return Ok(new ClaseComprobacionOperacion { Permitido = false, Razon = "Unidad no encontrada" });

    return Ok(new ClaseComprobacionOperacion
    {
        Permitido = true,
        Razon = "La unidad se puede eliminar",
        TokenOperacion = Guid.NewGuid().ToString("N")        // [!code highlight]
    });
}

// POST: Ejecutar la eliminación (con token)
[HttpPost("{id:int}/eliminar")]
[ProducesResponseType(typeof(Result<bool>), StatusCodes.Status200OK)]
[ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
public ActionResult EliminarConfirmado(int id,
    [FromBody] ClaseConfirmarOperacion dto)
{
    if (string.IsNullOrWhiteSpace(dto.TokenOperacion))
        return ValidationProblem(new ValidationProblemDetails(
            new Dictionary<string, string[]>
            {
                { "tokenOperacion", new[] { "El token es obligatorio" } }
            }));

    var resultado = _unidades.Eliminar(id, dto.CodPer, dto.Ip);
    return HandleResult(resultado);
}
```

::: tip PATRÓN GET + POST
Este patrón es útil para operaciones destructivas o irreversibles:
1. **GET** `/api/unidades/5/puede-eliminar` → devuelve `{ permitido: true, token: "abc123" }`
2. **POST** `/api/unidades/5/eliminar` con `{ tokenOperacion: "abc123" }` → ejecuta la eliminación

El token evita ejecuciones accidentales y permite verificar en el servicio que la comprobación se realizó previamente.
:::

## 5.4 Validación en dos capas: DTO y servicio

### Capa 1: Validación del DTO (FluentValidation)

Valida **formato y estructura** (campos obligatorios, longitudes, rangos):

```csharp
public sealed class ClaseConfirmarOperacionValidator
    : AbstractValidator<ClaseConfirmarOperacion>
{
    public ClaseConfirmarOperacionValidator()
    {
        RuleFor(x => x.TokenOperacion)
            .NotEmpty().WithMessage("El token es obligatorio");
    }
}
```

### Capa 2: Validación en el servicio (reglas de negocio)

Valida **lógica de negocio** (token válido, permisos, estado):

```csharp
// En el servicio
if (!RepositorioTokens.EsValido(dto.TokenOperacion, id))
{
    return Result<bool>.Failure(
        new Error("Unidad.TokenInvalido",
            "El token de operación no es válido",
            ErrorType.Validation));
}
```

### Flujo completo

```
Frontend → POST /api/unidades/5/eliminar { tokenOperacion: "abc123" }
                     │
                     ▼
           FluentValidation (DTO)
           ¿Token no vacío? → 400 ValidationProblemDetails
                     │ OK
                     ▼
           Servicio (negocio)
           ¿Token válido? → 400 Result.Failure(Validation)
           ¿Error de BD? → 500 Result.Failure(Failure)
                     │ OK
                     ▼
           Eliminar en BD → 200 Result.Success(true)
```

## 5.5 Errores multiidioma con `IStringLocalizer`

Los mensajes de error pueden localizarse para los tres idiomas (es, ca, en):

```csharp
public class ClaseUnidades
{
    private readonly IStringLocalizer<SharedResources> _L;

    public ClaseUnidades(IStringLocalizer<SharedResources> L) => _L = L;

    public Result<bool> ValidarOperacion(...)
    {
        return Result<bool>.Failure(new Error(
            "Unidad.TokenInvalido",
            _L["UnidadTokenInvalido"],                           // [!code highlight]
            ErrorType.Validation));
    }
}
```

### Ficheros de recursos

```
Resources/
  SharedResources.resx          ← Español (por defecto)
  SharedResources.ca.resx       ← Catalán
  SharedResources.en.resx       ← Inglés
```

| Clave | ES | CA | EN |
|-------|----|----|-----|
| `UnidadTokenInvalido` | El token no es válido | El token no és vàlid | Token is not valid |
| `UnidadNoEncontrada` | Unidad no encontrada | Unitat no trobada | Unit not found |

::: info CÓMO SE SELECCIONA EL IDIOMA
El idioma se obtiene del claim del usuario autenticado (`ObtenerIdiomaClaimUsuario()`). El middleware de localización establece la cultura del hilo, y `IStringLocalizer` selecciona automáticamente el fichero `.resx` correcto.
:::

## 5.6 Naming JSON: camelCase vs PascalCase

### camelCase (recomendado para APIs web)

```csharp
// Program.cs — camelCase es el default en .NET
builder.Services.AddControllers().AddJsonOptions(o =>
{
    o.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
});
```

```json
// Respuesta camelCase
{ "id": 1, "nombreEs": "Biblioteca", "flgActiva": true }
```

### PascalCase (si el contrato legacy lo requiere)

```csharp
// Program.cs — PascalCase explícito
builder.Services.AddControllers().AddJsonOptions(o =>
{
    o.JsonSerializerOptions.PropertyNamingPolicy = null;          // [!code highlight]
});

builder.Services.ConfigureHttpJsonOptions(o =>
{
    o.SerializerOptions.PropertyNamingPolicy = null;
});
```

```json
// Respuesta PascalCase
{ "Id": 1, "NombreEs": "Biblioteca", "FlgActiva": true }
```

### ProblemDetails con formato personalizado

Si necesitas que `ProblemDetails` también use PascalCase:

```csharp
builder.Services.AddTransient<IProblemDetailsWriter, PascalCaseProblemDetailsWriter>();
builder.Services.AddProblemDetails();
```

```csharp
public sealed class PascalCaseProblemDetailsWriter : IProblemDetailsWriter
{
    public bool CanWrite(ProblemDetailsContext context) => true;

    public async ValueTask WriteAsync(ProblemDetailsContext context)
    {
        var options = new JsonSerializerOptions(JsonSerializerDefaults.Web)
        {
            PropertyNamingPolicy = null                          // [!code highlight]
        };
        context.HttpContext.Response.ContentType = "application/problem+json";
        await context.HttpContext.Response.WriteAsJsonAsync(
            context.ProblemDetails, options);
    }
}
```

::: warning RFC 7807
El estándar `ProblemDetails` (RFC 7807) usa nombres canónicos en minúsculas: `type`, `title`, `status`, `detail`, `errors`. Si cambias a PascalCase, documenta claramente ese contrato para el frontend.
:::

## 5.7 Filtros de acción (ActionFilter)

Los filtros permiten ejecutar lógica **antes y después** de cada acción del controlador:

```csharp
// Ejemplo: medir duración de cada endpoint
public class ApiTimingFilter : IActionFilter
{
    private readonly ILogger<ApiTimingFilter> _logger;
    private Stopwatch? _sw;

    public ApiTimingFilter(ILogger<ApiTimingFilter> logger)
        => _logger = logger;

    public void OnActionExecuting(ActionExecutingContext context)
    {
        _sw = Stopwatch.StartNew();
    }

    public void OnActionExecuted(ActionExecutedContext context)
    {
        _sw?.Stop();
        _logger.LogInformation("Action {Action} tardó {ElapsedMs}ms",
            context.ActionDescriptor.DisplayName,
            _sw?.ElapsedMilliseconds ?? 0);
    }
}
```

### Registro global

```csharp
// Program.cs — se aplica a TODOS los endpoints
builder.Services.AddControllers(options =>
{
    options.Filters.Add<ApiTimingFilter>();                       // [!code highlight]
});
```

### Otros filtros habituales

| Filtro | Uso |
|--------|-----|
| `ApiTimingFilter` | Medir duración de endpoints |
| `CustomModelStateErrorFilter` | Reformatear errores de validación |
| `AuthorizationFilter` | Verificar permisos personalizados |
| `ExceptionFilter` | Capturar excepciones no controladas |

## 5.8 Tests de integración con `WebApplicationFactory`

Los tests de integración arrancan la aplicación real y hacen peticiones HTTP contra ella:

### Factory de tests

```csharp
// CursoTest/Integration/OpenApiAndScalarIntegrationTests.cs
public class CursoAppFactory : WebApplicationFactory<Program>
{
    protected override IHost CreateHost(IHostBuilder builder)
    {
        builder.UseEnvironment("Staging");                       // [!code highlight]
        return base.CreateHost(builder);
    }
}
```

::: info ¿POR QUÉ STAGING?
Usamos `Staging` en los tests porque OpenAPI y Scalar solo se activan en `Development` y `Staging`. Si usáramos `Production`, los endpoints no existirían y los tests fallarían.
:::

### Test: OpenAPI disponible

```csharp
public class OpenApiAndScalarIntegrationTests
    : IClassFixture<CursoAppFactory>
{
    private readonly CursoAppFactory _factory;

    public OpenApiAndScalarIntegrationTests(CursoAppFactory factory)
        => _factory = factory;

    [Fact]
    public async Task OpenApiEndpoint_Disponible_EnEntornoStaging()
    {
        using var client = _factory.CreateClient();

        // Intentar varias rutas posibles (base path puede variar)
        var response = await GetFirstSuccessful(client,
            "/openapi/v1.json",
            "/CursoNormalizacionApps/openapi/v1.json");

        Assert.True(response.IsSuccessStatusCode);               // [!code highlight]
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("openapi", content,                      // [!code highlight]
            StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task ScalarUi_Disponible_EnEntornoStaging()
    {
        using var client = _factory.CreateClient();

        var response = await GetFirstSuccessful(client,
            "/scalar",
            "/CursoNormalizacionApps/scalar");

        Assert.True(response.IsSuccessStatusCode);
        var contentType = response.Content.Headers.ContentType
            ?.MediaType ?? string.Empty;
        Assert.Contains("text/html", contentType,                // [!code highlight]
            StringComparison.OrdinalIgnoreCase);
    }

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
}
```

### ¿Qué validan estos tests?

| Test | Valida |
|------|--------|
| `OpenApiEndpoint_Disponible` | Que `/openapi/v1.json` devuelve 200 y contiene "openapi" |
| `ScalarUi_Disponible` | Que `/scalar` devuelve 200 con content-type `text/html` |

::: tip HELPER GetFirstSuccessful
La app puede tener un base path (`/CursoNormalizacionApps`) o no, según la configuración. El helper prueba varias rutas y devuelve la primera que funciona. Esto hace los tests robustos ante cambios de despliegue.
:::

## 5.9 httpRepl: probar la API desde terminal

`httpRepl` es una herramienta CLI de Microsoft para explorar y probar APIs:

```bash
# Instalar (una sola vez)
dotnet tool install -g Microsoft.dotnet-httprepl

# Conectar a la app
httprepl https://localhost:5001

# Explorar endpoints
ls                                    # Ver rutas disponibles
cd api/Unidades                       # Navegar a un recurso

# Probar GET
get                                   # GET /api/Unidades
get 1                                 # GET /api/Unidades/1
get datatable?primerregistro=0&numeroregistros=5  # DataTable

# Probar POST
post --content "{ \"nombreEs\":\"Unidad IA\", \"nombreCa\":\"Unitat IA\", \"nombreEn\":\"AI Unit\", \"granularidad\":15, \"duracionMax\":\"60\", \"numCitasSimultaneas\":2 }"

# Salir
exit
```

::: tip ALTERNATIVAS
Si prefieres herramientas gráficas, puedes usar **Postman**, **Scalar** (la propia UI del proyecto) o la extensión **REST Client** de VS Code con ficheros `.http`.
:::

## 5.10 Resumen del ciclo completo

```
                    ┌─────────────────────────┐
                    │       DESARROLLO        │
                    │                         │
┌───────────┐      │  1. Crear endpoint       │      ┌──────────────┐
│ Modelo    │──────▶│  2. Añadir [Produces]   │──────▶│  OpenAPI JSON │
│ (DTO)     │      │  3. Implementar lógica   │      │  /openapi/v1 │
└───────────┘      │  4. FluentValidation     │      └──────┬───────┘
                    │  5. Result<T> + i18n     │             │
                    └─────────────────────────┘             ▼
                                                    ┌──────────────┐
┌───────────┐      ┌─────────────────────────┐      │   Scalar UI  │
│ xUnit     │──────│       TESTING           │      │   /scalar    │
│ Tests     │      │                         │      └──────────────┘
└───────────┘      │  - Unit (FakeService)   │
                    │  - Integration (Factory)│      ┌──────────────┐
                    │  - httpRepl / Postman   │──────▶│  Frontend    │
                    └─────────────────────────┘      │  (Vue 3)    │
                                                    └──────────────┘
```

## Preguntas de repaso

### Pregunta 1

**¿Qué diferencia hay entre `AddOpenApi()` y Swashbuckle?**

a) Son lo mismo, solo cambia el nombre
b) `AddOpenApi()` es nativo de .NET 9+ y no requiere NuGet adicional; Swashbuckle es un paquete externo más pesado
c) Swashbuckle es más moderno que `AddOpenApi()`
d) `AddOpenApi()` solo funciona con Swagger UI

::: details Respuesta
**b)** `AddOpenApi()` es el soporte nativo de OpenAPI en ASP.NET Core 9+. Swashbuckle es un paquete NuGet externo que fue el estándar durante años pero es más pesado. En el curso usamos `AddOpenApi()` nativo + Scalar como visualizador.
:::

### Pregunta 2

**¿Qué atributo usamos para documentar que un endpoint puede devolver 500 con `ProblemDetails`?**

a) `[Produces("application/json")]`
b) `[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]`
c) `[Route("500")]`
d) `[ApiExplorerSettings(IgnoreApi = false)]`

::: details Respuesta
**b)** `[ProducesResponseType(typeof(ProblemDetails), 500)]` indica a OpenAPI que este endpoint puede devolver un 500 con el esquema `ProblemDetails`. Scalar mostrará esta información al explorar la API.
:::

### Pregunta 3

**¿Por qué OpenAPI y Scalar solo se activan en Development/Staging?**

a) Porque no funcionan en producción
b) Para evitar revelar la estructura interna de la API en producción
c) Porque requieren más memoria en producción
d) Porque el frontend no los necesita

::: details Respuesta
**b)** En producción, exponer el documento OpenAPI revela todos los endpoints, parámetros y modelos de la API, lo que puede facilitar ataques. Solo se activan en entornos de desarrollo y pruebas.
:::

### Pregunta 4

**¿Cuál es la ventaja del patrón GET comprobación + POST ejecución?**

a) Es más rápido que un POST directo
b) Permite verificar si una operación es posible antes de ejecutarla, usando un token de confirmación
c) Evita tener que validar en el servidor
d) Es obligatorio en .NET Core

::: details Respuesta
**b)** El GET comprueba si la operación es posible (ej: ¿tiene dependencias?) y devuelve un token. El POST usa ese token para ejecutar la operación, evitando ejecuciones accidentales o sin comprobación previa.
:::

### Pregunta 5

**¿Qué valida el test `OpenApiEndpoint_Disponible_EnEntornoStaging`?**

a) Que los endpoints de la API devuelven 200
b) Que el documento OpenAPI JSON está disponible y contiene la palabra "openapi"
c) Que Scalar renderiza correctamente
d) Que la API acepta peticiones POST

::: details Respuesta
**b)** El test usa `WebApplicationFactory` para arrancar la app en `Staging`, hace un GET a `/openapi/v1.json`, verifica que devuelve 200, y comprueba que el contenido contiene "openapi" (indicando que es un documento OpenAPI válido).
:::

### Pregunta 6

**¿Por qué `CursoAppFactory` usa `UseEnvironment("Staging")`?**

a) Porque Staging es más rápido que Development
b) Porque OpenAPI y Scalar solo se activan en Development y Staging, y necesitamos que existan para testearlos
c) Porque Production no permite tests
d) Porque la base de datos solo está disponible en Staging

::: details Respuesta
**b)** Los tests de integración necesitan que OpenAPI y Scalar estén activos para poder verificar su disponibilidad. Como solo se activan en `Development` y `Staging` (por la condición `if (app.Environment.IsDevelopment() || app.Environment.IsStaging())`), el factory fuerza `Staging`.
:::

### Pregunta 7

**¿Qué pasa si configuras `PropertyNamingPolicy = null` en las opciones JSON?**

a) Las propiedades se serializan en minúsculas
b) Las propiedades se serializan tal como están en C# (PascalCase)
c) Se usa snake_case automáticamente
d) La serialización falla

::: details Respuesta
**b)** Con `PropertyNamingPolicy = null`, System.Text.Json serializa las propiedades exactamente como están declaradas en C# (PascalCase). El default de .NET es `CamelCase`, que convierte `NombreEs` → `nombreEs`.
:::

### Pregunta 8

**¿Dónde se valida el formato de un DTO (campos obligatorios, longitudes) y dónde las reglas de negocio (token válido, permisos)?**

a) Ambas en el controlador
b) Formato en FluentValidation (DTO), reglas de negocio en el servicio con Result\<T\>
c) Formato en la base de datos, reglas de negocio en el frontend
d) Ambas en el servicio

::: details Respuesta
**b)** FluentValidation valida el **formato** del DTO (campos obligatorios, rangos, longitudes) y devuelve `ValidationProblemDetails` (400). Las **reglas de negocio** (token válido, sin dependencias, permisos) se validan en el servicio y se devuelven como `Result.Failure` que `HandleResult` mapea al código HTTP adecuado.
:::

## Ejercicio Sesión 5

**Objetivo:** Configurar OpenAPI + Scalar, documentar endpoints con `ProducesResponseType`, crear tests de integración y probar con httpRepl.

1. Verificar que `AddOpenApi()` y `MapScalarApiReference("/scalar")` están en `Program.cs`
2. Añadir `[ProducesResponseType]` a los endpoints de `UnidadesController` (200, 400, 500)
3. Crear un endpoint `GET /api/unidades/{id}/puede-eliminar` que devuelva `ClaseComprobacionOperacion`
4. Crear un test de integración con `WebApplicationFactory` que verifique la disponibilidad de `/openapi/v1.json`
5. Probar los endpoints con httpRepl o Scalar

::: details Solución

**Program.cs (verificar):**

```csharp
using Scalar.AspNetCore;

builder.Services.AddOpenApi();

if (app.Environment.IsDevelopment() || app.Environment.IsStaging())
{
    app.MapOpenApi().AllowAnonymous();
    app.MapScalarApiReference("/scalar").AllowAnonymous();
}
```

**Documentar endpoints en UnidadesController:**

```csharp
[HttpGet("{id}")]
[ProducesResponseType(typeof(ClaseUnidad), StatusCodes.Status200OK)]
[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
public ActionResult ObtenerPorId(int id, [FromQuery] string idioma = "ES")
    => HandleResult(_unidades.ObtenerPorId(id, idioma));

[HttpPost]
[ProducesResponseType(typeof(int), StatusCodes.Status200OK)]
[ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
public ActionResult Guardar([FromBody] ClaseGuardarUnidad dto) { ... }
```

**Test de integración:**

```csharp
public class CursoAppFactory : WebApplicationFactory<Program>
{
    protected override IHost CreateHost(IHostBuilder builder)
    {
        builder.UseEnvironment("Staging");
        return base.CreateHost(builder);
    }
}

public class OpenApiTests : IClassFixture<CursoAppFactory>
{
    private readonly CursoAppFactory _factory;
    public OpenApiTests(CursoAppFactory factory) => _factory = factory;

    [Fact]
    public async Task OpenApi_Disponible()
    {
        using var client = _factory.CreateClient();
        var response = await client.GetAsync("/openapi/v1.json");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("openapi", content, StringComparison.OrdinalIgnoreCase);
    }
}
```
:::

::: details Código con fallos para Copilot

```csharp
// ⚠️ CÓDIGO CON FALLOS - Usa Copilot para encontrar y arreglar los errores

// 🐛 Falta using Scalar.AspNetCore
var builder = WebApplication.CreateBuilder(args);

// 🐛 No registra AddOpenApi()

var app = builder.Build();

// 🐛 OpenAPI activo en TODOS los entornos (incluido producción)
app.MapOpenApi();
app.MapScalarApiReference("/scalar");

// 🐛 Endpoint sin documentación OpenAPI
[HttpPost("{id}/eliminar")]
public IActionResult Eliminar(int id)
{
    // 🐛 No hay comprobación previa (falta GET puede-eliminar)
    // 🐛 No recibe ni valida token de operación
    var ok = _servicio.Eliminar(id);
    // 🐛 Devuelve texto plano en error, no ProblemDetails
    if (!ok) return StatusCode(500, "No se pudo eliminar");
    return Ok();
}

// 🐛 Test sin WebApplicationFactory (prueba contra servidor real)
[Fact]
public async Task TestOpenApi()
{
    // 🐛 Hardcoded a localhost — no funciona en CI/CD
    var client = new HttpClient();
    var response = await client.GetAsync("https://localhost:5001/openapi/v1.json");
    // 🐛 No verifica contenido, solo status code
    Assert.Equal(200, (int)response.StatusCode);
}
```
:::

---

## Referencias oficiales

- [OpenAPI en ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/aspnetcore-openapi)
- [Metadata OpenAPI (Produces, tags)](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/include-metadata)
- [Manejo de errores API y ProblemDetails](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/error-handling-api)
- [Filtros en controladores API/MVC](https://learn.microsoft.com/en-us/aspnet/core/mvc/controllers/filters)
- [Formato JSON camel/pascal en Web API](https://learn.microsoft.com/en-us/aspnet/core/web-api/advanced/formatting)
- [httpRepl](https://learn.microsoft.com/es-es/aspnet/core/web-api/http-repl)

---

## Tests y práctica IA

- [Ver tests y práctica de la sesión](../../test/sesion-5/)
- [Autoevaluación sesión 5](../../test/sesion-5/autoevaluacion.md)
- [Preguntas de test sesión 5](../../test/sesion-5/preguntas.md)
- [Respuestas del test sesión 5](../../test/sesion-5/respuestas.md)
- [Práctica IA-fix sesión 5](../../test/sesion-5/practica-ia-fix.md)

---

**Anterior:** [Sesión 4: DataTable server-side](../sesion-4-datatable-clasecrud/) | **Inicio:** [APIs en .NET Core 10](../../index.md)
