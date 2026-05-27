---
title: "Preguntas — Sesión 5: Servicios y acceso a Oracle"
description: "Banco de 21 preguntas tipo test sobre ClaseOracleBD3, mapeo automático, Result<T> básico, paquetes PL/SQL con OUT params y patrón de servicio."
outline: [2, 2]
search: false
---

# Test de autoevaluación — Sesión 5: Servicios y acceso a Oracle

::: tip ALCANCE
Las preguntas cubren **solo** lo que se enseña en esta sesión: separación de capas, `ClaseOracleBD3` (mapeo automático PascalCase → SNAKE_CASE, `[Columna]`, `[IgnorarMapeo]`, idioma), `Result<T>` con `Success`/`NotFound`/`Failure`, paquetes PL/SQL con `OUT` params y patrón de servicio + registro DI.

Los temas relacionados que se cubren en otras sesiones tienen su propio test:
- `HandleResult` interno (mapeo `ErrorType` → HTTP), `ProblemDetails` / `ValidationProblemDetails` detallados, `ErrorPaquetePlSql.DesdeCodigo` → [Sesión 16](../../../04-integracion/sesiones/sesion-16-errores/).
- Tests xUnit con `OracleTestFixture`, `[SkippableFact]`, fakes → [Sesión 21](../../../05-avanzadas/sesiones/sesion-21-tests-calidad/).
- FluentValidation y localización → [Sesión 15](../../../04-integracion/sesiones/sesion-15-validacion/).
:::

## Pregunta 1

Observa el siguiente modelo:

```csharp
public class ClaseDocumento
{
    public string Nombre { get; set; }
    public byte[]? Contenido { get; set; }
    public bool TieneContenido => Contenido?.Length > 0;
}
```

¿Qué ocurrirá al ejecutar `ObtenerTodosMap<ClaseDocumento>(sql, null)`?

a) Funcionará correctamente, las propiedades calculadas se ignoran automáticamente
b) Error de mapeo: la librería buscará una columna `TIENE_CONTENIDO` que no existe
c) La propiedad `TieneContenido` se mapeará a la columna `TIENE_CONTENIDO`
d) Error de compilación por no tener setter

## Pregunta 2

¿Cuál es el atributo correcto para evitar el error de la pregunta anterior?

a) `[JsonIgnore]`
b) `[NotMapped]`
c) `[IgnorarMapeo]`
d) `[Computed]`

## Pregunta 3

Según la convención de nombres de la UA, ¿cómo deben llamarse el DTO de lectura, el servicio y la interfaz para la entidad "Reserva"?

a) `Reserva.cs`, `Reservas.cs`, `IReservas.cs`
b) `ClaseReserva.cs`, `ClaseReservas.cs`, `IClaseReservas.cs`
c) `ReservaDto.cs`, `ReservaService.cs`, `IReservaService.cs`
d) `ClaseReserva.cs`, `ReservasService.cs`, `IReservasService.cs`

## Pregunta 4

Observa esta llamada a un procedimiento almacenado:

```csharp
bd.Command.Parameters.Clear();
bd.TipoComando = CommandType.StoredProcedure;
bd.TextoComando = "PKG_RES_RESERVA.CREAR";

bd.CrearParametro("p_id", dto.Id ?? 0,
    OracleDbType.Int32, 0, ParameterDirection.InputOutput);
bd.CrearParametro("p_nombre_es", dto.NombreEs);

bd.Ejecutar();

var idGenerado = Convert.ToInt32(
    bd.Command.Parameters["p_id"].Value?.ToString() ?? "0");
```

¿Qué falta al final de este código (antes de la siguiente llamada al paquete)?

a) `bd.Commit();`
b) `bd.Command.Parameters.Clear();`
c) `bd.EndTransaction();`
d) `bd.Dispose();`

## Pregunta 5

¿Para qué tipo de operación Oracle usamos `ParameterDirection.InputOutput`?

a) Solo para consultas SELECT con filtros
b) Para parámetros que envían un valor (ej: `Id=0` para crear) y reciben otro (ej: `Id` generado)
c) Para parámetros de salida pura que no reciben valor inicial
d) Para el `RETURN_VALUE` de funciones Oracle

## Pregunta 6

¿Qué ocurre con una columna Oracle `ACTIVO` de tipo `VARCHAR2(1)` con valor `'S'` al mapear a una propiedad `bool Activo`?

a) Error de conversión: `VARCHAR2` no se puede convertir a `bool`
b) Se convierte automáticamente a `true`
c) Se necesita un constructor `IDataRecord` para la conversión
d) Hay que usar `[Columna]` para indicar la conversión

## Pregunta 7

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

Si llamamos a `ObtenerTodosMap<ClaseHerramientaIA>(sql, null, idioma: "CA")`, ¿a qué columnas se mapearán `Nombre` y `Descripcion`?

a) `NOMBRE` y `DESCRIPCION`
b) `NOMBRE_CA` y `DESCRIPCION_CA`
c) `NOMBRE_ES` y `DESCRIPCION_ES` (siempre usa español por defecto)
d) `CA_NOMBRE` y `CA_DESCRIPCION`

## Pregunta 8

¿Cuál es el orden de prioridad que usa `ClaseOracleBD3` para resolver el nombre de columna de una propiedad?

a) PascalCase → SNAKE_CASE, luego nombre exacto, luego `[Columna]`
b) `[Columna]`, luego nombre exacto (case-insensitive), luego PascalCase → SNAKE_CASE, luego sufijo idioma
c) Nombre exacto, luego `[Columna]`, luego SNAKE_CASE
d) Solo usa `[Columna]` si existe, si no da error

## Pregunta 9

¿Qué permisos tiene el usuario web de Oracle sobre las tablas `TRES_*`?

a) `SELECT`, `INSERT`, `UPDATE`, `DELETE`
b) Solo `SELECT` y `EXECUTE`
c) No tiene permisos directos sobre las tablas — usa vistas `VRES_*` para leer y paquetes `PKG_RES_*` para escribir
d) Solo `EXECUTE`

## Pregunta 10

¿Cuál es la diferencia entre `ObtenerTodosMap<T>` y `ObtenerPrimeroMap<T>`?

a) `ObtenerTodosMap` es asíncrono y `ObtenerPrimeroMap` es síncrono
b) `ObtenerTodosMap` devuelve `IEnumerable<T>?` y `ObtenerPrimeroMap` devuelve `T?`
c) `ObtenerTodosMap` usa vistas y `ObtenerPrimeroMap` usa tablas directamente
d) No hay diferencia, son alias del mismo método

## Pregunta 11

¿Cómo se registra el servicio `ClaseUnidades` en la inyección de dependencias?

a) `builder.Services.AddSingleton<IClaseUnidades, ClaseUnidades>();`
b) `builder.Services.AddTransient<IClaseUnidades, ClaseUnidades>();`
c) `builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();`
d) `builder.Services.AddScoped<ClaseUnidades>();`

## Pregunta 12

¿Qué devuelve el siguiente método del servicio cuando `bd.ObtenerPrimeroMap` retorna `null`?

```csharp
public Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES")
{
    const string sql = "SELECT * FROM VRES_UNIDAD WHERE ID = :id";
    var unidad = bd.ObtenerPrimeroMap<ClaseUnidad>(sql, new { id }, idioma: idioma);
    return unidad is null
        ? Result<ClaseUnidad>.NotFound("UNIDAD_NO_ENCONTRADA", $"No existe una unidad con id {id}")
        : Result<ClaseUnidad>.Success(unidad);
}
```

a) `Result` con `IsSuccess = true` y `Value` igual a `null`
b) `Result` con `IsSuccess = false` y `Error.Type = ErrorType.NotFound`
c) Una excepción `NullReferenceException`
d) `Result` con `IsSuccess = true` y `Value` con un objeto cuyo `Id = 0`

## Pregunta 13

¿Qué código HTTP recibe el frontend cuando el resultado del servicio es `Result<T>.Success(valor)`?

a) 201 Created
b) 204 No Content
c) 200 OK con el valor serializado
d) Depende del tipo de `T`

## Pregunta 14

Dado el contrato de errores UA, ¿cuál de estas afirmaciones es **FALSA**?

a) `ErrorType.Validation` produce HTTP 400
b) `ErrorType.Failure` produce HTTP 500
c) Si un recurso no se encuentra, se devuelve HTTP 404
d) El contrato solo define dos códigos de error: 400 y 500

## Pregunta 15

Observa este código del controlador:

```csharp
[HttpPost]
public ActionResult Crear([FromBody] ReservaCrearDto dto)
{
    // CodPer del JWT (CodPer de ControladorBase), nunca del body
    return HandleResult(_reservas.CrearAsync(CodPer, dto).Result);
}
```

¿Por qué se asigna `CodPer` desde `ControladorBase` y no se acepta del JSON del cliente?

a) Porque es un campo opcional
b) Por seguridad: el `CodPer` debe venir del servidor (token JWT del usuario autenticado), nunca del cliente
c) Porque el JSON no soporta enteros
d) Porque `ClaseOracleBD3` no puede mapear ese campo

## Pregunta 16

¿Qué tipo de retorno tiene `EjecutarParams` (versión síncrona)?

a) `int` (filas afectadas)
b) `bool` (éxito/fallo)
c) `void`
d) `Result<T>`

## Pregunta 17

¿Cuál es la forma correcta de pasar múltiples parámetros a una consulta con `ObtenerTodosMap`?

a) `bd.ObtenerTodosMap<T>(sql, "activo=S&sala=A")`
b) `bd.ObtenerTodosMap<T>(sql, new { activo = "S", sala = "A" })`
c) `bd.ObtenerTodosMap<T>(sql, new List<string> { "S", "A" })`
d) `bd.ObtenerTodosMap<T>(sql, ("S", "A"))`

## Pregunta 18

¿Qué propiedad de `Result<T>` indica si la operación fue exitosa?

a) `Result.Success`
b) `Result.IsSuccess`
c) `Result.Ok`
d) `Result.HasValue`

## Pregunta 19

¿Qué pasa si creas un modelo con esta propiedad y la columna Oracle es `COD_USR`?

```csharp
public class ClaseUsuario
{
    public string CodUsr { get; set; }
}
```

a) Mapea correctamente porque `CodUsr` → `COD_USR`
b) Falla porque `CodUsr` se convierte a `COD_USR` pero la "r" de "Usr" no genera un guion bajo nuevo
c) Necesita `[Columna("COD_USR")]` porque la conversión PascalCase → SNAKE_CASE no funciona con abreviaturas
d) Mapea a `CODUSR`

## Pregunta 20

Observa este fragmento del servicio `Crear`:

```csharp
bd.CrearParametro("p_flg_activa", dto.FlgActiva ? "S" : "N");
```

¿Por qué se convierte el `bool` a `"S"` o `"N"` manualmente al llamar al paquete?

a) Porque `ClaseOracleBD3` no soporta booleanos
b) Porque el parámetro de entrada del paquete Oracle espera un `VARCHAR2`, no un booleano (Oracle no tiene `BOOLEAN` nativo en la API SQL)
c) Porque es una convención de la UA sin motivo técnico
d) Porque `bool` no existe en C#

## Pregunta 21

En el patrón de la UA, ¿dónde debe ir la lógica SQL y de acceso a datos?

a) En el controlador (`ReservasController.cs`)
b) En el modelo DTO (`ClaseReserva.cs`)
c) En el servicio (`ReservasServicio.cs`)
d) En `Program.cs`
