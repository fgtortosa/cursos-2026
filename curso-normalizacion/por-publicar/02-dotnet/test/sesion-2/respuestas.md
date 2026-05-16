# Respuestas -- Test Sesion 2: Servicios y Oracle

1. **d)** 500 Internal Server Error. `HandleResult` define tres ramas de error: `Validation` → 400, `NotFound` → 404, y el wildcard `_` (que captura `Failure` y cualquier tipo adicional) → 500. El tipo `Failure` cae siempre en el wildcard y devuelve 500.

2. **b)** `ValidationProblemDetails` con status 400. Cuando `ErrorType` es `Validation`, `HandleResult` genera un `ValidationProblemDetails` que incluye un diccionario `errors` con los errores agrupados por campo y status 400.

3. **b)** `public record Error(string Code, string Message, ErrorType Type, IDictionary<string, string[]>? ValidationErrors = null);`. El record `Error` tiene cuatro propiedades: `Code` (codigo de error), `Message` (mensaje), `Type` (enum `ErrorType`) y `ValidationErrors` (diccionario opcional para errores de validacion por campo).

4. **b)** `COD_RESERVA`, `NOMBRE_SALA`, `FECHA_INICIO`. ClaseOracleBD3 convierte automaticamente PascalCase a SNAKE_CASE en mayusculas. Cada letra mayuscula (excepto la primera) genera un guion bajo.

5. **c)** `bd.ObtenerTodosMap<ClaseUnidad>(sql, param: null, idioma: "ES")`. Para obtener una lista de objetos se usa `ObtenerTodosMap<T>`. `ObtenerPrimeroMap` devuelve un solo objeto, `EjecutarParams` es para procedimientos almacenados sin retorno, y `GetObject` es el metodo legacy.

6. **a)** Devolver 404 Not Found. Cuando `ObtenerPrimeroMapAsync` devuelve `null`, el servicio retorna `Result<T>.NotFound(codigo, mensaje)`. `HandleResult` tiene un caso explícito para `ErrorType.NotFound` que genera un `404 Not Found` con `ProblemDetails`. El frontend recibe el 404 y muestra el mensaje de error adecuado.

7. **b)** Error de mapeo: la libreria buscara una columna `TIENE_CONTENIDO` que no existe. ClaseOracleBD3 intenta mapear TODAS las propiedades publicas del modelo a columnas Oracle. Sin `[IgnorarMapeo]`, buscara una columna para `TieneContenido` y fallara al no encontrarla.

8. **c)** `[IgnorarMapeo]`. Es el atributo propio de ClaseOracleBD3 que indica que una propiedad no corresponde a ninguna columna de la base de datos. `[JsonIgnore]` es para serializacion JSON, `[NotMapped]` es de Entity Framework, y `[Computed]` no existe en este contexto.

9. **b)** Devuelve `Success(null)` si no existe la unidad, en vez de `Result<ClaseUnidad>.NotFound(...)`. Cuando `ObtenerPrimeroMap` devuelve `null`, el servicio pasa ese `null` directamente a `Result.Success`, y el controlador devolvera un 200 OK con `null` en el body en lugar del 404 esperado.

10. **c)** `return unidad is null ? Result<ClaseUnidad>.NotFound("UNIDAD_NO_ENCONTRADA", $"No existe una unidad con id {id}") : Result<ClaseUnidad>.Success(unidad);`. Cuando la unidad no existe se devuelve `Result.NotFound(...)`, que `HandleResult` convierte en 404. La opcion b) devolveria 200 OK con `Id = 0`, lo que oculta el error al frontend en vez de informarle correctamente.

11. **b)** `ClaseReserva.cs`, `ClaseReservas.cs`, `IClaseReservas.cs`. La convencion UA usa prefijo `Clase` + singular para el DTO, `Clase` + plural para el servicio, e `I` + `Clase` + plural para la interfaz.

12. **b)** Ambos en `Models/Reserva/` (mismo directorio). En la estructura UA, el DTO y el servicio conviven en el mismo directorio dentro de `Models/`. No hay carpeta `Services/` separada.

13. **b)** `bd.Command.Parameters.Clear();`. Despues de cada `bd.Ejecutar()`, hay que limpiar los parametros para evitar que se acumulen entre llamadas sucesivas. Es un patron obligatorio en ClaseOracleBD3.

14. **b)** Para parametros que envian un valor (ej: Id=0 para crear) y reciben otro (ej: Id generado). `InputOutput` se usa tipicamente con el parametro `pid` que vale 0 para creacion (Oracle genera el ID) o un valor existente para modificacion.

15. **b)** Se convierte automaticamente a `true`. ClaseOracleBD3 convierte automaticamente `'S'`, `'Y'`, `'1'`, `'SI'` a `true` y cualquier otro valor a `false` cuando la propiedad destino es `bool`.

16. **b)** `NOMBRE_CA` y `DESCRIPCION_CA`. Cuando se pasa `idioma: "CA"`, ClaseOracleBD3 anade el sufijo `_CA` a las propiedades de tipo `string` que tengan columnas multiidioma, buscando `NOMBRE_CA` y `DESCRIPCION_CA`.

17. **b)** `[Columna]`, luego nombre exacto (case-insensitive), luego PascalCase -> SNAKE_CASE, luego sufijo idioma. La prioridad mas alta es el atributo `[Columna]`, seguido del nombre exacto de la propiedad, luego la conversion automatica PascalCase -> SNAKE_CASE, y finalmente la busqueda con sufijo de idioma.

18. **b)** Porque las columnas Oracle no siguen la convencion PascalCase -> SNAKE_CASE. `IDDOC` no es `ID_DOCUMENTO`, `NOMBREFICH` no es `NOMBRE_ARCHIVO`, y `FECALTA` no es `FECHA_CREACION`. Cuando los nombres de columna son abreviaturas o no siguen la convencion, `[Columna]` es necesario.

19. **c)** No tiene permisos directos sobre las tablas -- usa vistas para leer y SPs para escribir. El usuario web solo tiene SELECT sobre vistas (`VCTS_*`) y EXECUTE sobre paquetes (`PKG_*`). No puede hacer INSERT, UPDATE ni DELETE directamente en las tablas `TCTS_*`.

20. **b)** Relanzar la excepcion (`throw;`) para que la capa superior muestre la pagina de mantenimiento. `MantenimientoException` indica que la BD esta en mantenimiento o la cuenta bloqueada. Debe propagarse para que la capa superior (middleware) muestre la pagina de mantenimiento, no convertirse en un `Result.Failure`.

21. **b)** `ObtenerTodosMap` devuelve `IEnumerable<T>?` y `ObtenerPrimeroMap` devuelve `T?`. El primero retorna una coleccion (que puede ser null), el segundo retorna un unico objeto o null si no hay resultados.

22. **b)** Oracle lanzara un error porque `RETURN_VALUE` debe ser el primer parametro. En funciones Oracle (no procedimientos), el parametro `RETURN_VALUE` con `ParameterDirection.ReturnValue` debe declararse siempre como el primer parametro en `DynamicParameters`.

23. **c)** `builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();`. Los servicios que dependen de `ClaseOracleBd` (que es scoped) deben registrarse como `Scoped`. `Singleton` causaria problemas con la conexion de BD, y sin interfaz se pierde la capacidad de mockear en tests.

24. **b)** `BeginTransaction` -> `Ejecutar` (try) -> `Commit` (try) -> `Rollback` (catch) -> `EndTransaction` (finally). El `Commit` va en el bloque try tras las operaciones exitosas, `Rollback` en el catch, y `EndTransaction` siempre en el finally para liberar la conexion.

25. **b)** Porque no existe como columna en la base de datos y es calculada a partir de otras propiedades. `NombreCompleto` se calcula concatenando `Nombre` y `Apellidos`. Sin `[IgnorarMapeo]`, ClaseOracleBD3 buscaria una columna `NOMBRE_COMPLETO` que no existe.

26. **b)** `Result` con `IsSuccess = false` y `Error.Type = ErrorType.NotFound`. El operador ternario comprueba si `unidad is null` y en ese caso retorna `Result<ClaseUnidad>.NotFound(...)`, que tiene `IsSuccess = false` y el error tipado como `NotFound`. `HandleResult` lo convertira en un 404 Not Found.

27. **c)** 200 OK con el valor serializado. Cuando `result.IsSuccess` es `true`, `HandleResult` ejecuta `return Ok(result.Value)`, que produce un HTTP 200 con el valor serializado a JSON.

28. **d)** El contrato solo define dos codigos de error: 400 y 500. FALSO. El contrato UA define tres codigos de error: 400 para `Validation`, 404 para `NotFound` y 500 para `Failure`. La afirmacion c) es VERDADERA: cuando un recurso no se encuentra, el servicio retorna `Result.NotFound(...)` y `HandleResult` lo convierte en 404.

29. **c)** `[JsonIgnore]`. Se usa `[JsonIgnore]` para que la propiedad no se deserialice desde el JSON del cliente. El controlador asigna `CodPer` e `Ip` con valores del servidor. `[IgnorarMapeo]` es para ClaseOracleBD3, no para JSON.

30. **b)** Por seguridad: estos valores deben venir del servidor (usuario autenticado e IP real), nunca del cliente. El `CodPer` viene del usuario autenticado (en produccion) y la IP se extrae de la conexion HTTP. Aceptar estos valores del cliente seria una vulnerabilidad de seguridad.

31. **c)** `void`. `EjecutarParams` en su version sincrona no devuelve valor. Se usa para ejecutar procedimientos almacenados que no retornan conjuntos de datos. Los valores de salida se recuperan via `DynamicParameters.Get()` o `bd.Command.Parameters`.

32. **b)** `bd.ObtenerTodosMap<T>(sql, new { activo = "S", sala = "A" })`. Los parametros se pasan como un objeto anonimo donde cada propiedad corresponde a un parametro SQL nombrado (`:activo`, `:sala`).

33. **b)** Para que los parametros se vinculen por nombre y no por posicion, evitando errores con multiples parametros. Sin `BindByName(true)`, Oracle vincula los parametros por orden de declaracion, no por nombre. Esto puede causar errores dificiles de detectar cuando hay varios parametros.

34. **b)** Legacy con constructor `IDataRecord` para mapeo manual. El constructor `IDataRecord` es el estilo antiguo donde se mapea manualmente cada columna a cada propiedad. El estilo moderno usa el mapeo automatico de ClaseOracleBD3 sin necesidad de ese constructor.

35. **d)** `CLOB` -> `int`. Un `CLOB` (Character Large Object) se mapea a `string` en .NET, no a `int`. Los CLOB contienen textos largos. Las demas conversiones son correctas: `VARCHAR2 'S'` -> `bool true`, `NUMBER` -> `int`, `BLOB` -> `byte[]`.

36. **b)** `p.Get("P_ID_GENERADO")`. Cuando se usan `DynamicParameters`, los valores de parametros OUT se recuperan con el metodo `Get` del propio objeto `DynamicParameters`. No se usa `bd.Command.Parameters` en este caso.

37. **c)** `ClaseGuardarUnidad.cs`. La convencion UA para DTOs de entrada usa el prefijo `Clase` + verbo (Guardar/Crear) + nombre singular de la entidad.

38. **b)** `Result.IsSuccess`. La propiedad `IsSuccess` de `Result<T>` indica si la operacion fue exitosa (`true`) o si hubo un error (`false`). Es una propiedad de solo lectura establecida en el constructor.

39. **c)** `Models/Plantilla/Inicializacion/ServicesExtensionsApp.cs`. En la arquitectura UA, los servicios especificos de la aplicacion se registran en `ServicesExtensionsApp.cs` dentro del metodo `AddServicesApp()`. `ClaseOracleBd` se registra automaticamente en la PlantillaMVCCore.

40. **b)** Para ejecutar logica de conversion personalizada despues del mapeo automatico. `funcionPostMapeo` recibe cada objeto ya mapeado junto con el `IDataRecord` original, permitiendo asignar valores que requieren logica especial (roles, campos compuestos) que el mapeo automatico no puede resolver.

41. **a)** Si el servicio devuelve `Result.NotFound(...)`, el controlador devuelve 404. El `switch` tiene tres ramas: `Validation` → 400, `NotFound` → 404 (caso explicito), y el wildcard `_` para `Failure` y cualquier otro tipo → 500. La opcion b) es falsa porque `NotFound` tiene su propio caso y NO cae en el wildcard.

42. **c)** Necesita `[Columna("COD_USR")]` porque la conversion PascalCase -> SNAKE_CASE no funciona con abreviaturas. `CodUsr` se convertiria a `COD_USR` solo si "Usr" se descompone correctamente, pero las abreviaturas pueden no seguir el patron esperado. En la documentacion se indica que `CodUsr` necesita `[Columna("COD_USR")]`.

43. **b)** Porque el parametro de entrada del SP Oracle espera un `VARCHAR2`, no un booleano. Oracle no tiene tipo de dato `boolean` nativo en SQL. Los procedimientos almacenados usan `VARCHAR2` con valores `'S'`/`'N'`, por lo que hay que convertir el `bool` de C# al string equivalente.

44. **b)** En APIs web con concurrencia media/alta y operaciones I/O bound. Las versiones async liberan el hilo mientras esperan la respuesta de Oracle, mejorando la concurrencia del servidor web. Para el curso se usa la version sincrona por simplicidad.

45. **b)** Un diccionario `errors` con los errores de validacion agrupados por campo. `ValidationProblemDetails` extiende `ProblemDetails` anadiendo la propiedad `Errors` (tipo `IDictionary<string, string[]>`) que agrupa los mensajes de error por nombre de campo.

46. **b)** `NOMBRE_EN`. Al pasar `idioma: "EN"`, ClaseOracleBD3 busca la columna con el sufijo del idioma. La propiedad `Nombre` se mapeara a `NOMBRE_EN`. Si se pasara `"ES"`, buscaria `NOMBRE_ES`.

47. **a)** Para obligar a usar los metodos estaticos `Success` y `Failure`, haciendo el codigo mas expresivo. Los constructores privados implementan el patron Factory Method. Al usar `Result<T>.Success(valor)` o `Result<T>.Failure(error)`, el codigo es autodocumentado y no se puede crear un `Result` en un estado inconsistente.

48. **c)** `MantenimientoException`. ClaseOracleBD3 detecta el error ORA-28000 (cuenta bloqueada) y otros indicadores de mantenimiento, lanzando `MantenimientoException` para que la capa superior muestre la pagina de mantenimiento.

49. **b)** La obtiene del contenedor de inyeccion de dependencias a traves del constructor. El constructor recibe `IClaseUnidades` como parametro, y el contenedor de DI de ASP.NET Core inyecta automaticamente la implementacion registrada (`ClaseUnidades`) al crear el controlador.

50. **c)** En el servicio (`ClaseUnidades.cs`). En la arquitectura de capas de la UA, toda la logica SQL y de acceso a datos va en el servicio. Los controladores solo orquestan (reciben la peticion, llaman al servicio, devuelven el resultado con `HandleResult`). Los DTOs son solo estructuras de datos.
