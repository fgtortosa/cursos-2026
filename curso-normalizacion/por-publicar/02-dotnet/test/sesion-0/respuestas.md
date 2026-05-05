# Respuestas -- Test Sesion 0: Introduccion a .NET

1. **c)** Se crea una instancia por cada peticion HTTP. `AddScoped` crea una instancia que vive durante toda la peticion HTTP y se destruye al finalizar.

2. **b)** `UseAuthorization` y `UseAuthentication` estan en orden incorrecto respecto a `UseRouting`. El orden correcto es: `UseRouting` -> `UseAuthentication` -> `UseAuthorization`. Sin routing primero, la autorizacion no sabe que endpoint evaluar, y sin autenticacion antes de autorizacion, no se conoce la identidad del usuario.

3. **b)** .NET lanza una excepcion en desarrollo porque un Singleton consume un Scoped. El Singleton vive para siempre, pero el servicio Scoped deberia morir al terminar la peticion. Esto se conoce como "captive dependency" y .NET lo detecta en modo desarrollo.

4. **c)** "ANONIMO". El operador `?.` evalua `nombre?.ToUpper()` como `null` (porque `nombre` es null), y luego `??` devuelve el valor por defecto "ANONIMO".

5. **c)** En `ServicesExtensionsApp.cs`, invocado desde `Program.cs` con `builder.AddServicesApp()`. Esta es la convencion de la plantilla UA para mantener `Program.cs` limpio y centralizar los servicios propios.

6. **b)** Una tupla con dos valores: un bool y un string. Las tuplas en C# permiten devolver multiples valores desde un metodo sin crear una clase dedicada. Se pueden desestructurar con `var (exito, mensaje) = Validar();`.

7. **b)** Dos instancias con los mismos valores de Code, Message y Type se consideran iguales. Los records en C# implementan igualdad por valor automaticamente, a diferencia de las clases que comparan por referencia.

8. **b)** UseStaticFiles -> UseRouting -> UseCors -> UseAuthentication -> UseAuthorization -> MapControllers. Este es el orden correcto: primero archivos estaticos, luego rutas, CORS antes de auth, autenticacion antes de autorizacion, y finalmente mapear los controladores.

9. **b)** Actua como caso por defecto, capturando cualquier valor no contemplado. El `_` (discard pattern) en un `switch` expression funciona como el `default:` de un switch clasico. En `HandleResult`, cualquier error que no sea Validation devuelve 500.

10. **b)** `AddControllersWithViews` registra soporte para MVC con vistas Razor ademas de APIs. `AddControllers` solo registra el soporte para controladores API sin vistas. En nuestro proyecto usamos `AddControllersWithViews` porque `HomeController` sirve la vista `Index.cshtml` que carga la SPA Vue.

11. **c)** "es". La lista esta vacia, `FirstOrDefault` devuelve `null`, el operador `?.` hace que `.Value` no se ejecute y devuelva `null`, y finalmente `??` proporciona el valor por defecto "es".

12. **a)** DTO en singular (`ClaseUsuario`), servicio en plural (`ClaseUsuarios`). Esta es la convencion de nombres de la plantilla UA: `Models/Usuario.cs` para el DTO y `Models/Usuarios.cs` para el servicio.

13. **b)** Registra servicios de infraestructura UA: autenticacion CAS, tokens JWT, Oracle. Es un metodo de extension que configura todos los servicios internos de la Universidad de Alicante que necesita la aplicacion.

14. **b)** No se debe crear instancias manualmente con `new`; se debe inyectar por constructor. Crear dependencias con `new` genera acoplamiento fuerte, dificulta el testing y no permite que el contenedor de DI gestione los ciclos de vida.

15. **c)** `field`. Es una novedad de C# 14 que permite acceder al campo de respaldo generado automaticamente por el compilador, sin necesidad de declarar un campo privado manual.

16. **b)** Los records tienen igualdad por valor y son inmutables por defecto; las clases tienen igualdad por referencia. Los records son ideales para DTOs y objetos de valor como `Error` en el patron `Result<T>`.

17. **b)** 3. La sintaxis `["uno", "dos", "tres"]` es una expresion de coleccion valida desde C# 12, y crea una lista con tres elementos.

18. **b)** Falta `app.MapControllers()`. Sin esta llamada, los endpoints de los controladores no se registran en el sistema de rutas y las peticiones API no llegaran a ningun controlador.

19. **c)** Una lista de objetos `ClaseUnidad` mapeados automaticamente desde las columnas Oracle. `ClaseOracleBD3` convierte las columnas SNAKE_CASE de Oracle a propiedades PascalCase del DTO automaticamente.

20. **d)** Todas las anteriores son validas. Se puede acceder con `Item1`/`Item2`, desestructurar con `var (exito, mensaje)`, o con `(var exito, var mensaje)`.

21. **b)** `ClaseOracleBd` gestiona conexiones y no deberia ser Transient. Con `AddTransient` se crearia una nueva conexion a Oracle cada vez que se inyecta, lo cual es ineficiente. Deberia ser `AddScoped` para tener una conexion por peticion.

22. **b)** Sirve archivos CSS/JS directamente; va primero para no pasar por autenticacion innecesariamente. Los archivos estaticos no necesitan autenticacion ni autorizacion, asi que ponerlo primero mejora el rendimiento y evita procesamiento innecesario.

23. **b)** `true`. Las raw string literals (`"""..."""`) de C# 11+ permiten escribir strings multilinea sin escapar. El string resultante contiene "NOMBRE_ES", por lo que `Contains` devuelve `true`.

24. **b)** Patron MVC con capas de servicio. El controlador recibe la peticion, delega en el servicio (modelo) que accede a datos, y devuelve la respuesta. La vista es la SPA Vue que consume la API.

25. **c)** Para desacoplar: permite cambiar la implementacion y facilitar testing con mocks. Al depender de la interfaz, se puede sustituir `ClaseUnidades` por un `FakeUnidadesService` en tests sin necesitar una base de datos real.

26. **b)** Se lanza una `NullReferenceException`. Al intentar acceder a `.Length` de una variable `null` sin usar el operador null-conditional (`?.`), se produce una excepcion en tiempo de ejecucion.

27. **b)** Es una dependencia inyectada por constructor que da acceso a Oracle. El campo `_bd` almacena la referencia al servicio `IClaseOracleBd` que el contenedor de DI inyecta al crear la instancia de `ClaseUnidades`.

28. **b)** .NET 10 porque es LTS con soporte hasta noviembre de 2028. Las versiones LTS (Long Term Support) tienen 3 anos de soporte, mientras que las versiones impares (9, 11...) solo tienen 18 meses.

29. **b)** "Hola, JUAN. Tienes 5 reservas." La interpolacion de strings (`$"..."`) evalua las expresiones dentro de `{}`, ejecutando `"Juan".ToUpper()` y calculando `3 + 2`.

30. **b)** En `appsettings.json` (y variantes por entorno). Las cadenas de conexion se configuran en archivos de configuracion que varian segun el entorno (`appsettings.Development.json`, `appsettings.Production.json`, etc.).

31. **a)** `UseCors` debe ir antes de `UseAuthentication` y despues de `UseRouting`. El orden correcto es: UseRouting -> UseCors -> UseAuthentication -> UseAuthorization. En el codigo dado, `UseRouting` va despues de `UseCors` y `UseAuthentication`.

32. **b)** Busca y registra automaticamente todas las clases que hereden de `AbstractValidator<T>` en el ensamblado. Esto evita tener que registrar cada validador manualmente en el contenedor de DI.

33. **b)** `Result<List<ClaseUnidad>>`. El metodo `Success` devuelve un `Result<T>` que envuelve el valor, en este caso una lista de `ClaseUnidad`.

34. **a)** `?.` accede a un miembro solo si el objeto no es null; `??` proporciona un valor por defecto si el resultado es null. Son complementarios: `objeto?.Propiedad ?? valorDefecto`.

35. **b)** HTTP 400 con un `ValidationProblemDetails`. Segun el contrato de error UA, `ErrorType.Validation` se mapea a HTTP 400, mientras que `ErrorType.Failure` se mapea a HTTP 500.

36. **b)** Se registra la clase concreta sin interfaz, lo que impide inyectar `IClaseUnidades` en controladores. Para que funcione la inyeccion con interfaz, se debe registrar como `AddScoped<IClaseUnidades, ClaseUnidades>()`.

37. **d)** Tanto a) como b) son validas. `var lista = new[] { "uno", "dos" }` crea un array (valido en cualquier version de C#), y `List<string> lista = ["uno", "dos"]` usa la sintaxis de expresion de coleccion de C# 12+.

38. **a)** La aplicacion compila pero los controladores no se descubren ni registran. Sin `AddControllersWithViews()` o `AddControllers()`, el framework no busca ni registra los controladores del ensamblado.

39. **b)** `ObtenerPrimeroMap<T>()`. Este metodo devuelve el primer objeto mapeado del resultado o null si no hay resultados. `ObtenerTodosMap<T>()` devuelve una lista completa.

40. **b)** `true` porque los records comparan por valor. A diferencia de las clases, los records implementan automaticamente la comparacion por valor de todas sus propiedades, por lo que dos instancias con los mismos valores son iguales.

41. **b)** Indica que la propiedad se mapea a esa columna en lugar de seguir la convencion PascalCase -> SNAKE_CASE. Se usa cuando el nombre de la columna Oracle no sigue la convencion automatica de `ClaseOracleBD3`.

42. **b)** HTTP 200 OK con un objeto vacio (Id=0) y el frontend valida ese caso. En el patron UA, los recursos no encontrados no devuelven 404 sino 200 con datos vacios, y es responsabilidad del frontend validar esa situacion.

43. **a)** Opcion A: inyeccion por constructor con interfaces. El contenedor de DI de ASP.NET Core resuelve todas las dependencias declaradas en el constructor automaticamente. La opcion B crea acoplamiento fuerte y es un antipatron.

44. **b)** Archivos de recursos de localizacion para castellano, valenciano e ingles. Los archivos `.resx` con sufijos de cultura (`es-ES`, `ca-ES`, `en-US`) contienen las traducciones para el soporte multiidioma de la aplicacion.

45. **b)** Crea acoplamiento fuerte: la dependencia deberia inyectarse por constructor, no instanciarse con `new`. Instanciar `ClaseOracleBd` directamente impide sustituir la implementacion en tests y acopla el servicio a una implementacion concreta.

46. **b)** `UseStaticFiles` sirve el archivo directamente y la peticion no continua al resto del pipeline. Si el archivo existe, el middleware lo sirve y cortocircuita el pipeline, evitando que la peticion pase por autenticacion, autorizacion o controladores.

47. **b)** El campo solo puede asignarse en el constructor y no puede reasignarse despues. `readonly` garantiza que la referencia inyectada no se modifique accidentalmente durante la vida del objeto, proporcionando inmutabilidad del campo.

48. **b)** Ejecuta automaticamente los validadores FluentValidation antes de que la accion del controlador se ejecute. Esto permite que la validacion ocurra de forma transparente, similar a como funciona DataAnnotations, pero con la potencia de FluentValidation.

49. **b)** 500. El valor `ErrorType.Failure` coincide con el segundo caso del switch, que devuelve 500. El caso `_` (default) tambien devolveria 500, pero no se alcanza porque hay una coincidencia explicita.

50. **b)** Obliga al controlador a manejar explicitamente exitos y errores sin depender de try/catch. El patron `Result<T>` hace explicito en el tipo de retorno que un metodo puede fallar, forzando al llamador a verificar si el resultado es exitoso o contiene un error.
