---
title: "Solución del ejercicio: Observaciones con servicio + tests (sesión 2)"
description: "Cierre del ejercicio de §1.9 conectado a Oracle vía un servicio real, con sus dos tests."
---

# Solución del ejercicio §2.6 — Observaciones con servicio + tests (sesión 2)

::: warning ESTO ES LA SOLUCIÓN
Compárala con la tuya **después** de intentarlo. Antes, mira `TiposRecursoServicio` / `RecursosServicio` y deriva el patrón por tu cuenta. La sesión 3 (Validación + Errores) sigue desde aquí, así que la nomenclatura tiene que coincidir.
:::

## Estructura

Siete ficheros en juego: **cuatro nuevos** en `uaReservas`, **uno modificado** (`Program.cs`), **dos nuevos** en `uaReservas.Tests`.

```
uaReservas/
├── Services/Reservas/
│   ├── IObservacionesServicio.cs            ← NUEVO
│   └── ObservacionesServicio.cs              ← NUEVO
├── Controllers/Apis/
│   └── ObservacionesController.cs            ← MODIFICADO (borrar _datos, delegar)
└── Program.cs                                 ← MODIFICADO (1 línea)

uaReservas.Tests/
├── Infraestructura/
│   └── FakeObservacionesServicio.cs           ← NUEVO
├── Controllers/
│   └── ObservacionesControllerSimuladoTests.cs ← NUEVO
└── Servicios/
    └── ObservacionesServicioRealTests.cs       ← NUEVO
```

---

## 1. `Services/Reservas/IObservacionesServicio.cs`

```csharp
using ua.Models.Errors;
using ua.Models.Reservas;

namespace uaReservas.Services.Reservas
{
    /// <summary>
    /// Servicio de Observaciones de reserva. Lecturas contra
    /// VRES_OBSERVACION_RESERVA; escrituras vía PKG_RES_OBSERVACION_RESERVA.
    ///
    /// El parámetro codperAutor de CrearAsync viene del JWT (CodPer en
    /// ControladorBase). El servicio NO sabe nada del HttpContext: es el
    /// controlador quien rellena ese argumento. Así el servicio es
    /// testeable sin levantar el pipeline HTTP.
    /// </summary>
    public interface IObservacionesServicio
    {
        Task<Result<List<ObservacionReservaLectura>>> ObtenerTodosAsync(string idioma);
        Task<Result<ObservacionReservaLectura>>       ObtenerPorIdAsync(int idObs, string idioma);
        Task<Result<int>>                              CrearAsync(int codperAutor, ObservacionReservaCrearDto dto);
        Task<Result<bool>>                             EliminarAsync(int idObs);
    }
}
```

---

## 2. `Services/Reservas/ObservacionesServicio.cs`

Es **calco** de `TiposRecursoServicio` con dos diferencias: el campo `Texto` viaja resuelto al idioma (no los tres a la vez), y `CrearAsync` recibe `codperAutor` por parámetro.

```csharp
using System.Data;
using ua;
using ua.Models.Errors;
using ua.Models.Reservas;

namespace uaReservas.Services.Reservas
{
    public class ObservacionesServicio : IObservacionesServicio
    {
        private readonly IClaseOracleBd _bd;
        private readonly ILogger<ObservacionesServicio> _logger;

        // SIEMPRE leemos por la vista (filtra ACTIVO='S').
        private const string VISTA = "CURSONORMADM.VRES_OBSERVACION_RESERVA";

        public ObservacionesServicio(IClaseOracleBd bd, ILogger<ObservacionesServicio> logger)
        {
            _bd = bd;
            _logger = logger;
        }

        // ============================================================
        //  LECTURAS
        // ============================================================

        public async Task<Result<List<ObservacionReservaLectura>>> ObtenerTodosAsync(string idioma)
        {
            var idiomaNormalizado = NormalizarIdioma(idioma);

            // ORDER BY FECHA_ALTA DESC: la más reciente primero.
            // Texto se resuelve a TEXTO_{idioma} automaticamente por ClaseOracleBD3.
            var sql = $@"
                SELECT ID_OBSERVACION_RESERVA, ID_RESERVA, CODPER_AUTOR,
                       TEXTO_ES, TEXTO_CA, TEXTO_EN, FECHA_ALTA
                  FROM {VISTA}
                 ORDER BY FECHA_ALTA DESC";

            var filas = await _bd.ObtenerTodosMapAsync<ObservacionReservaLectura>(
                sql, param: null, idioma: idiomaNormalizado);

            return Result<List<ObservacionReservaLectura>>.Success(
                filas?.ToList() ?? new List<ObservacionReservaLectura>());
        }

        public async Task<Result<ObservacionReservaLectura>> ObtenerPorIdAsync(int idObs, string idioma)
        {
            var idiomaNormalizado = NormalizarIdioma(idioma);

            const string sql = @"
                SELECT ID_OBSERVACION_RESERVA, ID_RESERVA, CODPER_AUTOR,
                       TEXTO_ES, TEXTO_CA, TEXTO_EN, FECHA_ALTA
                  FROM CURSONORMADM.VRES_OBSERVACION_RESERVA
                 WHERE ID_OBSERVACION_RESERVA = :id";

            var fila = await _bd.ObtenerPrimeroMapAsync<ObservacionReservaLectura>(
                sql, new { id = idObs }, idioma: idiomaNormalizado);

            return fila is null
                ? Result<ObservacionReservaLectura>.NotFound(
                    "OBSERVACION_NO_ENCONTRADA",
                    $"No existe una observacion con id {idObs}.",
                    idObs)
                : Result<ObservacionReservaLectura>.Success(fila);
        }

        // ============================================================
        //  ESCRITURAS (via PKG_RES_OBSERVACION_RESERVA)
        // ============================================================

        public async Task<Result<int>> CrearAsync(int codperAutor, ObservacionReservaCrearDto dto)
        {
            var p = new DynamicParameters();
            p.Add("P_ID_RESERVA",     dto.IdReserva);
            p.Add("P_CODPER_AUTOR",   codperAutor);              // ← del token, NUNCA del body
            p.Add("P_TEXTO_ES",       dto.TextoEs);
            p.Add("P_TEXTO_CA",       dto.TextoCa);
            p.Add("P_TEXTO_EN",       dto.TextoEn);
            p.Add("P_ID_OBSERVACION_RESERVA", null, direccion: ParameterDirection.Output);
            p.Add("P_CODIGO_ERROR",           null, direccion: ParameterDirection.Output);
            p.Add("P_MENSAJE_ERROR",          null, direccion: ParameterDirection.Output);

            await _bd.EjecutarParamsAsync("CURSONORMADM.PKG_RES_OBSERVACION_RESERVA.CREAR", p);

            // Traduce el OUT a Result.{NotFound|Validation|Fail} si toca.
            var failure = ErrorPaquetePlSql.AResultFailure<int>(
                ErrorPaquetePlSql.LeerInt   (p, "P_CODIGO_ERROR"),
                ErrorPaquetePlSql.LeerString(p, "P_MENSAJE_ERROR"));
            if (failure is not null) return failure;

            return Result<int>.Success(ErrorPaquetePlSql.LeerInt(p, "P_ID_OBSERVACION_RESERVA"));
        }

        public async Task<Result<bool>> EliminarAsync(int idObs)
        {
            var p = new DynamicParameters();
            p.Add("P_ID_OBSERVACION_RESERVA", idObs);
            p.Add("P_CODIGO_ERROR",  null, direccion: ParameterDirection.Output);
            p.Add("P_MENSAJE_ERROR", null, direccion: ParameterDirection.Output);

            await _bd.EjecutarParamsAsync("CURSONORMADM.PKG_RES_OBSERVACION_RESERVA.ELIMINAR", p);

            var failure = ErrorPaquetePlSql.AResultFailure<bool>(
                ErrorPaquetePlSql.LeerInt   (p, "P_CODIGO_ERROR"),
                ErrorPaquetePlSql.LeerString(p, "P_MENSAJE_ERROR"));
            return failure ?? Result<bool>.Success(true);
        }

        // ============================================================
        //  Helpers
        // ============================================================

        private static string NormalizarIdioma(string idioma)
        {
            var limpio = (idioma ?? "es").Trim().ToUpperInvariant();
            if (limpio == "VA") limpio = "CA";
            return limpio is "ES" or "CA" or "EN" ? limpio : "ES";
        }
    }
}
```

::: info CONTEXTO — el contrato de errores del paquete
`ErrorPaquetePlSql.AResultFailure<T>(codigo, mensaje)` mira el `P_CODIGO_ERROR` que devolvió el paquete y decide el tipo de `Result`:

| Códigos                                                              | Devuelve                    | HTTP final |
| -------------------------------------------------------------------- | --------------------------- | ---------- |
| `0`                                                                  | `null` (no es failure)      | (continúa) |
| `-20003`, `-20307`, `-20702`                                         | `Result<T>.NotFound(...)`   | 404        |
| `-20001`, `-20002`, `-20301..-20306`, `-20308`, `-20700`, `-20701`, `-20703` | `Result<T>.Validation(...)` | 400 |
| Cualquier otro                                                       | `Result<T>.Fail(...)`       | 500        |

Si tu paquete `PKG_RES_OBSERVACION_RESERVA` añade un `RAISE_APPLICATION_ERROR` nuevo (por ejemplo `-20710 "Reserva inexistente"`), recuerda añadirlo al `switch` de `ErrorPaquetePlSql.DesdeCodigo` para que reciba el `ErrorType` adecuado.
:::

---

## 3. `Controllers/Apis/ObservacionesController.cs` (reescrito)

Borra el `_datos` estático. El controlador queda en **una línea por acción** salvo `Crear` (necesita `CreatedAtAction`).

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ua.Models.Reservas;
using uaReservas.Services.Reservas;

namespace uaReservas.Controllers.Apis
{
    /// <summary>
    /// API REST para las observaciones de reservas (TRES_OBSERVACION_RESERVA).
    ///
    /// Lecturas contra VRES_OBSERVACION_RESERVA (vista filtrada ACTIVO='S').
    /// Escrituras vía PKG_RES_OBSERVACION_RESERVA.{CREAR,ELIMINAR}.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    [Produces("application/json")]
    [Tags("Observaciones")]
    public class ObservacionesController : ControladorBase
    {
        private readonly IObservacionesServicio _observaciones;
        public ObservacionesController(IObservacionesServicio observaciones) =>
            _observaciones = observaciones;

        // ===== LECTURA =====

        /// <summary>Lista todas las observaciones, resueltas al idioma del usuario.</summary>
        [HttpGet]
        [ProducesResponseType<List<ObservacionReservaLectura>>(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult> Listar() =>
            HandleResult(await _observaciones.ObtenerTodosAsync(Idioma));

        /// <summary>Devuelve una observación por su id.</summary>
        [HttpGet("{id:int}")]
        [ProducesResponseType<ObservacionReservaLectura>(StatusCodes.Status200OK)]
        [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult> ObtenerPorId([FromRoute] int id) =>
            HandleResult(await _observaciones.ObtenerPorIdAsync(id, Idioma));

        // ===== ESCRITURA =====

        /// <summary>Crea una observación. CodperAutor se toma del JWT.</summary>
        [HttpPost]
        [ProducesResponseType<int>(StatusCodes.Status201Created)]
        [ProducesResponseType<ValidationProblemDetails>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<ActionResult> Crear([FromBody] ObservacionReservaCrearDto dto)
        {
            // CodperAutor SIEMPRE de CodPer (ControladorBase, del JWT), NUNCA del body.
            var resultado = await _observaciones.CrearAsync(CodPer, dto);
            if (!resultado.IsSuccess) return HandleResult(resultado);

            return CreatedAtAction(nameof(ObtenerPorId),
                                   new { id = resultado.Value },
                                   resultado.Value);
        }

        /// <summary>Borra una observación (soft: ACTIVO='N').</summary>
        [HttpDelete("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound)]
        public async Task<ActionResult> Eliminar([FromRoute] int id)
        {
            var resultado = await _observaciones.EliminarAsync(id);
            if (!resultado.IsSuccess) return HandleResult(resultado);

            return NoContent();
        }
    }
}
```

---

## 4. `Program.cs` (una línea añadida)

Justo después de los `AddScoped` de los otros servicios:

```csharp
builder.Services.AddScoped<uaReservas.Services.Reservas.ITiposRecursoServicio,
                           uaReservas.Services.Reservas.TiposRecursoServicio>();
builder.Services.AddScoped<uaReservas.Services.Reservas.IRecursosServicio,
                           uaReservas.Services.Reservas.RecursosServicio>();
builder.Services.AddScoped<uaReservas.Services.Reservas.IReservasServicio,
                           uaReservas.Services.Reservas.ReservasServicio>();

// Anyade esta linea:
builder.Services.AddScoped<uaReservas.Services.Reservas.IObservacionesServicio,
                           uaReservas.Services.Reservas.ObservacionesServicio>();
```

---

## 5. `uaReservas.Tests/Infraestructura/FakeObservacionesServicio.cs`

Clon de `FakeTiposRecursoServicio`. Mismas listas "huella" para que los tests asserten lo que llegó al servicio.

```csharp
using ua.Models.Errors;
using ua.Models.Reservas;
using uaReservas.Services.Reservas;

namespace uaReservas.Tests.Infraestructura
{
    public class FakeObservacionesServicio : IObservacionesServicio
    {
        // Datos pre-cargados por cada test:
        public List<ObservacionReservaLectura> ListaParaDevolver { get; set; } = new();
        public ObservacionReservaLectura?      LecturaParaDevolver { get; set; }

        // Huella para asserts:
        public List<string> IdiomasPedidos   { get; } = new();
        public List<int>    IdsPedidos       { get; } = new();
        public List<int>    CodPersRecibidos { get; } = new();

        public List<ObservacionReservaCrearDto> CreadosRecibidos  { get; } = new();
        public List<int>                         EliminadosRecibidos { get; } = new();

        // Resultados configurables (si están a null, devuelve Success):
        public Result<int>?  ResultadoCrear    { get; set; }
        public Result<bool>? ResultadoEliminar { get; set; }
        public int IdGeneradoEnCrear { get; set; } = 1;

        public Task<Result<List<ObservacionReservaLectura>>> ObtenerTodosAsync(string idioma)
        {
            IdiomasPedidos.Add(idioma);
            return Task.FromResult(Result<List<ObservacionReservaLectura>>.Success(ListaParaDevolver));
        }

        public Task<Result<ObservacionReservaLectura>> ObtenerPorIdAsync(int idObs, string idioma)
        {
            IdiomasPedidos.Add(idioma);
            IdsPedidos.Add(idObs);

            return Task.FromResult(LecturaParaDevolver is null
                ? Result<ObservacionReservaLectura>.NotFound(
                      "OBSERVACION_NO_ENCONTRADA",
                      $"No existe una observacion con id {idObs}.")
                : Result<ObservacionReservaLectura>.Success(LecturaParaDevolver));
        }

        public Task<Result<int>> CrearAsync(int codperAutor, ObservacionReservaCrearDto dto)
        {
            CodPersRecibidos.Add(codperAutor);
            CreadosRecibidos.Add(dto);
            return Task.FromResult(ResultadoCrear ?? Result<int>.Success(IdGeneradoEnCrear));
        }

        public Task<Result<bool>> EliminarAsync(int idObs)
        {
            EliminadosRecibidos.Add(idObs);
            return Task.FromResult(ResultadoEliminar ?? Result<bool>.Success(true));
        }
    }
}
```

---

## 6. `uaReservas.Tests/Controllers/ObservacionesControllerSimuladoTests.cs`

Dos tests: que `Listar` delega y que `Crear` usa el `CodPer` del token (chequeo de seguridad).

```csharp
using Microsoft.AspNetCore.Mvc;
using ua.Models.Reservas;
using uaReservas.Controllers.Apis;
using uaReservas.Tests.Infraestructura;
using Xunit;

namespace uaReservas.Tests.Controllers
{
    public class ObservacionesControllerSimuladoTests
    {
        private static (ObservacionesController controller, FakeObservacionesServicio fake)
            CrearControlador(string idiomaClaim = "es", int codPer = 12345)
        {
            var fake = new FakeObservacionesServicio();
            var controller = new ObservacionesController(fake)
            {
                ControllerContext = UsuarioFake.ConClaims(
                    idiomaClaim: idiomaClaim,
                    codPersona:  codPer)
            };
            return (controller, fake);
        }

        [Fact]
        public async Task Listar_DevuelveOk_ConLaListaDelServicio()
        {
            // ARRANGE
            var (controller, fake) = CrearControlador();
            fake.ListaParaDevolver =
            [
                new ObservacionReservaLectura { IdObservacionReserva = 1, IdReserva = 10, Texto = "nota A" },
                new ObservacionReservaLectura { IdObservacionReserva = 2, IdReserva = 10, Texto = "nota B" },
            ];

            // ACT
            var resultado = await controller.Listar();

            // ASSERT
            var ok    = Assert.IsType<OkObjectResult>(resultado);
            var lista = Assert.IsType<List<ObservacionReservaLectura>>(ok.Value);
            Assert.Equal(2, lista.Count);
        }

        [Fact]
        public async Task Crear_UsaElCodPerDelToken_NoElDelBody()
        {
            // ARRANGE: codPer del token = 12345. Si el body trajese otro codper,
            // tendria que ignorarlo (de hecho ObservacionReservaCrearDto no lo tiene).
            var (controller, fake) = CrearControlador(codPer: 12345);
            var dto = new ObservacionReservaCrearDto
            {
                IdReserva = 10,
                TextoEs   = "obs en es",
                TextoCa   = "obs en ca",
                TextoEn   = "obs en en",
            };

            // ACT
            await controller.Crear(dto);

            // ASSERT: el servicio recibió 12345 como codperAutor.
            Assert.Single(fake.CodPersRecibidos);
            Assert.Equal(12345, fake.CodPersRecibidos[0]);
            Assert.Single(fake.CreadosRecibidos);
            Assert.Equal("obs en es", fake.CreadosRecibidos[0].TextoEs);
        }
    }
}
```

---

## 7. `uaReservas.Tests/Servicios/ObservacionesServicioRealTests.cs`

Dos tests reales con `[SkippableFact]` — saltan si no hay cadena de conexión configurada.

```csharp
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using ua;
using ua.Models.Errors;
using uaReservas.Services.Reservas;
using uaReservas.Tests.Infraestructura;
using Xunit;

namespace uaReservas.Tests.Servicios
{
    public class ObservacionesServicioRealTests : IClassFixture<OracleTestFixture>
    {
        private readonly OracleTestFixture _fixture;
        public ObservacionesServicioRealTests(OracleTestFixture fixture) => _fixture = fixture;

        private ObservacionesServicio CrearServicio(out IServiceScope scope)
        {
            scope = _fixture.CrearScope();
            var bd = scope.ServiceProvider.GetRequiredService<IClaseOracleBd>();
            return new ObservacionesServicio(bd, NullLogger<ObservacionesServicio>.Instance);
        }

        [SkippableFact]
        public async Task ObtenerTodosAsync_DevuelveSuccess()
        {
            // ARRANGE
            Skip.IfNot(_fixture.HayConexion, _fixture.MotivoSinConexion);
            var servicio = CrearServicio(out var scope);
            using (scope)
            {
                // ACT
                var resultado = await servicio.ObtenerTodosAsync("es");

                // ASSERT: el SQL es valido y la vista existe.
                // No asumimos que haya datos: la lista puede estar vacía.
                Assert.True(resultado.IsSuccess);
                Assert.NotNull(resultado.Value);
            }
        }

        [SkippableFact]
        public async Task ObtenerPorIdAsync_DevuelveNotFound_SiElIdNoExiste()
        {
            Skip.IfNot(_fixture.HayConexion, _fixture.MotivoSinConexion);
            var servicio = CrearServicio(out var scope);
            using (scope)
            {
                // ACT
                var resultado = await servicio.ObtenerPorIdAsync(-9999, "es");

                // ASSERT: id imposible -> NotFound.
                Assert.False(resultado.IsSuccess);
                Assert.NotNull(resultado.Error);
                Assert.Equal(ErrorType.NotFound, resultado.Error!.Type);
            }
        }
    }
}
```

---

## Pruebas en vivo

1. `dotnet build` sin errores.
2. `dotnet test` ejecuta los **dos simulados** (rápido) y, si hay user-secrets configurado, los **dos reales** (lentos).
3. Arrancar la app y abrir Scalar (`/uareservas/scalar/`):
   - **`GET /api/Observaciones`** → 200 con la lista real de la BD.
   - **`POST /api/Observaciones`** con body válido → 201 + `Location: /api/Observaciones/{id}`.
   - **`POST /api/Observaciones`** con `idReserva = 999999` (no existe) → 500 o 400 según el `RAISE_APPLICATION_ERROR` que el paquete decida lanzar; lee el código `P_CODIGO_ERROR` en el log y comprueba que `ErrorPaquetePlSql.DesdeCodigo` lo clasifica correctamente.
   - **`DELETE /api/Observaciones/{id}`** → 204 (soft delete: la fila sigue ahí con `ACTIVO='N'`).
4. En `Home.vue`: el botón **`GET /api/Observaciones (ejercicio)`** ya pinta datos reales sin tocar Vue.

::: tip BUENA PRÁCTICA — qué fijarse al revisar
1. **`CrearAsync(codperAutor, dto)`** recibe el codper por parámetro. Si lo lees del `dto`, fallas la seguridad.
2. **`HandleResult(await ...)`** en todas las acciones excepto `Crear` (que necesita `CreatedAtAction`).
3. **`_datos` estático eliminado** del controlador. Si sigue ahí, no estás pasando por Oracle.
4. **`Program.cs` registra el servicio**: si no, la DI lanza `Unable to resolve service for type 'IObservacionesServicio'` en la primera petición.
5. **`FakeObservacionesServicio` implementa `IObservacionesServicio` completa**: si la interfaz crece, el fake tiene que crecer también.
:::

## Próximos pasos (sesión 3)

- Validación robusta con `FluentValidation` (los `[Required]`/`[MaxLength]` se quedan cortos cuando hay reglas cruzadas).
- Cómo añadir entradas nuevas a `Resources/SharedResource.{es,ca,en}.resx` para que `VALIDACION_TEXTO_ES_REQUERIDO` aparezca traducido.
- Cómo `useGestionFormularios.adaptarProblemDetails` muestra los errores campo a campo en el formulario Vue.
- Patrón completo Oracle → .NET → Vue del ejercicio "Observaciones".
