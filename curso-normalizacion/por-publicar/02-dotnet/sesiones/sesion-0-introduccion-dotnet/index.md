---
title: "Sesión 3: Introducción a .NET y conceptos previos"
description: Fundamentos de .NET 10, inyección de dependencias, estructura de Program.cs y anatomía de un proyecto ASP.NET Core con SPA Vue
outline: deep
---

# Sesión 3: Introducción a .NET y conceptos previos (~45 min)

[[toc]]

::: info CONTEXTO
Esta sesión sienta las bases para el resto del curso. Si ya conoces .NET Core, sirve como repaso rápido y actualización a .NET 10. Si vienes de otros lenguajes, aquí encontrarás todo lo que necesitas para seguir las sesiones siguientes.

**Sesiones de .NET en este curso:**

| Sesión | Tema | Qué aprenderás |
|--------|------|-----------------|
| **3 (esta)** | Introducción a .NET | Estructura del proyecto, inyección de dependencias, Program.cs |
| **4** | Modelos y primer API | Crear controladores API REST, verbos HTTP, códigos de estado |
| **5** | Servicios y acceso a Oracle | Capas, ClaseOracleBD3, mapeo automático, flujo completo |

Los temas de validación, errores, DataTable y OpenAPI se cubren en las sesiones de **Integración full-stack** (11-14).
:::

## 0.1 ¿Qué es .NET? {#que-es-dotnet}

.NET es la plataforma de desarrollo de Microsoft. Cuando decimos ".NET Core" o simplemente ".NET", nos referimos a la versión moderna, multiplataforma y de código abierto.

| Concepto | Descripción |
|----------|-------------|
| **.NET 10** | Versión actual (LTS — soporte de 3 años). Es la que usamos en el curso |
| **ASP.NET Core** | Framework para crear aplicaciones web y APIs sobre .NET |
| **C# 14** | Lenguaje de programación que usamos con .NET 10 |
| **NuGet** | Gestor de paquetes (equivalente a npm en JavaScript) |

::: tip BUENA PRÁCTICA
Usamos **.NET 10** porque es **LTS** (Long Term Support): tiene soporte oficial hasta noviembre de 2028. Las versiones impares (9, 11...) solo tienen soporte de 18 meses.
:::

### Novedades de .NET 10 que nos afectan

No necesitamos conocer todo .NET 10, pero hay tres cosas que nos resultan útiles:

1. **OpenAPI 3.1 por defecto** — la documentación de nuestras APIs usa el estándar más reciente
2. **APIs con cookies devuelven 401 en vez de redirigir** — los controladores con `[ApiController]` ya no redirigen a login, devuelven `401 Unauthorized` directamente
3. **C# 14: `field` keyword** — simplifica propiedades con lógica en el `set`:

```csharp
// Antes (C# 13): necesitábamos un campo privado manual
private string _nombre;
public string Nombre
{
    get => _nombre;
    set => _nombre = value?.Trim() ?? "";
}

// Ahora (C# 14): el compilador genera el campo automáticamente
public string Nombre
{
    get => field;
    set => field = value?.Trim() ?? "";
}
```

## 0.2 Anatomía de nuestro proyecto {#anatomia-proyecto}

Nuestro proyecto sigue la **plantilla UA** (`PlantillaMVCCore`). Es una aplicación ASP.NET Core con un frontend Vue.js integrado:

```
Ejercicio-Andres/
├── ReserUA/                         ← Proyecto principal (.NET)
│   ├── Controllers/
│   │   ├── Apis/                    ← Controladores API REST
│   │   │   ├── RecursoController.cs
│   │   │   ├── ReservaController.cs
│   │   │   ├── FranjaHorarioController.cs
│   │   │   ├── HorarioDiaController.cs
│   │   │   ├── RolController.cs
│   │   │   ├── PersonaController.cs
│   │   │   └── RecursoUsuarioController.cs
│   │   ├── HomeController.cs        ← Sirve la SPA Vue
│   │   └── PlantillaController.cs
│   ├── Models/
│   │   ├── Fotografia/              ← DTOs del dominio (ClaseRecurso, ClaseReserva...)
│   │   ├── Reservas/Validators/     ← Validadores FluentValidation
│   │   └── Plantilla/               ← Clases de la plantilla UA
│   ├── Services/                    ← Servicios de negocio
│   │   ├── RecursoService.cs        ← CRUD + DataTable (hereda ClaseCrudUtils)
│   │   ├── ReservaService.cs        ← Lógica de disponibilidad y reservas
│   │   └── ...
│   ├── ClientApp/                   ← Frontend Vue 3 + TypeScript
│   │   ├── src/
│   │   │   ├── views/
│   │   │   ├── components/
│   │   │   └── router/
│   │   └── package.json             ← pnpm, no npm
│   ├── Resources/                   ← Archivos de localización (.resx)
│   │   ├── Validacion.resx          ← Español (por defecto)
│   │   ├── Validacion.ca.resx       ← Valenciano
│   │   └── Validacion.en.resx       ← Inglés
│   ├── Views/Home/Index.cshtml      ← Punto de entrada de la SPA
│   ├── Program.cs                   ← Configuración de la aplicación
│   ├── appsettings.json             ← Configuración por entorno
│   └── ReserUA.csproj
├── ReserUA.Tests/                   ← Proyecto de pruebas (xUnit)
│   ├── Controllers/                 ← Tests de controladores
│   ├── Validation/                  ← Tests de validadores FluentValidation
│   ├── Services/                    ← Tests de lógica pura (disponibilidad)
│   └── Helpers/                     ← FakeStringLocalizer y utilidades
├── Documentacion/                   ← Documentación VitePress
└── CursoNormalizacionApps.sln       ← Solución raíz
```

### Cómo funciona nuestra aplicación

```
Navegador                   Servidor .NET                    Oracle
─────────                   ─────────────                    ──────
                    ┌─ Views/Home/Index.cshtml
GET /               │  (carga la SPA Vue)
──────────────────► │
                    │  Vue Router + Componentes
◄────── HTML+JS ────┘

                    ┌─ Controllers/Apis/
POST /api/unidades  │  UnidadesController
───────────────────►│       │
                    │       ▼
                    │  Models/Unidad/
                    │  ClaseUnidades (servicio)
                    │       │
                    │       ▼                      PKG_CITAS
◄─── JSON 200 ─────┘  ClaseOracleBD3 ──────────► Oracle BD
```

::: warning IMPORTANTE
El frontend Vue está **dentro** del proyecto .NET, en `Curso/ClientApp/`. No es un proyecto separado. El `HomeController` sirve la vista `Index.cshtml` que carga la SPA. Toda la comunicación después es por **API REST** (`/api/...`).
:::

### Archivos clave que vamos a tocar

| Archivo | Para qué sirve |
|---------|----------------|
| `Program.cs` | Registrar servicios y configurar el pipeline HTTP |
| `Controllers/Apis/*.cs` | Endpoints de la API REST |
| `Models/**/*.cs` | DTOs, servicios, validadores |
| `appsettings.json` | Cadenas de conexión, configuración |
| `ClientApp/src/views/*.vue` | Vistas del frontend |

## 0.3 Program.cs: el centro de todo {#program-cs}

`Program.cs` es el punto de entrada de la aplicación. Aquí ocurren dos cosas:

1. **Registrar servicios** (inyección de dependencias)
2. **Configurar el pipeline** de middleware (el orden importa)

```csharp
// Program.cs simplificado para entender la estructura
var builder = WebApplication.CreateBuilder(args);

// ═══════════════════════════════════════════════
// 1. REGISTRAR SERVICIOS (antes de builder.Build)
// ═══════════════════════════════════════════════
builder.Services.AddControllersWithViews();    // MVC + API controllers
builder.Services.AddLocalization();             // Soporte multiidioma
builder.Services.AddOpenApi();                  // Documentación OpenAPI

// Servicios de la UA
builder.AddServicesUA();                        // CAS, tokens, Oracle

// Nuestros servicios (inyección de dependencias)
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();

var app = builder.Build();

// ═══════════════════════════════════════════════
// 2. PIPELINE DE MIDDLEWARE (después de Build)
//    ⚠️ EL ORDEN IMPORTA
// ═══════════════════════════════════════════════
app.UseStaticFiles();          // 1º Archivos estáticos (CSS, JS)
app.UseRouting();              // 2º Sistema de rutas
app.UseCors();                 // 3º CORS (antes de auth)
app.UseAuthentication();       // 4º ¿Quién eres? (CAS)
app.UseAuthorization();        // 5º ¿Tienes permiso?
app.MapControllers();          // 6º Mapear controladores

app.Run();
```

::: danger ZONA PELIGROSA
El orden del middleware es crítico. Si ponemos `UseAuthorization` **antes** de `UseRouting`, la autorización no funcionará. Si ponemos `UseCors` **después** de `UseAuthorization`, las peticiones CORS fallarán.

**Regla mnemotécnica:** Estáticos → Rutas → CORS → Auth → Autorización → Controladores
:::

### ¿Qué es el middleware?

Cada `app.Use...()` añade una capa que procesa la petición HTTP. Podemos pensar en una cadena:

```
Petición HTTP
    │
    ▼
┌─────────────────┐
│ UseStaticFiles   │ → ¿Es un .js o .css? Lo sirvo y paro
└────────┬────────┘
         ▼
┌─────────────────┐
│ UseRouting       │ → Determina qué controlador se va a usar
└────────┬────────┘
         ▼
┌─────────────────┐
│ UseAuthentication│ → Lee la cookie CAS y crea los claims
└────────┬────────┘
         ▼
┌─────────────────┐
│ UseAuthorization │ → ¿El usuario tiene el rol necesario?
└────────┬────────┘
         ▼
┌─────────────────┐
│ Controlador API  │ → Ejecuta la acción y devuelve respuesta
└─────────────────┘
```

## 0.4 Inyección de dependencias {#inyeccion-dependencias}

::: info CONTEXTO
**¿Por qué no creamos los objetos con `new`?**

Sin inyección de dependencias, un controlador crearía sus dependencias directamente:

```csharp
// ❌ MAL: acoplamiento fuerte
public class UnidadesController : ControllerBase
{
    public ActionResult Listar()
    {
        var servicio = new ClaseUnidades(new ClaseOracleBd(...)); // ¿Y los parámetros?
        return Ok(servicio.ObtenerActivas("ES"));
    }
}
```

Problemas: el controlador necesita saber cómo crear `ClaseUnidades`, cómo crear `ClaseOracleBd`, qué parámetros necesitan... y no podemos testear sin una base de datos real.
:::

Con **inyección de dependencias (DI)**, le decimos al contenedor de .NET: *"cuando alguien pida un `IClaseUnidades`, dale una instancia de `ClaseUnidades`"*. El contenedor se encarga de crear y gestionar las instancias.

### Paso 1: Definir la interfaz

```csharp
// Models/Unidad/IClaseUnidades.cs
public interface IClaseUnidades
{
    Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES");
    Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES");
    Result<int> Guardar(ClaseGuardarUnidad dto);
    Result<bool> Eliminar(int id, int codPer, string ip);
}
```

### Paso 2: Implementar el servicio

```csharp
// Models/Unidad/ClaseUnidades.cs
public class ClaseUnidades : IClaseUnidades
{
    private readonly IClaseOracleBd _bd;

    // El contenedor inyecta IClaseOracleBd automáticamente
    public ClaseUnidades(IClaseOracleBd bd)
    {
        _bd = bd;
    }

    public Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES")
    {
        var datos = _bd.ObtenerTodosMap<ClaseUnidad>("SELECT ...", idioma: idioma);
        return Result<List<ClaseUnidad>>.Success(datos);
    }
}
```

### Paso 3: Registrar en ServicesExtensionsApp

En la plantilla UA, los servicios propios de la aplicación **no se registran directamente en `Program.cs`**, sino en un archivo dedicado:

```
Models/Plantilla/Inicializacion/ServicesExtensionsApp.cs
```

`Program.cs` llama a `builder.AddServicesApp()`, que internamente registra todo lo nuestro:

```csharp
// Models/Plantilla/Inicializacion/ServicesExtensionsApp.cs
public static class ServicesExtensionsApp
{
    public static void AddServicesApp(this WebApplicationBuilder builder)
    {
        // Inyección de servicios de la aplicación
        builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>(); // [!code highlight]
        //                 │           │                │
        //                 │           │                └─ Implementación real
        //                 │           └─ Interfaz (lo que piden los controladores)
        //                 └─ Vida: una instancia por petición HTTP

        // FluentValidation - registrar todos los validadores del ensamblado
        builder.Services.AddValidatorsFromAssemblyContaining<Program>();
        builder.Services.AddFluentValidationAutoValidation();
    }
}
```

::: tip BUENA PRÁCTICA
Cuando crees un nuevo servicio (DTO + interfaz + implementación), regístralo aquí en `AddServicesApp`. Así `Program.cs` queda limpio y todos los servicios propios están centralizados en un solo sitio.
:::

### Paso 4: Inyectar en el controlador

```csharp
// Controllers/Apis/UnidadesController.cs
public class UnidadesController : ApiControllerBase
{
    private readonly IClaseUnidades _unidades;

    // ✅ BIEN: el contenedor inyecta la implementación
    public UnidadesController(IClaseUnidades unidades)
    {
        _unidades = unidades;
    }

    [HttpGet]
    public ActionResult Listar([FromQuery] string idioma = "ES")
    {
        var resultado = _unidades.ObtenerActivas(idioma);
        return HandleResult(resultado);
    }
}
```

### Los tres ciclos de vida {#ciclos-vida-di}

Cuando registramos un servicio, elegimos **cuánto tiempo vive** la instancia:

| Método | Vida | Cuándo usar | Ejemplo |
|--------|------|-------------|---------|
| `AddTransient` | Se crea nuevo **cada vez** que se pide | Servicios ligeros sin estado | Validadores, utilidades |
| `AddScoped` | **Una instancia por petición HTTP** | Servicios con estado por petición | Servicios de datos, `ClaseOracleBd` |
| `AddSingleton` | **Una instancia para toda la aplicación** | Configuración, caché | Logger, configuración |

```csharp
// ServicesExtensionsApp.cs — Servicios propios de la aplicación
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();  // Una por petición

// Los servicios de infraestructura (Oracle, Auth, etc.) los registra
// la plantilla UA en builder.AddServicesUA(), no los tocamos nosotros
```

::: warning IMPORTANTE
**Nunca inyectes un servicio Scoped dentro de un Singleton.** El Singleton vive para siempre, pero el Scoped debería morir al terminar la petición. .NET lanza una excepción si detecta esta situación en desarrollo.
:::

### ¿Por qué usamos `AddScoped` para los servicios de datos?

Porque `ClaseOracleBd` mantiene la conexión a Oracle. Queremos:
- **Una conexión por petición HTTP** (no una nueva por cada consulta)
- **Que se libere al terminar la petición** (no que se quede abierta para siempre)

## 0.5 El patrón MVC en nuestras APIs {#mvc-apis}

MVC significa **Modelo-Vista-Controlador**. En nuestro caso, como trabajamos con una SPA Vue, no usamos vistas de Razor (excepto `Index.cshtml` para arrancar Vue). Nuestro flujo es:

| Capa | En nuestro proyecto | Responsabilidad |
|------|---------------------|-----------------|
| **Modelo** | `Models/` (DTOs, servicios, validadores) | Datos y lógica de negocio |
| **Vista** | `ClientApp/` (Vue 3) | Interfaz de usuario |
| **Controlador** | `Controllers/Apis/` | Recibe peticiones HTTP, llama al servicio, devuelve JSON |

### Convención de nombres UA

```
Models/Usuario.cs              ← DTO (singular): ClaseUsuario
Models/Usuarios.cs             ← Servicio (plural): ClaseUsuarios
Controllers/UsuariosController.cs  ← Controlador
```

El controlador **nunca** accede a la base de datos directamente. Siempre pasa por el servicio:

```
Controlador → Servicio → ClaseOracleBD3 → Oracle
```

## 0.6 Características útiles de C# {#csharp-util}

Estas características del lenguaje aparecen en el código del curso. Las presentamos aquí para que no sorprendan después.

### Tuplas: devolver varios valores sin crear una clase

```csharp
// Devolver dos valores de un método
public (bool exito, string mensaje) ValidarReserva(int id)
{
    if (id <= 0)
        return (false, "ID no válido");

    return (true, "Reserva válida");
}

// Usarlo
var (exito, mensaje) = ValidarReserva(5);
if (!exito)
    Console.WriteLine(mensaje);
```

### Records: DTOs inmutables en una línea

```csharp
// Record: clase inmutable con igualdad por valor (ideal para errores)
public record Error(string Code, string Message, ErrorType Type);

// Equivale a una clase con constructor, Equals, GetHashCode, ToString...
// Lo usamos en nuestro patrón Result<T> (sesión 2)
```

### Pattern matching con `switch`

```csharp
// En vez de if/else encadenados, usamos switch con expresiones
return result.Error!.Type switch
{
    ErrorType.Validation => BadRequest(...),     // 400
    _                    => Problem(..., 500)    // 500 (cualquier otro error)
};
```

::: tip BUENA PRÁCTICA
El `_` en el `switch` es el caso por defecto (como `default:`). Captura cualquier valor no contemplado. Lo usamos en `ApiControllerBase.HandleResult`: si la validación falla → 400, cualquier otro error → 500 genérico (sin dar pistas al cliente).
:::

### String interpolation y raw strings

```csharp
// Interpolación: insertar valores en strings
var saludo = $"Hola, {usuario.Nombre}. Tienes {reservas.Count} reservas.";

// Raw string literal (C# 11+): strings multilínea sin escapar
var sql = """
    SELECT ID, NOMBRE_ES, FLG_ACTIVA
    FROM TCTS_UNIDADES
    WHERE FLG_ACTIVA = 'S'
    ORDER BY NOMBRE_ES
    """;
```

### Null-conditional y null-coalescing

```csharp
// ?. → si es null, devuelve null (no lanza excepción)
var idioma = claims.FirstOrDefault(c => c.Type == "LENGUA")?.Value;

// ?? → si es null, usa el valor por defecto
var idiomaFinal = idioma ?? "es";

// Combinado: obtener claim o usar "es" por defecto
var idioma = User.Claims.FirstOrDefault(c => c.Type == "LENGUA")?.Value ?? "es";
```

### Colecciones con expresión de colección (C# 12+)

```csharp
// Antes
var lista = new List<string> { "uno", "dos", "tres" };

// Ahora: expresión de colección
List<string> lista = ["uno", "dos", "tres"];

// Funciona en arrays, listas, spans...
int[] numeros = [1, 2, 3, 4, 5];
```

## 0.7 Lo que viene en las próximas sesiones {#preview-curso}

Para que tengas el mapa mental completo de lo que vamos a construir:

### Sesión 1: DTOs y APIs sin base de datos

Crearemos controladores API que devuelven datos hardcodeados. Aprenderemos a usar `[ApiController]`, verbos HTTP y códigos de estado. Añadiremos validación con `DataAnnotations`.

### Sesión 2: Servicios, Oracle y `Result<T>`

Conectaremos con Oracle usando `ClaseOracleBD3`. Implementaremos el patrón `Result<T>` para que los servicios no lancen excepciones sino que devuelvan errores tipados.

### Sesión 3: Validación y errores

Pasaremos de `DataAnnotations` a **FluentValidation** con mensajes multiidioma. Configuraremos `ProblemDetails` para que todos los errores tengan el mismo formato.

### Sesión 4: DataTable server-side

Implementaremos paginación, filtrado y ordenación en servidor con `ClaseCrudUtils`. El frontend usará el componente DataTable UA de Vue.

### Sesión 5: OpenAPI, Scalar y testing

Documentaremos nuestras APIs con OpenAPI + Scalar. Escribiremos tests de integración con `WebApplicationFactory`.

---

## Ejercicio Sesión 0

**Objetivo:** Familiarizarse con la estructura del proyecto y la inyección de dependencias.

1. Abre la solución `CursoNormalizacionApps.sln` en Visual Studio
2. Localiza `Program.cs` y encuentra dónde se llama a `builder.AddServicesApp()`
3. Abre `ServicesExtensionsApp.cs` y localiza dónde se registran los servicios propios
4. Abre `UnidadesController.cs` e identifica qué servicio se inyecta por constructor
5. Busca la interfaz `IClaseUnidades` y su implementación `ClaseUnidades`
6. Ejecuta `dotnet build` y `dotnet test` para verificar que todo compila

::: details Solución

**Program.cs** llama a `builder.AddServicesApp()`, que está en `ServicesExtensionsApp.cs`:

```csharp
// Models/Plantilla/Inicializacion/ServicesExtensionsApp.cs
public static void AddServicesApp(this WebApplicationBuilder builder)
{
    builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();
}
```

::: tip NOTA
Técnicamente `builder.Services.AddScoped<...>()` funciona tanto en `Program.cs` como en `ServicesExtensionsApp.cs`. Nosotros hemos normalizado la plantilla para que **los servicios propios de la aplicación siempre se registren en `ServicesExtensionsApp.cs`**. Así `Program.cs` queda limpio y centralizado.
:::

**UnidadesController.cs** — Inyección por constructor:
```csharp
public class UnidadesController : ApiControllerBase
{
    private readonly IClaseUnidades _unidades;  // ← Interfaz inyectada

    public UnidadesController(IClaseUnidades unidades)  // ← Constructor
    {
        _unidades = unidades;
    }
}
```

**IClaseUnidades** define el contrato (qué métodos están disponibles).
**ClaseUnidades** implementa la lógica real con acceso a Oracle.

El controlador **solo conoce la interfaz**, nunca la implementación concreta. Esto nos permite:
- Cambiar la implementación sin tocar el controlador
- Testear con un `FakeUnidadesService` que no necesita BD

:::

::: details Código con fallos para Copilot — Inyección de dependencias

Este `Program.cs` tiene **5 errores** relacionados con DI y pipeline. Pide a Copilot que los identifique:

```csharp
// ⚠️ CÓDIGO CON FALLOS - Program.cs
var builder = WebApplication.CreateBuilder(args);

// 🐛 1: Registra como Singleton un servicio que usa conexión BD
builder.Services.AddSingleton<IClaseUnidades, ClaseUnidades>();

// 🐛 2: Falta registrar el controlador de vistas
// (no hay AddControllersWithViews ni AddControllers)

builder.Services.AddOpenApi();

var app = builder.Build();

// 🐛 3: UseAuthorization ANTES de UseRouting
app.UseAuthorization();
app.UseRouting();

// 🐛 4: UseAuthentication DESPUÉS de UseAuthorization
app.UseAuthentication();

// 🐛 5: Falta MapControllers — los endpoints API no se registran
app.Run();
```

**Respuesta esperada:**

```csharp
// ✅ CORREGIDO
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();     // Fix 2: registrar controladores
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>(); // Fix 1: Scoped, no Singleton
builder.Services.AddOpenApi();

var app = builder.Build();

app.UseRouting();          // Fix 3: primero Routing
app.UseAuthentication();   // Fix 4: luego Authentication
app.UseAuthorization();    // después Authorization
app.MapControllers();      // Fix 5: mapear endpoints
app.Run();
```

:::

## Preguntas de test

::: details 1. ¿Qué es .NET 10?
**a)** Un framework solo para Windows creado por Microsoft
**b)** La versión LTS actual de la plataforma .NET, multiplataforma y de código abierto ✅
**c)** Un lenguaje de programación derivado de Java
**d)** El gestor de paquetes de Visual Studio
:::

::: details 2. ¿Dónde se registran los servicios propios de la aplicación?
**a)** En el constructor de cada controlador
**b)** En `appsettings.json`
**c)** En `ServicesExtensionsApp.cs`, llamado desde `Program.cs` con `builder.AddServicesApp()` ✅
**d)** En el archivo `.csproj`
:::

::: details 3. ¿Qué diferencia hay entre AddScoped y AddSingleton?
**a)** AddScoped crea una instancia por petición HTTP; AddSingleton crea una para toda la aplicación ✅
**b)** AddScoped es más rápido que AddSingleton
**c)** AddSingleton solo funciona en producción
**d)** No hay diferencia, son sinónimos
:::

::: details 4. ¿Por qué el controlador recibe una interfaz (IClaseUnidades) y no la clase concreta (ClaseUnidades)?
**a)** Porque las interfaces son más rápidas en .NET
**b)** Para poder cambiar la implementación sin tocar el controlador y facilitar testing ✅
**c)** Porque las clases concretas no se pueden inyectar
**d)** Es obligatorio por la plantilla UA
:::

::: details 5. ¿Qué ocurre si ponemos UseAuthorization antes de UseRouting?
**a)** Funciona igual, el orden no importa
**b)** La autorización no puede determinar qué endpoint se va a ejecutar y falla ✅
**c)** La aplicación no compila
**d)** Solo afecta en producción
:::

::: details 6. ¿Qué es un record en C#?
**a)** Un tipo de dato para almacenar registros de base de datos
**b)** Una clase inmutable con igualdad por valor, ideal para DTOs y objetos de valor ✅
**c)** Un tipo especial de array
**d)** Una interfaz para serialización JSON
:::

::: details 7. ¿Qué hace el operador ?? en C#?
**a)** Compara dos valores y devuelve el mayor
**b)** Devuelve el operando izquierdo si no es null; si es null, devuelve el derecho ✅
**c)** Convierte un valor a nullable
**d)** Lanza una excepción si el valor es null
:::

::: details 8. En nuestro proyecto, ¿cómo se comunica el frontend Vue con el backend .NET?
**a)** Directamente accediendo a la base de datos Oracle desde JavaScript
**b)** Mediante peticiones HTTP a los endpoints API REST (`/api/...`) ✅
**c)** A través de WebSockets en tiempo real
**d)** El backend genera el HTML y Vue solo añade animaciones
:::

::: details 9. ¿Por qué usamos AddScoped para ClaseOracleBd?
**a)** Porque Oracle solo permite una conexión por aplicación
**b)** Para tener una conexión por petición HTTP que se libere al terminar ✅
**c)** Porque Singleton no funciona con Oracle
**d)** Es una convención de la UA sin motivo técnico
:::

::: details 10. ¿Qué hace `builder.AddServicesUA()` en Program.cs?
**a)** Instala los paquetes NuGet de la UA
**b)** Registra los servicios internos de la UA: autenticación CAS, tokens JWT, Oracle ✅
**c)** Configura el frontend Vue
**d)** Crea las tablas en la base de datos
:::

---

## Tests y práctica IA

- [Ver tests y práctica de la sesión](../../test/sesion-0/)
- [Autoevaluación sesión 0](../../test/sesion-0/autoevaluacion.md)
- [Preguntas de test sesión 0](../../test/sesion-0/preguntas.md)
- [Respuestas del test sesión 0](../../test/sesion-0/respuestas.md)
- [Práctica IA-fix sesión 0](../../test/sesion-0/practica-ia-fix.md)

---

**Siguiente:** [Sesión 1: DTOs y APIs sin base de datos](../sesion-1-dtos-apis/)
