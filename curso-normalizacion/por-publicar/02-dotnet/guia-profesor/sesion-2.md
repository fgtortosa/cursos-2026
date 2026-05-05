# Guia del profesor — Sesion 5: Servicios y acceso a Oracle

## Objetivo y material

| | |
|---|---|
| **Duracion** | ~45 minutos |
| **Objetivo** | El alumno entiende el patron Result\<T\>, la arquitectura de capas UA y sabe conectar con Oracle via ClaseOracleBD3 |
| **Material alumno** | `sesion-2-servicios-oracle.md` |
| **Test** | `sesion-2/tests/preguntas.md` (50 preguntas, seleccionar 10) |
| **Practica IA** | `sesion-2/tests/practica-ia-fix.md` |
| **Prerequisitos** | Sesion 1 completada (DTOs, EcoController, Swagger) |
| **Resultado** | Crear un servicio con lectura desde vista, escritura via SP, null gestionado con Id=0 y mapeo PascalCase → SNAKE_CASE |

---

## Parte 1: Teoria con codigo real (~20 min)

### Bloque 1.1: Patron Result\<T\> y contrato de errores (~5 min)

📂 **Abrir:** `Curso/Models/Errors/ErrorType.cs`
👉 **Mostrar:** Solo dos valores: `Failure = 0` y `Validation = 1`. No hay NotFound, Conflict ni nada mas.
💡 **Enfatizar:** Todo el contrato HTTP de la UA se reduce a dos codigos: **400** (Validation) y **500** (Failure/todo lo demas). No se usa 404 nunca.

📂 **Abrir:** `Curso/Models/Errors/Error.cs`
👉 **Mostrar:** Es un `record` con cuatro campos: `Code`, `Message`, `Type` y `ValidationErrors` opcional. Senalar que `ValidationErrors` solo se rellena cuando `Type == Validation`.

📂 **Abrir:** `Curso/Models/Errors/Result.cs`
👉 **Mostrar:** Los constructores son `private` — solo se puede crear via `Success(T value)` o `Failure(Error error)`. Preguntar a los alumnos por que son privados (respuesta: obliga a usar los metodos estaticos, haciendo el codigo mas expresivo).

📂 **Abrir:** `Curso/Controllers/ApiControllerBase.cs`
👉 **Mostrar:** Ir directamente al metodo `HandleResult<T>()` (lineas 70-85). Senalar el `switch`: Validation → `ValidationProblem` con status 400, wildcard `_` → `Problem` con status 500.
💡 **Enfatizar:** El wildcard `_` captura **cualquier** ErrorType que no sea Validation. Si manana se anade un nuevo tipo, ira a 500 por defecto.

🔗 **Material alumno:** Secciones 2.1 y 2.2

**Pregunta al aula:**
> "Si un servicio no encuentra una unidad por ID, ¿que devolvemos: 404, 200 con null, o 200 con Id=0?"

Respuesta: 200 con Id=0. Explicar que no se usa 404 porque el contrato UA solo tiene 400/500 y porque revelar existencia de recursos con 404 facilita enumeracion de IDs.

⚡ **Si falta tiempo:** Mostrar solo `HandleResult` en `ApiControllerBase.cs` y mencionar los tres ficheros de `Models/Errors/` sin abrirlos.

---

### Bloque 1.2: Arquitectura de capas UA (~5 min)

📂 **Abrir:** Explorador de archivos en `Curso/Models/Unidad/`
👉 **Mostrar:** Los cuatro ficheros conviven en el mismo directorio: `ClaseUnidad.cs` (DTO lectura), `ClaseGuardarUnidad.cs` (DTO entrada), `ClaseUnidades.cs` (servicio), `IClaseUnidades.cs` (interfaz). No hay carpeta `Services/` separada.
💡 **Enfatizar:** Convencion de nombres UA: singular para DTO (`ClaseUnidad`), plural para servicio (`ClaseUnidades`), prefijo `I` para interfaz (`IClaseUnidades`).

📂 **Abrir:** `Curso/Models/Unidad/IClaseUnidades.cs`
👉 **Mostrar:** Todos los metodos devuelven `Result<T>`. El servicio nunca lanza excepciones para flujo de negocio.

📂 **Abrir:** `Curso/Controllers/Apis/UnidadesController.cs`
👉 **Mostrar:** El constructor recibe `IClaseUnidades` por inyeccion de dependencias (linea 13). Cada action llama al servicio y pasa el resultado a `HandleResult`. Senalar en `Guardar` (lineas 57-65) como `CodPer` e `Ip` se asignan en el controlador, no del JSON del cliente.
💡 **Enfatizar:** Por seguridad, datos sensibles (usuario autenticado, IP) siempre vienen del servidor.

🔗 **Material alumno:** Seccion 2.3

**Pregunta al aula:**
> "¿Por que usamos `AddScoped` y no `AddSingleton` para registrar ClaseUnidades?"

Respuesta: porque `ClaseOracleBd` es scoped (una conexion por peticion). Un singleton compartiria conexion entre peticiones → errores de concurrencia.

⚡ **Si falta tiempo:** Saltar la pregunta de AddScoped; mencionarlo de pasada al mostrar el constructor.

---

### Bloque 1.3: ClaseOracleBD3 — mapeo automatico y lectura (~5 min)

📂 **Abrir:** `Curso/Models/Unidad/ClaseUnidad.cs`
👉 **Mostrar:** Las propiedades y los comentarios que indican a que columna Oracle mapea cada una. Senalar: `Id` → `ID`, `Nombre` → `NOMBRE_ES`/`NOMBRE_CA`/`NOMBRE_EN` (multiidioma), `FlgActiva` → `FLG_ACTIVA` con conversion `'S'/'N'` → `bool`.
💡 **Enfatizar:** El mapeo PascalCase → SNAKE_CASE es automatico. Solo se usa `[Columna("X")]` cuando la columna no sigue la convencion (abreviaturas como `IDDOC`, `FECALTA`). Usar `[IgnorarMapeo]` en propiedades calculadas.

📂 **Abrir:** `Curso/Models/Unidad/ClaseUnidades.cs`
👉 **Mostrar:** Metodo `ObtenerActivas` (lineas 116-126): consulta sobre la vista `VCTS_UNIDADES`, usa `ObtenerTodosMap<ClaseUnidad>` con parametro `idioma`.
👉 **Mostrar:** Metodo `ObtenerPorId` (lineas 128-138): usa `ObtenerPrimeroMap<ClaseUnidad>` con parametro nombrado `:id` y `new { id }`. Senalar el `?? new ClaseUnidad { Id = 0 }` para el caso de no encontrado.
💡 **Enfatizar:** Tres metodos clave: `ObtenerTodosMap<T>` (lista), `ObtenerPrimeroMap<T>` (uno o null), `EjecutarParams` (SPs/funciones). Las vistas (`VCTS_*`) son para leer; los paquetes (`PKG_*`) para escribir.

🔗 **Material alumno:** Secciones 2.4 y 2.5

**Pregunta al aula:**
> "Si mi modelo tiene `bool TieneContenido => Contenido?.Length > 0;` sin ningun atributo, ¿que pasara con ObtenerTodosMap?"

Respuesta: error de mapeo — buscara columna `TIENE_CONTENIDO` que no existe. Solucion: `[IgnorarMapeo]`.

⚡ **Si falta tiempo:** Mostrar solo `ObtenerPorId` como ejemplo de lectura. Mencionar `ObtenerActivas` sin detenerse.

---

### Bloque 1.4: Procedimientos almacenados y errores Oracle (~5 min)

📂 **Abrir:** `Curso/Models/Unidad/ClaseUnidades.cs`
👉 **Mostrar:** Metodo `Guardar` (lineas 140-177). Recorrer paso a paso: `Parameters.Clear()`, `CommandType.StoredProcedure`, nombre del SP `PKG_CITAS.GUARDA_UNIDAD`, parametro `pid` con `ParameterDirection.InputOutput` (0 = crear, existente = modificar), conversion `bool` → `"S"/"N"` en `pflg_activa`, recuperacion del ID generado, y el `Parameters.Clear()` final.
💡 **Enfatizar:** Siempre limpiar parametros antes y despues. Olvidar `Parameters.Clear()` acumula parametros de llamadas anteriores → error Oracle.

👉 **Mostrar:** Metodo `Eliminar` (lineas 179-216). Senalar que primero verifica existencia con `ObtenerPrimeroMap`, y si no existe devuelve `Result.Failure` con `ErrorType.Failure` (no 404).

💡 **Enfatizar:**
- `BDException` → log + `Result.Failure` (error de BD generico)
- `MantenimientoException` → relanzar con `throw;` (cuenta bloqueada, ORA-28000)
- Funciones Oracle: `RETURN_VALUE` siempre como primer parametro en `DynamicParameters`
- Transacciones: `BeginTransaction` → `Commit` (try) → `Rollback` (catch) → `EndTransaction` (finally)

🔗 **Material alumno:** Secciones 2.6 y 2.7

⚡ **Si falta tiempo:** Mostrar solo los 5 primeros `CrearParametro` de `Guardar` y el `InputOutput` de `pid`. Saltar `Eliminar` y transacciones.

---

## Parte 2: Practica guiada (~10 min)

### Ejercicio: Rojo-Verde-Refactor con ObtenerPorId

📂 **Abrir:** `Curso/Models/Unidad/ClaseUnidades.cs`, metodo `ObtenerPorId` (lineas 128-138)

**Paso 1 — ROJO (2 min):**
Pedir a los alumnos que imaginen este metodo SIN el `?? new ClaseUnidad { Id = 0 }`. Preguntar: "¿Que recibe el frontend si el ID no existe?" → Un `200 OK` con `null`. El frontend no puede distinguirlo de un campo vacio.

**Paso 2 — VERDE (3 min):**
Mostrar la linea 137 con el operador `??`. Ahora el frontend siempre recibe un objeto. Si `Id == 0`, sabe que no existe.

**Paso 3 — CONTROLADOR (3 min):**
📂 **Abrir:** `Curso/Controllers/Apis/UnidadesController.cs`, metodo `ObtenerPorId` (lineas 49-54)
Mostrar como el controlador simplemente hace `HandleResult(_unidades.ObtenerPorId(id, idioma))`. Toda la logica esta en el servicio.

**Extension (2 min):**
Si sobra tiempo, pedir a los alumnos que describan los pasos para crear un metodo `Guardar` similar: `Parameters.Clear`, `StoredProcedure`, `CrearParametro` con `InputOutput`, `Ejecutar`, recuperar ID, `Parameters.Clear`.

---

## Parte 3: Test (~5 min)

Seleccion de 10 preguntas del banco de `preguntas.md`. Proyectar una a una, 30 segundos por pregunta.

| # | Pregunta | Tema | Respuesta |
|---|----------|------|-----------|
| 1 | P1: ErrorType.Failure → ¿que HTTP? | Result → HTTP | **d)** 500 |
| 2 | P6: Unidad no existe → ¿comportamiento correcto? | Id=0, no 404 | **b)** 200 OK con Id=0 |
| 3 | P4: ClaseReserva → ¿columnas Oracle? | PascalCase → SNAKE_CASE | **b)** COD_RESERVA, NOMBRE_SALA... |
| 4 | P7: Propiedad calculada sin atributo → ¿que ocurre? | [IgnorarMapeo] | **b)** Error de mapeo |
| 5 | P19: Permisos usuario web sobre TCTS_* | Vistas/SPs | **c)** No tiene permisos directos |
| 6 | P20: catch de MantenimientoException | Excepciones | **b)** Relanzar con throw; |
| 7 | P22: RETURN_VALUE despues de otro parametro | Funciones Oracle | **b)** Error, debe ser primero |
| 8 | P24: Orden correcto transacciones | Transacciones | **b)** Begin → Ejecutar → Commit/Rollback → End |
| 9 | P30: ¿Por que CodPer e Ip en controlador? | Seguridad | **b)** Valores del servidor |
| 10 | P43: ¿Por que bool → "S"/"N" manualmente? | Oracle VARCHAR2 | **b)** El SP espera VARCHAR2 |

**Dinamica:** Mano alzada, comentar brevemente la justificacion. No mas de 30 segundos por pregunta.

---

## Parte 4: Ejercicio Copilot (~10 min)

### Codigo con fallos

Proyectar `sesion-2/tests/practica-ia-fix.md`. Los alumnos ven un servicio con 4 errores.

### Dinamica

1. **(2 min)** Los alumnos leen el codigo e identifican fallos sin IA.
2. **(5 min)** Usan Copilot para corregir. Prompt sugerido:
   > "Este servicio tiene errores de seguridad y no sigue el patron Result\<T\> de la UA. Corrige: parametrizar la query, usar la vista VCTS_UNIDADES, devolver Result\<T\> y gestionar null con Id=0."
3. **(3 min)** Puesta en comun. Verificar las 4 correcciones:

| # | Error | Correccion | Concepto |
|---|-------|-----------|----------|
| 1 | SQL injection: `$"...{id}"` | Parametro `:id` con `new { id }` | Seguridad |
| 2 | Tabla directa `TCTS_UNIDADES` | Vista `VCTS_UNIDADES` | Permisos Oracle |
| 3 | No usa `Result<T>` | Envolver en `Result<ClaseUnidad>.Success(...)` | Patron Result |
| 4 | No gestiona null | `?? new ClaseUnidad { Id = 0 }` | Contrato UA |

📂 **Para validar:** Abrir `Curso/Models/Unidad/ClaseUnidades.cs`, metodo `ObtenerPorId` (lineas 128-138) y comparar con la solucion de los alumnos.

---

## Resumen

Repasar en 1-2 minutos los conceptos clave:

1. **Result\<T\>** — servicios devuelven Result, nunca lanzan excepciones para errores de negocio
2. **Solo 400 y 500** — Validation → 400, todo lo demas → 500. No existe 404
3. **Id=0 para "no encontrado"** — el frontend comprueba `id === 0`
4. **Arquitectura UA** — DTO y servicio en mismo directorio dentro de `Models/`
5. **ClaseOracleBD3** — mapeo PascalCase → SNAKE_CASE, `[Columna]` para excepciones, `[IgnorarMapeo]` para calculadas
6. **Vistas para leer, SPs para escribir** — el usuario web no tiene INSERT/UPDATE/DELETE en tablas
7. **Parameters.Clear()** — siempre antes y despues de cada ejecucion de SP

**Conexion con la sesion 3:** Validacion con FluentValidation y DataAnnotations — como validar DTOs antes de que lleguen al servicio.

---

## Si falta tiempo

- Saltar el Bloque 1.4 (SPs y errores Oracle) y dedicar solo 1 minuto a mencionarlo
- Reducir el test a 5 preguntas: P1, P6, P4, P7, P19
- Reducir la practica IA a solo identificar los fallos sin corregir

## Si sobra tiempo

- Abrir `Curso/Models/Unidad/ClaseUnidades.cs` y recorrer el metodo `Eliminar` completo (lineas 179-216)
- Mostrar el patron de transacciones: `BeginTransaction` → `Commit`/`Rollback` → `EndTransaction`
- Ampliar la practica IA con el codigo extendido del material (8+ errores)
- Preguntas extra del banco: P15 (VARCHAR2 S/N → bool), P16 (multiidioma CA), P42 (abreviaturas y SNAKE_CASE)

---

## Preguntas dificiles frecuentes

**"¿Por que no usamos 404 como hacen en todos los tutoriales?"**
El contrato UA solo define 400 y 500. No revelar existencia de recursos con 404 evita enumeracion de IDs. Ademas simplifica el frontend: solo dos tipos de error.

**"¿Que pasa si ObtenerPrimeroMap devuelve null y no lo controlo?"**
El controlador devuelve `200 OK` con `null` en el body. El frontend recibe JSON vacio → errores de JavaScript al acceder a propiedades.

**"¿Cuando uso ObtenerTodosMap vs ObtenerPrimeroMap?"**
`ObtenerTodosMap` → `IEnumerable<T>?` (lista). `ObtenerPrimeroMap` → `T?` (uno o null). Usar `ObtenerPrimeroMap` cuando la query devuelve 0 o 1 resultado.

**"¿Por que Parameters.Clear() despues de cada Ejecutar?"**
ClaseOracleBD3 reutiliza el objeto `Command`. Sin limpiar, la siguiente llamada acumula parametros → error Oracle.

**"Un alumno tiene error de mapeo"**
Checklist: (1) ¿PascalCase → SNAKE_CASE correcto? (2) ¿Necesita `[Columna]`? (3) ¿Propiedades calculadas con `[IgnorarMapeo]`? (4) ¿Constructor vacio? (5) ¿Tipos nullable para columnas NULL?

**"Un alumno obtiene datos vacios en campos multiidioma"**
Verificar que pasa el parametro `idioma` a `ObtenerTodosMap`/`ObtenerPrimeroMap`. Sin el, busca la columna sin sufijo (`NOMBRE` en vez de `NOMBRE_ES`).

**"AddScoped vs AddSingleton vs AddTransient"**
Scoped: una instancia por peticion (obligatorio con ClaseOracleBd). Singleton: NO usar con BD. Transient: nueva instancia cada vez (valido pero menos eficiente que Scoped).
