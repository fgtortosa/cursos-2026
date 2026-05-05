# Guia del profesor — Material de referencia: Validacion, errores y buenas practicas

> **Nota:** Este contenido se ha integrado en las sesiones 12 (Validacion) y 13 (Errores) del bloque de Integracion full-stack.

## Vision general de la sesion

| | |
|---|---|
| **Duracion** | ~45 minutos |
| **Objetivo** | El alumno valida DTOs con DataAnnotations y FluentValidation, gestiona errores con `Result<T>` + `HandleResult` (solo 400/500), configura `IExceptionHandler`, localiza mensajes con `IStringLocalizer` y entiende Serilog basico |
| **Material** | `sesion-3-validacion-errores.md`, `preguntas.md`, `practica-ia-fix.md` |
| **Prerequisitos** | Sesion 1 (DTOs, APIs) y Sesion 2 (servicios, Oracle, `Result<T>`) completadas. Proyecto compilando en VS 2022. |
| **Resultado esperado** | El alumno entiende la cadena completa: DTO -> DataAnnotations -> FluentValidation -> Servicio con Result\<T\> -> HandleResult -> Vue (400 vs 500) |

---

## Parte 1: Teoria con practica intercalada (~20 min)

### Bloque 1.1 -- DataAnnotations y validacion automatica (5 min)

::: tip 📂 Abrir fichero
`Curso/Models/Eco/ClaseEcoUnidadDataAnnotations.cs`
:::

::: tip 👉 Que mostrar
- Atributos `[Required]`, `[StringLength]`, `[Range]`, `[RegularExpression]` con mensajes localizados via `ErrorMessageResourceType` + `ErrorMessageResourceName`.
- Senalar que los mensajes apuntan a ficheros `.resx` con `typeof(EcoDataAnnotationsMessages)`.
- Comparar con la validacion de `Granularidad`: `[Range(5, 120)]` -- no permite 0.
:::

::: warning 💡 Idea clave
Con `[ApiController]`, .NET valida DataAnnotations automaticamente ANTES de ejecutar la accion. Si fallan, devuelve 400 con `ValidationProblemDetails` (RFC 7807). El alumno NO escribe codigo de validacion en el controlador para estos casos.
:::

**Demo rapida:** Enviar desde Scalar/Postman un POST a `/api/Eco/validar-dataannotations` con `NombreEs: ""` y `Granularidad: -5`. Mostrar la respuesta 400 con el diccionario `errors`.

**Pregunta para los asistentes:**

> "Si envio un POST con `Granularidad: 0` y el DTO tiene `[Range(0, 120)]`, la API lo acepta. Que problema hay?"

Respuesta esperada: el rango permite 0, que no es valido para una granularidad en minutos. Deberia ser `[Range(5, 120)]`.

---

### Bloque 1.2 -- FluentValidation y reglas cruzadas (5 min)

::: tip 📂 Abrir ficheros (dos pestanas)
1. `Curso/Models/Eco/ClaseEcoUnidadValidator.cs` -- validador del Eco (mas sencillo)
2. `Curso/Models/Unidad/ClaseGuardarUnidadValidator.cs` -- validador real de Unidades
:::

::: tip 👉 Que mostrar en ClaseEcoUnidadValidator
- Constructor recibe `IStringLocalizerFactory` (patron de la UA para resolver claves).
- Regla custom con `RuleFor(x => x).Custom(...)` que valida que al menos un nombre tenga valor.
- `.When()` para aplicar reglas solo si el campo tiene contenido (lineas 31-33: `When(x => !string.IsNullOrWhiteSpace(x.NombreEs))`).
- `InclusiveBetween(5, 120)` para Granularidad con mensaje localizado.
- Regex para validar dominio de email UA.
:::

::: tip 👉 Que mostrar en ClaseGuardarUnidadValidator
- Reglas `NotEmpty().MaximumLength(200)` para los tres nombres.
- La regla cruzada (lineas 48-51): `RuleFor(x => x).Must(...)` que valida granularidad <= duracion maxima.
- Explicar `.WithName("Granularidad")`: asocia el error al campo correcto en el `ValidationProblemDetails` porque la regla valida el objeto completo.
- Metodo privado `Get(key)` que resuelve claves de localizacion con fallback entre dos `IStringLocalizer`.
:::

::: warning 💡 Ideas clave
- **DataAnnotations por defecto**, FluentValidation cuando la regla lo requiera (reglas cruzadas, condicionales).
- Si las DataAnnotations fallan, FluentValidation NO se ejecuta. .NET devuelve 400 inmediatamente.
- Los validadores se registran automaticamente con `AddValidatorsFromAssemblyContaining`.
:::

**Pregunta para los asistentes:**

> "Si las DataAnnotations del DTO fallan, se ejecuta FluentValidation?"

Respuesta: No. `[ApiController]` intercepta y devuelve 400 inmediatamente.

**Pregunta adicional:**

> "Que diferencia hay entre `NotEmpty()` y `NotNull()` en FluentValidation?"

Respuesta: `NotEmpty()` valida que no sea null, cadena vacia ni solo espacios. `NotNull()` solo comprueba null.

---

### Bloque 1.3 -- Localizacion con IStringLocalizer y ficheros .resx (3 min)

::: tip 📂 Abrir ficheros (dos pestanas)
1. `Curso/Resources/SharedResources.resx` -- espanol (por defecto)
2. `Curso/Resources/SharedResources.ca.resx` -- catalan
:::

::: tip 👉 Que mostrar
- Las claves siguen el patron `Entidad.Campo.Regla`: `Unidad.NombreEs.Required`, `Eco.Granularidad.Range`.
- Comparar el mismo mensaje en espanol y catalan: por ejemplo `Unidad.Granularidad.Range` -> "La granularidad debe estar entre 5 y 120 minutos" vs "La granularitat ha d'estar entre 5 i 120 minuts".
- Senalar que hay claves tanto para Eco como para Unidad, cada entidad tiene sus propios mensajes.
- Tres idiomas soportados: `es-ES` (defecto), `ca-ES`, `en-US`.
:::

::: warning 💡 Idea clave
Las claves de localizacion se usan desde los validadores FluentValidation via `IStringLocalizerFactory`. El idioma se resuelve automaticamente segun la peticion HTTP (`Accept-Language` o claim del usuario).
:::

**Pregunta rapida:**

> "Donde se configura el idioma por defecto en `Program.cs`?"

Respuesta: Con `SetDefaultCulture("es-ES")` dentro de `RequestLocalizationOptions`.

---

### Bloque 1.4 -- HandleResult + IExceptionHandler: solo 400 y 500 (5 min)

::: tip 📂 Abrir fichero
`Curso/Controllers/ApiControllerBase.cs`
:::

::: tip 👉 Que mostrar
- Metodo `HandleResult<T>` (lineas 70-85): el switch que mapea `ErrorType` a HTTP.
- `ErrorType.Validation` -> 400 con `ValidationProblemDetails` (incluye diccionario `errors` por campo).
- `_ =>` (cualquier otro, incluyendo `Failure`) -> 500 con `ProblemDetails` generico.
- Si `IsSuccess` -> 200 OK con el valor.
- Senalar tambien los metodos auxiliares: `ObtenerIdiomaClaimUsuario()`, `ObtenerCodPer()`, `NormalizarIdioma()`.
:::

::: danger ⚡ Enfatizar
**Solo dos codigos de error en la API UA: 400 (validacion) y 500 (todo lo demas).** No se usa 404. Si un recurso no existe: 200 OK con `Id = 0` y el frontend valida. Nunca exponer `ex.Message` ni `ex.StackTrace` al cliente en el `IExceptionHandler`.
:::

**Pregunta para los asistentes:**

> "Si el servicio devuelve `Result<int>.Failure(new Error("Unidad.Duplicada", "Error al guardar", ErrorType.Failure))`, que codigo HTTP genera `HandleResult`?"

Respuesta: 500. `ErrorType.Failure` siempre mapea a 500.

**Pregunta adicional (seguridad):**

> "Este `IExceptionHandler` tiene un problema. Cual? `Detail = ex.Message + "\n" + ex.StackTrace`"

Respuesta: Expone rutas, SQL, clases internas al cliente. Riesgo de seguridad. Debe devolver mensaje generico y registrar todo en Serilog.

---

### Bloque 1.5 -- Serilog basico y convenciones de nombrado (2 min)

**Puntos clave (explicar sin abrir fichero):**

- Tres niveles relevantes: `Information` (flujo normal), `Warning` (validacion/negocio), `Error` (excepciones tecnicas).
- Placeholders con nombre: `_logger.LogInformation("Unidad {Id} guardada", id)`. NUNCA concatenar ni interpolar strings.
- `app.UseSerilogRequestLogging()` registra cada request HTTP automaticamente.

**Convenciones de nombrado UA (proyectar tabla del material):**

| Elemento | Convencion | Ejemplo |
|----------|-----------|---------|
| DTO lectura | Singular, prefijo `Clase` | `ClaseUnidad` |
| DTO escritura | Singular, prefijo `Clase` + verbo | `ClaseGuardarUnidad` |
| Servicio | Plural | `ClaseUnidades` |
| Controlador | Plural + Controller | `UnidadesController` |
| Error code | `Entidad.Tipo` | `"Unidad.SaveError"` |
| Clave .resx | PascalCase ingles o `Entidad.Campo.Regla` | `RequiredField`, `Unidad.NombreEs.Required` |

**Pregunta rapida:**

> "Cual es la forma correcta: `$"Unidad {id} guardada"` o `"Unidad {Id} guardada", id`?"

Respuesta: La segunda. La interpolacion impide el logging estructurado de Serilog.

---

## Parte 2: Practica guiada -- Rojo-Verde-Refactor (~10 min)

### Paso 1 -- ROJO (2 min)

::: tip 📂 Abrir fichero
`Curso/Models/Unidad/ClaseGuardarUnidad.cs`
:::

Senalar que el DTO actualmente NO tiene DataAnnotations (solo propiedades planas). Pedir a los alumnos que envien este JSON desde Scalar/Postman a `POST /api/Unidades`:

```json
{
  "nombreEs": "",
  "nombreCa": "",
  "nombreEn": "",
  "granularidad": -5,
  "duracionMax": "",
  "numCitasSimultaneas": 0
}
```

Preguntar: "La API lo acepta? Estos datos llegarian a Oracle?"

---

### Paso 2 -- VERDE (4 min)

Los alumnos anaden DataAnnotations a `ClaseGuardarUnidad.cs`:

- `NombreEs`, `NombreCa`, `NombreEn`: `[Required]` + `[StringLength(200)]`
- `Granularidad`: `[Range(5, 120)]`
- `DuracionMax`: `[Required]`
- `NumCitasSimultaneas`: `[Range(1, 50)]`

Reenviar el mismo JSON. Ahora debe devolver 400 con errores por campo.

---

### Paso 3 -- REFACTOR (4 min)

::: tip 📂 Abrir fichero como referencia
`Curso/Models/Unidad/ClaseGuardarUnidadValidator.cs`
:::

Los alumnos crean (o revisan) la regla cruzada de FluentValidation: granularidad no puede superar duracion maxima. Referirse a las lineas 48-51 del validador real.

Probar con `granularidad: 60` y `duracionMax: "30"` para verificar que la regla cruzada funciona.

**Criterio de exito:** El alumno ve la respuesta 400 con el error en el campo `Granularidad`.

---

### Paso 4 -- Ver errores en Vue (si da tiempo, 2 min)

::: tip 📂 Abrir fichero
`Curso/ClientApp/src/views/apis/Eco.vue`
:::

::: tip 👉 Que mostrar
- Lineas 53-58: el `catch` que distingue 400 (con `error.response.data.errors`) de otros errores (con `gestionarError`).
- Lineas 99, 108, 117, 126, 135: las clases CSS `:class="{ 'is-invalid': errores?.NombreEs }"` que pintan el borde rojo.
- Lineas 100-102: `invalid-feedback` que muestra el mensaje de error por campo.
- La seccion de respuesta JSON (lineas 160-178) que muestra visualmente tanto el exito como los errores.
:::

---

## Parte 3: Test de autoevaluacion (~5 min)

Seleccion de 10 preguntas del banco de `preguntas.md`. Proyectar una a una, 20-30 segundos por pregunta, respuestas a mano alzada.

| # | Pregunta | Tema | Respuesta |
|---|----------|------|-----------|
| 1 | P1 -- `[Range(0, 120)]` en Granularidad | DataAnnotations | **b)** Permite 0, minimo deberia ser 5 |
| 2 | P2 -- Que devuelve .NET cuando DataAnnotations falla | Validacion automatica | **c)** 400 con `ValidationProblemDetails` |
| 3 | P5 -- Orden de la cadena de validacion UA | Cadena completa | **b)** DataAnnotations -> FluentValidation -> Servicio -> HandleResult |
| 4 | P7 -- Mapeo ErrorType a HTTP | Contrato errores | **c)** Validation -> 400, Failure -> 500 |
| 5 | P9 -- Inyeccion de mensajes localizados en FluentValidation | Localizacion | **b)** `IStringLocalizer<SharedResources>` |
| 6 | P15 -- Forma correcta de loguear con Serilog | Serilog | **c)** `"Unidad {Id} guardada", id` |
| 7 | P16 -- Que debe hacer el `IExceptionHandler` | IExceptionHandler | **b)** Registrar en Serilog, devolver ProblemDetails generico |
| 8 | P25 -- Que falta en el catch de Vue | Vue + errores | **b)** Distinguir 400 (`.errors`) de 500 (`gestionarError`) |
| 9 | P35 -- Seguridad con `ex.Message + ex.StackTrace` | Seguridad | **b)** Expone informacion interna al cliente |
| 10 | P36 -- Si DataAnnotations falla, se ejecuta FluentValidation? | Cadena validacion | **c)** No, .NET devuelve 400 directamente |

::: info 🔗 Preguntas extra para debate
Si el grupo es rapido: P3 (logica `Must` con cortocircuito `||`), P41 (proposito de `.WithName`), P32 (por que 200 con Id=0 en vez de 404).
:::

---

## Parte 4: Ejercicio con Copilot -- Codigo con fallos (~10 min)

::: tip 📂 Proyectar fichero
`Documentacion/vitepress/curso/dotnet/sesion-3/tests/practica-ia-fix.md`
:::

Los alumnos usan Copilot/IA para identificar y corregir los errores. NO dar respuestas de antemano.

### Fallos que deben encontrar

| # | Fallo | Correccion | Concepto |
|---|-------|-----------|----------|
| 1 | `GreaterThan(0)` no limita maximo ni tiene mensaje | `InclusiveBetween(5, 120).WithMessage(...)` | Rangos completos |
| 2 | Faltan reglas para `NombreEs`, `NombreCa`, `NombreEn` | Anadir `NotEmpty().MaximumLength(200)` | Validacion completa |
| 3 | Falta regla cruzada granularidad <= duracion maxima | `RuleFor(x => x).Must(...).WithName("Granularidad")` | Reglas cruzadas |
| 4 | Falta validar `NumCitasSimultaneas` | `InclusiveBetween(1, 50)` | Cobertura de campos |
| 5 | `throw new Exception(r.Error?.Message)` en controlador | `return HandleResult(r)` | Patron Result, no excepciones |
| 6 | `Ok(r)` devuelve el Result completo | `HandleResult(r)` para todo el flujo | ProblemDetails homogeneo |

::: tip 👉 Referencia para la solucion
Abrir `Curso/Models/Unidad/ClaseGuardarUnidadValidator.cs` como ejemplo de validador correcto completo.
:::

### Dinamica

1. **(2 min)** Los alumnos leen el codigo e intentan identificar fallos sin IA.
2. **(5 min)** Usan Copilot para corregir. El profesor circula por el aula.
3. **(3 min)** Puesta en comun: proyectar la solucion y repasar cada correccion.

**Prompt sugerido para Copilot:**

> "Este validador y controlador tienen errores. El validador debe cubrir todos los campos de ClaseGuardarUnidad con reglas completas y mensajes localizables. El controlador debe usar HandleResult en vez de lanzar excepciones. Corrige ambos siguiendo el patron Result\<T\> de la UA."

**Criterio de exito:** El alumno identifica al menos 4 de los 6 fallos y comprende por que `throw new Exception` rompe el patron `Result<T>` + `HandleResult`.

---

## Resumen y cierre

### Cadena completa que el alumno debe recordar

```
Vue (llamadaAxios + gestionarError)
        |
        v
[ApiController] valida DataAnnotations (400 automatico si falla)
        |
        v
FluentValidation (solo si DataAnnotations paso)
        |
        v
Servicio devuelve Result<T> con ErrorType
        |
        v
ApiControllerBase.HandleResult => 200 / 400 / 500
        |
        v
Vue muestra errores por campo (400) o mensaje generico (500)
```

### Tres ideas clave para cerrar

1. **Solo 400 y 500.** Validacion es 400, todo lo demas es 500. No usar 404 ni 409.
2. **Nunca excepciones para errores de negocio.** Usar `Result<T>.Failure(...)` y `HandleResult`.
3. **Nunca exponer informacion interna.** `IExceptionHandler` registra en Serilog y devuelve mensaje generico.

---

## Si falta tiempo

- Recortar Bloque 1.5 (Serilog) a una mencion de 30 segundos.
- Saltar Paso 4 de la practica (Vue).
- Reducir el test a 5 preguntas: P2, P5, P7, P16, P35.

## Si sobra tiempo

- Abrir `Curso/Models/Eco/ClaseEcoUnidadDataAnnotations.cs` y comparar lado a lado con `ClaseEcoUnidadValidator.cs`: mismas reglas expresadas de dos formas distintas.
- Pedir a los alumnos que anadan una regla `.When()` para validar email solo si tiene valor (ver lineas 42-45 de `ClaseGuardarUnidadValidator.cs`).
- Debatir P32 del banco de preguntas: por que 200 con objeto vacio en vez de 404.
- Explorar como funciona `SuppressModelStateInvalidFilter` para desactivar la validacion automatica.

---

## Preguntas dificiles

### "Por que no usamos solo FluentValidation para todo?"

DataAnnotations tiene una ventaja: el `[ApiController]` las valida automaticamente sin codigo adicional. FluentValidation requiere registro explicito. En la UA usamos DataAnnotations para lo basico (required, length, range) y FluentValidation cuando necesitamos reglas cruzadas, condicionales o mensajes localizados complejos.

### "No me compila FluentValidation"

Verificar que `FluentValidation.AspNetCore` esta instalado y que `Program.cs` tiene `AddValidatorsFromAssemblyContaining` y `AddFluentValidationAutoValidation`.

### "Mi validador FluentValidation no se ejecuta"

Tres causas habituales: (1) Las DataAnnotations fallan primero y .NET devuelve 400 sin ejecutar FluentValidation. (2) El validador no esta en el ensamblado que se escanea. (3) El constructor del validador no es publico.

### "El error no aparece en el campo correcto en la respuesta 400"

Si la regla usa `RuleFor(x => x)` (objeto completo), hay que anadir `.WithName("NombreCampo")` para asociar el error al campo correcto. Ver linea 50 de `ClaseGuardarUnidadValidator.cs`.

### "La API devuelve 500 en vez de 400 para errores de validacion"

Verificar que el servicio usa `ErrorType.Validation` (no `ErrorType.Failure`) al crear el `Error`. `Failure` siempre mapea a 500 en `HandleResult`.

### "Los mensajes de error salen en el idioma incorrecto"

Comprobar: (1) `app.UseRequestLocalization` esta ANTES de `MapControllers` en el pipeline. (2) Los ficheros `.resx` existen con las claves correctas. (3) La peticion incluye `Accept-Language` o el idioma se extrae del claim del usuario.

### "Por que no usamos 404 como en todos los tutoriales?"

El contrato simplificado de la UA solo define 400 y 500. No revelar existencia/inexistencia de recursos con 404 evita enumeracion de IDs por un atacante. Simplifica el frontend: solo dos tipos de error posibles.
