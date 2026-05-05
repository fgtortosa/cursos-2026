# Guia del profesor — Sesion 3: Introduccion a .NET y conceptos previos

## Objetivo y material
- **Duracion:** 45 min
- **Objetivo:** Que los asistentes comprendan la estructura de un proyecto ASP.NET Core con SPA Vue segun la plantilla UA, dominen la inyeccion de dependencias (registro, ciclos de vida, inyeccion por constructor) y conozcan el orden correcto del pipeline de middleware en `Program.cs`.
- **Material alumno:** sesion-0-introduccion-dotnet.md
- **Prerequisitos:** Conocimientos basicos de programacion orientada a objetos. Familiaridad con Visual Studio. No se requiere experiencia previa en .NET ni C#.

## Parte 1: Teoria con codigo real (~20 min)

### Bloque 1.1: Que es .NET y anatomia del proyecto (~7 min)

📂 **Abrir:** La solucion `CursoNormalizacionApps.sln` en Visual Studio y desplegar el arbol de carpetas del Explorador de Soluciones.
👉 **Mostrar:** La estructura de carpetas real: `Curso/Controllers/Apis/`, `Curso/Models/`, `Curso/ClientApp/`, `CursoTest/`. Senalar que el frontend Vue vive **dentro** del proyecto .NET en `ClientApp/`.
💡 **Enfatizar:** El flujo de comunicacion: el navegador carga la SPA via `HomeController` y a partir de ahi toda la interaccion es por API REST (`/api/...`). Vue nunca accede a Oracle directamente.
🔗 **Material alumno:** Secciones 0.1 y 0.2

**Preguntar a los asistentes:**
- "Si el frontend Vue esta dentro del proyecto .NET, como se comunican entre si? Accede Vue directamente a Oracle?"

> Respuesta esperada: No. Vue hace peticiones HTTP a los endpoints API REST. Nunca accede a la BD directamente.

**Mencionar brevemente** la novedad de C# 14 (keyword `field`) del material seccion 0.1, sin profundizar. Solo dejar constancia de que el lenguaje sigue evolucionando.

⚡ **Si falta tiempo:** Omitir las novedades de .NET 10/C# 14 y pasar directamente al bloque 1.2.

### Bloque 1.2: Program.cs y pipeline de middleware (~6 min)

📂 **Abrir:** `Curso/Program.cs`
👉 **Mostrar:** Las dos zonas del fichero:
  - **Zona de registro de servicios** (lineas 26-76): desde `var builder = WebApplication.CreateBuilder(args)` hasta `var app = builder.Build()`. Senalar `builder.AddServicesUA()` (linea 51), `AddControllersWithViews` (linea 54), `AddOpenApi` (linea 64), `AddCors` (linea 66).
  - **Zona del pipeline de middleware** (lineas 84 en adelante): senalar el orden real: `UseStaticFiles` (linea 161), `UseRouting` (linea 167), `UseCors` (linea 170), `UseAuthentication` (linea 175), `UseAuthorization` (linea 194).
💡 **Enfatizar:** El orden del middleware es critico. Regla mnemotecnica: **Estaticos - Rutas - CORS - Auth - Autorizacion - Controladores**. Si se altera el orden, la autorizacion no sabe que endpoint se ejecuta.
🔗 **Material alumno:** Seccion 0.3

**Preguntar a los asistentes:**
- "Que pasa si ponemos `UseAuthorization` antes de `UseRouting`?"

> Respuesta esperada: La autorizacion no puede determinar que endpoint se va a ejecutar y falla silenciosamente (no aplica las politicas de roles).

⚡ **Si falta tiempo:** Senalar solo las dos zonas del fichero y el orden del pipeline sin recorrer cada middleware individual. Dejar el diagrama de capas del material (seccion 0.3) como lectura.

### Bloque 1.3: Inyeccion de dependencias (~7 min)

Este bloque se explica recorriendo cuatro ficheros reales en secuencia. Abrir cada uno con F12 / Go to Definition para que vean la navegacion natural en Visual Studio.

**Paso 1 -- La interfaz (contrato)**
📂 **Abrir:** `Curso/Models/Unidad/IClaseUnidades.cs`
👉 **Mostrar:** Los metodos que devuelven `Result<T>`: `ObtenerActivas`, `ObtenerPorId`, `Guardar`, `Eliminar` (lineas 12-15). Senalar que el controlador solo conoce esta interfaz.
🔗 **Material alumno:** Seccion 0.4, "Paso 1: Definir la interfaz"

**Paso 2 -- La implementacion (servicio)**
📂 **Abrir:** `Curso/Models/Unidad/ClaseUnidades.cs`
👉 **Mostrar:** El constructor (linea 20) que recibe `ClaseOracleBd` y `ILogger` por inyeccion. Mostrar brevemente el metodo `ObtenerActivas` (lineas 116-126) para ver como usa `bd.ObtenerTodosMap<ClaseUnidad>` y devuelve `Result<T>.Success(...)`.
💡 **Enfatizar:** El servicio tambien recibe sus dependencias por constructor (DI en cadena). Nunca hace `new ClaseOracleBd(...)`.
🔗 **Material alumno:** Seccion 0.4, "Paso 2: Implementar el servicio"

**Paso 3 -- El registro**
📂 **Abrir:** `Curso/Models/Plantilla/Inicializacion/ServicesExtensionsApp.cs`
👉 **Mostrar:** La linea `builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>()` (linea 25). Senalar tambien el registro de FluentValidation (lineas 28-29).
💡 **Enfatizar:** Los servicios propios se registran aqui, no directamente en `Program.cs`. Esto mantiene `Program.cs` limpio. `Program.cs` solo llama a `builder.AddServicesApp()`.
🔗 **Material alumno:** Seccion 0.4, "Paso 3: Registrar en ServicesExtensionsApp"

**Paso 4 -- La inyeccion en el controlador**
📂 **Abrir:** `Curso/Controllers/Apis/UnidadesController.cs`
👉 **Mostrar:** El constructor (lineas 13-16) que recibe `IClaseUnidades` y lo guarda en `_unidades`. Mostrar el metodo `Listar` (lineas 18-22): llama a `_unidades.ObtenerActivas(idioma)` y pasa el resultado a `HandleResult`.
💡 **Enfatizar:** El controlador no sabe que implementacion tiene detras. Solo conoce la interfaz. Esto permite testear con un fake sin BD real.
🔗 **Material alumno:** Seccion 0.4, "Paso 4: Inyectar en el controlador"

**Mostrar brevemente HandleResult:**
📂 **Abrir:** `Curso/Controllers/ApiControllerBase.cs`
👉 **Mostrar:** El metodo `HandleResult<T>` (lineas 70-85): si es exito devuelve `Ok(result.Value)`, si es error de validacion devuelve 400, cualquier otro error devuelve 500.
💡 **Enfatizar:** Solo dos codigos de error: 400 (validacion) y 500 (sistema). Si un recurso no se encuentra, se devuelve 200 con `Id=0`. Esta es la convencion UA.
🔗 **Material alumno:** Seccion 0.5

**Preguntar a los asistentes:**
- "Por que el controlador recibe `IClaseUnidades` (interfaz) y no `ClaseUnidades` (clase concreta)?"

> Respuesta esperada: Para desacoplar. Permite cambiar la implementacion sin tocar el controlador y facilita testing con mocks.

**Ciclos de vida -- explicar con ejemplo:**
- `AddScoped`: una instancia por peticion HTTP. Lo usamos para `ClaseUnidades` y `ClaseOracleBd` porque mantienen conexion a Oracle.
- `AddTransient`: nueva instancia cada vez que se pide. Para servicios ligeros sin estado.
- `AddSingleton`: una instancia para toda la app. Para configuracion o cache.
- **Regla critica:** nunca inyectar un Scoped dentro de un Singleton. .NET lanza excepcion en desarrollo.

⚡ **Si falta tiempo:** Mostrar solo los pasos 3 (registro) y 4 (controlador), omitiendo la interfaz y la implementacion del servicio. Mencionar HandleResult sin abrir el fichero.

## Parte 2: Practica guiada (~10 min)

🔗 **Material alumno:** Seccion "Ejercicio Sesion 0" (al final del documento)

Guiar a los asistentes paso a paso, dando 1-2 minutos por paso:

1. **"Abrid la solucion** `CursoNormalizacionApps.sln` en Visual Studio."
2. **"Localizad `Program.cs`** y encontrad donde se llama a `builder.AddServicesApp()`." (esta cerca de la linea 51, dentro del bloque de registro de servicios)
3. **"Haced F12 sobre `AddServicesApp`** para navegar a `ServicesExtensionsApp.cs`. Que servicios se registran? Con que ciclo de vida?"
4. **"Abrid `UnidadesController.cs`** (en `Controllers/Apis/`). Que tipo tiene el campo `_unidades`? Es la interfaz o la clase concreta?"
5. **"Buscad `IClaseUnidades`** (Ctrl+T) y luego su implementacion `ClaseUnidades`. Observad que el servicio tambien recibe `ClaseOracleBd` por constructor."
6. **"Ejecutad `dotnet build`** desde la terminal (Ctrl+`) para verificar que compila."

**Convencion de nombres UA a reforzar durante la practica:**
- DTO singular: `ClaseUnidad` (en `Models/Unidad/ClaseUnidad.cs`)
- Servicio plural: `ClaseUnidades` (en `Models/Unidad/ClaseUnidades.cs`)
- Controlador: `UnidadesController` (en `Controllers/Apis/UnidadesController.cs`)
- Flujo: Controlador -> Servicio -> ClaseOracleBD3 -> Oracle

## Parte 3: Test (~5 min)

Seleccion de 10 preguntas de `preguntas.md` para resolver en grupo. Proyectar cada pregunta, dar 15-20 segundos para pensar y pedir respuesta a alguien concreto.

| # | Tema | Por que incluirla |
|---|------|-------------------|
| **1** | Ciclo de vida de `AddScoped` | Concepto fundamental de DI |
| **2** | Orden incorrecto del pipeline | Refuerza bloque 1.2 |
| **3** | Singleton que consume Scoped | Error clasico, .NET lo detecta en desarrollo |
| **5** | Donde se registran servicios propios | Refuerza convencion `ServicesExtensionsApp.cs` |
| **8** | Orden correcto del pipeline completo | Consolida regla mnemotecnica |
| **14** | Controlador con `new` en lugar de DI | Conecta con bloque 1.3 |
| **25** | Interfaz vs clase concreta | Refuerza la pregunta de clase |
| **27** | Rol de `_bd` como dependencia inyectada | Cadena de inyeccion |
| **42** | Recurso no encontrado devuelve 200 con Id=0 | Convencion UA critica |
| **47** | Significado de `private readonly` | Patron que veran en cada fichero |

💡 **Pregunta 42 merece atencion especial:** Muchos esperaran un 404. Explicar que la UA devuelve 200 con `Id=0` y que el frontend valida ese caso. Abrir `Curso/Models/Unidad/ClaseUnidades.cs` lineas 135-137 para mostrar `new ClaseUnidad { Id = 0 }` como ejemplo real.

## Parte 4: Ejercicio Copilot (~10 min)

🔗 **Material alumno:** `practica-ia-fix.md`

### Presentacion (2 min)
Explicar: "Vamos a usar Copilot/ChatGPT como herramienta de aprendizaje. Le daremos un `Program.cs` con 5 errores y le pediremos que los encuentre y corrija. Luego evaluaremos si la IA lo ha hecho bien."

Proyectar el codigo con fallos de `practica-ia-fix.md`. Los 5 errores son:
1. `AddSingleton` para un servicio con conexion BD (deberia ser `AddScoped`)
2. Falta `AddControllersWithViews()`
3. `UseAuthorization` antes de `UseRouting`
4. `UseAuthentication` despues de `UseAuthorization`
5. Falta `MapControllers()`

### Ejecucion (5 min)
Cada asistente abre Copilot Chat (o ChatGPT) y pega el codigo con el prompt: *"Este Program.cs tiene 5 errores de inyeccion de dependencias y pipeline. Identifica y corrige cada uno."*

Circular por las mesas para ver las respuestas.

### Puesta en comun (3 min)
Preguntar al grupo:
- "Cuantos errores encontro vuestra IA? Los 5?"
- "Explico correctamente POR QUE `AddSingleton` es incorrecto para un servicio con conexion BD?"
- "Propuso el orden correcto del pipeline?"

**Pistas si se atascan:**
- Error 1: "Que ciclo de vida deberia tener un servicio que usa `ClaseOracleBd`?"
- Error 2: "Si no registramos controladores, como los descubre .NET?"
- Errores 3-4: "Recordad: Estaticos - Rutas - CORS - Auth - Autorizacion - Controladores"
- Error 5: "De que sirve registrar controladores si no mapeamos sus endpoints?"

Proyectar la solucion esperada de `practica-ia-fix.md` al final.

## Resumen (conceptos clave que deben llevarse)

1. **`Program.cs` tiene dos zonas:** registro de servicios (antes de `Build()`) y pipeline de middleware (despues).
2. **El orden del pipeline importa:** Estaticos - Rutas - CORS - Auth - Autorizacion - Controladores.
3. **Inyeccion de dependencias:** interfaz + implementacion + registro en `ServicesExtensionsApp.cs` con `AddScoped`.
4. **El controlador solo conoce la interfaz**, nunca la implementacion concreta. Esto permite testing sin BD.
5. **Convencion UA:** DTO singular, servicio plural. Controlador -> Servicio -> ClaseOracleBD3 -> Oracle.
6. **Solo dos codigos de error HTTP:** 400 (validacion) y 500 (sistema). Recurso no encontrado = 200 con `Id=0`.

**Para practicar en casa:**
- Completar las 50 preguntas de `preguntas.md` (en clase solo se cubren 10)
- Repasar las caracteristicas de C# de la seccion 0.6 del material (tuplas, records, pattern matching, `?.` y `??`)
- Abrir `Curso/Controllers/ApiControllerBase.cs` y leer `HandleResult<T>()` con detenimiento

## Si falta tiempo (que recortar)

1. **Primero:** Reducir el test a 5 preguntas: 1, 2, 5, 14, 25 (cubren DI, pipeline y convencion UA).
2. **Segundo:** En la practica guiada, omitir los pasos 5-6 (buscar `IClaseUnidades` y `dotnet build`).
3. **Tercero:** En el bloque 1.1, omitir las novedades de .NET 10/C# 14.
4. **Cuarto:** El ejercicio Copilot hacerlo en grupo (proyectar pantalla del profesor) en lugar de individualmente.
5. **Ultimo recurso:** Dejar la seccion 0.6 de C# (tuplas, records, pattern matching) como lectura para casa.

## Si sobra tiempo (que ampliar)

1. Pedir que abran `Curso/Controllers/ApiControllerBase.cs` y lean `HandleResult<T>()`, anticipando la sesion 2. Preguntar: "Que devuelve si `ErrorType` es `Validation`? Y si es `Failure`?"
2. En `ServicesExtensionsApp.cs`, senalar `AddValidatorsFromAssemblyContaining<Program>()` y explicar que registra automaticamente todos los validadores FluentValidation del ensamblado.
3. Proponer que modifiquen el codigo con fallos anadiendo un sexto error (por ejemplo, `ClaseOracleBd` como `AddTransient`) y se lo pasen a Copilot para ver si lo detecta.
4. Cubrir preguntas de C# del banco de test: 4 (null-coalescing), 6 (tuplas), 7 (records), 17 (expresiones de coleccion), 40 (igualdad de records).
5. Mostrar en `Curso/Program.cs` el middleware personalizado de idioma (lineas 176-192) como ejemplo de middleware inline con `app.Use(async ...)`.

## Preguntas dificiles frecuentes

**"Cual es la diferencia real entre AddScoped y AddTransient?"**
Usar el ejemplo de `ClaseOracleBd`: con Transient se crearia una conexion nueva cada vez que alguien inyecta el servicio (incluso varias veces en la misma peticion). Con Scoped se reutiliza la misma conexion durante toda la peticion HTTP. Abrir `Curso/Models/Unidad/ClaseUnidades.cs` y senalar que `ClaseOracleBd` se inyecta en el constructor (linea 20): si fuera Transient, cada servicio tendria su propia conexion.

**"Por que no usar siempre Singleton si es mas eficiente?"**
Porque los servicios con estado (conexiones BD, datos de usuario) no deben compartirse entre peticiones de distintos usuarios. Ademas, .NET lanza excepcion si un Singleton consume un Scoped (pregunta 3 del test).

**"Por que 200 con Id=0 en lugar de 404?"**
Es una decision de arquitectura de la UA. Simplifica el contrato: solo hay 200, 400 y 500. El frontend comprueba `Id === 0`. Mostrar `Curso/Models/Unidad/ClaseUnidades.cs` lineas 135-137 como ejemplo real. Explicar que es una convencion valida aunque no sea la mas comun en la industria.

**"Para que sirve `HandleResult` si podria devolver Ok/BadRequest directamente?"**
Para centralizar el mapeo ErrorType -> HTTP y no repetir la logica en cada accion del controlador. Abrir `Curso/Controllers/ApiControllerBase.cs` lineas 70-85 y senalar que todos los controladores heredan de esta base.

**"Que hace `builder.AddServicesUA()` exactamente?"**
Registra los servicios internos de la plantilla UA: autenticacion CAS, tokens JWT, conexion Oracle (`ClaseOracleBd`), logging. No lo tocamos nosotros, lo proporciona la libreria `PlantillaMVCCore`. Senalar la llamada en `Curso/Program.cs` linea 51.
