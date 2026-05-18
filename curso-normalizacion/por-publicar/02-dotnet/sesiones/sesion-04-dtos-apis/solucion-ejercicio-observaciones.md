---
title: "Solución del ejercicio: API de Observaciones (sesión 1)"
description: "Ficheros completos de la API mock de Observaciones que el alumno debe construir en la sesión 1."
---

# Solución del ejercicio §1.9 — API de Observaciones (sesión 1)

::: warning ESTO ES LA SOLUCIÓN
Este fichero contiene los ficheros completos que el alumno debería entregar al final de §1.9. **Compáralo con el tuyo después de intentarlo**, no antes. Si lo lees antes, te pierdes el aprendizaje de mirar `TipoRecursosController` y derivar el patrón por tu cuenta.

La sesión 2 (Servicios Oracle) **continúa este ejercicio**: pasaremos del controlador con datos hardcodeados al controlador con un servicio real contra Oracle. La nomenclatura (DTOs, nombre del controlador, claves de error) tiene que coincidir con la de esta solución para que la sesión 2 enganche sin sobresaltos.
:::

## Estructura

Tres ficheros nuevos en el proyecto `uaReservas`:

```
uaReservas/
├── Models/Reservas/
│   ├── ObservacionReservaLectura.cs        ← NUEVO
│   └── ObservacionReservaCrearDto.cs        ← NUEVO
└── Controllers/Apis/
    └── ObservacionesController.cs           ← NUEVO
```

Ningún otro fichero del proyecto se toca en la sesión 1.

---

## 1. `Models/Reservas/ObservacionReservaLectura.cs`

DTO de **salida**. Es lo que viaja desde la API hacia Vue en cada `GET`.

- `Texto` (en singular) es el campo "resuelto" al idioma del usuario. En la sesión 2, `ClaseOracleBD3` lo rellenará automáticamente desde `TEXTO_ES` / `TEXTO_CA` / `TEXTO_EN` según el `Idioma` que le pase el servicio.
- `FechaAlta` la rellena Oracle (default `SYSTIMESTAMP`); el cliente nunca la envía.
- `Activo` no aparece: la vista `VRES_OBSERVACION_RESERVA` ya filtra por `ACTIVO='S'`, así que para el cliente todas las observaciones que ve son las "vivas".

```csharp
namespace ua.Models.Reservas
{
    /// <summary>
    /// DTO de salida de una observación. Lo que la API devuelve a Vue.
    /// El campo Texto se resuelve al idioma del usuario (TEXTO_{idioma}).
    /// </summary>
    public class ObservacionReservaLectura
    {
        public int      IdObservacionReserva { get; set; }   // ID_OBSERVACION_RESERVA
        public int      IdReserva            { get; set; }   // ID_RESERVA
        public int      CodperAutor          { get; set; }   // CODPER_AUTOR
        public string   Texto                { get; set; } = string.Empty;  // TEXTO_{idioma}
        public DateTime FechaAlta            { get; set; }   // FECHA_ALTA
    }
}
```

::: info CONTEXTO — por qué no exponer `TextoEs`/`TextoCa`/`TextoEn` en la salida
Podrías. Lo hace `TipoRecursoLectura`, que devuelve los tres nombres y un `Nombre` calculado. Para `Observaciones` lo dejamos en **solo `Texto`** porque el caso de uso es "mostrar la observación al usuario logueado en su idioma" — Vue no necesita los otros dos. Es una decisión deliberada: cada DTO solo lleva lo que ese caso de uso requiere.
:::

---

## 2. `Models/Reservas/ObservacionReservaCrearDto.cs`

DTO de **entrada**. Es lo que Vue envía en el `POST` para crear una observación.

- **No lleva `CodperAutor`**: lo rellena el controlador con `CodPer` de `ControladorBase`, leído del JWT. Si alguien intenta inyectar `codperAutor` en el body, el binder de ASP.NET lo ignora porque la propiedad no existe en el DTO.
- **No lleva `IdObservacionReserva`** ni `FechaAlta` ni `Activo`: los pone Oracle.
- Los tres textos son **obligatorios** y `MaxLength(2000)` — coincide con el `VARCHAR2(2000)` de la tabla y permite que `useGestionFormularios` pinte los errores de validación por campo.

```csharp
using System.ComponentModel.DataAnnotations;

namespace ua.Models.Reservas
{
    /// <summary>
    /// DTO de entrada para crear una observación. Vue rellena los tres
    /// textos y la reserva a la que pertenecen. CodperAutor lo añade el
    /// controlador desde el JWT — NUNCA viene del body.
    /// </summary>
    public class ObservacionReservaCrearDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "VALIDACION_ID_RESERVA_POSITIVO")]
        public int IdReserva { get; set; }

        [Required(ErrorMessage = "VALIDACION_TEXTO_ES_REQUERIDO")]
        [MaxLength(2000, ErrorMessage = "VALIDACION_TEXTO_ES_LONGITUD")]
        public string TextoEs { get; set; } = string.Empty;

        [Required(ErrorMessage = "VALIDACION_TEXTO_CA_REQUERIDO")]
        [MaxLength(2000, ErrorMessage = "VALIDACION_TEXTO_CA_LONGITUD")]
        public string TextoCa { get; set; } = string.Empty;

        [Required(ErrorMessage = "VALIDACION_TEXTO_EN_REQUERIDO")]
        [MaxLength(2000, ErrorMessage = "VALIDACION_TEXTO_EN_LONGITUD")]
        public string TextoEn { get; set; } = string.Empty;
    }
}
```

::: info CONTEXTO — `ErrorMessage` con clave en mayúsculas
Los `ErrorMessage` son **claves de `Resources/SharedResource.{es,ca,en}.resx`**, no mensajes literales. `AddDataAnnotationsLocalization()` (en `Program.cs`) las resuelve al idioma activo. Si la clave no existe en el resx, el cliente ve la clave literal — útil para detectar entradas que faltan.

En la solución uso convenciones del proyecto: `VALIDACION_<CAMPO>_<REGLA>`. La sesión 3 profundiza en el sistema completo.
:::

---

## 3. `Controllers/Apis/ObservacionesController.cs`

Controlador con **datos hardcodeados en memoria**. La sesión 2 lo reescribirá enganchando un `IObservacionesServicio` real.

Tres endpoints: `Listar`, `ObtenerPorId`, `Crear`. Heredamos de `ControladorBase` (de `Apis/ControladorBase.cs`) y respetamos todas las convenciones de §1.3.

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ua.Models.Reservas;

namespace uaReservas.Controllers.Apis
{
    /// <summary>
    /// API REST para las observaciones de reservas (TRES_OBSERVACION_RESERVA).
    ///
    /// SESIÓN 1: datos hardcodeados en memoria. La sesión 2 conectará el
    /// controlador a IObservacionesServicio que llama a la vista
    /// VRES_OBSERVACION_RESERVA y al paquete PKG_RES_OBSERVACION_RESERVA.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    [Produces("application/json")]
    [Tags("Observaciones")]
    public class ObservacionesController : ControladorBase
    {
        // Datos "de pega" mientras no hay servicio. La lista es estática para
        // que `Crear` simule un insert añadiendo a la colección durante la
        // vida del proceso (se reinicia con cada reinicio del servidor).
        private static readonly List<ObservacionReservaLectura> _datos = new()
        {
            new ObservacionReservaLectura
            {
                IdObservacionReserva = 1,
                IdReserva            = 100,
                CodperAutor          = 55471,
                Texto                = "Pizarra a punto, proyector revisado.",
                FechaAlta            = new DateTime(2026, 5, 10, 9, 30, 0)
            },
            new ObservacionReservaLectura
            {
                IdObservacionReserva = 2,
                IdReserva            = 100,
                CodperAutor          = 67890,
                Texto                = "Se necesita un alargador adicional.",
                FechaAlta            = new DateTime(2026, 5, 11, 12, 0, 0)
            }
        };

        // ============================================================
        //  LECTURA
        // ============================================================

        /// <summary>Lista todas las observaciones registradas (mock en memoria).</summary>
        /// <response code="200">Lista completa (puede estar vacía).</response>
        /// <response code="401">No autenticado.</response>
        [HttpGet]
        [ProducesResponseType<List<ObservacionReservaLectura>>(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public ActionResult Listar() => Ok(_datos);

        /// <summary>Devuelve una observación por su id.</summary>
        /// <param name="id">Identificador de la observación.</param>
        /// <response code="200">Observación encontrada.</response>
        /// <response code="404">No existe una observación con ese id.</response>
        [HttpGet("{id:int}")]
        [ProducesResponseType<ObservacionReservaLectura>(StatusCodes.Status200OK)]
        [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public ActionResult ObtenerPorId([FromRoute] int id)
        {
            var obs = _datos.FirstOrDefault(o => o.IdObservacionReserva == id);
            return obs is null
                ? NotFound(new ProblemDetails
                {
                    Title  = "OBSERVACION_NO_ENCONTRADA",
                    Detail = $"No existe una observacion con id {id}.",
                    Status = StatusCodes.Status404NotFound
                })
                : Ok(obs);
        }

        // ============================================================
        //  ESCRITURA
        // ============================================================

        /// <summary>Crea una nueva observación (mock).</summary>
        /// <param name="dto">Datos de la observación a crear.</param>
        /// <response code="201">Creada. La cabecera Location apunta a la nueva observación.</response>
        /// <response code="400">Datos inválidos.</response>
        /// <response code="401">No autenticado.</response>
        [HttpPost]
        [ProducesResponseType<int>(StatusCodes.Status201Created)]
        [ProducesResponseType<ValidationProblemDetails>(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public ActionResult Crear([FromBody] ObservacionReservaCrearDto dto)
        {
            // CodperAutor se rellena AQUI desde el token (NUNCA del body).
            // En la sesion 2 el controlador pasara CodPer al servicio, igual
            // que ReservasController hace con ReservaCrearDto.
            var nueva = new ObservacionReservaLectura
            {
                IdObservacionReserva = _datos.Max(o => o.IdObservacionReserva) + 1,
                IdReserva            = dto.IdReserva,
                CodperAutor          = CodPer,                    // ← del JWT, via ControladorBase
                Texto                = dto.TextoEs,               // el mock devuelve TextoEs en Texto
                FechaAlta            = DateTime.UtcNow
            };
            _datos.Add(nueva);

            return CreatedAtAction(
                nameof(ObtenerPorId),
                new { id = nueva.IdObservacionReserva },
                nueva.IdObservacionReserva);
        }
    }
}
```

::: tip BUENA PRÁCTICA — qué fijarse al revisar tu solución
Si has llegado hasta aquí con tu propio código, **compara estos cuatro detalles** con el tuyo:

1. **`CodperAutor` no aparece en `ObservacionReservaCrearDto`** y se rellena en el controlador con `CodPer`.
2. **`Crear` devuelve `CreatedAtAction(nameof(ObtenerPorId), new { id }, id)`** — no `Ok(...)`, no `Created("/api/...", ...)` a mano.
3. **`ObtenerPorId` con id desconocido devuelve `NotFound(new ProblemDetails {...})`**, no `NotFound()` a secas — así `useGestionFormularios.adaptarProblemDetails` puede mostrar el `Detail` al usuario.
4. **El controlador hereda de `ControladorBase`**, no de `ControllerBase`. Si heredas del de ASP.NET, te falta `CodPer`, `Idioma`, `Roles`...

Si tu código pasa los cuatro puntos, estás listo para la sesión 2.
:::

---

## Probar la solución

1. Compilar: `dotnet build` (o `dotnet watch`).
2. Abrir `https://localhost:44306/uareservas/scalar/` → aparece la pestaña **Observaciones** con los tres endpoints.
3. **`GET /api/Observaciones`** → 200 con la lista de dos observaciones mock.
4. **`GET /api/Observaciones/999`** → 404 con `ProblemDetails`.
5. **`POST /api/Observaciones`** con body válido → 201 + cabecera `Location: /api/Observaciones/3`.
6. **`POST /api/Observaciones`** con `textoEs` vacío → 400 con `ValidationProblemDetails` y `errors.TextoEs[0] = "VALIDACION_TEXTO_ES_REQUERIDO"` (la clave en crudo, hasta que la sesión 3 te enseñe a añadir entradas al `SharedResource.resx`).
7. Abrir `Home.vue` y pulsar **`GET /api/Observaciones (ejercicio)`** → la zona de salida pinta el JSON.

## Próximos pasos (sesión 2)

- Crear `IObservacionesServicio` + `ObservacionesServicio` con el patrón de `TiposRecursoServicio` (`ObtenerTodosAsync` contra la vista; `CrearAsync` / `EliminarAsync` contra el paquete con `DynamicParameters`).
- Registrar el servicio en `Program.cs`.
- Cambiar el controlador para que delegue en el servicio: `HandleResult(await _observaciones.ObtenerTodosAsync(Idioma))` etc.
- Borrar el `_datos` estático.
- Añadir tests xUnit (uno simulado del controlador, uno real contra Oracle con `[SkippableFact]`).
