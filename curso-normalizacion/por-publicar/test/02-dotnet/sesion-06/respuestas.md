---
title: "Respuestas — Sesión 6: Servicios y acceso a Oracle"
description: "Solucionario razonado del test de 21 preguntas de la Sesión 6."
outline: [2, 2]
search: false
---

# Respuestas — Test Sesión 6: Servicios y acceso a Oracle

1. **b)** Error de mapeo: la librería buscará una columna `TIENE_CONTENIDO` que no existe. `ClaseOracleBD3` intenta mapear TODAS las propiedades públicas del modelo a columnas Oracle. Sin `[IgnorarMapeo]`, buscará una columna para `TieneContenido` y fallará al no encontrarla.

2. **c)** `[IgnorarMapeo]`. Es el atributo propio de `ClaseOracleBD3` que indica que una propiedad no corresponde a ninguna columna de la base de datos. `[JsonIgnore]` es para serialización JSON, `[NotMapped]` es de Entity Framework, y `[Computed]` no existe en este contexto.

3. **b)** `ClaseReserva.cs`, `ClaseReservas.cs`, `IClaseReservas.cs`. La convención UA usa prefijo `Clase` + singular para el DTO, `Clase` + plural para el servicio, e `I` + `Clase` + plural para la interfaz.

4. **b)** `bd.Command.Parameters.Clear();`. Después de cada `bd.Ejecutar()`, hay que limpiar los parámetros para evitar que se acumulen entre llamadas sucesivas al paquete. Es un patrón obligatorio en `ClaseOracleBD3`.

5. **b)** Para parámetros que envían un valor (ej: `Id=0` para crear) y reciben otro (ej: `Id` generado). `InputOutput` se usa típicamente con el parámetro `p_id` que vale 0 para creación (Oracle genera el `ID` desde una secuencia) o un valor existente para modificación.

6. **b)** Se convierte automáticamente a `true`. `ClaseOracleBD3` convierte automáticamente `'S'`, `'Y'`, `'1'`, `'SI'` a `true` y cualquier otro valor a `false` cuando la propiedad destino es `bool`.

7. **b)** `NOMBRE_CA` y `DESCRIPCION_CA`. Cuando se pasa `idioma: "CA"`, `ClaseOracleBD3` añade el sufijo `_CA` a las propiedades de tipo `string` que tengan columnas multiidioma, buscando `NOMBRE_CA` y `DESCRIPCION_CA`.

8. **b)** `[Columna]`, luego nombre exacto (case-insensitive), luego PascalCase → SNAKE_CASE, luego sufijo idioma. La prioridad más alta es el atributo `[Columna]`, seguido del nombre exacto de la propiedad, luego la conversión automática PascalCase → SNAKE_CASE, y finalmente la búsqueda con sufijo de idioma.

9. **c)** No tiene permisos directos sobre las tablas — usa vistas `VRES_*` para leer y paquetes `PKG_RES_*` para escribir. El usuario web solo tiene `SELECT` sobre vistas (`VRES_*`) y `EXECUTE` sobre paquetes (`PKG_RES_*`). No puede hacer `INSERT`, `UPDATE` ni `DELETE` directamente en las tablas `TRES_*`.

10. **b)** `ObtenerTodosMap` devuelve `IEnumerable<T>?` y `ObtenerPrimeroMap` devuelve `T?`. El primero retorna una colección (que puede ser null), el segundo retorna un único objeto o null si no hay resultados.

11. **c)** `builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();`. Los servicios que dependen de `ClaseOracleBd` (que es `Scoped`) deben registrarse como `Scoped`. `Singleton` causaría captive dependency con la conexión a BD, y sin interfaz se pierde la capacidad de fakear en tests.

12. **b)** `Result` con `IsSuccess = false` y `Error.Type = ErrorType.NotFound`. El operador ternario comprueba si `unidad is null` y en ese caso retorna `Result<ClaseUnidad>.NotFound(...)`, que tiene `IsSuccess = false` y el error tipado como `NotFound`. `HandleResult` lo convertirá en un `404 Not Found` con `ProblemDetails`.

13. **c)** 200 OK con el valor serializado. Cuando `result.IsSuccess` es `true`, `HandleResult` ejecuta `return Ok(result.Value)`, que produce un HTTP 200 con el valor serializado a JSON.

14. **d)** El contrato solo define dos códigos de error: 400 y 500 → FALSA. El contrato UA define tres códigos de error: 400 para `Validation`, 404 para `NotFound` y 500 para `Failure`. La afirmación c) es VERDADERA: cuando un recurso no se encuentra, el servicio retorna `Result.NotFound(...)` y `HandleResult` lo convierte en 404. (El detalle completo del mapeo `ErrorType` → HTTP se ve en la sesión 16.)

15. **b)** Por seguridad: el `CodPer` debe venir del servidor (token JWT del usuario autenticado), nunca del cliente. `CodPer` se lee del JWT en `ControladorBase`. Aceptar este valor del body sería una vulnerabilidad: un usuario malicioso podría crear recursos a nombre de otra persona.

16. **c)** `void`. `EjecutarParams` en su versión síncrona no devuelve valor. Se usa para ejecutar procedimientos almacenados que no retornan conjuntos de datos. Los valores de salida (`OUT` / `InputOutput`) se recuperan vía `bd.Command.Parameters["p_xxx"].Value`.

17. **b)** `bd.ObtenerTodosMap<T>(sql, new { activo = "S", sala = "A" })`. Los parámetros se pasan como un objeto anónimo donde cada propiedad corresponde a un parámetro SQL nombrado (`:activo`, `:sala`).

18. **b)** `Result.IsSuccess`. La propiedad `IsSuccess` de `Result<T>` indica si la operación fue exitosa (`true`) o si hubo un error (`false`). Es una propiedad de solo lectura establecida en el constructor.

19. **c)** Necesita `[Columna("COD_USR")]` porque la conversión PascalCase → SNAKE_CASE no funciona con abreviaturas. `CodUsr` se convertiría a `COD_USR` solo si "Usr" se descompone correctamente, pero las abreviaturas pueden no seguir el patrón esperado. Cuando los nombres de columna son abreviaturas, `[Columna]` es necesario.

20. **b)** Porque el parámetro de entrada del paquete Oracle espera un `VARCHAR2`, no un booleano (Oracle no tiene `BOOLEAN` nativo en la API SQL). Los paquetes PL/SQL usan `VARCHAR2` con valores `'S'`/`'N'`, por lo que hay que convertir el `bool` de C# al string equivalente al pasar el parámetro.

21. **c)** En el servicio (`ReservasServicio.cs`). En la arquitectura de capas de la UA, toda la lógica SQL y de acceso a datos va en el servicio. Los controladores solo orquestan (reciben la petición, llaman al servicio, devuelven el resultado con `HandleResult`). Los DTOs son solo estructuras de datos.
