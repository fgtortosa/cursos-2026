# Test de autoevaluacion -- Sesion 0: Introduccion a .NET

## Pregunta 1
¿Que ciclo de vida tiene un servicio registrado con `AddScoped`?

a) Se crea una nueva instancia cada vez que se solicita
b) Se crea una unica instancia compartida por toda la aplicacion
c) Se crea una instancia por cada peticion HTTP
d) Se crea una instancia por cada controlador

## Pregunta 2
Dado el siguiente codigo en `Program.cs`, ¿cual es el problema?

```csharp
var app = builder.Build();
app.UseAuthorization();
app.UseRouting();
app.UseAuthentication();
app.MapControllers();
app.Run();
```

a) Falta `app.UseStaticFiles()`
b) `UseAuthorization` y `UseAuthentication` estan en orden incorrecto respecto a `UseRouting`
c) `MapControllers` deberia ir antes de `UseRouting`
d) Falta `app.UseCors()`

## Pregunta 3
¿Que ocurre si registramos `ClaseUnidades` como `AddSingleton` y este servicio usa `ClaseOracleBd` registrado como `AddScoped`?

a) Funciona correctamente en todos los entornos
b) .NET lanza una excepcion en desarrollo porque un Singleton consume un Scoped
c) La conexion a Oracle se cierra automaticamente
d) Se crea una nueva conexion por cada llamada al metodo

## Pregunta 4
¿Cual es la salida del siguiente codigo?

```csharp
string? nombre = null;
var resultado = nombre?.ToUpper() ?? "ANONIMO";
Console.WriteLine(resultado);
```

a) null
b) Una excepcion NullReferenceException
c) "ANONIMO"
d) "" (cadena vacia)

## Pregunta 5
¿Donde se registran los servicios propios de la aplicacion en la plantilla UA?

a) Directamente en `Program.cs` dentro de `Main()`
b) En `appsettings.json` bajo la clave "Services"
c) En `ServicesExtensionsApp.cs`, invocado desde `Program.cs` con `builder.AddServicesApp()`
d) En cada controlador mediante el atributo `[Service]`

## Pregunta 6
¿Que tipo de dato devuelve este metodo?

```csharp
public (bool exito, string mensaje) ValidarReserva(int id)
{
    if (id <= 0)
        return (false, "ID no valido");
    return (true, "Reserva valida");
}
```

a) Un objeto anonimo
b) Una tupla con dos valores: un bool y un string
c) Un record de tipo Validacion
d) Un Dictionary<bool, string>

## Pregunta 7
Dado el siguiente `record`:

```csharp
public record Error(string Code, string Message, ErrorType Type);
```

¿Cual de las siguientes afirmaciones es correcta?

a) El record permite modificar sus propiedades despues de creado
b) Dos instancias con los mismos valores de Code, Message y Type se consideran iguales
c) Es obligatorio definir un constructor explicito
d) Los records no pueden usarse como parametros de metodos

## Pregunta 8
¿Cual es el orden correcto del pipeline de middleware en `Program.cs`?

a) UseAuthentication -> UseRouting -> UseAuthorization -> UseStaticFiles -> MapControllers
b) UseStaticFiles -> UseRouting -> UseCors -> UseAuthentication -> UseAuthorization -> MapControllers
c) MapControllers -> UseRouting -> UseAuthentication -> UseAuthorization -> UseStaticFiles
d) UseRouting -> UseStaticFiles -> UseAuthentication -> UseCors -> UseAuthorization -> MapControllers

## Pregunta 9
En el siguiente codigo, ¿que hace el `_` en la expresion `switch`?

```csharp
return result.Error!.Type switch
{
    ErrorType.Validation => BadRequest(...),
    _ => Problem(..., 500)
};
```

a) Ignora el valor de retorno
b) Actua como caso por defecto, capturando cualquier valor no contemplado
c) Representa un valor null
d) Es un operador de descarte que no compila si hay mas valores en el enum

## Pregunta 10
¿Que diferencia hay entre `AddControllersWithViews()` y `AddControllers()` en `Program.cs`?

a) No hay diferencia, son equivalentes
b) `AddControllersWithViews` registra soporte para MVC con vistas Razor ademas de APIs
c) `AddControllers` solo funciona con APIs en .NET Framework
d) `AddControllersWithViews` es obsoleto en .NET 10

## Pregunta 11
¿Cual es el resultado de este codigo?

```csharp
var claims = new List<Claim>();
var idioma = claims.FirstOrDefault(c => c.Type == "LENGUA")?.Value ?? "es";
Console.WriteLine(idioma);
```

a) null
b) Una excepcion porque la lista esta vacia
c) "es"
d) "LENGUA"

## Pregunta 12
En la plantilla UA, ¿cual es la convencion de nombres para modelos y servicios?

a) DTO en singular (`ClaseUsuario`), servicio en plural (`ClaseUsuarios`)
b) Todo en singular: `ClaseUsuario` y `ClaseUsuarioService`
c) DTO en plural, servicio en singular
d) Se usa ingles: `UserClass` y `UsersService`

## Pregunta 13
¿Que hace `builder.AddServicesUA()` en `Program.cs`?

a) Crea las tablas en Oracle
b) Registra servicios de infraestructura UA: autenticacion CAS, tokens JWT, Oracle
c) Configura el frontend Vue
d) Instala los paquetes NuGet de la UA automaticamente

## Pregunta 14
Dado este controlador, ¿que fallo tiene?

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
d) `FromQuery` no se puede usar con parametros por defecto

## Pregunta 15
¿Que keyword de C# 14 simplifica propiedades con logica en el setter?

```csharp
public string Nombre
{
    get => field;
    set => field = value?.Trim() ?? "";
}
```

a) `auto`
b) `value`
c) `field`
d) `backing`

## Pregunta 16
¿Cual es la diferencia principal entre una `class` y un `record` en C#?

a) Los records son mas rapidos en ejecucion
b) Los records tienen igualdad por valor y son inmutables por defecto; las clases tienen igualdad por referencia
c) Las clases no pueden tener constructores
d) Los records no pueden implementar interfaces

## Pregunta 17
¿Que resultado produce este codigo?

```csharp
List<string> lista = ["uno", "dos", "tres"];
Console.WriteLine(lista.Count);
```

a) Error de compilacion: la sintaxis `[]` no es valida para listas
b) 3
c) 0
d) Error en tiempo de ejecucion

## Pregunta 18
En el siguiente `Program.cs`, ¿que falta para que los controladores API funcionen?

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
d) Los controladores se registran automaticamente, no falta nada

## Pregunta 19
¿Que devuelve `ObtenerTodosMap<ClaseUnidad>(sql, idioma: "ES")` de `ClaseOracleBD3`?

a) Un `DataTable` con los resultados de Oracle
b) Un `string` JSON con los datos
c) Una lista de objetos `ClaseUnidad` mapeados automaticamente desde las columnas Oracle
d) Un `Dictionary<string, object>` con clave-valor

## Pregunta 20
¿Como se desestructura una tupla en C#?

```csharp
public (bool exito, string mensaje) Validar() => (true, "OK");
```

a) `var resultado = Validar(); var e = resultado.Item1;`
b) `var (exito, mensaje) = Validar();`
c) `(var exito, var mensaje) = Validar();`
d) Todas las anteriores son validas

## Pregunta 21
¿Que problema tiene este registro de servicios?

```csharp
builder.Services.AddTransient<IClaseOracleBd, ClaseOracleBd>();
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();
```

a) No se puede mezclar Transient y Scoped
b) `ClaseOracleBd` gestiona conexiones y no deberia ser Transient (crea una conexion nueva cada vez que se inyecta)
c) Falta registrar `ClaseUnidades` como Transient tambien
d) El orden de registro es incorrecto

## Pregunta 22
¿Que hace el middleware `UseStaticFiles()` y por que va primero en el pipeline?

a) Comprime los archivos estaticos; va primero para mejorar el rendimiento
b) Sirve archivos CSS/JS directamente; va primero para no pasar por autenticacion innecesariamente
c) Registra las rutas de los archivos estaticos; debe ir antes de `UseRouting`
d) Genera los archivos estaticos del frontend Vue; va primero para que esten disponibles

## Pregunta 23
¿Cual es el resultado de este codigo?

```csharp
var sql = """
    SELECT ID, NOMBRE_ES
    FROM TCTS_UNIDADES
    WHERE FLG_ACTIVA = 'S'
    """;
Console.WriteLine(sql.Contains("NOMBRE_ES"));
```

a) `false`
b) `true`
c) Error de compilacion: `"""` no es sintaxis valida
d) Error en tiempo de ejecucion

## Pregunta 24
¿Que patron sigue el flujo `Controlador -> Servicio -> ClaseOracleBD3 -> Oracle`?

a) Patron Repositorio
b) Patron MVC con capas de servicio
c) Patron Observer
d) Patron Factory

## Pregunta 25
¿Por que el controlador recibe `IClaseUnidades` (interfaz) y no `ClaseUnidades` (clase concreta)?

a) Las interfaces son mas rapidas en .NET
b) Es un requisito del atributo `[ApiController]`
c) Para desacoplar: permite cambiar la implementacion y facilitar testing con mocks
d) Las clases concretas no se pueden inyectar en ASP.NET Core

## Pregunta 26
¿Que ocurre al ejecutar este codigo?

```csharp
string? texto = null;
int longitud = texto.Length;
```

a) `longitud` vale 0
b) Se lanza una `NullReferenceException`
c) `longitud` vale -1
d) El codigo no compila

## Pregunta 27
En el siguiente servicio, ¿que rol cumple `_bd`?

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

a) Es una variable estatica compartida entre instancias
b) Es una dependencia inyectada por constructor que da acceso a Oracle
c) Es un campo que se inicializa con `new ClaseOracleBd()`
d) Es un parametro de configuracion leido de `appsettings.json`

## Pregunta 28
¿Que version de .NET se usa en este curso y por que?

a) .NET 9 porque es la mas reciente
b) .NET 10 porque es LTS con soporte hasta noviembre de 2028
c) .NET 8 porque es la mas estable
d) .NET Framework 4.8 porque es compatible con Oracle

## Pregunta 29
¿Que salida produce este codigo?

```csharp
var saludo = $"Hola, {"Juan". ToUpper()}. Tienes {3 + 2} reservas.";
Console.WriteLine(saludo);
```

a) "Hola, Juan. Tienes 3 + 2 reservas."
b) "Hola, JUAN. Tienes 5 reservas."
c) Error de compilacion
d) "Hola, {Juan.ToUpper()}. Tienes {3 + 2} reservas."

## Pregunta 30
¿Donde se configura la cadena de conexion a Oracle en el proyecto?

a) En `Program.cs` como constante
b) En `appsettings.json` (y variantes por entorno)
c) En `ServicesExtensionsApp.cs`
d) En cada servicio que accede a Oracle

## Pregunta 31
¿Que problema hay en este pipeline?

```csharp
app.UseAuthentication();
app.UseCors();
app.UseRouting();
app.UseAuthorization();
app.MapControllers();
```

a) `UseCors` debe ir antes de `UseAuthentication` y despues de `UseRouting`
b) Falta `UseStaticFiles`
c) `MapControllers` debe ir antes de `UseAuthorization`
d) `UseAuthentication` no es compatible con `UseCors`

## Pregunta 32
¿Que hace `AddValidatorsFromAssemblyContaining<Program>()` en `ServicesExtensionsApp`?

a) Crea los validadores en tiempo de ejecucion
b) Busca y registra automaticamente todas las clases que hereden de `AbstractValidator<T>` en el ensamblado
c) Solo registra el validador de `Program`
d) Configura DataAnnotations para todos los modelos

## Pregunta 33
Dado este codigo, ¿que tipo es `resultado`?

```csharp
var resultado = Result<List<ClaseUnidad>>.Success(new List<ClaseUnidad>());
```

a) `List<ClaseUnidad>`
b) `Result<List<ClaseUnidad>>`
c) `ClaseUnidad`
d) `ActionResult`

## Pregunta 34
¿Cual es la diferencia entre `?. ` y `??` en C#?

a) `?.` accede a un miembro solo si el objeto no es null; `??` proporciona un valor por defecto si el resultado es null
b) `?.` convierte a nullable; `??` lanza una excepcion si es null
c) Son equivalentes, ambos comprueban null
d) `?.` se usa solo con strings; `??` se usa con numeros

## Pregunta 35
¿Que devuelve `HandleResult(resultado)` en `ApiControllerBase` cuando el `Result` contiene un error de tipo `ErrorType.Validation`?

a) HTTP 500 con un `ProblemDetails`
b) HTTP 400 con un `ValidationProblemDetails`
c) HTTP 404 con un mensaje de recurso no encontrado
d) HTTP 200 con el error en el cuerpo JSON

## Pregunta 36
¿Cual es el error en este registro de dependencias?

```csharp
builder.Services.AddScoped<ClaseUnidades>();
```

a) Falta especificar el ciclo de vida
b) Se registra la clase concreta sin interfaz, lo que impide inyectar `IClaseUnidades` en controladores
c) `AddScoped` no acepta un solo parametro generico
d) No hay error, es una forma valida de registro

## Pregunta 37
¿Que expresion de coleccion es valida en C# 12+?

a) `var lista = new[] { "uno", "dos" };`
b) `List<string> lista = ["uno", "dos"];`
c) `string[] lista = new("uno", "dos");`
d) Tanto a) como b) son validas

## Pregunta 38
¿Que ocurre si en `Program.cs` no se llama a `builder.Services.AddControllersWithViews()`?

a) La aplicacion compila pero los controladores no se descubren ni registran
b) Solo fallan los controladores API, no los MVC
c) La aplicacion no compila
d) Funciona igual, los controladores se descubren automaticamente

## Pregunta 39
¿Que metodo de `ClaseOracleBD3` usarias para obtener un unico objeto mapeado desde Oracle?

a) `ObtenerTodosMap<T>()`
b) `ObtenerPrimeroMap<T>()`
c) `EjecutarParams()`
d) `ObtenerUnicoMap<T>()`

## Pregunta 40
¿Que salida produce este codigo?

```csharp
record Punto(int X, int Y);

var p1 = new Punto(3, 5);
var p2 = new Punto(3, 5);
Console.WriteLine(p1 == p2);
```

a) `false` porque son referencias distintas
b) `true` porque los records comparan por valor
c) Error de compilacion: los records no soportan `==`
d) Depende del garbage collector

## Pregunta 41
¿Que hace el atributo `[Columna("NOMBRE_COMPLETO")]` en una propiedad de un DTO usado con `ClaseOracleBD3`?

a) Crea la columna en Oracle al ejecutar migraciones
b) Indica que la propiedad se mapea a esa columna en lugar de seguir la convencion PascalCase -> SNAKE_CASE
c) Valida que el valor no sea null
d) Define un alias para la serializacion JSON

## Pregunta 42
En el patron UA, si un recurso no se encuentra, ¿que se devuelve?

a) HTTP 404 Not Found
b) HTTP 200 OK con un objeto vacio (Id=0) y el frontend valida ese caso
c) HTTP 204 No Content
d) HTTP 400 Bad Request con un mensaje de error

## Pregunta 43
¿Cual es la forma correcta de inyectar multiples servicios en un controlador?

```csharp
// Opcion A
public UnidadesController(IClaseUnidades unidades, ILogger<UnidadesController> logger)
{
    _unidades = unidades;
    _logger = logger;
}

// Opcion B
public UnidadesController()
{
    _unidades = new ClaseUnidades();
    _logger = new Logger();
}
```

a) Opcion A: inyeccion por constructor con interfaces
b) Opcion B: crear instancias directamente
c) Ambas son equivalentes
d) Ninguna es correcta en ASP.NET Core

## Pregunta 44
¿Que representan las versiones `.resx` con sufijos `App.es-ES.resx`, `App.ca-ES.resx`, `App.en-US.resx`?

a) Archivos de configuracion por entorno (desarrollo, staging, produccion)
b) Archivos de recursos de localizacion para castellano, valenciano e ingles
c) Esquemas de base de datos por idioma
d) Plantillas HTML para emails en diferentes idiomas

## Pregunta 45
¿Que problema tiene este codigo?

```csharp
public class MiServicio
{
    private readonly IClaseOracleBd _bd;

    public MiServicio()
    {
        _bd = new ClaseOracleBd("conexion");
    }
}
```

a) Falta el modificador `static`
b) Crea acoplamiento fuerte: la dependencia deberia inyectarse por constructor, no instanciarse con `new`
c) `readonly` no permite asignar en el constructor
d) `ClaseOracleBd` debe ser Singleton

## Pregunta 46
¿Que ocurre cuando la peticion HTTP es para un archivo `.js` y el primer middleware es `UseStaticFiles`?

a) La peticion pasa por todo el pipeline y el controlador devuelve el archivo
b) `UseStaticFiles` sirve el archivo directamente y la peticion no continua al resto del pipeline
c) Se redirige la peticion al frontend Vue
d) Se lanza un error 404 porque los archivos JS no se sirven como estaticos

## Pregunta 47
¿Que significa `private readonly` en la declaracion de un campo inyectado?

```csharp
private readonly IClaseUnidades _unidades;
```

a) El campo solo se puede leer desde metodos privados
b) El campo solo puede asignarse en el constructor y no puede reasignarse despues
c) El campo es accesible solo en modo lectura desde otras clases
d) El campo se destruye al terminar el constructor

## Pregunta 48
¿Que hace `AddFluentValidationAutoValidation()` en `ServicesExtensionsApp`?

a) Reemplaza completamente DataAnnotations en el proyecto
b) Ejecuta automaticamente los validadores FluentValidation antes de que la accion del controlador se ejecute
c) Genera validadores automaticos para todos los DTOs
d) Solo funciona con formularios HTML, no con APIs REST

## Pregunta 49
Dado este pattern matching, ¿que valor devuelve si `tipo` es `ErrorType.Failure`?

```csharp
ErrorType tipo = ErrorType.Failure;
var codigo = tipo switch
{
    ErrorType.Validation => 400,
    ErrorType.Failure => 500,
    _ => 500
};
```

a) 400
b) 500
c) 0
d) Lanza una excepcion porque `Failure` no esta contemplado explicitamente

## Pregunta 50
¿Que beneficio principal aporta el patron `Result<T>` frente a lanzar excepciones en los servicios?

a) Es mas rapido en ejecucion porque evita el coste del stack trace de excepciones
b) Obliga al controlador a manejar explicitamente exitos y errores sin depender de try/catch
c) Permite devolver multiples resultados simultaneamente
d) Es requisito obligatorio de ASP.NET Core 10
