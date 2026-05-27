# Autoevaluación — Sesión 0

## Preguntas rápidas

1. ¿Qué diferencia hay entre .NET y ASP.NET Core?
2. ¿Dónde se registran los servicios de inyección de dependencias?
3. ¿Qué ciclo de vida (`AddScoped`, `AddTransient`, `AddSingleton`) usarías para un servicio que accede a Oracle?
4. ¿Por qué el controlador recibe `IClaseUnidades` (interfaz) y no `ClaseUnidades` (clase)?
5. ¿Qué orden deben seguir `UseRouting`, `UseAuthentication` y `UseAuthorization` en el pipeline?

## Respuestas esperadas

1. .NET es la plataforma completa (runtime + bibliotecas); ASP.NET Core es el framework web que se ejecuta sobre .NET para crear APIs y aplicaciones web.
2. En `Program.cs` (o en métodos de extensión como `ServicesExtensionsApp`) usando `builder.Services.AddScoped/AddTransient/AddSingleton`.
3. `AddScoped`: una instancia por petición HTTP. La conexión se abre al inicio de la petición y se libera al final.
4. Para desacoplar: se puede cambiar la implementación sin modificar el controlador y se puede testear con un servicio falso (Fake) sin base de datos.
5. `UseRouting()` → `UseAuthentication()` → `UseAuthorization()`. Si se cambia el orden, la autorización no sabe qué endpoint proteger.
