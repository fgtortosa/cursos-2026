# Guia del profesor — Sesion 4: Modelos y primer API

## Objetivo y material
- **Duracion:** 45 min
- **Objetivo:** Los asistentes comprenden que es un DTO, crean un controlador API REST con datos hardcodeados, aplican validacion con DataAnnotations (ciclo Rojo-Verde-Refactor) y ven como Vue consume la API
- **Material alumno:** `sesion-1-dtos-apis.md`
- **Prerequisitos:** Sesion 0 completada (entorno configurado, proyecto compilando)
- **Herramientas abiertas:** VS 2022 con el proyecto, navegador con Scalar, VS Code con ClientApp

---

## Parte 1: Teoria con codigo real (~20 min)

### Bloque 1.1: Que es un DTO (~4 min)

📂 **Abrir:** `Curso/Models/Reserva/ClaseReserva.cs`
👉 **Mostrar:** Las 5 propiedades del DTO (lineas 5-9). Explicar que es un objeto plano sin logica: solo propiedades con get/set.
💡 **Enfatizar:** Convencion UA: prefijo `Clase`, carpeta `Models/`, PascalCase en C# que mapea a SNAKE_CASE en Oracle (`CodReserva` -> `COD_RESERVA`, `Activo` -> `ACTIVO` con conversion `'S'/'N'` a `bool`).
🔗 **Material alumno:** Seccion 1.1

**Preguntar a los asistentes:**
- "Si tengo una propiedad `FechaNacimiento` en C#, que nombre tendra la columna en Oracle?" -- Respuesta: `FECHA_NACIMIENTO`
- "Si la columna Oracle no sigue la convencion SNAKE_CASE, que atributo uso?" -- Respuesta: `[Columna("NOMBRE_REAL")]` (NO `[Column]` de EF)

📂 **Abrir:** `Curso/Models/Eco/ClaseEcoUnidad.cs`
👉 **Mostrar:** Las propiedades multiidioma `NombreEs`, `NombreCa`, `NombreEn` (lineas 9-13). Destacar que NO tiene validaciones todavia -- esto lo usaremos en Rojo-Verde-Refactor.

⚡ **Si falta tiempo:** Saltar este bloque si los asistentes ya tienen experiencia con DTOs. Pasar directo al 1.2.

---

### Bloque 1.2: Anatomia de un controlador API (~5 min)

📂 **Abrir:** `Curso/Controllers/Apis/EcoController.cs`
👉 **Mostrar:** Los tres elementos obligatorios de un controlador API:
1. `[Route("api/[controller]")]` (linea 9) -- ruta base con sustitucion automatica del nombre
2. `[ApiController]` (linea 10) -- validacion automatica del ModelState
3. Herencia de `ApiControllerBase` (linea 11) -- en el patron UA; para APIs simples basta `ControllerBase`

💡 **Enfatizar:** `[ApiController]` hace que si el DTO tiene DataAnnotations y los datos no son validos, .NET devuelve 400 automaticamente SIN codigo en la accion. Es la magia que veremos en la fase Verde.

📂 **Abrir:** `Curso/Controllers/Apis/ReservasController.cs`
👉 **Mostrar:** Comparar con EcoController: este hereda directamente de `ControllerBase` (linea 8). Senalar los tres endpoints y sus verbos HTTP: `[HttpGet]` (linea 38), `[HttpGet("{id:int}")]` (linea 44), `[HttpGet("error")]` (linea 56).
🔗 **Material alumno:** Seccion 1.2 (tabla de verbos HTTP y codigos de estado)

**Preguntar a los asistentes:**
- "Si el controlador se llama `ReservasController` con `[Route("api/[controller]")]`, cual es la URL?" -- Respuesta: `/api/Reservas`
- "Que pasa si escribo `[Route("api/controller")]` sin corchetes?" -- Respuesta: La ruta literal seria `/api/controller` para todos los controladores

⚡ **Si falta tiempo:** No detenerse en la tabla de verbos HTTP; los asistentes la pueden leer solos.

---

### Bloque 1.3: API sin base de datos (~5 min)

📂 **Abrir:** `Curso/Controllers/Apis/ReservasController.cs`
👉 **Mostrar:** La lista estatica hardcodeada (lineas 10-36). Recorrer los tres endpoints:
1. `Listar()` (linea 39-42) -- filtra por `Activo` con LINQ
2. `ObtenerPorId()` (lineas 44-54) -- `FirstOrDefault` + comprobacion de null + `NotFound()`
3. `ProvocarError()` (lineas 56-60) -- devuelve `Problem()` con ProblemDetails (RFC 7807)

💡 **Enfatizar:** El patron de comprobar null despues de `FirstOrDefault` y devolver `NotFound()` en vez de `Ok(null)`. Es un error clasico de principiante.

📂 **Abrir:** `Curso/Models/Reserva/ClaseReserva.cs`
👉 **Mostrar:** Como el DTO es extremadamente simple (lineas 3-11). No necesita validaciones porque solo es para lectura en este ejemplo.

**Demo en vivo** -- ejecutar la app y probar desde Scalar:
1. `GET /api/Reservas` -- devuelve solo las activas (2 de 3)
2. `GET /api/Reservas/1` -- devuelve la reserva 1
3. `GET /api/Reservas/999` -- devuelve 404
4. `GET /api/Reservas/error` -- devuelve 500 con JSON ProblemDetails

**Preguntar a los asistentes:**
- "Si `id = 99` y no existe, que devuelve `FirstOrDefault`?" -- Respuesta: `null`
- "Que formato tiene la respuesta de `Problem()`?" -- Respuesta: JSON con `ProblemDetails` (RFC 7807)

🔗 **Material alumno:** Seccion 1.3

---

### Bloque 1.4: Validacion Rojo-Verde-Refactor (~6 min)

Este es el bloque central de la sesion. Se trabaja con el EcoController y el DTO ClaseEcoUnidad.

📂 **Abrir:** `Curso/Models/Eco/ClaseEcoUnidad.cs`
👉 **Mostrar:** El DTO SIN ninguna validacion (lineas 7-18). Solo propiedades.

📂 **Abrir:** `Curso/Controllers/Apis/EcoController.cs`
👉 **Mostrar:** El endpoint `Validar` (lineas 27-32) que simplemente devuelve el DTO recibido. No hay codigo de validacion en el controlador.

**Fase ROJO -- Demo en vivo:**
Enviar a `POST /api/Eco/validar` un JSON con campos vacios. Mostrar que devuelve 200 OK con datos vacios.
- "Esto esta bien? Deberia aceptar un nombre vacio y granularidad 0?"

💡 **Enfatizar:** El DTO no tiene validaciones, asi que todo pasa. Esto es el ROJO.

**Fase VERDE:**
Explicar que anadiriamos `[Required(ErrorMessage = "...")]` a los campos de nombre. NO modificar el fichero en vivo (el material del alumno tiene el codigo paso a paso).
🔗 **Material alumno:** Seccion 1.5, Paso 2

**Fase REFACTOR:**

📂 **Abrir:** `Curso/Models/Eco/ClaseEcoUnidadDataAnnotations.cs`
👉 **Mostrar:** La version completa con DataAnnotations localizadas (lineas 1-41):
- `[Required]` con `ErrorMessageResourceType` (lineas 8-10)
- `[StringLength(200, MinimumLength = 3)]` (lineas 11-13)
- `[Range(5, 120)]` (lineas 32-34)
- `[RegularExpression(@"^[^@]+@(ua\.es|alu\.ua\.es)$")]` (lineas 37-39)

💡 **Enfatizar:** Comparar con la version sin localizar del material alumno (seccion 1.5, Paso 3) que usa `ErrorMessage = "..."` directo. La version real usa recursos `.resx` para multiidioma.

**Demo en vivo** -- enviar a `POST /api/Eco/validar-dataannotations`:
```json
{ "nombreEs": "AB", "granularidad": 3, "emailContacto": "user@gmail.com" }
```
Mostrar el 400 con errores acumulados por campo.

📂 **Abrir:** `Curso/ClientApp/src/views/apis/Eco.vue`
👉 **Mostrar:**
- Lineas 44-58: funcion `enviarValidar` -- limpia errores (lineas 45-46), hace POST, y en el catch distingue 400 de otros errores (linea 53)
- Lineas 98-103: binding del campo `NombreEs` con `:class="{ 'is-invalid': errores?.NombreEs }"` y el `invalid-feedback` de Bootstrap

💡 **Enfatizar:** Tres claves en Vue: (1) limpiar errores antes de cada llamada, (2) usar POST no GET, (3) errores en `error.response.data.errors` no en `error.response.data`.

🔗 **Material alumno:** Secciones 1.4 y 1.5

**Preguntar a los asistentes:**
- "Si un email tiene formato invalido Y no es de @ua.es, cuantos errores aparecen?" -- Respuesta: Pueden acumularse varios
- "Que pasa con `[StringLength(200)]` sin `MinimumLength`?" -- Respuesta: Acepta strings de 1 caracter

📂 **Abrir (opcional):** `Curso/Models/Eco/ClaseEcoUnidadValidator.cs`
👉 **Mostrar:** Brevemente la alternativa FluentValidation (lineas 8-50). Senalar la regla custom de lineas 19-28 que valida que al menos un nombre este relleno. Decir: "Esto lo veremos en profundidad en la sesion 2."

⚡ **Si falta tiempo:** Saltar FluentValidation y la demo en Vue. Centrarse solo en las DataAnnotations y el 400 en Scalar.

---

## Parte 2: Practica guiada (~10 min)

Los asistentes implementan el ejercicio de la seccion "Ejercicio Sesion 1" del material alumno.

**Tarea:**
1. Crear el DTO `ClaseReserva` con `CodReserva`, `Descripcion`, `FechaInicio`, `FechaFin`, `Activo`
2. Crear `ReservasController` con GET (listar), GET {id} (buscar), GET error (provocar 500)
3. Probar los tres endpoints desde Scalar

**Guia durante la practica:**
- Pasar por las mesas comprobando los tres errores mas frecuentes: falta `[Route("api/[controller]")]`, falta `[ApiController]`, no hereda de `ControllerBase`
- Si alguien termina rapido: pedirle que anade `[Required]` a `Descripcion` y un `[HttpPost]` para probar validacion
- Si alguien se atasca: recordar que `[controller]` va con corchetes y que el nombre pierde el sufijo `Controller`
- Solucion de referencia: esta en el desplegable del material. No mostrarla hasta 7-8 minutos

---

## Parte 3: Test (~5 min)

10 preguntas del banco de `preguntas.md`, de menor a mayor dificultad. Leer en voz alta y pedir respuestas.

| # | Pregunta (banco) | Respuesta |
|---|-----------------|-----------|
| 1 | P1 -- Diferencia DTO vs entidad | c) DTO transporta datos sin logica |
| 2 | P4 -- Que hace `[ApiController]` | c) Valida ModelState, devuelve 400 |
| 3 | P5 -- Ruta de `HerramientasController` | b) `/api/Herramientas/activas` |
| 4 | P9 -- De que clase hereda un controlador API | c) `ControllerBase` |
| 5 | P12 -- Error en `[Route("api/controller")]` | b) Falta corchetes en `[controller]` |
| 6 | P21 -- `return _reservas;` sin `Ok()` | b) Falta `Ok()` |
| 7 | P26 -- `[Required]` sin ErrorMessage + `[StringLength]` sin MinimumLength | b) Mensaje en ingles + acepta 1 caracter |
| 8 | P36 -- Enviar datos invalidos al refactor completo | b) 400 con errores en 3 campos |
| 9 | P40 -- `string id` + no comprobar null | b) Tipo incorrecto Y falta NotFound |
| 10 | P45 -- Vue con GET + sin limpiar + `.data` mal | c) Tres errores |

⚡ **Si falta tiempo:** Hacer solo P1, P4, P9, P21 y P36 (5 preguntas).

---

## Parte 4: Ejercicio Copilot (~10 min)

Referencia: `sesion-1/tests/practica-ia-fix.md` y bloques de codigo con fallos del material alumno.

### Ejercicio A: Controlador con 3 fallos (practica-ia-fix.md)

Proyectar el codigo de `practica-ia-fix.md`. Los asistentes piden a Copilot/ChatGPT que lo corrija.

| Fallo | Problema | Correccion esperada |
|-------|----------|-------------------|
| BUG 1 | `return Ok()` cuando dto es null | `BadRequest()` o 400 |
| BUG 2 | `StatusCode(500)` para validacion | `BadRequest("Nombre requerido")` o DataAnnotations |
| BUG 3 | `Ok(dto)` al crear recurso | `CreatedAtAction(...)` o `StatusCode(201, dto)` |

**Preguntar:**
- "Tiene sentido validar `string.IsNullOrEmpty` manualmente si podemos usar `[Required]`?" -- No, con `[ApiController]` es automatico
- "Que diferencia hay entre 200 y 201 al crear?" -- 201 es el correcto semanticamente

### Ejercicio B: Controlador con 5 fallos (del material alumno, seccion "Codigo con fallos para Copilot - Controlador")

Proyectar el bloque del material. Pedir: "Copiad en Copilot con el prompt: _Encuentra y corrige todos los errores de este controlador API de .NET Core_."

Los 5 fallos: ruta sin corchetes, no hereda ControllerBase, falta Ok(), id string en vez de int, no comprueba null.

**Discusion (2-3 min):** Pedir a 2-3 asistentes que compartan resultados. Copilot suele encontrar los 5? Normalmente si, pero a veces falla con el tipo de `id`.

### Ejercicio C (si sobra tiempo): DTO + Vue con fallos

Del material alumno, seccion "Codigo con fallos para Copilot (Validacion DTO + Vue)". Tiene 4 errores en DataAnnotations y 3 en Vue.

---

## Resumen

Conceptos clave para llevarse:

1. **DTO** = objeto plano en `Models/` con prefijo `Clase`. PascalCase -> SNAKE_CASE en Oracle
2. **Controlador API** = `[Route("api/[controller]")]` + `[ApiController]` + herencia de `ControllerBase`
3. **`[ApiController]`** valida automaticamente el ModelState. Sin codigo manual en acciones
4. **DataAnnotations**: `[Required]`, `[StringLength]`, `[Range]`, `[RegularExpression]`. Siempre con `ErrorMessage`
5. **Codigos HTTP**: 200 OK, 400 ValidationProblemDetails, 404 NotFound, 500 ProblemDetails
6. **En Vue**: limpiar errores antes de llamar, usar POST, errores en `error.response.data.errors`, clase `is-invalid` de Bootstrap

---

## Si falta tiempo

- Saltar Bloque 1.1 (DTOs) si los asistentes ya tienen experiencia
- Reducir practica: dar el DTO hecho, que solo implementen el controlador
- Test: solo 5 preguntas (P1, P4, P9, P21, P36)
- Copilot: solo Ejercicio A (3 fallos)

## Si sobra tiempo

- Ejercicio C: DTO + Vue con fallos para Copilot
- Pedir que implementen la vista Vue del ejercicio de Reservas
- Retar a que anadan `DELETE /api/Reservas/{id}` que devuelva `NoContent()`
- Mostrar brevemente `ClaseEcoUnidadValidator.cs` como anticipo de FluentValidation en sesion 2

---

## Preguntas dificiles frecuentes

| Pregunta | Respuesta |
|----------|-----------|
| "Por que no usamos Entity Framework?" | En la UA usamos ClaseOracleBD3 por compatibilidad con la infraestructura Oracle y los paquetes PL/SQL corporativos |
| "Diferencia entre `Controller` y `ControllerBase`?" | `Controller` anade soporte para vistas MVC (ViewBag, View()). En APIs no las necesitamos, usamos `ControllerBase` |
| "Por que `[Required]` y no validacion manual?" | Separacion de responsabilidades: la validacion pertenece al modelo. Ademas `[ApiController]` la ejecuta automaticamente. FluentValidation en sesion 2 para casos complejos |
| "Que pasa si el JSON no se puede deserializar?" | Con `[ApiController]`, .NET devuelve 400 automaticamente con el error de deserializacion. La accion no se ejecuta |
| "Diferencia entre `EcoController : ApiControllerBase` y `ReservasController : ControllerBase`?" | `ApiControllerBase` es la clase base del patron UA que anade `HandleResult<T>()` y metodos helper. Para APIs simples sin Result pattern basta `ControllerBase` |
