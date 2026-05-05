# Guia del profesor — Material de referencia: OpenAPI, Scalar y pruebas de integracion

> **Nota:** Este contenido se ha dividido entre la sesion 11 (API y autenticacion) y la sesion 18 (Tests y calidad) del bloque de Integracion full-stack y Sesiones avanzadas.

## Objetivo

El alumno configura OpenAPI + Scalar, documenta endpoints con `ProducesResponseType` (solo 200/400/500, sin 404), aplica el patron GET comprobacion + POST ejecucion, entiende naming JSON camelCase, ActionFilters, y crea tests de integracion con `WebApplicationFactory`.

| | |
|---|---|
| **Duracion** | ~45 minutos |
| **Material alumno** | `Documentacion/vitepress/curso/dotnet/sesion-5-openapi-scalar.md` |
| **Tests** | `sesion-5/tests/preguntas.md` y `sesion-5/tests/practica-ia-fix.md` |
| **Prerequisitos** | Sesiones 1-4 completadas (CRUD, FluentValidation, Result\<T\>, HandleResult, DataTable) |

**Idea clave:** "Como sabe el frontend que existe, que acepta y que devuelve cada endpoint, sin leer tu codigo fuente?"

---

## Parte 1: Teoria con practica intercalada (~20 min)

### Bloque A -- OpenAPI y Scalar (5 min)

📂 Abrir `Curso/Program.cs`

👉 Senalar las lineas clave:
- Linea 64: `builder.Services.AddOpenApi()` -- registro nativo .NET 9+, sin Swashbuckle
- Lineas 120-124: bloque `if (IsDevelopment || IsStaging)` con `MapOpenApi().AllowAnonymous()` y `MapScalarApiReference("/scalar").AllowAnonymous()`
- Lineas 96-117: middleware de redireccion para que `/scalar` y `/openapi` funcionen con el base path `/CursoNormalizacionApps`

💡 Pregunta al aula:
> "Si no documentais la API, como sabe el equipo de frontend que parametros acepta vuestro endpoint de guardar unidad?"

Respuesta esperada: tendrian que leer el codigo o preguntarnos. OpenAPI elimina esa dependencia.

⚡ Demo en vivo:
- Arrancar la app y navegar a `/CursoNormalizacionApps/openapi/v1.json` -- mostrar el JSON generado
- Navegar a `/CursoNormalizacionApps/scalar` -- explorar un endpoint visualmente

💡 Pregunta rapida:
> "Por que envolvemos MapOpenApi y MapScalarApiReference dentro del if de Development/Staging?"

Respuesta: para no revelar la estructura interna de la API en produccion.

### Bloque B -- ProducesResponseType y contrato 200/400/500 (5 min)

📂 Abrir `Curso/Controllers/Apis/UnidadesController.cs`

👉 Observar que actualmente los endpoints NO tienen atributos `[ProducesResponseType]`. Esto es lo que los alumnos van a anadir en la practica.

📂 Abrir `Curso/Controllers/ApiControllerBase.cs`

👉 Senalar el metodo `HandleResult<T>` (lineas 70-85):
- `result.IsSuccess` devuelve `Ok(result.Value)` -- HTTP 200
- `ErrorType.Validation` devuelve `ValidationProblem` con status 400
- Cualquier otro error devuelve `Problem` con status 500
- **Solo hay dos caminos de error: 400 y 500. No existe 404.**

💡 Explicar el contrato UA:

| ErrorType | HTTP | Respuesta |
|-----------|------|-----------|
| (exito) | 200 | DTO o valor |
| Validation | 400 | `ValidationProblemDetails` |
| Failure | 500 | `ProblemDetails` generico |

Si un recurso no se encuentra: 200 con objeto vacio (Id=0). El frontend valida ese caso.

💡 Pregunta al aula:
> "Un POST que usa FluentValidation y HandleResult, cuantos ProducesResponseType necesita como minimo?"

Respuesta: 3 -- 200 (exito), 400 (validacion), 500 (error interno).

### Bloque C -- Patron GET comprobacion + POST ejecucion (4 min)

📂 Seguir en `sesion-5-openapi-scalar.md`, seccion 5.3

👉 Explicar el flujo con ejemplo concreto:
1. Frontend quiere eliminar la unidad 5
2. `GET /api/unidades/5/puede-eliminar` -- devuelve `ClaseComprobacionOperacion` con `Permitido`, `Razon` y `TokenOperacion` (GUID)
3. Si `Permitido = true`, el frontend llama `POST /api/unidades/5/eliminar` con el token
4. El servicio valida el token antes de ejecutar

💡 Pregunta al aula:
> "Para que sirve el token? No bastaria con comprobar y luego hacer el POST sin mas?"

Respuesta: el token vincula la comprobacion con la ejecucion. Evita llamar al POST sin haber comprobado. El servicio verifica que el token es valido.

👉 Senalar la validacion en dos capas:
- Capa 1 (FluentValidation): token no vacio (formato del DTO)
- Capa 2 (servicio): token valido y vigente (regla de negocio)

### Bloque D -- Naming JSON y ActionFilters (3 min)

📂 Abrir `Curso/Program.cs`

👉 Naming JSON -- senalar que .NET usa camelCase por defecto:
- `NombreEs` en C# se serializa como `nombreEs` en JSON
- Para PascalCase: `PropertyNamingPolicy = null`
- Cuidado: `ProblemDetails` usa su propia serializacion; necesitas `IProblemDetailsWriter` personalizado para consistencia total

📂 Abrir `Curso/ClientApp/src/views/apis/Unidades.vue`

👉 Senalar la interfaz `Unidad` (lineas 13-21): las propiedades usan camelCase (`id`, `flgActiva`, `granularidad`) porque el JSON llega asi. Si cambias a PascalCase en el backend, rompes el frontend.

💡 Pregunta rapida:
> "Si la propiedad en C# es FlgActiva y usais camelCase, como aparece en el JSON?"

Respuesta: `flgActiva`.

👉 ActionFilters -- explicar brevemente:
- `IActionFilter` tiene `OnActionExecuting` (antes) y `OnActionExecuted` (despues)
- Registro global en `AddControllers(options => options.Filters.Add<T>())`

📂 Senalar en `Curso/Program.cs` linea 56: ya hay un filtro registrado (`GestionLayoutFilter`) como ejemplo de registro global

⚡ Diferencia clave: `Add<T>()` permite inyeccion de dependencias. `Add(new T())` no.

### Bloque E -- Tests de integracion y WebApplicationFactory (3 min)

📂 Abrir `CursoTest/Integration/OpenApiAndScalarIntegrationTests.cs`

👉 Senalar:
- `CursoAppFactory` (lineas 71-78): hereda de `WebApplicationFactory<Program>`, fuerza `UseEnvironment("Staging")`
- Decorador `[Collection("Integration")]` para compartir la factory entre clases de test
- Test `OpenApiEndpoint_Disponible_EnEntornoStaging` (lineas 17-32): hace GET, verifica 2xx, verifica que contiene "openapi"
- Test `ScalarUi_Disponible_EnEntornoStaging` (lineas 34-49): verifica que Scalar devuelve `text/html`
- Helper `GetFirstSuccessful` (lineas 52-68): prueba varias rutas (con y sin base path) y devuelve la primera exitosa

📂 Abrir `CursoTest/Integration/JsonSerializationTests.cs`

👉 Senalar el test `OpenApi_ExponePropiedadesEnCamelCase` (lineas 52-69): verifica que el documento OpenAPI usa camelCase (`"nombreEs"`, no `"NombreEs"`)

💡 Pregunta al aula:
> "Por que el helper GetFirstSuccessful prueba dos rutas diferentes?"

Respuesta: la app puede tener un base path (`/CursoNormalizacionApps`) o no. El helper prueba ambas y devuelve la primera que funciona.

🔗 Mencionar httpRepl como herramienta complementaria: instalar con `dotnet tool install -g Microsoft.dotnet-httprepl`, conectar, navegar con `cd`, probar con `get` y `post`.

---

## Parte 2: Practica guiada (~10 min)

### Paso 1: Verificar configuracion (2 min)

📂 Los alumnos abren `Curso/Program.cs`

👉 Confirmar que tienen:
- `builder.Services.AddOpenApi()` (linea 64)
- `app.MapOpenApi().AllowAnonymous()` y `app.MapScalarApiReference("/scalar").AllowAnonymous()` dentro del bloque `if` (lineas 122-123)

⚡ Arrancar la app, navegar a `/scalar` y verificar que carga. Navegar a `/openapi/v1.json` y ver el JSON.

### Paso 2: Documentar endpoints (4 min)

📂 Los alumnos abren `Curso/Controllers/Apis/UnidadesController.cs`

👉 Anadir `[ProducesResponseType]` a cada metodo:
- `Listar` (GET): 200 con `List<ClaseUnidad>` + 500 con `ProblemDetails`
- `ObtenerPorId` (GET): 200 con `ClaseUnidad` + 500 con `ProblemDetails`
- `Guardar` (POST): 200 con `int` + 400 con `ValidationProblemDetails` + 500 con `ProblemDetails`
- `Eliminar` (DELETE): 200 con `bool` + 500 con `ProblemDetails`
- `DataTable` (GET): ya devuelve `Ok()` directo, documentar 200 con `ClaseDataTable`

⚡ Recargar Scalar y verificar que ahora muestra las respuestas posibles de cada endpoint.

### Paso 3: Crear/verificar test de integracion (4 min)

📂 Los alumnos abren `CursoTest/Integration/OpenApiAndScalarIntegrationTests.cs`

👉 Si ya existe, revisar su estructura. Si no, crearlo siguiendo el patron del fichero real:
1. `CursoAppFactory` con `UseEnvironment("Staging")`
2. Test que hace GET a `/openapi/v1.json`, verifica 2xx y verifica que contiene `"openapi"`

⚡ Ejecutar: `dotnet test CursoNormalizacionApps.sln --filter "FullyQualifiedName~OpenApi"`

💡 Punto de verificacion: todos los alumnos deben tener Scalar con respuestas documentadas y el test en verde.

---

## Parte 3: Test de autoevaluacion (~5 min)

Seleccion de 10 preguntas del banco de `sesion-5/tests/preguntas.md`:

| # | Pregunta | Tema | Motivo |
|---|----------|------|--------|
| 1 | **P1** -- Metodo nativo .NET 9+ para OpenAPI | Basico | Distinguir `AddOpenApi()` de `AddSwaggerGen()` |
| 2 | **P3** -- NuGet para Scalar | Configuracion | Saber que paquete necesitan |
| 3 | **P4** -- OpenAPI sin condicion de entorno | Seguridad | Riesgo de exponer API en produccion |
| 4 | **P5** -- Atributo para documentar 500 | ProducesResponseType | Concepto central |
| 5 | **P7** -- Funcion del TokenOperacion | Patron GET+POST | Proposito del token |
| 6 | **P9** -- ErrorType.Validation a HTTP | Contrato UA | Mapeo 400/500 |
| 7 | **P13** -- Interfaz de ApiTimingFilter | ActionFilters | Distinguir IActionFilter de otros |
| 8 | **P17** -- Por que Staging en tests | WebApplicationFactory | Relacion entorno-activacion |
| 9 | **P27** -- Cuantos ProducesResponseType en POST | Documentacion | Sintetizar: 200 + 400 + 500 = 3 |
| 10 | **P43** -- Recurso no encontrado en contrato UA | Contrato UA | Confirmar: 200 con Id=0, no 404 |

**Dinamica:** proyectar cada pregunta, 20-30 segundos, mano alzada, explicar brevemente.

**Respuestas:** 1-b, 2-c, 3-b, 4-b, 5-b, 6-b, 7-c, 8-b, 9-c, 10-b

---

## Parte 4: Ejercicio con Copilot -- Codigo con fallos (~10 min)

📂 Los alumnos abren `sesion-5/tests/practica-ia-fix.md`

### Instrucciones

1. Copiar el bloque de codigo con errores en un fichero `.cs` o trabajar directamente en el editor.
2. Usar Copilot o Claude para identificar y corregir los 10 errores.
3. Deben **explicar** cada error en un comentario, no solo corregir.

### Los 10 errores

| # | Ubicacion | Error | Puntos |
|---|-----------|-------|--------|
| 1 | Program.cs | Falta `using Scalar.AspNetCore` | 0.5 |
| 2 | Program.cs | No registra `AddOpenApi()` | 1.0 |
| 3 | Program.cs | OpenAPI expuesto en produccion (sin if de entorno) | 1.0 |
| 4 | Controller | Hereda de `ControllerBase` en vez de `ApiControllerBase` | 1.0 |
| 5 | Controller | Sin `[ProducesResponseType]` | 1.5 |
| 6 | Controller, Listar | Manejo manual de Result en vez de `HandleResult` | 1.0 |
| 7 | Controller, Eliminar | No hay GET comprobacion previa | 1.0 |
| 8 | Controller, Eliminar | POST sin token de operacion | 1.0 |
| 9 | Test | No usa `WebApplicationFactory` (HttpClient contra localhost) | 1.0 |
| 10 | Test | Solo verifica status code, no contenido | 0.5 |

### Pistas progresivas

**Nivel 1:** "Hay 3 errores en Program.cs, 5 en el controlador y 2 en el test."

**Nivel 2:** "En Program.cs: falta un using, falta registrar un servicio, falta condicion de entorno. En el controlador: herencia, atributos, manejo de errores, patron eliminacion incompleto. En el test: infraestructura incorrecta y validacion insuficiente."

**Nivel 3:** "Consulta las secciones 5.2, 5.3 y 5.8 del material del alumno."

### Cierre

Pedir a 2-3 alumnos que compartan pantalla y expliquen sus correcciones. Comparar con la solucion desplegable de `practica-ia-fix.md`.

---

## Resumen y cierre

Pedir a los alumnos que enumeren los 5 conceptos clave:

1. **OpenAPI + Scalar**: `AddOpenApi()` genera el JSON, Scalar lo visualiza. Solo en Development/Staging.
2. **ProducesResponseType**: documenta respuestas. Contrato UA: 200/400/500. No usamos 404.
3. **Patron GET comprobacion + POST ejecucion**: verificar antes de actuar, vincular con token.
4. **Naming JSON**: camelCase por defecto. PascalCase requiere `PropertyNamingPolicy = null` + `IProblemDetailsWriter`.
5. **WebApplicationFactory**: tests de integracion en memoria, sin servidor externo.

> "Con esta sesion habeis cerrado el ciclo: crear endpoints, validarlos, documentarlos con OpenAPI, y verificarlos con tests de integracion. El frontend ya puede consumir vuestra API sin leeros el codigo."

---

## Si falta tiempo

- Saltar el Bloque D (naming JSON y ActionFilters) -- se puede cubrir como lectura.
- Reducir la practica al Paso 1 + Paso 3 (verificar config y test de integracion).
- Hacer solo 5 preguntas del test (P1, P5, P9, P17, P43).

## Si sobra tiempo

- Probar endpoints desde httpRepl en vivo.
- Anadir test de integracion para verificar que `/scalar` devuelve `text/html` (ver `ScalarUi_Disponible_EnEntornoStaging` en `OpenApiAndScalarIntegrationTests.cs`).
- Explorar `CursoTest/Integration/JsonSerializationTests.cs`: test que verifica camelCase en el documento OpenAPI.
- Cambiar la serializacion a PascalCase y comprobar el impacto en Scalar y en el frontend Vue.

---

## Preguntas dificiles

### "Scalar no carga / se ve en blanco"

📂 Verificar en `Curso/Program.cs`:
- `AddOpenApi()` registrado (linea 64). Sin el, Scalar no tiene esquema.
- `MapOpenApi()` esta antes de `MapScalarApiReference()` (lineas 122-123).
- Entorno es Development: `ASPNETCORE_ENVIRONMENT=Development`.

### "El test de integracion falla con 404"

📂 Verificar en `CursoTest/Integration/OpenApiAndScalarIntegrationTests.cs`:
- `CursoAppFactory` usa `UseEnvironment("Staging")` (linea 75).
- El helper `GetFirstSuccessful` prueba rutas con y sin base path.
- Si falla por BD, recordar que el test de OpenAPI no necesita BD real.

### "No entiendo por que no usamos 404"

📂 Abrir `Curso/Controllers/ApiControllerBase.cs`, metodo `HandleResult` (lineas 70-85):
> "En HandleResult solo hay dos caminos de error: Validation devuelve 400, todo lo demas devuelve 500. No hay case para 404. Si un recurso no existe, el servicio devuelve exito con un objeto vacio (Id=0) y el frontend lo valida."

📂 Verificar en `CursoTest/Controllers/UnidadesControllerTests.cs`, test `ObtenerPorId_CuandoNoExiste_Devuelve200ConId0` (lineas 32-45): demuestra que un id inexistente devuelve 200 con Id=0.

### "Que diferencia hay entre AddJsonOptions y ConfigureHttpJsonOptions?"

- `AddJsonOptions` configura controladores MVC/API.
- `ConfigureHttpJsonOptions` configura Minimal APIs.
- Si solo usais controladores (nuestro caso), basta con `AddJsonOptions`. Si usais ambos, las politicas deben ser consistentes.

### "El filtro ApiTimingFilter no recibe el ILogger"

📂 Senalar en `Curso/Program.cs` linea 56: el filtro `GestionLayoutFilter` se registra con `typeof()`, que permite inyeccion. Si usas `new`, no hay inyeccion.

### "Copilot no encuentra los 10 errores"

- Es normal. Pedir al alumno que verifique cada correccion propuesta.
- Sugerir prompt: "Hay 10 errores en este codigo. Listalos todos con su correccion."
- Dar pistas progresivas si se atascan.
