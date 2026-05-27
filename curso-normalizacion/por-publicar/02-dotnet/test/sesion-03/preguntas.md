---
title: "Preguntas — Sesión 3: Introducción a .NET"
description: "Banco de 22 preguntas tipo test sobre Program.cs, inyección de dependencias, pipeline, C# moderno y arquitectura del proyecto UA."
outline: [2, 2]
search: false
---

# Test de autoevaluación — Sesión 3: Introducción a .NET

::: tip ALCANCE
Las preguntas cubren **solo** lo que se enseña en esta sesión: anatomía del proyecto, `Program.cs`, inyección de dependencias (`AddScoped`/`Transient`/`Singleton`), orden del pipeline, características útiles de C# (operadores `?.` / `??`, records, raw strings, expresiones de colección, `switch` con discard, tuplas) y arquitectura por capas.

Los temas relacionados que se cubren en otras sesiones tienen su propio test:
- DTOs, `[ApiController]`, verbos HTTP, validación con DataAnnotations → [Sesión 4](../sesion-04/).
- `ClaseOracleBD3`, mapeo automático, `[Columna]`, `Result<T>`, paquetes PL/SQL → [Sesión 5](../sesion-05/).
- `HandleResult` interno, `ProblemDetails`, `ValidationProblemDetails`, contrato de error UA → [Sesión 16](../../../04-integracion/sesiones/sesion-16-errores/).
- FluentValidation, `AddValidatorsFromAssemblyContaining`, localización con `.resx` → [Sesión 15](../../../04-integracion/sesiones/sesion-15-validacion/).
- CAS / JWT / claims → [Sesión 14](../../../04-integracion/sesiones/sesion-14-api-autenticacion/).
:::

## Pregunta 1

¿Qué ciclo de vida tiene un servicio registrado con `AddScoped`?

a) Se crea una nueva instancia cada vez que se solicita
b) Se crea una única instancia compartida por toda la aplicación
c) Se crea una instancia por cada petición HTTP
d) Se crea una instancia por cada controlador

## Pregunta 2

Dado el siguiente código en `Program.cs`, ¿cuál es el problema?

```csharp
var app = builder.Build();
app.UseAuthorization();
app.UseRouting();
app.UseAuthentication();
app.MapControllers();
app.Run();
```

a) Falta `app.UseStaticFiles()`
b) `UseAuthorization` y `UseAuthentication` están en orden incorrecto respecto a `UseRouting`
c) `MapControllers` debería ir antes de `UseRouting`
d) Falta `app.UseCors()`

## Pregunta 3

¿Qué ocurre si registramos `ClaseUnidades` como `AddSingleton` y este servicio usa `ClaseOracleBd` registrado como `AddScoped`?

a) Funciona correctamente en todos los entornos
b) .NET lanza una excepción en desarrollo porque un Singleton consume un Scoped (captive dependency)
c) La conexión a Oracle se cierra automáticamente
d) Se crea una nueva conexión por cada llamada al método

## Pregunta 4

¿Cuál es la salida del siguiente código?

```csharp
string? nombre = null;
var resultado = nombre?.ToUpper() ?? "ANONIMO";
Console.WriteLine(resultado);
```

a) `null`
b) Una excepción `NullReferenceException`
c) `"ANONIMO"`
d) `""` (cadena vacía)

## Pregunta 5

¿Dónde se registran los servicios propios de la aplicación en la plantilla UA?

a) Directamente en `Program.cs` dentro de `Main()`
b) En `appsettings.json` bajo la clave `"Services"`
c) En `ServicesExtensionsApp.cs`, invocado desde `Program.cs` con `builder.AddServicesApp()`
d) En cada controlador mediante el atributo `[Service]`

## Pregunta 6

¿Qué tipo de dato devuelve este método?

```csharp
public (bool exito, string mensaje) ValidarReserva(int id)
{
    if (id <= 0)
        return (false, "ID no valido");
    return (true, "Reserva valida");
}
```

a) Un objeto anónimo
b) Una tupla con dos valores: un `bool` y un `string`
c) Un `record` de tipo `Validacion`
d) Un `Dictionary<bool, string>`

## Pregunta 7

Dado el siguiente `record`:

```csharp
public record Error(string Code, string Message, ErrorType Type);
```

¿Cuál de las siguientes afirmaciones es correcta?

a) El record permite modificar sus propiedades después de creado
b) Dos instancias con los mismos valores de `Code`, `Message` y `Type` se consideran iguales
c) Es obligatorio definir un constructor explícito
d) Los records no pueden usarse como parámetros de métodos

## Pregunta 8

¿Cuál es el orden correcto del pipeline de middleware en `Program.cs`?

a) `UseAuthentication` → `UseRouting` → `UseAuthorization` → `UseStaticFiles` → `MapControllers`
b) `UseStaticFiles` → `UseRouting` → `UseCors` → `UseAuthentication` → `UseAuthorization` → `MapControllers`
c) `MapControllers` → `UseRouting` → `UseAuthentication` → `UseAuthorization` → `UseStaticFiles`
d) `UseRouting` → `UseStaticFiles` → `UseAuthentication` → `UseCors` → `UseAuthorization` → `MapControllers`

## Pregunta 9

En el siguiente código, ¿qué hace el `_` en la expresión `switch`?

```csharp
return result.Error!.Type switch
{
    ErrorType.Validation => BadRequest(...),
    _ => Problem(..., 500)
};
```

a) Ignora el valor de retorno
b) Actúa como caso por defecto, capturando cualquier valor no contemplado
c) Representa un valor null
d) Es un operador de descarte que no compila si hay más valores en el enum

## Pregunta 10

¿Qué diferencia hay entre `AddControllersWithViews()` y `AddControllers()` en `Program.cs`?

a) No hay diferencia, son equivalentes
b) `AddControllersWithViews` registra soporte para MVC con vistas Razor además de APIs (lo necesitamos porque `HomeController` sirve la vista `Index.cshtml` que carga la SPA Vue)
c) `AddControllers` solo funciona con APIs en .NET Framework
d) `AddControllersWithViews` es obsoleto en .NET 10

## Pregunta 11

Dado este controlador, ¿qué fallo tiene?

```csharp
public class UnidadesController : ApiControllerBase
{
    public ActionResult Listar([FromQuery] string idioma = "ES")
    {
        var servicio = new ClaseUnidades(new ClaseOracleBd());
        var resultado = servicio.ObtenerActivas(idioma);
        return HandleResult(resultado);
    }
}
```

a) Falta el atributo `[HttpGet]`
b) No se debe crear instancias manualmente con `new`; se debe inyectar por constructor
c) `HandleResult` no existe en `ApiControllerBase`
d) `FromQuery` no se puede usar con parámetros por defecto

## Pregunta 12

En el siguiente `Program.cs`, ¿qué falta para que los controladores API funcionen?

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllersWithViews();
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();
var app = builder.Build();
app.UseRouting();
app.Run();
```

a) Falta `app.UseEndpoints()`
b) Falta `app.MapControllers()`
c) Falta `app.UseControllers()`
d) Los controladores se registran automáticamente, no falta nada

## Pregunta 13

¿Qué problema tiene este registro de servicios?

```csharp
builder.Services.AddTransient<IClaseOracleBd, ClaseOracleBd>();
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();
```

a) No se puede mezclar Transient y Scoped
b) `ClaseOracleBd` gestiona conexiones y no debería ser Transient (crearía una conexión nueva cada vez que se inyecta)
c) Falta registrar `ClaseUnidades` como Transient también
d) El orden de registro es incorrecto

## Pregunta 14

¿Qué hace el middleware `UseStaticFiles()` y por qué va primero en el pipeline?

a) Comprime los archivos estáticos; va primero para mejorar el rendimiento
b) Sirve archivos CSS/JS directamente; va primero para no pasar por autenticación innecesariamente
c) Registra las rutas de los archivos estáticos; debe ir antes de `UseRouting`
d) Genera los archivos estáticos del frontend Vue; va primero para que estén disponibles

## Pregunta 15

¿Cuál es el resultado de este código?

```csharp
var sql = """
    SELECT ID, NOMBRE_ES
    FROM TRES_UNIDAD
    WHERE FLG_ACTIVA = 'S'
    """;
Console.WriteLine(sql.Contains("NOMBRE_ES"));
```

a) `false`
b) `true`
c) Error de compilación: `"""` no es sintaxis válida
d) Error en tiempo de ejecución

## Pregunta 16

¿Qué patrón sigue el flujo `Controlador → Servicio → ClaseOracleBD3 → Oracle`?

a) Patrón Repositorio
b) Patrón MVC con capas de servicio
c) Patrón Observer
d) Patrón Factory

## Pregunta 17

¿Por qué el controlador recibe `IClaseUnidades` (interfaz) y no `ClaseUnidades` (clase concreta)?

a) Las interfaces son más rápidas en .NET
b) Es un requisito del atributo `[ApiController]`
c) Para desacoplar: permite cambiar la implementación y facilitar testing con fakes
d) Las clases concretas no se pueden inyectar en ASP.NET Core

## Pregunta 18

En el siguiente servicio, ¿qué rol cumple `_bd`?

```csharp
public class ClaseUnidades : IClaseUnidades
{
    private readonly IClaseOracleBd _bd;

    public ClaseUnidades(IClaseOracleBd bd)
    {
        _bd = bd;
    }
}
```

a) Es una variable estática compartida entre instancias
b) Es una dependencia inyectada por constructor que da acceso a Oracle
c) Es un campo que se inicializa con `new ClaseOracleBd()`
d) Es un parámetro de configuración leído de `appsettings.json`

## Pregunta 19

¿Qué versión de .NET se usa en este curso y por qué?

a) .NET 9 porque es la más reciente
b) .NET 10 porque es LTS con soporte hasta noviembre de 2028
c) .NET 8 porque es la más estable
d) .NET Framework 4.8 porque es compatible con Oracle

## Pregunta 20

¿Dónde se configura la cadena de conexión a Oracle en el proyecto?

a) En `Program.cs` como constante
b) En `appsettings.json` (y variantes por entorno)
c) En `ServicesExtensionsApp.cs`
d) En cada servicio que accede a Oracle

## Pregunta 21

¿Cuál es el error en este registro de dependencias?

```csharp
builder.Services.AddScoped<ClaseUnidades>();
```

a) Falta especificar el ciclo de vida
b) Se registra la clase concreta sin interfaz, lo que impide inyectar `IClaseUnidades` en controladores
c) `AddScoped` no acepta un solo parámetro genérico
d) No hay error, es una forma válida de registro

## Pregunta 22

¿Qué beneficio principal aporta el patrón `Result<T>` frente a lanzar excepciones en los servicios?

a) Es más rápido en ejecución porque evita el coste del stack trace de excepciones
b) Obliga al controlador a manejar explícitamente éxitos y errores sin depender de try/catch
c) Permite devolver múltiples resultados simultáneamente
d) Es requisito obligatorio de ASP.NET Core 10
