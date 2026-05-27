---
url: /curso-normalizacion/02-dotnet/test/sesion-03/respuestas.md
description: Solucionario razonado del test de 22 preguntas de la Sesión 3.
---

# Respuestas — Test Sesión 3: Introducción a .NET

1. **c)** Se crea una instancia por cada petición HTTP. `AddScoped` crea una instancia que vive durante toda la petición HTTP y se destruye al finalizar.

2. **b)** `UseAuthorization` y `UseAuthentication` están en orden incorrecto respecto a `UseRouting`. El orden correcto es: `UseRouting` → `UseAuthentication` → `UseAuthorization`. Sin routing primero, la autorización no sabe qué endpoint evaluar, y sin autenticación antes de autorización, no se conoce la identidad del usuario.

3. **b)** .NET lanza una excepción en desarrollo porque un Singleton consume un Scoped. El Singleton vive para siempre, pero el servicio Scoped debería morir al terminar la petición. Esto se conoce como **captive dependency** y .NET lo detecta en modo desarrollo al construir el host.

4. **c)** `"ANONIMO"`. El operador `?.` evalúa `nombre?.ToUpper()` como `null` (porque `nombre` es null), y luego `??` devuelve el valor por defecto `"ANONIMO"`.

5. **c)** En `ServicesExtensionsApp.cs`, invocado desde `Program.cs` con `builder.AddServicesApp()`. Esta es la convención de la plantilla UA para mantener `Program.cs` limpio y centralizar los servicios propios.

6. **b)** Una tupla con dos valores: un `bool` y un `string`. Las tuplas en C# permiten devolver múltiples valores desde un método sin crear una clase dedicada. Se pueden desestructurar con `var (exito, mensaje) = Validar();`.

7. **b)** Dos instancias con los mismos valores de `Code`, `Message` y `Type` se consideran iguales. Los records en C# implementan **igualdad por valor** automáticamente, a diferencia de las clases que comparan por referencia.

8. **b)** `UseStaticFiles` → `UseRouting` → `UseCors` → `UseAuthentication` → `UseAuthorization` → `MapControllers`. Primero archivos estáticos (no requieren auth), luego rutas, CORS antes de auth, autenticación antes de autorización, y finalmente mapear los controladores.

9. **b)** Actúa como caso por defecto, capturando cualquier valor no contemplado. El `_` (*discard pattern*) en un `switch` expression funciona como el `default:` de un switch clásico.

10. **b)** `AddControllersWithViews` registra soporte para MVC con vistas Razor además de APIs. En este proyecto lo necesitamos porque `HomeController` sirve la vista `Index.cshtml` que carga la SPA Vue. `AddControllers` solo registra el soporte para controladores API sin vistas.

11. **b)** No se debe crear instancias manualmente con `new`; se debe inyectar por constructor. Crear dependencias con `new` genera acoplamiento fuerte, dificulta el testing y no permite que el contenedor de DI gestione los ciclos de vida.

12. **b)** Falta `app.MapControllers()`. Sin esta llamada, los endpoints de los controladores no se registran en el sistema de rutas y las peticiones API no llegarán a ningún controlador.

13. **b)** `ClaseOracleBd` gestiona conexiones y no debería ser `Transient`. Con `AddTransient` se crearía una nueva conexión a Oracle cada vez que se inyecta, lo cual es ineficiente. Debería ser `AddScoped` para tener una conexión por petición HTTP.

14. **b)** Sirve archivos CSS/JS directamente; va primero para no pasar por autenticación innecesariamente. Si el archivo existe, el middleware lo sirve y cortocircuita el pipeline, evitando que la petición pase por autenticación, autorización o controladores.

15. **b)** `true`. Las *raw string literals* (`"""..."""`) de C# 11+ permiten escribir strings multilínea sin escapar. El string resultante contiene `NOMBRE_ES`, por lo que `Contains` devuelve `true`.

16. **b)** Patrón MVC con capas de servicio. El controlador recibe la petición, delega en el servicio (modelo) que accede a datos, y devuelve la respuesta. La vista es la SPA Vue que consume la API.

17. **c)** Para desacoplar: permite cambiar la implementación y facilitar testing con fakes. Al depender de la interfaz, se puede sustituir `ClaseUnidades` por un `FakeUnidadesService` en tests sin necesitar una base de datos real. (Esto se ve en detalle en sesión 21.)

18. **b)** Es una dependencia inyectada por constructor que da acceso a Oracle. El campo `_bd` almacena la referencia al servicio `IClaseOracleBd` que el contenedor de DI inyecta al crear la instancia de `ClaseUnidades`.

19. **b)** .NET 10 porque es LTS con soporte hasta noviembre de 2028. Las versiones LTS (Long Term Support) tienen 3 años de soporte, mientras que las versiones impares (9, 11…) solo tienen 18 meses.

20. **b)** En `appsettings.json` (y variantes por entorno). Las cadenas de conexión se configuran en archivos de configuración que varían según el entorno (`appsettings.Development.json`, `appsettings.Production.json`, etc.).

21. **b)** Se registra la clase concreta sin interfaz, lo que impide inyectar `IClaseUnidades` en controladores. Para que funcione la inyección con interfaz, se debe registrar como `AddScoped<IClaseUnidades, ClaseUnidades>()`.

22. **b)** Obliga al controlador a manejar explícitamente éxitos y errores sin depender de try/catch. El patrón `Result<T>` hace explícito en el tipo de retorno que un método puede fallar, forzando al llamador a verificar si el resultado es exitoso o contiene un error. El detalle del patrón se introduce en la sesión 5.
