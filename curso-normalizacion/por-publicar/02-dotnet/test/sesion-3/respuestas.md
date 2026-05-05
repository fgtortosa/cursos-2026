# Respuestas -- Test Sesion 3: Validacion y errores

1. **b)** El rango permite el valor 0, que no es valido para una granularidad (minimo deberia ser 5). `[Range(0, 120)]` acepta 0, pero la granularidad minima en la UA es 5 minutos, deberia ser `[Range(5, 120)]`.

2. **c)** El atributo `[ApiController]` activa la validacion automatica. Si el DTO no pasa las DataAnnotations, .NET devuelve un `400 Bad Request` con `ValidationProblemDetails` (RFC 7807) sin ejecutar la accion del controlador.

3. **c)** La regla usa `Must` para validar que, si `DuracionMax` es un entero valido, la granularidad no lo supere. Si `DuracionMax` no es parseable, la condicion se cumple por cortocircuito del operador `||`.

4. **c)** En el contrato UA solo existen dos codigos de error: 400 (validacion) y 500 (resto). Si un recurso no se encuentra, se devuelve `200 OK` con un objeto vacio (`Id = 0`) y el frontend gestiona ese caso.

5. **b)** El orden es: primero DataAnnotations (validacion automatica del `[ApiController]`), luego FluentValidation (si DataAnnotations pasa), despues el servicio devuelve `Result<T>`, y finalmente `HandleResult` traduce a HTTP.

6. **b)** El metodo se llama `HandleResult<T>`. Recibe un `Result<T>` y devuelve `Ok(result.Value)` si tiene exito, o el codigo de error correspondiente si falla.

7. **c)** El contrato UA mapea `ErrorType.Validation` a HTTP 400 y `ErrorType.Failure` a HTTP 500. No se usan 404 ni 409 en el contrato de errores.

8. **b)** El caso `Validation` genera un `ValidationProblemDetails` con status 400 y un diccionario de errores por campo (`ValidationErrors`). Esto permite al frontend mostrar errores especificos por campo.

9. **b)** Los validadores FluentValidation reciben `IStringLocalizer<SharedResources>` por inyeccion de dependencias en su constructor, lo que permite usar claves como `L["RequiredField"]` que se resuelven segun el idioma de la peticion.

10. **b)** La UA soporta tres idiomas: espanol (fichero por defecto `SharedResources.resx`), catalan (`SharedResources.ca.resx`) e ingles (`SharedResources.en.resx`).

11. **c)** `[StringLength(max, MinimumLength = n)]` permite definir longitud minima y maxima para cadenas. `[Range]` es para numeros, `[MaxLength]` no soporta minimo, y `[Length]` no existe como atributo estandar.

12. **b)** `GreaterThan(0)` solo valida que sea positivo pero no limita el maximo. La granularidad debe estar entre 5 y 120, asi que deberia usar `InclusiveBetween(5, 120)` para validar ambos extremos.

13. **b)** Los errores de validacion de negocio se registran con nivel `Warning` en Serilog. Son errores esperados que no indican un fallo tecnico del sistema.

14. **d)** Las excepciones tecnicas no esperadas (BD caida, NullReferenceException, etc.) se registran con nivel `Error` en Serilog, ya que indican un fallo tecnico real.

15. **c)** Las buenas practicas UA recomiendan usar placeholders con nombre: `_logger.LogInformation("Unidad {Id} guardada", id)`. Esto permite logging estructurado (Serilog indexa los valores). Concatenar strings o usar interpolacion impide el logging estructurado.

16. **b)** El `IExceptionHandler` debe registrar la excepcion completa en Serilog (con stack trace, para el equipo de desarrollo) y devolver al cliente un `ProblemDetails` generico sin detalles internos, para no exponer informacion sensible.

17. **b)** El estandar UA basado en RFC 7807 exige: `type` (URI de categoria), `title` (resumen legible), `status` (codigo HTTP) y `detail` (mensaje para el cliente). Adicionalmente se recomiendan `instance` y `traceId`.

18. **b)** La convencion UA para DTOs de lectura es singular con prefijo `Clase`: `ClaseUnidad`, `ClaseReserva`. No se usan sufijos como `DTO`, `Model` ni prefijos como `Dto`.

19. **c)** Los servicios UA usan el prefijo `Clase` + nombre en plural: `ClaseUnidades`, `ClaseReservas`. El DTO singular es `ClaseUnidad` y el servicio plural es `ClaseUnidades`.

20. **b)** La UA usa el patron `Result<T>` con un record `Error` que contiene `Code`, `Message`, `Type` (enum `ErrorType`) y opcionalmente `ValidationErrors`. Esto evita lanzar excepciones para flujo de negocio normal.

21. **b)** `AddValidatorsFromAssemblyContaining<CrearReservaValidador>()` escanea el ensamblado y registra automaticamente todos los validadores que hereden de `AbstractValidator<T>`.

22. **b)** En `ValidationProblemDetails`, las claves del diccionario `errors` son los nombres de los campos del DTO que fallaron la validacion. Cada clave tiene asociado un array de strings con los mensajes de error para ese campo.

23. **d)** `ErrorType.Failure` siempre se mapea a HTTP 500 en `HandleResult`. El contrato UA solo tiene dos codigos: 400 para validacion y 500 para todo lo demas (incluyendo duplicados, errores de BD, etc.).

24. **b)** `InclusiveBetween(1, 100)` valida que el valor este entre 1 y 100, ambos incluidos. `Between` y `Range` no existen en FluentValidation; `GreaterThan/LessThan` son exclusivos (no incluyen los extremos).

25. **b)** El catch debe distinguir entre error 400 (acceder a `error.response.data.errors` para errores por campo) y cualquier otro error (usar `gestionarError` como fallback). Acceder solo a `error.message` pierde la informacion estructurada del servidor.

26. **b)** `ValidationProblemDetails` hereda de `ProblemDetails` y anade la propiedad `errors`, que es un diccionario `IDictionary<string, string[]>` con los errores de validacion por campo. `ProblemDetails` base no tiene este campo.

27. **b)** `"Override": { "Microsoft": "Warning" }` establece que los logs provenientes de namespaces de Microsoft (framework interno) solo se registren a partir de nivel Warning, reduciendo el ruido en los logs mientras el nivel general es Information.

28. **b)** La configuracion correcta es crear `RequestLocalizationOptions` con `SetDefaultCulture("es-ES")` y luego llamar a `AddSupportedCultures` y `AddSupportedUICultures` con los tres idiomas. Finalmente se aplica con `app.UseRequestLocalization(localizationOptions)`.

29. **b)** `GreaterThan(x => x.FechaInicio)` valida que `FechaFin` sea estrictamente mayor que `FechaInicio`. FluentValidation permite referenciar otras propiedades del mismo objeto usando una lambda.

30. **b)** La convencion UA para error codes es `Entidad.Tipo` en PascalCase: `"Unidad.SaveError"`, `"Reserva.Error"`, `"Usuario.Validation"`. Es descriptivo, consistente y facil de buscar en logs.

31. **c)** `AddFluentValidationAutoValidation()` integra FluentValidation en el pipeline de validacion automatica de ASP.NET Core, de modo que los validadores se ejecutan automaticamente cuando se recibe un DTO, despues de las DataAnnotations.

32. **b)** El contrato UA solo usa dos codigos de error: 400 (validacion) y 500 (fallos). No se usa 404. Si un recurso no existe, se devuelve `200 OK` con un objeto vacio (`Id = 0`) y el frontend es quien valida ese caso.

33. **c)** `[EmailAddress]` es el atributo DataAnnotations estandar que valida formato de email. `[Email]` y `[MailAddress]` no existen como atributos DataAnnotations.

34. **b)** Se registra con `builder.Services.AddExceptionHandler<GlobalExceptionHandler>()` y se activa con `app.UseExceptionHandler()`. Esta es la API de .NET para manejadores de excepciones globales.

35. **b)** Incluir `ex.Message` y `ex.StackTrace` en la respuesta expone informacion interna del servidor (rutas, nombres de clases, queries SQL, versiones de frameworks) que es un riesgo de seguridad. El `IExceptionHandler` debe devolver un mensaje generico al cliente.

36. **c)** Si las DataAnnotations fallan, el atributo `[ApiController]` intercepta la peticion y devuelve automaticamente un 400 con `ValidationProblemDetails`. No se ejecuta la accion del controlador ni FluentValidation.

37. **b)** La convencion UA para DTOs de escritura es singular con prefijo `Clase` + verbo: `ClaseCrearReserva`, `ClaseGuardarUnidad`, `ClaseGrabarPermiso`.

38. **a)** `UseSerilogRequestLogging()` registra cada peticion HTTP como un log estructurado que incluye metodo HTTP, path, codigo de estado y duracion. Es mas eficiente que el logging por defecto de ASP.NET Core.

39. **c)** La clave de localizacion es `"FutureDateRequired"`, que se pasa a `L["FutureDateRequired"]` y se resuelve desde los ficheros `.resx` segun el idioma de la peticion actual.

40. **b)** El campo `errors` de `ValidationProblemDetails` es un `IDictionary<string, string[]>`. La clave es el nombre del campo del DTO y el valor es un array de strings con todos los mensajes de error para ese campo.

41. **b)** Cuando se usa `RuleFor(x => x)` (validando todo el objeto), FluentValidation no sabe a que campo asociar el error. `.WithName("Granularidad")` indica que el error se asocie al campo `Granularidad` en el diccionario `errors` del `ValidationProblemDetails`.

42. **a)** En la configuracion JSON de Serilog, `"rollingInterval": "Day"` establece rotacion diaria y `"retainedFileCountLimit": 30` mantiene como maximo 30 ficheros de log (30 dias).

43. **b)** Si `result.IsSuccess` es true, `HandleResult` devuelve `Ok(result.Value)`, que genera una respuesta `200 OK` con el valor serializado en JSON.

44. **b)** Para errores de validacion (400), los errores por campo estan en `error.response.data.errors`, no en `.detail`. El campo `.detail` contiene un mensaje general, pero los errores especificos por campo estan en el diccionario `errors`.

45. **b)** Las claves de los ficheros `.resx` siguen la convencion PascalCase en ingles: `RequiredField`, `UnexpectedError`, `UserNotFound`, `InvalidDateRange`. Son descriptivas y consistentes.

46. **b)** `NotEmpty()` es mas estricto: valida que no sea null, cadena vacia (`""`) ni solo espacios en blanco. `NotNull()` solo comprueba que el valor no sea null, permitiendo cadenas vacias.

47. **c)** El `IExceptionHandler` registrado captura la excepcion no controlada, la registra completa en Serilog (nivel Error con stack trace) y devuelve un `ProblemDetails` generico con status 500, sin exponer detalles internos al cliente.

48. **b)** `.When(x => !string.IsNullOrEmpty(x.EmailContacto))` aplica la regla de validacion de formato email solo cuando el campo tiene valor. Si el email es null o vacio, la regla se omite, ya que el campo es opcional.

49. **b)** La convencion UA es registrar los servicios en `ServicesExtensionsApp.cs` usando `AddScoped`. Esto centraliza el registro de dependencias de la aplicacion en un unico fichero.

50. **b)** El checklist completo UA incluye: DTO con DataAnnotations, servicio que devuelve `Result<T>` (nunca lanza excepciones de negocio), controlador que hereda de `ApiControllerBase` y usa `HandleResult`, `IExceptionHandler` para errores no controlados, y mensajes localizados con `IStringLocalizer`.
