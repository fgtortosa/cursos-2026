---
title: "Sesión 5: Servicios y acceso a Oracle"
description: Arquitectura de capas, ClaseOracleBD3, mapeo automático y servicios con Oracle
outline: deep
---

# Sesión 5: Servicios y acceso a Oracle (~45 min)

[[toc]]

## 2.1 Patrón Result\<T\>

::: tip SESIÓN DE INTEGRACIÓN
Aquí se introduce el patrón Result\<T\> como base de la arquitectura. La gestión completa de errores (IExceptionHandler, ProblemDetails, toasts en Vue) se cubre en la **Sesión 13 — Gestión de errores de extremo a extremo**.
:::

::: info CONTEXTO
**¿Por qué no lanzar excepciones para errores de negocio?**

Las excepciones están diseñadas para situaciones *excepcionales* (la base de datos se cae, la red falla). Pero un usuario que introduce un email duplicado o una reserva en fecha pasada es un error **esperado**. Usar excepciones para flujo de control tiene varios problemas:
- **Rendimiento**: lanzar una excepción es 100-1000x más lento que devolver un objeto
- **Legibilidad**: el flujo `try/catch` oculta la lógica de negocio
- **Consistencia**: es difícil saber qué excepciones puede lanzar un servicio

El patrón `Result<T>` encapsula el resultado de una operación: si fue exitosa devuelve el valor, si fue un error devuelve un objeto `Error` con toda la información necesaria.
:::

### El núcleo: `Result<T>`, `Error` y `ErrorType`

```csharp
// Models/Errors/ErrorType.cs
public enum ErrorType
{
    Failure = 0,       // Error genérico (500)
    Validation = 1     // Error de validación (400)
}
```

```csharp
// Models/Errors/Error.cs
public record Error(
    string Code,
    string Message,
    ErrorType Type,
    IDictionary<string, string[]>? ValidationErrors = null);
```

```csharp
// Models/Errors/Result.cs
public class Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public Error? Error { get; }

    private Result(T value)
        => (IsSuccess, Value, Error) = (true, value, null);
    private Result(Error error)
        => (IsSuccess, Value, Error) = (false, default, error);

    public static Result<T> Success(T value) => new(value);
    public static Result<T> Failure(Error error) => new(error);
}
```

### El controlador base: `ApiControllerBase.HandleResult`

Este método centraliza el mapeo de `Result<T>` a respuestas HTTP. Todos los controladores API heredan de esta clase:

```csharp
// Controllers/ApiControllerBase.cs
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

### Matriz ErrorType → HTTP → ProblemDetails

| ErrorType UA | HTTP | Respuesta | Nivel Serilog |
|--------------|------|-----------|---------------|
| `Validation` | `400` | `ValidationProblemDetails` con `errors` por campo | `Warning` |
| `Failure` | `500` | `ProblemDetails` genérico (sin pistas al cliente) | `Error` |

::: tip BUENA PRÁCTICA
Mantenemos solo dos códigos de error en la API: **400** para validación (el cliente puede corregir los datos) y **500** para todo lo demás (no damos pistas sobre el error interno). Si un recurso no se encuentra, devolvemos **200 OK** con un objeto vacío (Id=0) y el frontend valida ese caso.
:::

## 2.2 Arquitectura de capas: Modelo → Servicio → API

### Estructura de ficheros UA

::: warning IMPORTANTE
El DTO y el servicio van **en el mismo directorio** dentro de `Models/`. El usuario web de Oracle **no tiene permisos** de INSERT, UPDATE ni DELETE — solo puede ejecutar procedimientos almacenados (EXECUTE) y consultar vistas (SELECT).
:::

```
Models/
  Unidad/
    ClaseUnidad.cs             ← DTO de lectura (singular)
    ClaseGuardarUnidad.cs      ← DTO de entrada con DataAnnotations
    ClaseUnidades.cs           ← Servicio (plural) - lógica + acceso a datos
    IClaseUnidades.cs          ← Interfaz del servicio
  Errors/
    Result.cs
    Error.cs
    ErrorType.cs
Controllers/
  ApiControllerBase.cs         ← Base con HandleResult
  Apis/
    UnidadesController.cs      ← Controlador API
```

::: tip CONVENCIÓN DE NOMBRES UA
- **DTO lectura:** `Clase` + singular → `ClaseUnidad.cs`
- **DTO entrada:** `Clase` + Guardar/Crear + singular → `ClaseGuardarUnidad.cs`
- **Servicio:** `Clase` + plural → `ClaseUnidades.cs` (en el **mismo directorio** que el DTO)
- **Interfaz:** `I` + `Clase` + plural → `IClaseUnidades.cs`
- **Controlador:** plural + Controller → `UnidadesController.cs`
:::

### Permisos Oracle: vistas para leer, SPs para escribir

| Operación | Objeto Oracle | Permiso usuario web |
|-----------|--------------|---------------------|
| **Leer** (SELECT) | Vistas `VCTS_UNIDADES` | SELECT |
| **Escribir** (INSERT/UPDATE) | SP `PKG_CITAS.GUARDA_UNIDAD` | EXECUTE |
| **Eliminar** (DELETE) | SP `PKG_CITAS.ELIMINA_UNIDAD` | EXECUTE |
| ~~INSERT directo~~ | ~~Tabla TCTS_UNIDADES~~ | **NO tiene permiso** |

### Inyección de dependencias

```csharp
// En ServicesExtensionsApp.cs → AddServicesApp()
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();

// ClaseOracleBd se registra automáticamente en la PlantillaMVCCore
```

### Servicio con ILogger (Serilog)

Todo servicio inyecta `ClaseOracleBd` y `ILogger<T>`:

```csharp
// Models/Unidad/ClaseUnidades.cs
public class ClaseUnidades : IClaseUnidades
{
    private readonly ClaseOracleBd bd;
    private readonly ILogger<ClaseUnidades> _logger;

    public ClaseUnidades(ClaseOracleBd claseoraclebd, ILogger<ClaseUnidades> logger)
    {
        bd = claseoraclebd;
        _logger = logger;
    }

    public Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES")
    {
        _logger.LogInformation("Obteniendo unidades activas (idioma: {Idioma})", idioma);

        const string sql = "SELECT * FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'";
        var unidades = bd.ObtenerTodosMap<ClaseUnidad>(sql, param: null, idioma: idioma)
            ?.ToList() ?? new List<ClaseUnidad>();

        _logger.LogInformation("Unidades activas encontradas: {Total}", unidades.Count);
        return Result<List<ClaseUnidad>>.Success(unidades);
    }
}
```

### Controlador

```csharp
// Controllers/Apis/UnidadesController.cs
[Route("api/[controller]")]
[ApiController]
public class UnidadesController : ApiControllerBase  // ← Hereda de ApiControllerBase
{
    private readonly IClaseUnidades _unidades;

    public UnidadesController(IClaseUnidades unidades) => _unidades = unidades;

    [HttpGet]
    public ActionResult Listar([FromQuery] string idioma = "ES")
    {
        var resultado = _unidades.ObtenerActivas(idioma);
        return HandleResult(resultado);  // ← Mapeo automático a HTTP
    }

    [HttpGet("{id}")]
    public ActionResult ObtenerPorId(int id, [FromQuery] string idioma = "ES")
    {
        var resultado = _unidades.ObtenerPorId(id, idioma);
        return HandleResult(resultado);
    }
}
```

### ¿Dónde validar: en BD o en .NET?

| | En el paquete Oracle (SP) | En el servicio .NET |
|-|--------------------------|---------------------|
| **Ventaja** | No hay que recompilar la app | Lenguaje más expresivo y flexible |
| **Ventaja** | Más rápido (cerca de los datos) | Más fácil de testear con xUnit |
| **Ventaja** | Protege contra cualquier cliente | Mensajes localizados (i18n) |
| **Desventaja** | PL/SQL es menos capaz para lógica compleja | Requiere redespliegue |
| **Recomendación** | Validaciones de integridad y negocio crítico | Validaciones de formato y UX |

::: info EN LA PRÁCTICA
Lo habitual es combinar ambas: **DataAnnotations** en el DTO validan formato (campos obligatorios, longitudes, regex). Las **reglas de negocio críticas** (no hay solapamiento de citas, la unidad no tiene dependencias) se validan en el paquete Oracle con parámetros OUT `p_codigo_error` y `p_mensaje_error`.
:::

## 2.3 Conectando con Oracle: ClaseOracleBD3

### Configuración

```json
// appsettings.json
{
  "ConnectionStrings": {
    "oradb": "User ID=USUARIO;Password=PASSWORD;Data Source=SERVIDOR/SERVICIO;"
  }
}
```

```csharp
// Program.cs — ClaseOracleBd se registra automáticamente en PlantillaMVCCore
// No hace falta añadir nada manualmente
```

### Mapeo automático: PascalCase → SNAKE_CASE

ClaseOracleBD3 convierte automáticamente los nombres de propiedades C# a columnas Oracle:

| Propiedad C# | Columna Oracle | Método |
|---------------|---------------|--------|
| `CodReserva` | `COD_RESERVA` | Conversión automática |
| `Email` | `EMAIL` | Nombre exacto |
| `FechaNacimiento` | `FECHA_NACIMIENTO` | Conversión automática |
| `CodUsr` | `COD_USR` | Usa `[Columna("COD_USR")]` si no coincide |

::: code-group
```csharp [Legacy (IDataRecord)]
// Forma antigua - mapeo manual con constructor IDataRecord
public class ClasePermiso
{
    public int CodPermiso { get; set; }
    public string Descripcion { get; set; }
    public bool Activo { get; set; }

    // Constructor vacío (requerido)
    public ClasePermiso() { }

    // Constructor legacy para mapeo manual
    public ClasePermiso(IDataRecord reader)
    {
        CodPermiso = Convert.ToInt32(reader["COD_PERMISO"]);
        Descripcion = reader["DESCRIPCION"].ToString();
        Activo = reader["ACTIVO"].ToString() == "S";
    }
}

// Uso legacy en el servicio
public ClasePermiso? ObtenerPorId(int id)
{
    _bd.TextoComando = "SELECT * FROM PERMISOS WHERE COD_PERMISO = :id";
    _bd.CrearParametro("id", id);
    return _bd.GetObject<ClasePermiso>();
}
```

```csharp [Moderno (mapeo automático)]
// Forma actual - mapeo automático sin constructor especial
public class ClaseHerramientaIA
{
    public int CodHerramienta { get; set; }   // → COD_HERRAMIENTA
    public string Nombre { get; set; }         // → NOMBRE_ES/CA/EN (multiidioma)
    public string Descripcion { get; set; }    // → DESCRIPCION_ES/CA/EN
    public string Url { get; set; }            // → URL
    public bool Activo { get; set; }           // → ACTIVO ('S'/'N' → bool)
}

// Uso moderno en el servicio — lectura desde VISTA
public ClaseHerramientaIA? ObtenerPorId(int id, string idioma)
{
    const string sql = "SELECT * FROM VACC_HERRAMIENTAS_IA WHERE COD_HERRAMIENTA = :id";
    return bd.ObtenerPrimeroMap<ClaseHerramientaIA>(sql, new { id }, idioma);
}
```
:::

### Atributos de mapeo: `[Columna]` y `[IgnorarMapeo]`

Cuando la columna Oracle **no sigue** la convención SNAKE_CASE, usamos `[Columna]` para indicar el nombre real:

```csharp
public class ClaseDocumento
{
    [Columna("IDDOC")]           // Columna no sigue SNAKE_CASE
    public int IdDocumento { get; set; }

    [Columna("NOMBREFICH")]      // Nombre abreviado en BD
    public string NombreArchivo { get; set; }

    [Columna("FECALTA")]         // Nombre abreviado en BD
    public DateTime FechaCreacion { get; set; }
}
```

Para propiedades calculadas que **no existen** en la base de datos, usamos `[IgnorarMapeo]`:

```csharp
public class ClaseDocumento
{
    public string Nombre { get; set; }
    public byte[]? Contenido { get; set; }
    public string? TipoMime { get; set; }

    // Propiedades calculadas — NO existen en la BD
    [IgnorarMapeo]                                           // [!code highlight]
    public bool TieneContenido => Contenido?.Length > 0;

    [IgnorarMapeo]                                           // [!code highlight]
    public string? ContenidoBase64 => Contenido != null
        ? $"data:{TipoMime};base64,{Convert.ToBase64String(Contenido)}"
        : null;
}
```

::: danger SIN [IgnorarMapeo]
Si olvidas `[IgnorarMapeo]`, la librería buscará columnas llamadas `TieneContenido` y `ContenidoBase64` en el resultado SQL, provocando un error de mapeo.
:::

### Orden de resolución de nombres

ClaseOracleBD3 busca la columna en este orden:

| Prioridad | Método | Ejemplo |
|-----------|--------|---------|
| 1 | Atributo `[Columna]` | `[Columna("COD_USR")]` → busca `COD_USR` |
| 2 | Nombre exacto (case-insensitive) | `Email` → busca `EMAIL` |
| 3 | Conversión PascalCase → SNAKE_CASE | `FechaNacimiento` → busca `FECHA_NACIMIENTO` |
| 4 | Con sufijo de idioma | `Nombre` + idioma `"ES"` → busca `NOMBRE_ES` |

### Conversiones automáticas de tipos

ClaseOracleBD3 convierte automáticamente los tipos Oracle a .NET:

| Oracle | .NET | Notas |
|--------|------|-------|
| `NUMBER` | `int`, `long`, `decimal` | Según el tipo de la propiedad C# |
| `VARCHAR2` | `string` | Directo |
| `VARCHAR2` `'S'`/`'N'` | `bool` | También acepta `'Y'`, `'1'`, `'SI'` → `true` |
| `VARCHAR2` numérico | `int`, `decimal` | Si contiene texto numérico, lo convierte |
| `VARCHAR2` fecha | `DateTime` | Formatos: `dd/MM/yyyy`, `yyyy-MM-dd` |
| `DATE`, `TIMESTAMP` | `DateTime` | Directo |
| `CLOB` | `string` | Para textos largos |
| `BLOB` | `byte[]` | Para ficheros binarios |

::: info EJEMPLO PRÁCTICO
Una columna `ACTIVO` de tipo `VARCHAR2(1)` con valor `'S'` se convierte automáticamente a `true` en una propiedad `bool Activo`. No necesitas escribir conversión manual.
:::

### Métodos principales de ClaseOracleBD3

| Método | Descripción | Retorno |
|--------|-------------|---------|
| `ObtenerTodosMap<T>(sql, param, idioma)` | Lista de objetos | `IEnumerable<T>?` |
| `ObtenerPrimeroMap<T>(sql, param, idioma)` | Un objeto o null | `T?` |
| `ObtenerTodosMapAsync<T>(...)` | Versión async | `Task<IEnumerable<T>>` |
| `ObtenerPrimeroMapAsync<T>(...)` | Versión async | `Task<T?>` |
| `EjecutarParams(sql, param)` | Ejecutar SP/función | `void` |
| `EjecutarParamsAsync(sql, param)` | Versión async | `Task` |

::: tip BindByName
Cuando uses parámetros nombrados (`:p_nombre`), activa `BindByName(true)` para que Oracle los asocie por nombre y no por posición:

```csharp
bd.BindByName(true);
var usuario = bd.ObtenerPrimeroMap<ClaseUsuario>(sql, new { p_id = 123 });
```

Si no lo activas, los parámetros se vinculan **por orden de declaración**, lo que puede causar errores difíciles de detectar cuando tienes varios parámetros.
:::

### Parámetros con objetos anónimos

```csharp
// Un parámetro
var reserva = _bd.ObtenerPrimeroMap<ClaseReserva>(
    "SELECT * FROM RESERVAS WHERE COD_RESERVA = :id",
    new { id }
);

// Múltiples parámetros
var reservas = _bd.ObtenerTodosMap<ClaseReserva>(
    "SELECT * FROM RESERVAS WHERE ACTIVO = :activo AND SALA = :sala",
    new { activo = "S", sala = "A" }
);
```

### Multiidioma con sufijos _ES, _CA, _EN

```csharp
// La propiedad "Nombre" se mapeará a NOMBRE_ES, NOMBRE_CA o NOMBRE_EN
// según el tercer parámetro "idioma"

// En español
var herramientas = _bd.ObtenerTodosMap<ClaseHerramientaIA>(
    "SELECT * FROM HERRAMIENTAS_IA WHERE ACTIVO = 'S'",
    param: null,
    idioma: "ES"    // → busca columnas NOMBRE_ES, DESCRIPCION_ES
);

// En catalán
var herramientasCa = _bd.ObtenerTodosMap<ClaseHerramientaIA>(
    "SELECT * FROM HERRAMIENTAS_IA WHERE ACTIVO = 'S'",
    param: null,
    idioma: "CA"    // → busca columnas NOMBRE_CA, DESCRIPCION_CA
);
```

### Procedimientos almacenados

Recuerda: el usuario web solo tiene permiso EXECUTE sobre los paquetes.

```csharp
// Solo parámetros de entrada (IN) — con EjecutarParams
public void ActivarReserva(int codReserva)
{
    bd.EjecutarParams(
        "PKG_RESERVAS.ACTIVAR",
        new { p_cod_reserva = codReserva }
    );
}
```

Para parámetros OUT o IN OUT, usamos `CrearParametro` + `Ejecutar`:

```csharp
// Con parámetro IN OUT y parámetros OUT (patrón real)
public Result<int> Guardar(ClaseGuardarUnidad dto)
{
    bd.Command.Parameters.Clear();                              // [!code highlight]
    bd.TipoComando = CommandType.StoredProcedure;               // [!code highlight]
    bd.TextoComando = "PKG_CITAS.GUARDA_UNIDAD";               // [!code highlight]

    // Parámetro IN OUT — permite crear (pid=0) o modificar (pid=valor)
    bd.CrearParametro("pid", dto.Id ?? 0,
        OracleDbType.Int32, 0, ParameterDirection.InputOutput); // [!code highlight]

    // Parámetros IN
    bd.CrearParametro("pnombre_es", dto.NombreEs);
    bd.CrearParametro("pnombre_ca", dto.NombreCa);
    bd.CrearParametro("pnombre_en", dto.NombreEn);
    bd.CrearParametro("pflg_activa", dto.FlgActiva ? "S" : "N");
    bd.CrearParametro("pgranularidad", dto.Granularidad);
    bd.CrearParametro("pcodper", dto.CodPer);
    bd.CrearParametro("pip", dto.Ip);

    bd.Ejecutar();                                              // [!code highlight]

    // Recuperar el ID generado del parámetro IN OUT
    var idGenerado = Convert.ToInt32(
        bd.Command.Parameters["pid"].Value?.ToString() ?? "0"); // [!code highlight]
    bd.Command.Parameters.Clear();                              // [!code highlight]

    return Result<int>.Success(idGenerado);
}
```

::: warning SIEMPRE LIMPIAR PARÁMETROS
Después de cada `bd.Ejecutar()`, llama a `bd.Command.Parameters.Clear()` para evitar que los parámetros se acumulen entre llamadas.
:::

### Alternativa: DynamicParameters

Además de `CrearParametro`, puedes usar `DynamicParameters` (clase propia de la librería) para un código más limpio con parámetros OUT:

::: code-group
```csharp [Con DynamicParameters]
// Patrón con DynamicParameters — más limpio para OUT
public int CrearUsuario(string nombre, string email)
{
    var p = new DynamicParameters();
    p.Add("P_NOMBRE", nombre);
    p.Add("P_EMAIL", email);
    p.Add("P_ID_GENERADO", null, OracleDbType.Decimal,
        ParameterDirection.Output);                          // [!code highlight]

    bd.EjecutarParams("PKG_USUARIOS.CREAR_USUARIO", p);

    return Convert.ToInt32(p.Get("P_ID_GENERADO"));          // [!code highlight]
}
```

```csharp [Con CrearParametro]
// Patrón con CrearParametro — usado en el curso
public int CrearUsuario(string nombre, string email)
{
    bd.Command.Parameters.Clear();
    bd.TipoComando = CommandType.StoredProcedure;
    bd.TextoComando = "PKG_USUARIOS.CREAR_USUARIO";

    bd.CrearParametro("P_NOMBRE", nombre);
    bd.CrearParametro("P_EMAIL", email);
    bd.CrearParametro("P_ID_GENERADO", null,
        OracleDbType.Decimal, 0, ParameterDirection.Output);

    bd.Ejecutar();

    var id = Convert.ToInt32(
        bd.Command.Parameters["P_ID_GENERADO"].Value?.ToString() ?? "0");
    bd.Command.Parameters.Clear();
    return id;
}
```
:::

### Funciones Oracle: RETURN_VALUE siempre primero

::: danger REGLA OBLIGATORIA
En llamadas a **funciones** Oracle (no procedimientos), el parámetro `RETURN_VALUE` debe declararse **siempre el primero**. Si no, Oracle lanzará un error.
:::

```csharp
public decimal ObtenerPesoFoto(int idFoto)
{
    var p = new DynamicParameters();
    p.Add("RETURN_VALUE", null, OracleDbType.Decimal,
        ParameterDirection.ReturnValue);                     // [!code highlight]
    p.Add("P_ID_FOTO", idFoto);

    bd.EjecutarParams("PKG_FOTOS.OBTENER_PESO", p);

    return Convert.ToDecimal(p.Get("RETURN_VALUE"));         // [!code highlight]
}
```

| Tipo parámetro | Dirección | Valor inicial | Recuperación |
|----------------|-----------|---------------|--------------|
| Entrada (IN) | `Input` (default) | Sí | No |
| Salida (OUT) | `Output` | No | `p.Get("nombre")` |
| Entrada/Salida | `InputOutput` | Sí | `p.Get("nombre")` |
| Retorno función | `ReturnValue` | No | `p.Get("RETURN_VALUE")` |

### postMapeo: conversión personalizada

Cuando necesitas lógica especial después del mapeo automático, usa el parámetro `postMapeo`:

```csharp
var datos = bd.ObtenerTodosMap<ClaseUsuario>(
    sql,
    parametros,
    funcionPostMapeo: (item, rs) =>                          // [!code highlight]
    {
        // Lógica especial que el mapeo automático no cubre
        item.EsAdmin = (rs["ROL"]?.ToString() ?? "") == "ADMIN";
        item.NombreCompleto = $"{item.Nombre} {item.Apellidos}";
    });
```

::: info CUÁNDO USAR postMapeo
Úsalo solo cuando la conversión automática no sea suficiente: roles con lógica, campos compuestos, etc. Para la mayoría de casos, el mapeo automático con `[Columna]` es suficiente.
:::

### Síncrono vs asíncrono

| Cuándo usar **síncrono** | Cuándo usar **asíncrono** |
|--------------------------|---------------------------|
| Procesos cortos de backoffice | APIs web con concurrencia media/alta |
| Código existente ya síncrono | Operaciones potencialmente lentas |
| Flujos sin alta concurrencia | Endpoints I/O bound |

```csharp
// Síncrono — lo que usamos en el curso
var unidades = bd.ObtenerTodosMap<ClaseUnidad>(sql, param: null, idioma: idioma);

// Asíncrono — para APIs con alta concurrencia
bd.BindByName(true);
var unidades = await bd.ObtenerTodosMapAsync<ClaseUnidad>(sql, new { p_max = 100 });
```

::: tip RECOMENDACIÓN
Para las aplicaciones del curso usamos código **síncrono** por simplicidad. En producción con alta concurrencia, usa las versiones `Async`.
:::

### Transacciones

Cuando varias operaciones deben ser **atómicas** (todas o ninguna):

```csharp
try
{
    bd.BeginTransaction();                                   // [!code highlight]

    bd.EjecutarParams("PKG_CUENTAS.RETIRAR",
        new { p_cuenta = origen, p_monto = monto });
    bd.EjecutarParams("PKG_CUENTAS.DEPOSITAR",
        new { p_cuenta = destino, p_monto = monto });

    bd.Commit();                                             // [!code highlight]
}
catch
{
    bd.Rollback();                                           // [!code highlight]
    throw;
}
finally
{
    bd.EndTransaction();                                     // [!code highlight]
}
```

::: warning PATRÓN OBLIGATORIO
Siempre incluye `Rollback()` en el `catch` y `EndTransaction()` en el `finally`. Si olvidas `EndTransaction`, la conexión queda en estado inconsistente.
:::

### Manejo de errores Oracle

ClaseOracleBD3 envuelve los errores de Oracle en dos tipos de excepción:

| Excepción | Causa | Acción recomendada |
|-----------|-------|--------------------|
| `BDException` | Error Oracle genérico (SQL incorrecto, constraints, etc.) | Log + devolver `Result.Failure` |
| `MantenimientoException` | BD en mantenimiento o cuenta bloqueada (`ORA-28000`) | Mostrar página de mantenimiento |

```csharp
public Result<List<ClaseUnidad>> ObtenerActivas(string idioma)
{
    try
    {
        const string sql = "SELECT * FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'";
        var unidades = bd.ObtenerTodosMap<ClaseUnidad>(sql, param: null, idioma: idioma)
            ?.ToList() ?? [];
        return Result<List<ClaseUnidad>>.Success(unidades);
    }
    catch (MantenimientoException)                           // [!code highlight]
    {
        // La capa superior debe mostrar página de mantenimiento
        throw;
    }
    catch (BDException ex)                                   // [!code highlight]
    {
        _logger.LogError(ex, "Error Oracle al obtener unidades");
        return Result<List<ClaseUnidad>>.Failure(
            new Error("Unidad.DbError",
                "Error al acceder a la base de datos", ErrorType.Failure));
    }
}
```

### Errores comunes y cómo evitarlos

| Error | Causa habitual | Solución |
|-------|---------------|----------|
| Parámetro no encontrado | Nombre distinto entre SQL y parámetro | Activar `BindByName(true)` y usar prefijos coherentes |
| Mapeo vacío o propiedades en null | Alias SQL no coincide con propiedad C# | Usar `AS NombrePropiedad` o `[Columna]` |
| Fallo en función Oracle | `RETURN_VALUE` no declarado primero | Declarar `RETURN_VALUE` como primer parámetro |
| Propiedad calculada no encontrada | Falta `[IgnorarMapeo]` | Añadir `[IgnorarMapeo]` a propiedades que no vienen de BD |
| Conexiones inestables | Mal manejo del ciclo de vida | Usar DI scoped, no retener instancias estáticas |
| SQL injection | Concatenación de texto en query | Siempre parámetros (`:p_nombre`) |
| Parámetros residuales | No limpiar después de `Ejecutar` | `bd.Command.Parameters.Clear()` tras cada ejecución |

::: tip CHECKLIST PARA NUEVOS MODELOS
Cuando crees un nuevo modelo para mapeo con ClaseOracleBD3:
- [ ] Propiedades en **PascalCase** que correspondan a columnas **SNAKE_CASE**
- [ ] `[Columna("X")]` solo si el nombre NO sigue la convención
- [ ] `[IgnorarMapeo]` en todas las propiedades calculadas
- [ ] Constructor vacío (implícito o explícito)
- [ ] Tipos nullable (`?`) para columnas que pueden ser NULL
- [ ] `bool` para columnas VARCHAR2 con valores `'S'`/`'N'`
- [ ] Propiedades multiidioma **sin** sufijo (el sufijo lo pone la librería)
- [ ] En DTOs de entrada, `[JsonIgnore]` para propiedades que no vienen del JSON (CodPer, Ip)
- [ ] Lectura desde **vistas** (`VCTS_xxx`), escritura mediante **SPs** (`PKG_xxx`)

Checklist de seguridad y robustez:
- [ ] `BindByName(true)` en consultas con parámetros nombrados
- [ ] Sin SQL en controllers ni models — todo SQL va en **Services**
- [ ] Parámetros siempre nombrados (nunca concatenar entrada de usuario)
- [ ] Funciones Oracle con `RETURN_VALUE` declarado **primero**
- [ ] `bd.Command.Parameters.Clear()` después de cada `bd.Ejecutar()`
- [ ] Manejo de `BDException` con logging y `Result.Failure`
:::

## 2.4 Práctica guiada: Rojo-Verde-Refactor con ObtenerPorId

Aplicamos el ciclo RGR a un caso real: ¿qué pasa cuando buscamos una unidad con un ID que no existe?

### Paso 1: ROJO — Sin control de null

Si el servicio no comprueba `null`, obtenemos un error inesperado:

```csharp
// ⚠️ Versión ROJA - sin control
public Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES")
{
    const string sql = "SELECT * FROM VCTS_UNIDADES WHERE ID = :id";
    var unidad = _bd.ObtenerPrimeroMap<ClaseUnidad>(sql, new { id }, idioma: idioma);
    return Result<ClaseUnidad>.Success(unidad); // ← unidad puede ser null!
}
```

```json
// GET /api/Unidades/9999
// Respuesta: 200 OK con null (o NullReferenceException → 500)
null
```

::: danger ESTO ES ROJO
El servicio devuelve `Success(null)` — el controlador envía un `200 OK` con `null` al frontend. El frontend no sabe si la unidad no existe o si el campo viene vacío.
:::

### Paso 2: VERDE — Comprobar null y devolver un objeto vacío

```csharp
// ✅ Versión VERDE - con control
public Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES")
{
    const string sql = "SELECT * FROM VCTS_UNIDADES WHERE ID = :id";
    var unidad = _bd.ObtenerPrimeroMap<ClaseUnidad>(sql, new { id }, idioma: idioma);

    // Si no existe, devolvemos un objeto con Id=0                // [!code highlight]
    // El frontend valida Id==0 para detectar que no se encontró  // [!code highlight]
    return Result<ClaseUnidad>.Success(unidad ?? new ClaseUnidad { Id = 0 }); // [!code highlight]
}
```

```json
// GET /api/Unidades/9999
// Respuesta: 200 OK con Id=0 (el frontend detecta que no existe)
{
  "id": 0,
  "nombre": null,
  "flgActiva": false
}
```

::: tip ESTO ES VERDE
Siempre devolvemos `200 OK`. Si `Id == 0`, el frontend sabe que la unidad no existe. **No revelamos códigos HTTP específicos** (404, 409...) que puedan dar pistas a un atacante sobre la existencia de recursos. Solo usamos `400` (validación) y `500` (error interno genérico).
:::

### Paso 3: REFACTOR — Validación en Vue

En **Vue**, comprobamos el Id del objeto recibido:

```typescript
llamadaAxios(`Unidades/${id}`, verbosAxios.GET)
  .then(({ data }) => {
    if (data.value.id === 0) {                      // [!code highlight]
      avisarError("Unidad no encontrada");           // [!code highlight]
    } else {
      unidad.value = data.value;
    }
  })
  .catch((error) => {
    gestionarError(error, "Error al buscar");       // 500 genérico
  });
```

## 2.5 Servicio completo con Oracle

Unimos todos los conceptos: modelo + ClaseOracleBD3 + `Result<T>` + ILogger + controlador API.

### Modelo (en `Models/Unidad/`)

```csharp
// Models/Unidad/ClaseUnidad.cs — DTO de lectura
public class ClaseUnidad
{
    public int Id { get; set; }                         // ID
    public string Nombre { get; set; }                  // NOMBRE_ES/CA/EN (multiidioma)
    public bool FlgActiva { get; set; }                 // FLG_ACTIVA ('S'/'N' → bool)
    public int Granularidad { get; set; }               // GRANULARIDAD (minutos)
    public string DuracionMax { get; set; }             // DURACION_MAX
    public bool FlgRequiereConfirmacion { get; set; }   // FLG_REQUIERE_CONFIRMACION
    public int NumCitasSimultaneas { get; set; }        // NUM_CITAS_SIMULTANEAS
}
```

### Servicio (en el **mismo directorio** `Models/Unidad/`)

```csharp
// Models/Unidad/ClaseUnidades.cs
public class ClaseUnidades : IClaseUnidades
{
    private readonly ClaseOracleBd bd;                          // [!code highlight]
    private readonly ILogger<ClaseUnidades> _logger;            // [!code highlight]

    public ClaseUnidades(ClaseOracleBd claseoraclebd, ILogger<ClaseUnidades> logger)
    {
        bd = claseoraclebd;
        _logger = logger;
    }

    public Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES")
    {
        _logger.LogInformation("Obteniendo unidades activas (idioma: {Idioma})", idioma);

        const string sql = "SELECT * FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'";
        var unidades = bd.ObtenerTodosMap<ClaseUnidad>(sql, param: null, idioma: idioma)
            ?.ToList() ?? new List<ClaseUnidad>();

        return Result<List<ClaseUnidad>>.Success(unidades);
    }

    public Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES")
    {
        const string sql = "SELECT * FROM VCTS_UNIDADES WHERE ID = :id";
        var unidad = bd.ObtenerPrimeroMap<ClaseUnidad>(sql, new { id }, idioma: idioma);

        // Si no existe, devolvemos objeto vacío con Id=0
        return Result<ClaseUnidad>.Success(unidad ?? new ClaseUnidad { Id = 0 });
    }

    public Result<int> Guardar(ClaseGuardarUnidad dto)
    {
        _logger.LogInformation("Guardando unidad {NombreEs} (Id: {Id})", dto.NombreEs, dto.Id);

        try
        {
            bd.Command.Parameters.Clear();
            bd.TipoComando = CommandType.StoredProcedure;
            bd.TextoComando = "PKG_CITAS.GUARDA_UNIDAD";

            bd.CrearParametro("pid", dto.Id ?? 0,
                OracleDbType.Int32, 0, ParameterDirection.InputOutput);
            bd.CrearParametro("pnombre_es", dto.NombreEs);
            bd.CrearParametro("pnombre_ca", dto.NombreCa);
            bd.CrearParametro("pnombre_en", dto.NombreEn);
            bd.CrearParametro("pflg_activa", dto.FlgActiva ? "S" : "N");
            bd.CrearParametro("pgranularidad", dto.Granularidad);
            bd.CrearParametro("pduracion_max", dto.DuracionMax);
            bd.CrearParametro("pflg_requiere_confirmacion",
                dto.FlgRequiereConfirmacion ? "S" : "N");
            bd.CrearParametro("pnum_citas_simultaneas",
                dto.NumCitasSimultaneas.ToString());
            bd.CrearParametro("pcodper", dto.CodPer);
            bd.CrearParametro("pip", dto.Ip);

            bd.Ejecutar();

            var idGenerado = Convert.ToInt32(
                bd.Command.Parameters["pid"].Value?.ToString() ?? "0");
            bd.Command.Parameters.Clear();

            _logger.LogInformation("Unidad guardada con ID: {Id}", idGenerado);
            return Result<int>.Success(idGenerado);
        }
        catch (Exception ex)
        {
            bd.Command.Parameters.Clear();
            _logger.LogError(ex, "Error al guardar unidad {NombreEs}", dto.NombreEs);
            return Result<int>.Failure(
                new Error("Unidad.SaveError", "Error al guardar la unidad", ErrorType.Failure));
        }
    }
}
```

### Controlador API

```csharp
// Controllers/Apis/UnidadesController.cs
[Route("api/[controller]")]
[ApiController]
public class UnidadesController : ApiControllerBase
{
    private readonly IClaseUnidades _unidades;

    public UnidadesController(IClaseUnidades unidades) => _unidades = unidades;

    [HttpGet]
    public ActionResult Listar([FromQuery] string idioma = "ES")
        => HandleResult(_unidades.ObtenerActivas(idioma));

    [HttpGet("{id}")]
    public ActionResult ObtenerPorId(int id, [FromQuery] string idioma = "ES")
        => HandleResult(_unidades.ObtenerPorId(id, idioma));

    [HttpPost]
    public ActionResult Guardar([FromBody] ClaseGuardarUnidad dto)
    {
        dto.CodPer = 0; // En producción: del usuario autenticado
        dto.Ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
        return HandleResult(_unidades.Guardar(dto));
    }
}
```

### Vista Vue

```vue
<script setup lang="ts">
import { ref, onMounted } from "vue";
import { llamadaAxios, verbosAxios, gestionarError } from "vueua-useaxios/services/useAxios";

interface HerramientaIA {
  codHerramienta: number;
  nombre: string;
  descripcion: string;
  url: string;
  activo: boolean;
}

const herramientas = ref<HerramientaIA[]>([]);

const cargar = () => {
  llamadaAxios("HerramientasIA", verbosAxios.GET)
    .then(({ data }) => {
      herramientas.value = data.value;
    })
    .catch((error) => {
      gestionarError(error, "Error al cargar herramientas IA");
    });
};

onMounted(cargar);
</script>

<template>
  <h1>Herramientas IA</h1>
  <ul>
    <li v-for="h in herramientas" :key="h.codHerramienta">
      <a :href="h.url" target="_blank">{{ h.nombre }}</a> - {{ h.descripcion }}
    </li>
  </ul>
</template>
```

## Preguntas de repaso

### Pregunta 1

**¿Cuál es la principal ventaja de usar `Result<T>` en lugar de excepciones para errores de negocio?**

a) `Result<T>` es más fácil de escribir
b) Las excepciones no funcionan en .NET Core 10
c) `Result<T>` hace explícito el flujo de errores y es mucho más eficiente
d) No hay ninguna diferencia, es cuestión de preferencia

::: details Respuesta
**c)** Las excepciones son para situaciones *excepcionales* (BD caída, red). Un email duplicado o un ID inexistente es un error **esperado**. `Result<T>` es 100-1000x más rápido que lanzar excepciones y hace el flujo de errores explícito en la firma del método.
:::

### Pregunta 2

**¿Qué devuelve `HandleResult` cuando el servicio retorna `ErrorType.Failure`?**

a) 400 Bad Request
b) 200 OK con el objeto
c) 404 Not Found
d) 500 Internal Server Error

::: details Respuesta
**d)** El método `HandleResult` en `ApiControllerBase` mapea cualquier error que no sea `Validation` a `Problem(statusCode: 500)`. Solo hay dos respuestas de error: 400 (validación) y 500 (todo lo demás).
:::

### Pregunta 3

**¿Qué método de ClaseOracleBD3 usamos para obtener un solo registro que puede no existir?**

a) `ObtenerTodosMap<T>(sql, param)`
b) `ObtenerPrimeroMap<T>(sql, param)`
c) `GetObject<T>()`
d) `EjecutarParams(sql, param)`

::: details Respuesta
**b)** `ObtenerPrimeroMap<T>` devuelve `T?` — un objeto o `null` si no hay resultados. `GetObject<T>` es el método legacy que requiere constructor `IDataRecord`. `ObtenerTodosMap` devuelve una lista completa.
:::

### Pregunta 4

**Si tu modelo tiene la propiedad `NumCitasSimultaneas`, ¿qué columna buscará ClaseOracleBD3?**

a) `NUMCITASSIMULTANEAS`
b) `NUM_CITAS_SIMULTANEAS`
c) `numCitasSimultaneas`
d) Dará error si no usas `[Columna]`

::: details Respuesta
**b)** ClaseOracleBD3 convierte automáticamente PascalCase a SNAKE_CASE. `NumCitasSimultaneas` → `NUM_CITAS_SIMULTANEAS`. Solo necesitas `[Columna("X")]` si la columna no sigue esta convención.
:::

### Pregunta 5

**¿Por qué el usuario web de Oracle no puede hacer INSERT directo en las tablas?**

a) Porque Oracle no permite INSERT desde aplicaciones web
b) Porque el usuario web solo tiene permisos de EXECUTE en SPs y SELECT en vistas
c) Porque .NET Core no soporta INSERT directo
d) Porque los INSERT son más lentos que los procedimientos almacenados

::: details Respuesta
**b)** Por seguridad, el usuario web solo tiene permiso EXECUTE sobre los paquetes (PKG_CITAS, etc.) y SELECT sobre las vistas (VCTS_UNIDADES, etc.). Toda escritura se hace mediante procedimientos almacenados, que son el único punto de entrada controlado.
:::

### Pregunta 6

**¿Cómo funciona el mapeo multiidioma en ClaseOracleBD3?**

a) Crea un JOIN automático con una tabla de traducciones
b) Añade el sufijo del idioma (_ES, _CA, _EN) al nombre de la propiedad
c) Traduce automáticamente el texto usando una API
d) Busca la columna IDIOMA en la tabla

::: details Respuesta
**b)** Si pasas `idioma: "ES"` y tu modelo tiene `Nombre`, la librería buscará la columna `NOMBRE_ES`. Si pasas `"CA"`, buscará `NOMBRE_CA`. La propiedad del modelo NO lleva sufijo.
:::

### Pregunta 7

**¿Cuál es el patrón correcto para llamar a un procedimiento almacenado con parámetro `IN OUT`?**

a) Usar un objeto anónimo `new { pid = valor }`
b) Usar `EjecutarParams` con un string SQL
c) Usar `ObtenerPrimeroMap` con el nombre del procedimiento
d) Usar `bd.TipoComando = StoredProcedure` + `bd.CrearParametro` con `ParameterDirection.InputOutput`

::: details Respuesta
**d)** Los parámetros `IN OUT` requieren `CrearParametro` con `OracleDbType` y `ParameterDirection.InputOutput`, y luego recuperar el valor con `bd.Command.Parameters["pid"].Value`. Los objetos anónimos y `EjecutarParams` solo sirven para parámetros IN.
:::

### Pregunta 8

**En la convención UA, ¿cómo se nombran modelo, servicio y controlador para la tabla `TCTS_UNIDADES`?**

a) Unidad.cs / Unidades.cs / UnidadesController.cs
b) ClaseUnidad.cs / Unidades.cs / UnidadesController.cs
c) ClaseUnidad.cs / ClaseUnidades.cs / UnidadesController.cs
d) TctsUnidad.cs / TctsUnidades.cs / UnidadesController.cs

::: details Respuesta
**c)** Convención UA: el DTO lleva prefijo `Clase` + nombre singular (`ClaseUnidad`), el servicio lleva prefijo `Clase` + nombre plural (`ClaseUnidades`), y el controlador es plural + Controller (`UnidadesController`). Tanto DTO como servicio van en el **mismo directorio** `Models/Unidad/`.
:::

### Pregunta 9

**¿Para qué sirve el atributo `[IgnorarMapeo]` en un modelo?**

a) Para ignorar columnas NULL de la base de datos
b) Para excluir propiedades calculadas que no existen como columnas en BD
c) Para ignorar errores de conversión de tipos
d) Para que la propiedad no se serialice a JSON

::: details Respuesta
**b)** `[IgnorarMapeo]` indica a ClaseOracleBD3 que esa propiedad no corresponde a ninguna columna de la base de datos. Sin este atributo, la librería intentará buscar una columna con ese nombre y fallará. Se usa en propiedades calculadas como `TieneContenido` o `NombreCompleto`.
:::

### Pregunta 10

**¿Cuál es la regla obligatoria al llamar a una función Oracle (no un procedimiento)?**

a) Usar siempre `EjecutarParams` en lugar de `Ejecutar`
b) Declarar `RETURN_VALUE` como primer parámetro con `ParameterDirection.ReturnValue`
c) Usar `TipoComando = CommandType.Text`
d) Pasar el nombre de la función como `TextoComando`

::: details Respuesta
**b)** En funciones Oracle, `RETURN_VALUE` debe ser el **primer** parámetro declarado en `DynamicParameters` con dirección `ReturnValue`. Si no se declara primero, Oracle lanzará un error. En procedimientos, los parámetros OUT se declaran después de los IN.
:::

### Pregunta 11

**¿Qué excepción lanza ClaseOracleBD3 cuando detecta que la BD está en mantenimiento?**

a) `BDException`
b) `MantenimientoException`
c) `OracleException`
d) `InvalidOperationException`

::: details Respuesta
**b)** `MantenimientoException` se lanza cuando ClaseOracleBD3 detecta mensajes de mantenimiento o cuenta bloqueada (`ORA-28000`). A diferencia de `BDException` (errores Oracle genéricos), esta excepción debe propagarse hacia arriba para mostrar una página de mantenimiento al usuario. No debe capturarse con `Result.Failure`.
:::

### Pregunta 12

**¿Qué pasa si no llamas a `bd.EndTransaction()` después de usar transacciones?**

a) La transacción se confirma automáticamente
b) Oracle hace rollback automáticamente
c) La conexión queda en estado inconsistente
d) No pasa nada, es opcional

::: details Respuesta
**c)** Si olvidas `EndTransaction()`, la conexión queda en estado inconsistente y puede provocar errores en operaciones posteriores. El patrón correcto es: `BeginTransaction` → `Commit` (en try) → `Rollback` (en catch) → `EndTransaction` (en finally, **siempre**).
:::

## Ejercicio Sesión 2

**Objetivo:** Crear un servicio completo siguiendo los patrones UA: DTO y servicio en el mismo directorio, lectura desde vistas, escritura mediante SPs.

1. Crear el modelo `ClaseUnidad` en `Models/Unidad/` mapeado a la vista `VCTS_UNIDADES`
2. Crear la interfaz `IClaseUnidades` y el servicio `ClaseUnidades` **en el mismo directorio** con:
   - Inyección de `ClaseOracleBd` + `ILogger<ClaseUnidades>`
   - `ObtenerActivas(idioma)` → SELECT desde **vista** con `ObtenerTodosMap` + multiidioma
   - `ObtenerPorId(id, idioma)` → SELECT desde **vista** con `ObtenerPrimeroMap` + `Result<T>`
   - `Guardar(dto)` → llamada al **SP** `PKG_CITAS.GUARDA_UNIDAD` con `CrearParametro` + `IN OUT`
3. Crear `UnidadesController` que herede de `ApiControllerBase` y use `HandleResult`
4. Registrar `IClaseUnidades → ClaseUnidades` en `ServicesExtensionsApp`
5. En Vue, mostrar las unidades y comprobar `Id == 0` para detectar recursos no encontrados

::: details Solución

**Estructura de ficheros:**

```
Models/Unidad/
  ClaseUnidad.cs           ← DTO de lectura
  ClaseGuardarUnidad.cs    ← DTO de entrada
  ClaseUnidades.cs         ← Servicio
  IClaseUnidades.cs        ← Interfaz
```

**DTO de entrada:**

```csharp
// Models/Unidad/ClaseGuardarUnidad.cs
public class ClaseGuardarUnidad
{
    public int? Id { get; set; }

    [Required(ErrorMessage = "El nombre en español es obligatorio")]
    [StringLength(200)]
    public string NombreEs { get; set; }
    // ... NombreCa, NombreEn, FlgActiva, Granularidad, etc.

    // Datos de auditoría — no vienen del JSON
    [JsonIgnore]
    public int CodPer { get; set; }
    [JsonIgnore]
    public string Ip { get; set; }
}
```

**Interfaz:**

```csharp
// Models/Unidad/IClaseUnidades.cs
public interface IClaseUnidades
{
    Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES");
    Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES");
    Result<int> Guardar(ClaseGuardarUnidad dto);
}
```

**Servicio:**

```csharp
// Models/Unidad/ClaseUnidades.cs
public class ClaseUnidades : IClaseUnidades
{
    private readonly ClaseOracleBd bd;
    private readonly ILogger<ClaseUnidades> _logger;

    public ClaseUnidades(ClaseOracleBd claseoraclebd, ILogger<ClaseUnidades> logger)
    {
        bd = claseoraclebd;
        _logger = logger;
    }

    public Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES")
    {
        const string sql = "SELECT * FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'";
        var unidades = bd.ObtenerTodosMap<ClaseUnidad>(sql, param: null, idioma: idioma)
            ?.ToList() ?? new List<ClaseUnidad>();
        return Result<List<ClaseUnidad>>.Success(unidades);
    }

    public Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES")
    {
        const string sql = "SELECT * FROM VCTS_UNIDADES WHERE ID = :id";
        var unidad = bd.ObtenerPrimeroMap<ClaseUnidad>(sql, new { id }, idioma: idioma);

        // Si no existe, devolvemos objeto vacío con Id=0
        return Result<ClaseUnidad>.Success(unidad ?? new ClaseUnidad { Id = 0 });
    }

    public Result<int> Guardar(ClaseGuardarUnidad dto)
    {
        _logger.LogInformation("Guardando unidad {NombreEs}", dto.NombreEs);

        bd.Command.Parameters.Clear();
        bd.TipoComando = CommandType.StoredProcedure;
        bd.TextoComando = "PKG_CITAS.GUARDA_UNIDAD";

        bd.CrearParametro("pid", dto.Id ?? 0,
            OracleDbType.Int32, 0, ParameterDirection.InputOutput);
        bd.CrearParametro("pnombre_es", dto.NombreEs);
        bd.CrearParametro("pnombre_ca", dto.NombreCa);
        bd.CrearParametro("pnombre_en", dto.NombreEn);
        bd.CrearParametro("pflg_activa", dto.FlgActiva ? "S" : "N");
        bd.CrearParametro("pgranularidad", dto.Granularidad);
        bd.CrearParametro("pduracion_max", dto.DuracionMax);
        bd.CrearParametro("pflg_requiere_confirmacion",
            dto.FlgRequiereConfirmacion ? "S" : "N");
        bd.CrearParametro("pnum_citas_simultaneas",
            dto.NumCitasSimultaneas.ToString());
        bd.CrearParametro("pcodper", dto.CodPer);
        bd.CrearParametro("pip", dto.Ip);

        bd.Ejecutar();

        var idGenerado = Convert.ToInt32(
            bd.Command.Parameters["pid"].Value?.ToString() ?? "0");
        bd.Command.Parameters.Clear();

        return Result<int>.Success(idGenerado);
    }
}
```

**Controlador:**

```csharp
// Controllers/Apis/UnidadesController.cs
[Route("api/[controller]")]
[ApiController]
public class UnidadesController : ApiControllerBase
{
    private readonly IClaseUnidades _unidades;

    public UnidadesController(IClaseUnidades unidades) => _unidades = unidades;

    [HttpGet]
    public ActionResult Listar([FromQuery] string idioma = "ES")
        => HandleResult(_unidades.ObtenerActivas(idioma));

    [HttpGet("{id}")]
    public ActionResult ObtenerPorId(int id, [FromQuery] string idioma = "ES")
        => HandleResult(_unidades.ObtenerPorId(id, idioma));

    [HttpPost]
    public ActionResult Guardar([FromBody] ClaseGuardarUnidad dto)
    {
        dto.CodPer = 0; // En producción: del usuario autenticado
        dto.Ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
        return HandleResult(_unidades.Guardar(dto));
    }
}
```

**ServicesExtensionsApp.cs:**

```csharp
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();
```
:::

::: details Código con fallos para Copilot

```csharp
// ⚠️ CÓDIGO CON FALLOS - Usa Copilot para encontrar y arreglar los errores
public class Unidades
{
    private readonly IClaseOracleBd _bd;

    // 🐛 Constructor sin parámetro - falta inyección de dependencias
    public Unidades() { }

    public Result<List<ClaseUnidad>> ObtenerActivas(string idioma)
    {
        // 🐛 FLG_ACTIVA es VARCHAR2 'S'/'N', no un número
        const string sql = "SELECT * FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 1";
        var lista = _bd.ObtenerTodosMap<ClaseUnidad>(sql);
        // 🐛 No gestiona null y no pasa el idioma (no habrá multiidioma)
        return Result<List<ClaseUnidad>>.Success(lista.ToList());
    }

    public Result<ClaseUnidad> ObtenerPorId(int id, string idioma)
    {
        // 🐛 Parámetro inline - SQL injection + usa tabla directa en vez de vista
        var sql = $"SELECT * FROM TCTS_UNIDADES WHERE ID = {id}";
        var unidad = _bd.ObtenerPrimeroMap<ClaseUnidad>(sql);
        // 🐛 No comprueba null - debería devolver objeto vacío con Id=0
        return Result<ClaseUnidad>.Success(unidad);
    }

    public Result<int> Guardar(ClaseGuardarUnidad dto)
    {
        var parametros = new DynamicParameters();
        // 🐛 Dirección incorrecta: pid es IN OUT, no solo Input
        parametros.Add("pid", dto.Id);
        parametros.Add("pnombre_es", dto.NombreEs);
        // 🐛 Falta convertir bool a 'S'/'N' para Oracle
        parametros.Add("pflg_activa", dto.FlgActiva);
        // 🐛 Faltan parámetros: pnombre_ca, pnombre_en, pgranularidad,
        //    pduracion_max, pflg_requiere_confirmacion, pnum_citas_simultaneas,
        //    pcodper, pip

        _bd.EjecutarParams("PKG_CITAS.GUARDA_UNIDAD", parametros);

        // 🐛 Si pid era IN OUT, necesitamos recuperar el valor generado
        return Result<int>.Success(0);
    }

    // 🐛 RETURN_VALUE no declarado primero (orden incorrecto)
    public decimal ObtenerPeso(int idFoto)
    {
        var p = new DynamicParameters();
        p.Add("P_ID_FOTO", idFoto);
        // 🐛 RETURN_VALUE debe ser el PRIMER parámetro
        p.Add("RETURN_VALUE", null, OracleDbType.Decimal,
            ParameterDirection.ReturnValue);

        _bd.EjecutarParams("PKG_FOTOS.OBTENER_PESO", p);
        return Convert.ToDecimal(p.Get("RETURN_VALUE"));
    }

    // 🐛 Transacción sin EndTransaction en finally
    public void Transferir(int origen, int destino, decimal monto)
    {
        _bd.BeginTransaction();
        try
        {
            _bd.EjecutarParams("PKG.RETIRAR", new { p_cuenta = origen, p_monto = monto });
            _bd.EjecutarParams("PKG.DEPOSITAR", new { p_cuenta = destino, p_monto = monto });
            _bd.Commit();
        }
        catch
        {
            _bd.Rollback();
            throw;
        }
        // 🐛 Falta finally { _bd.EndTransaction(); }
    }
}

// 🐛 Modelo sin [IgnorarMapeo] en propiedad calculada
public class ClaseDocumento
{
    public int IdDocumento { get; set; }
    public string Nombre { get; set; }
    public byte[]? Contenido { get; set; }

    // 🐛 Falta [IgnorarMapeo] — la librería buscará columna TIENE_CONTENIDO
    public bool TieneContenido => Contenido?.Length > 0;
}
```
:::

---

## Tests y práctica IA

- [Ver tests y práctica de la sesión](../../test/sesion-2/)
- [Autoevaluación sesión 2](../../test/sesion-2/autoevaluacion.md)
- [Preguntas de test sesión 2](../../test/sesion-2/preguntas.md)
- [Respuestas del test sesión 2](../../test/sesion-2/respuestas.md)
- [Práctica IA-fix sesión 2](../../test/sesion-2/practica-ia-fix.md)

---

**Anterior:** [Sesión 1: DTOs y APIs](../sesion-1-dtos-apis/) | **Siguiente:** [Sesión 3: Validación, errores y buenas prácticas](../sesion-3-validacion-errores/)
