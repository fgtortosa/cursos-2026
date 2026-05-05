# Test de autoevaluacion -- Sesion 2: Servicios y Oracle

## Pregunta 1

Dado el siguiente enum:

```csharp
public enum ErrorType
{
    Failure = 0,
    Validation = 1
}
```

Si un servicio devuelve un `Result<T>` con `ErrorType.Failure`, que codigo HTTP devuelve `HandleResult`?

a) 400 Bad Request
b) 404 Not Found
c) 409 Conflict
d) 500 Internal Server Error

## Pregunta 2

Observa el siguiente codigo del controlador base:

```csharp
protected ActionResult HandleResult<T>(Result<T> result)
{
    if (result.IsSuccess)
        return Ok(result.Value);

    return result.Error!.Type switch
    {
        ErrorType.Validation => ValidationProblem(...),
        _ => Problem(detail: result.Error.Message, statusCode: 500)
    };
}
```

Que tipo de respuesta genera `HandleResult` cuando `ErrorType` es `Validation`?

a) `ProblemDetails` con status 500
b) `ValidationProblemDetails` con status 400
c) `ProblemDetails` con status 404
d) Un JSON plano con los errores

## Pregunta 3

Cual es la firma correcta del record `Error` en el patron Result de la UA?

a) `public record Error(string Message, int StatusCode);`
b) `public record Error(string Code, string Message, ErrorType Type, IDictionary<string, string[]>? ValidationErrors = null);`
c) `public record Error(ErrorType Type, string Message, Exception InnerException);`
d) `public record Error(string Code, string Message, int HttpStatus);`

## Pregunta 4

Dado este modelo:

```csharp
public class ClaseReserva
{
    public int CodReserva { get; set; }
    public string NombreSala { get; set; }
    public DateTime FechaInicio { get; set; }
}
```

A que columnas Oracle mapeara ClaseOracleBD3 automaticamente?

a) `codReserva`, `nombreSala`, `fechaInicio`
b) `COD_RESERVA`, `NOMBRE_SALA`, `FECHA_INICIO`
c) `CODRESERVA`, `NOMBRESALA`, `FECHAINICIO`
d) Dara error porque no tiene atributos `[Columna]`

## Pregunta 5

Que metodo de ClaseOracleBD3 usarias para obtener una lista de unidades activas desde una vista?

```csharp
const string sql = "SELECT * FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'";
var unidades = ???;
```

a) `bd.EjecutarParams(sql, param: null)`
b) `bd.ObtenerPrimeroMap<ClaseUnidad>(sql, param: null, idioma: "ES")`
c) `bd.ObtenerTodosMap<ClaseUnidad>(sql, param: null, idioma: "ES")`
d) `bd.GetObject<ClaseUnidad>()`

## Pregunta 6

Si buscamos una unidad por ID y no existe en la base de datos, cual es el comportamiento correcto segun el contrato UA?

a) Devolver 404 Not Found
b) Devolver 200 OK con un objeto cuyo `Id = 0`
c) Devolver 500 Internal Server Error
d) Devolver 204 No Content

## Pregunta 7

Observa el siguiente modelo:

```csharp
public class ClaseDocumento
{
    public string Nombre { get; set; }
    public byte[]? Contenido { get; set; }
    public bool TieneContenido => Contenido?.Length > 0;
}
```

Que ocurrira al ejecutar `ObtenerTodosMap<ClaseDocumento>(sql, null)`?

a) Funcionara correctamente, las propiedades calculadas se ignoran automaticamente
b) Error de mapeo: la libreria buscara una columna `TIENE_CONTENIDO` que no existe
c) La propiedad `TieneContenido` se mapeara a la columna `TIENE_CONTENIDO`
d) Error de compilacion por no tener setter

## Pregunta 8

Cual es el atributo correcto para evitar el error de la pregunta anterior?

a) `[JsonIgnore]`
b) `[NotMapped]`
c) `[IgnorarMapeo]`
d) `[Computed]`

## Pregunta 9

Dado este codigo de servicio:

```csharp
public Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES")
{
    const string sql = "SELECT * FROM VCTS_UNIDADES WHERE ID = :id";
    var unidad = bd.ObtenerPrimeroMap<ClaseUnidad>(sql, new { id }, idioma: idioma);
    return Result<ClaseUnidad>.Success(unidad);
}
```

Que problema tiene este codigo?

a) No usa `EjecutarParams` para la consulta
b) Devuelve `Success(null)` si no existe la unidad, en vez de un objeto con `Id = 0`
c) No usa `BindByName(true)`
d) Falta el `try/catch` para `BDException`

## Pregunta 10

Cual es la correccion adecuada del codigo de la pregunta anterior?

a) `return Result<ClaseUnidad>.Failure(new Error(..., ErrorType.Failure));`
b) `return Result<ClaseUnidad>.Success(unidad ?? new ClaseUnidad());`
c) `return Result<ClaseUnidad>.Success(unidad ?? new ClaseUnidad { Id = 0 });`
d) Lanzar una `NotFoundException` si `unidad` es null

## Pregunta 11

Segun la convencion de nombres de la UA, como deben llamarse el DTO de lectura, el servicio y la interfaz para la entidad "Reserva"?

a) `Reserva.cs`, `Reservas.cs`, `IReservas.cs`
b) `ClaseReserva.cs`, `ClaseReservas.cs`, `IClaseReservas.cs`
c) `ReservaDto.cs`, `ReservaService.cs`, `IReservaService.cs`
d) `ClaseReserva.cs`, `ReservasService.cs`, `IReservasService.cs`

## Pregunta 12

Donde se ubican el DTO y el servicio en la estructura de carpetas UA?

a) DTO en `Models/Reserva/` y servicio en `Services/Reserva/`
b) Ambos en `Models/Reserva/` (mismo directorio)
c) DTO en `DTOs/` y servicio en `Models/`
d) Ambos en `Controllers/Apis/`

## Pregunta 13

Observa esta llamada a un procedimiento almacenado:

```csharp
bd.Command.Parameters.Clear();
bd.TipoComando = CommandType.StoredProcedure;
bd.TextoComando = "PKG_CITAS.GUARDA_UNIDAD";

bd.CrearParametro("pid", dto.Id ?? 0,
    OracleDbType.Int32, 0, ParameterDirection.InputOutput);
bd.CrearParametro("pnombre_es", dto.NombreEs);

bd.Ejecutar();

var idGenerado = Convert.ToInt32(
    bd.Command.Parameters["pid"].Value?.ToString() ?? "0");
```

Que falta al final de este codigo?

a) `bd.Commit();`
b) `bd.Command.Parameters.Clear();`
c) `bd.EndTransaction();`
d) `bd.Dispose();`

## Pregunta 14

Para que tipo de operacion Oracle usamos `ParameterDirection.InputOutput`?

a) Solo para consultas SELECT con filtros
b) Para parametros que envian un valor (ej: Id=0 para crear) y reciben otro (ej: Id generado)
c) Para parametros de salida pura que no reciben valor inicial
d) Para el RETURN_VALUE de funciones Oracle

## Pregunta 15

Que ocurre con una columna Oracle `ACTIVO` de tipo `VARCHAR2(1)` con valor `'S'` al mapear a una propiedad `bool Activo`?

a) Error de conversion: VARCHAR2 no se puede convertir a bool
b) Se convierte automaticamente a `true`
c) Se necesita un constructor `IDataRecord` para la conversion
d) Hay que usar `[Columna]` para indicar la conversion

## Pregunta 16

Dado el siguiente modelo con multiidioma:

```csharp
public class ClaseHerramientaIA
{
    public int CodHerramienta { get; set; }
    public string Nombre { get; set; }
    public string Descripcion { get; set; }
    public bool Activo { get; set; }
}
```

Si llamamos a `ObtenerTodosMap<ClaseHerramientaIA>(sql, null, idioma: "CA")`, a que columnas se mapearan `Nombre` y `Descripcion`?

a) `NOMBRE` y `DESCRIPCION`
b) `NOMBRE_CA` y `DESCRIPCION_CA`
c) `NOMBRE_ES` y `DESCRIPCION_ES` (siempre usa espanol por defecto)
d) `CA_NOMBRE` y `CA_DESCRIPCION`

## Pregunta 17

Cual es el orden de prioridad que usa ClaseOracleBD3 para resolver el nombre de columna de una propiedad?

a) PascalCase -> SNAKE_CASE, luego nombre exacto, luego `[Columna]`
b) `[Columna]`, luego nombre exacto (case-insensitive), luego PascalCase -> SNAKE_CASE, luego sufijo idioma
c) Nombre exacto, luego `[Columna]`, luego SNAKE_CASE
d) Solo usa `[Columna]` si existe, si no da error

## Pregunta 18

Dado este modelo:

```csharp
public class ClaseDocumento
{
    [Columna("IDDOC")]
    public int IdDocumento { get; set; }

    [Columna("NOMBREFICH")]
    public string NombreArchivo { get; set; }

    [Columna("FECALTA")]
    public DateTime FechaCreacion { get; set; }
}
```

Por que se usa `[Columna]` en estas propiedades?

a) Porque ClaseOracleBD3 no soporta mapeo automatico
b) Porque las columnas Oracle no siguen la convencion PascalCase -> SNAKE_CASE
c) Porque son columnas de tipo DATE
d) Porque el modelo tiene mas de dos propiedades

## Pregunta 19

Que permisos tiene el usuario web de Oracle sobre las tablas `TCTS_*`?

a) SELECT, INSERT, UPDATE, DELETE
b) Solo SELECT y EXECUTE
c) No tiene permisos directos sobre las tablas — usa vistas para leer y SPs para escribir
d) Solo EXECUTE

## Pregunta 20

Observa el siguiente servicio:

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
    catch (MantenimientoException)
    {
        // ???
    }
    catch (BDException ex)
    {
        _logger.LogError(ex, "Error Oracle al obtener unidades");
        return Result<List<ClaseUnidad>>.Failure(
            new Error("Unidad.DbError", "Error al acceder a la base de datos", ErrorType.Failure));
    }
}
```

Que debe hacer el catch de `MantenimientoException`?

a) Devolver `Result.Failure` con `ErrorType.Failure`
b) Relanzar la excepcion (`throw;`) para que la capa superior muestre la pagina de mantenimiento
c) Devolver `Result.Failure` con `ErrorType.Validation`
d) Loggear el error y devolver una lista vacia

## Pregunta 21

Cual es la diferencia entre `ObtenerTodosMap<T>` y `ObtenerPrimeroMap<T>`?

a) `ObtenerTodosMap` es asincrono y `ObtenerPrimeroMap` es sincrono
b) `ObtenerTodosMap` devuelve `IEnumerable<T>?` y `ObtenerPrimeroMap` devuelve `T?`
c) `ObtenerTodosMap` usa vistas y `ObtenerPrimeroMap` usa tablas directamente
d) No hay diferencia, son alias del mismo metodo

## Pregunta 22

Dado el siguiente codigo:

```csharp
var p = new DynamicParameters();
p.Add("RETURN_VALUE", null, OracleDbType.Decimal, ParameterDirection.ReturnValue);
p.Add("P_ID_FOTO", idFoto);

bd.EjecutarParams("PKG_FOTOS.OBTENER_PESO", p);

return Convert.ToDecimal(p.Get("RETURN_VALUE"));
```

Que ocurriria si movemos `RETURN_VALUE` despues de `P_ID_FOTO`?

a) Nada, el orden no importa
b) Oracle lanzara un error porque `RETURN_VALUE` debe ser el primer parametro
c) El valor de retorno sera 0
d) Se ejecutara pero devolvera el valor de `P_ID_FOTO`

## Pregunta 23

Como se registra el servicio `ClaseUnidades` en la inyeccion de dependencias?

a) `builder.Services.AddSingleton<IClaseUnidades, ClaseUnidades>();`
b) `builder.Services.AddTransient<IClaseUnidades, ClaseUnidades>();`
c) `builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();`
d) `builder.Services.AddScoped<ClaseUnidades>();`

## Pregunta 24

En el patron de transacciones de ClaseOracleBD3, cual es el orden correcto?

a) `BeginTransaction` -> `Ejecutar` -> `EndTransaction` -> `Commit`
b) `BeginTransaction` -> `Ejecutar` -> `Commit` (try) -> `Rollback` (catch) -> `EndTransaction` (finally)
c) `Commit` -> `BeginTransaction` -> `Ejecutar` -> `EndTransaction`
d) `BeginTransaction` -> `Ejecutar` -> `Rollback` (try) -> `Commit` (catch)

## Pregunta 25

Observa esta propiedad en un modelo:

```csharp
public class ClaseUsuario
{
    public string Nombre { get; set; }
    public string Apellidos { get; set; }

    [IgnorarMapeo]
    public string NombreCompleto => $"{Nombre} {Apellidos}";
}
```

Por que `NombreCompleto` lleva `[IgnorarMapeo]`?

a) Porque es una propiedad de solo lectura
b) Porque no existe como columna en la base de datos y es calculada a partir de otras propiedades
c) Porque contiene caracteres especiales
d) Porque no queremos que se serialice a JSON

## Pregunta 26

Que devuelve el siguiente metodo del servicio cuando `bd.ObtenerPrimeroMap` retorna `null`?

```csharp
public Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES")
{
    const string sql = "SELECT * FROM VCTS_UNIDADES WHERE ID = :id";
    var unidad = bd.ObtenerPrimeroMap<ClaseUnidad>(sql, new { id }, idioma: idioma);
    return Result<ClaseUnidad>.Success(unidad ?? new ClaseUnidad { Id = 0 });
}
```

a) `Result` con `IsSuccess = false` y `Error` con `ErrorType.Failure`
b) `Result` con `IsSuccess = true` y `Value` con un objeto `ClaseUnidad` cuyo `Id = 0`
c) Una excepcion `NullReferenceException`
d) `Result` con `IsSuccess = false` y HTTP 404

## Pregunta 27

Que codigo HTTP recibe el frontend cuando el resultado del servicio es `Result<T>.Success(valor)`?

a) 201 Created
b) 204 No Content
c) 200 OK con el valor serializado
d) Depende del tipo de `T`

## Pregunta 28

Dado el siguiente contrato de error UA, cual de estas afirmaciones es FALSA?

a) `ErrorType.Validation` produce HTTP 400
b) `ErrorType.Failure` produce HTTP 500
c) Si un recurso no se encuentra, se devuelve HTTP 404
d) El contrato solo define dos codigos de error: 400 y 500

## Pregunta 29

En el modelo `ClaseGuardarUnidad`, que atributo debe llevar la propiedad `CodPer` que se rellena en el controlador y NO viene del JSON del cliente?

a) `[Required]`
b) `[IgnorarMapeo]`
c) `[JsonIgnore]`
d) `[Columna("CODPER")]`

## Pregunta 30

Observa este codigo del controlador:

```csharp
[HttpPost]
public ActionResult Guardar([FromBody] ClaseGuardarUnidad dto)
{
    dto.CodPer = 0;
    dto.Ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
    return HandleResult(_unidades.Guardar(dto));
}
```

Por que se asigna `CodPer` e `Ip` en el controlador y no se espera del JSON del cliente?

a) Porque son campos opcionales
b) Por seguridad: estos valores deben venir del servidor (usuario autenticado e IP real), nunca del cliente
c) Porque el JSON no soporta enteros
d) Porque ClaseOracleBD3 no puede mapear esos campos

## Pregunta 31

Que tipo de retorno tiene `EjecutarParams` (version sincrona)?

a) `int` (filas afectadas)
b) `bool` (exito/fallo)
c) `void`
d) `Result<T>`

## Pregunta 32

Cual es la forma correcta de pasar multiples parametros a una consulta con `ObtenerTodosMap`?

a) `bd.ObtenerTodosMap<T>(sql, "activo=S&sala=A")`
b) `bd.ObtenerTodosMap<T>(sql, new { activo = "S", sala = "A" })`
c) `bd.ObtenerTodosMap<T>(sql, new List<string> { "S", "A" })`
d) `bd.ObtenerTodosMap<T>(sql, ("S", "A"))`

## Pregunta 33

Por que es importante llamar a `bd.BindByName(true)` antes de consultas con parametros nombrados?

a) Para que Oracle use el driver moderno
b) Para que los parametros se vinculen por nombre y no por posicion, evitando errores con multiples parametros
c) Para activar el cache de consultas
d) Para habilitar el mapeo automatico PascalCase -> SNAKE_CASE

## Pregunta 34

Observa este fragmento de codigo:

```csharp
public class ClasePermiso
{
    public int CodPermiso { get; set; }
    public string Descripcion { get; set; }
    public bool Activo { get; set; }

    public ClasePermiso() { }

    public ClasePermiso(IDataRecord reader)
    {
        CodPermiso = Convert.ToInt32(reader["COD_PERMISO"]);
        Descripcion = reader["DESCRIPCION"].ToString();
        Activo = reader["ACTIVO"].ToString() == "S";
    }
}
```

Este codigo corresponde al estilo:

a) Moderno con mapeo automatico
b) Legacy con constructor `IDataRecord` para mapeo manual
c) Patron Repository con Entity Framework
d) Mapeo con Dapper

## Pregunta 35

Cual de estas conversiones automaticas de tipo Oracle -> .NET es INCORRECTA?

a) `VARCHAR2 'S'` -> `bool true`
b) `NUMBER` -> `int`
c) `BLOB` -> `byte[]`
d) `CLOB` -> `int`

## Pregunta 36

Dado este codigo con `DynamicParameters`:

```csharp
var p = new DynamicParameters();
p.Add("P_NOMBRE", nombre);
p.Add("P_EMAIL", email);
p.Add("P_ID_GENERADO", null, OracleDbType.Decimal, ParameterDirection.Output);

bd.EjecutarParams("PKG_USUARIOS.CREAR_USUARIO", p);

var id = ???;
```

Como se recupera el valor del parametro de salida `P_ID_GENERADO`?

a) `bd.Command.Parameters["P_ID_GENERADO"].Value`
b) `p.Get("P_ID_GENERADO")`
c) `p["P_ID_GENERADO"]`
d) `bd.GetOutput("P_ID_GENERADO")`

## Pregunta 37

En la conveccion UA, como se llama el DTO de entrada para guardar una unidad?

a) `UnidadInput.cs`
b) `ClaseUnidadDto.cs`
c) `ClaseGuardarUnidad.cs`
d) `SaveUnidadRequest.cs`

## Pregunta 38

Que propiedad de `Result<T>` indica si la operacion fue exitosa?

a) `Result.Success`
b) `Result.IsSuccess`
c) `Result.Ok`
d) `Result.HasValue`

## Pregunta 39

Observa esta registracion de servicio:

```csharp
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();
```

En que archivo de la estructura UA se encuentra esta linea?

a) `Program.cs`
b) `Controllers/ApiControllerBase.cs`
c) `Models/Plantilla/Inicializacion/ServicesExtensionsApp.cs`
d) `Startup.cs`

## Pregunta 40

Dado este servicio que usa `postMapeo`:

```csharp
var datos = bd.ObtenerTodosMap<ClaseUsuario>(
    sql,
    parametros,
    funcionPostMapeo: (item, rs) =>
    {
        item.EsAdmin = (rs["ROL"]?.ToString() ?? "") == "ADMIN";
        item.NombreCompleto = $"{item.Nombre} {item.Apellidos}";
    });
```

Para que sirve `funcionPostMapeo`?

a) Para filtrar resultados despues de la consulta SQL
b) Para ejecutar logica de conversion personalizada despues del mapeo automatico
c) Para validar los datos antes de devolverlos
d) Para reemplazar completamente el mapeo automatico

## Pregunta 41

Dado el siguiente contrato simplificado de errores UA, que afirmacion es correcta?

```csharp
return result.Error!.Type switch
{
    ErrorType.Validation => ValidationProblem(..., Status = 400),
    _ => Problem(detail: result.Error.Message, statusCode: 500)
};
```

a) Si el servicio no encuentra un recurso, el controlador devuelve 404
b) El wildcard `_` captura cualquier `ErrorType` que no sea `Validation` y devuelve 500
c) `ErrorType.Failure` devuelve 400
d) Hay un caso especifico para `ErrorType.NotFound` que devuelve 404

## Pregunta 42

Que pasa si creas un modelo con esta propiedad y la columna Oracle es `COD_USR`?

```csharp
public class ClaseUsuario
{
    public string CodUsr { get; set; }
}
```

a) Mapea correctamente porque `CodUsr` -> `COD_USR`
b) Falla porque `CodUsr` se convierte a `COD_USR` pero la "r" de "Usr" no genera un guion bajo nuevo
c) Necesita `[Columna("COD_USR")]` porque la conversion PascalCase -> SNAKE_CASE no funciona con abreviaturas
d) Mapea a `CODUSR`

## Pregunta 43

Observa este fragmento del servicio `Guardar`:

```csharp
bd.CrearParametro("pflg_activa", dto.FlgActiva ? "S" : "N");
```

Por que se convierte el `bool` a `"S"` o `"N"` manualmente?

a) Porque ClaseOracleBD3 no soporta booleanos
b) Porque el parametro de entrada del SP Oracle espera un `VARCHAR2`, no un booleano
c) Porque es una convencion de la UA sin motivo tecnico
d) Porque `bool` no existe en C#

## Pregunta 44

Cuando debemos usar la version asincrona (`ObtenerTodosMapAsync`) en lugar de la sincrona?

a) Siempre, la sincrona esta obsoleta
b) En APIs web con concurrencia media/alta y operaciones I/O bound
c) Solo para consultas que devuelven mas de 100 registros
d) Nunca, en la UA solo se usa la sincrona

## Pregunta 45

Que informacion incluye un `ValidationProblemDetails` que no tiene un `ProblemDetails` generico?

a) El stack trace de la excepcion
b) Un diccionario `errors` con los errores de validacion agrupados por campo
c) El nombre del usuario que causo el error
d) La query SQL que fallo

## Pregunta 46

Dado este modelo:

```csharp
public class ClaseUnidad
{
    public int Id { get; set; }
    public string Nombre { get; set; }
    public bool FlgActiva { get; set; }
    public int Granularidad { get; set; }
}
```

Si ejecutamos `ObtenerTodosMap<ClaseUnidad>(sql, null, idioma: "EN")`, a que columna se mapeara la propiedad `Nombre`?

a) `NOMBRE`
b) `NOMBRE_EN`
c) `NAME`
d) `NOMBRE_ES` (siempre usa espanol)

## Pregunta 47

Observa el siguiente patron de creacion de `Result<T>`:

```csharp
public static Result<T> Success(T value) => new(value);
public static Result<T> Failure(Error error) => new(error);
```

Por que los constructores de `Result<T>` son `private`?

a) Para obligar a usar los metodos estaticos `Success` y `Failure`, haciendo el codigo mas expresivo
b) Porque C# no permite constructores publicos en clases genericas
c) Para mejorar el rendimiento
d) Porque Result es un `record` y los records no tienen constructores publicos

## Pregunta 48

Que excepcion lanza ClaseOracleBD3 cuando la cuenta Oracle esta bloqueada (ORA-28000)?

a) `BDException`
b) `OracleException`
c) `MantenimientoException`
d) `UnauthorizedAccessException`

## Pregunta 49

Observa el siguiente fragmento del controlador:

```csharp
[Route("api/[controller]")]
[ApiController]
public class UnidadesController : ApiControllerBase
{
    private readonly IClaseUnidades _unidades;

    public UnidadesController(IClaseUnidades unidades) => _unidades = unidades;

    [HttpGet]
    public ActionResult Listar([FromQuery] string idioma = "ES")
        => HandleResult(_unidades.ObtenerActivas(idioma));
}
```

De donde obtiene el controlador la instancia de `IClaseUnidades`?

a) La crea con `new ClaseUnidades()`
b) La obtiene del contenedor de inyeccion de dependencias a traves del constructor
c) La obtiene de una propiedad estatica
d) La crea el atributo `[ApiController]`

## Pregunta 50

En el patron de la UA, donde debe ir la logica SQL y de acceso a datos?

a) En el controlador (`UnidadesController.cs`)
b) En el modelo DTO (`ClaseUnidad.cs`)
c) En el servicio (`ClaseUnidades.cs`)
d) En `Program.cs`
