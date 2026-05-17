# Práctica IA-fix — Sesión 5

## Objetivo

Corregir la configuración de OpenAPI/Scalar, la documentación de endpoints y un test de integración con múltiples errores. Usa Copilot o Claude para identificar y arreglar todos los fallos.

## Código con errores

```csharp
// ⚠️ CÓDIGO CON 10 ERRORES - Encuentra y corrige todos

// ─── Program.cs ───

// ERROR 1: Falta using Scalar.AspNetCore
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();
// ERROR 2: No registra AddOpenApi() — Scalar no tiene esquema que mostrar

var app = builder.Build();

// ERROR 3: OpenAPI y Scalar expuestos en TODOS los entornos (incluido producción)
app.MapOpenApi();
app.MapScalarApiReference(options =>
{
    options.WithTitle("CursoNormalizacionApps API");
});

app.MapControllers();
app.Run();

// ─── RecursosController.cs ───

[ApiController]
[Route("api/[controller]")]
public class RecursosController : ControllerBase
{
    private readonly IClaseRecursos _servicio;

    public RecursosController(IClaseRecursos servicio) => _servicio = servicio;

    // ERROR 4: No hereda de ApiControllerBase (no tiene HandleResult)
    // ERROR 5: Sin atributos [ProducesResponseType] — OpenAPI no documenta respuestas
    [HttpGet]
    public IActionResult Listar()
    {
        var resultado = _servicio.ObtenerActivos();
        // ERROR 6: Manejo manual de Result en vez de HandleResult
        if (resultado.IsSuccess)
            return Ok(resultado.Value);
        return StatusCode(500, resultado.Error.Message); // texto plano, no ProblemDetails
    }

    [HttpPost("{id}/eliminar")]
    public IActionResult Eliminar(int id)
    {
        // ERROR 7: No hay patrón GET comprobación + POST ejecución
        //          Ejecuta directamente sin verificar si se puede eliminar
        var ok = _servicio.Eliminar(id);
        if (!ok) return StatusCode(500, "No se pudo eliminar");
        return Ok();
    }
}

// ─── Test de integración ───

// ERROR 8: No usa IClassFixture<WebApplicationFactory> — no arranca app en memoria
public class OpenApiTests
{
    [Fact]
    public async Task OpenApi_Disponible()
    {
        // ERROR 9: Crea HttpClient contra servidor real (no funciona en CI/CD)
        var client = new HttpClient();
        var response = await client.GetAsync("https://localhost:5001/openapi/v1.json");

        // ERROR 10: Solo verifica status code, no verifica que el JSON contenga "openapi"
        Assert.Equal(200, (int)response.StatusCode);
    }
}
```

## Rúbrica de evaluación (10 puntos)

| Criterio | Puntos | Descripción |
|----------|--------|-------------|
| `using Scalar.AspNetCore` | 0.5 | Añadir el using necesario |
| `AddOpenApi()` registrado | 1 | `builder.Services.AddOpenApi()` antes de `Build()` |
| OpenAPI solo en Development | 1 | Envolver con `if (app.Environment.IsDevelopment())` |
| Heredar `ApiControllerBase` | 1 | Cambiar `ControllerBase` por `ApiControllerBase` |
| `[ProducesResponseType]` | 1.5 | Documentar 200/400/500 en cada endpoint |
| `HandleResult` en Listar | 1 | Reemplazar manejo manual por `HandleResult(resultado)` |
| Patrón GET comprobación | 1 | Añadir `GET {id}/puede-eliminar` con `Result<bool>` |
| POST con token operación | 1 | Recibir y validar token en el POST de eliminar |
| `WebApplicationFactory` | 1 | Usar `IClassFixture<WebApplicationFactory<Program>>` |
| Verificar contenido JSON | 0.5 | `Assert.Contains("openapi", content)` |

## Qué debe arreglar la IA

### 1. Program.cs — Configuración

- Añadir `using Scalar.AspNetCore;`
- Registrar `builder.Services.AddOpenApi()` en el contenedor de servicios
- Envolver `MapOpenApi()` y `MapScalarApiReference()` dentro de `if (app.Environment.IsDevelopment())` para no exponer en producción

### 2. Controlador — Herencia y documentación

- Heredar de `ApiControllerBase` en vez de `ControllerBase` para tener acceso a `HandleResult<T>()`
- Añadir atributos `[ProducesResponseType]` en cada método:
  ```csharp
  [ProducesResponseType(typeof(List<ClaseRecurso>), 200)]
  [ProducesResponseType(typeof(ProblemDetails), 500)]
  ```
- Reemplazar el manejo manual de `Result<T>` por `return HandleResult(resultado)`

### 3. Controlador — Patrón GET/POST para eliminar

- Crear `GET {id}/puede-eliminar` que verifique permisos/dependencias y devuelva un token
- Modificar `POST {id}/eliminar` para recibir el token de la comprobación previa
- Devolver `ProblemDetails` en errores (no texto plano)

### 4. Test de integración

- Implementar `IClassFixture<WebApplicationFactory<Program>>` para arrancar la app en memoria
- Usar `_factory.CreateClient()` en vez de `new HttpClient()` con URL hardcoded
- Verificar que el JSON de respuesta contiene la clave `"openapi"`, no solo el status code

## Solución corregida

::: details Ver solución completa

```csharp
// ─── Program.cs ───
using Scalar.AspNetCore; // ✅ Fix 1

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();
builder.Services.AddOpenApi(); // ✅ Fix 2

var app = builder.Build();

// ✅ Fix 3: Solo en Development
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference(options =>
    {
        options.WithTitle("CursoNormalizacionApps API");
    });
}

app.MapControllers();
app.Run();

// ─── RecursosController.cs ───

[ApiController]
[Route("api/[controller]")]
public class RecursosController : ApiControllerBase // ✅ Fix 4
{
    private readonly IClaseRecursos _servicio;

    public RecursosController(IClaseRecursos servicio) => _servicio = servicio;

    [HttpGet]
    [ProducesResponseType(typeof(List<ClaseRecurso>), 200)]  // ✅ Fix 5
    [ProducesResponseType(typeof(ProblemDetails), 500)]
    public IActionResult Listar()
    {
        var resultado = _servicio.ObtenerActivos();
        return HandleResult(resultado); // ✅ Fix 6
    }

    // ✅ Fix 7a: GET comprobación
    [HttpGet("{id}/puede-eliminar")]
    [ProducesResponseType(typeof(ResultadoComprobacion), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 500)]
    public IActionResult PuedeEliminar(int id)
    {
        var comprobacion = _servicio.ComprobarEliminacion(id);
        return HandleResult(comprobacion);
    }

    // ✅ Fix 7b: POST ejecución con token
    [HttpPost("{id}/eliminar")]
    [ProducesResponseType(200)]
    [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 500)]
    public IActionResult Eliminar(int id, [FromBody] ClaseTokenOperacion token)
    {
        var resultado = _servicio.Eliminar(id, token.Token);
        return HandleResult(resultado); // ProblemDetails automático
    }
}

// ─── Test de integración ───

// ✅ Fix 8: WebApplicationFactory en memoria
public class RecursosApiFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Staging");
    }
}

public class OpenApiTests : IClassFixture<RecursosApiFactory>
{
    private readonly RecursosApiFactory _factory;
    public OpenApiTests(RecursosApiFactory factory) => _factory = factory;

    [Fact]
    public async Task OpenApi_Disponible()
    {
        // ✅ Fix 9: Cliente in-memory
        using var client = _factory.CreateClient();
        var response = await client.GetAsync("/openapi/v1.json");

        Assert.True(response.IsSuccessStatusCode);
        // ✅ Fix 10: Verificar contenido
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("openapi", content, StringComparison.OrdinalIgnoreCase);
    }
}
```

:::
