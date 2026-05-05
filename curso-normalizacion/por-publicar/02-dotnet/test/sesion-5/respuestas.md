# Respuestas — Test Sesion 5: OpenAPI y Scalar

1. **b)** `builder.Services.AddOpenApi()` es el metodo nativo de .NET 9+ para registrar el soporte OpenAPI sin necesidad de Swashbuckle.

2. **c)** `MapOpenApi()` expone el documento en `/openapi/v1.json` por defecto. Scalar se sirve en la ruta configurada (`/scalar`).

3. **c)** `Scalar.AspNetCore` es el paquete NuGet que proporciona el metodo de extension `MapScalarApiReference`.

4. **b)** Sin la condicion de entorno, los endpoints de documentacion estaran accesibles en produccion, exponiendo la estructura completa de la API a posibles atacantes.

5. **b)** `[ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]` documenta en OpenAPI que el endpoint puede devolver un 500 con el esquema ProblemDetails.

6. **a)** Un POST que usa FluentValidation puede devolver 400 (errores de validacion) y `HandleResult` puede devolver 500 (errores de servicio). Ambos `ProducesResponseType` faltan. No se usa 404 en el contrato UA.

7. **b)** El token vincula la comprobacion previa (GET) con la ejecucion (POST), evitando que se ejecuten operaciones destructivas sin verificacion previa.

8. **b)** El endpoint devuelve siempre 200 OK con el DTO `ClaseComprobacionOperacion` donde `Permitido = false` y la razon. No devuelve 404 segun el contrato UA.

9. **b)** En el contrato UA, `ErrorType.Validation` se mapea a 400 Bad Request con `ValidationProblemDetails`.

10. **b)** FluentValidation (capa 1) valida formato y estructura del DTO: campos obligatorios, longitudes, rangos. La logica de negocio (token valido, permisos) se valida en el servicio (capa 2).

11. **c)** `PropertyNamingPolicy = null` indica que no se aplica ninguna transformacion y las propiedades se serializan tal como estan en C# (PascalCase). No existe `JsonNamingPolicy.PascalCase`.

12. **b)** La politica por defecto en .NET es camelCase, que transforma `NombreEs` a `nombreEs` (primera letra en minuscula, el resto mantiene las mayusculas).

13. **c)** `IActionFilter` define los metodos `OnActionExecuting` y `OnActionExecuted` que se ejecutan antes y despues de cada accion del controlador.

14. **b)** Registrando el filtro en `AddControllers(options => options.Filters.Add<ApiTimingFilter>())` se aplica globalmente a todos los endpoints, y permite inyeccion de dependencias.

15. **b)** `OnActionExecuting` se ejecuta ANTES de la accion del controlador, por lo que es el lugar correcto para iniciar el cronometro.

16. **b)** `WebApplicationFactory<Program>` arranca la aplicacion completa en memoria y permite hacer peticiones HTTP sin necesidad de un servidor real.

17. **b)** OpenAPI y Scalar solo se activan cuando `IsDevelopment()` o `IsStaging()` es true. Si el factory usara Production, esos endpoints no existirian y los tests fallarian.

18. **b)** El test hace GET a `/openapi/v1.json`, verifica que la respuesta es exitosa (2xx) y que el contenido contiene la cadena "openapi", confirmando que es un documento OpenAPI valido.

19. **b)** Scalar devuelve una pagina HTML interactiva, por lo que el content-type esperado es `text/html`.

20. **b)** La app puede tener un base path (`/CursoNormalizacionApps`) o no. El helper prueba multiples rutas y devuelve la primera que responde con exito, haciendo los tests robustos ante cambios de configuracion.

21. **b)** `dotnet tool install -g Microsoft.dotnet-httprepl` instala la herramienta globalmente como una dotnet tool.

22. **b)** En httpRepl se usa `cd` para navegar entre recursos, similar a un sistema de ficheros. `cd api/Unidades` cambia al contexto de ese recurso.

23. **c)** `ErrorType.Failure` se mapea a 500 Internal Server Error con `ProblemDetails` generico, sin revelar detalles internos al cliente.

24. **b)** Los controladores MVC serializaran en camelCase, pero Minimal APIs serializaran en PascalCase. Esto causa inconsistencia en las respuestas de la API.

25. **b)** `IProblemDetailsWriter` es la interfaz que permite personalizar como se serializa ProblemDetails, incluyendo la politica de naming.

26. **c)** Cuando el error es `ErrorType.Validation` y tiene `ValidationErrors`, `HandleResult` devuelve 400 Bad Request con `ValidationProblemDetails` que incluye los errores organizados por campo.

27. **c)** Un POST con FluentValidation y HandleResult puede devolver: 200 (exito), 400 (validacion del DTO o del servicio) y 500 (error interno). Necesita tres `ProducesResponseType`.

28. **b)** `IClassFixture<T>` en xUnit comparte una unica instancia del fixture entre todos los tests de la clase, evitando arrancar la app para cada test individual.

29. **b)** `AddJsonOptions` configura la serializacion para controladores MVC, mientras que `ConfigureHttpJsonOptions` configura Minimal APIs. Es importante que ambos sean consistentes.

30. **c)** Si ninguna ruta responde con exito, el helper devuelve `last!`, que es la ultima respuesta recibida (con su codigo de error), no null ni una excepcion.

31. **c)** Primero FluentValidation valida el formato del DTO (devuelve 400 si falla), luego el servicio valida reglas de negocio, y finalmente se ejecuta la operacion en BD.

32. **a)** Cuando la unidad se puede eliminar, devuelve 200 OK con `Permitido = true`, una razon descriptiva y un `TokenOperacion` generado como GUID sin guiones (`ToString("N")`).

33. **b)** `CanWrite` devuelve `false`, lo que significa que el framework nunca delegara la escritura a este writer. Deberia devolver `true` para que se use.

34. **b)** En httpRepl, una vez dentro de `cd api/Unidades`, el comando `get 1` ejecuta GET a `/api/Unidades/1`.

35. **c)** OpenAPI soporta tanto JSON como YAML para el documento de especificacion. En .NET, `MapOpenApi()` genera JSON por defecto.

36. **c)** Con la configuracion del curso, `MapOpenApi()` y `MapScalarApiReference()` solo se registran dentro del bloque `if (IsDevelopment || IsStaging)`, por lo que en produccion esas rutas no existen y devuelven 404.

37. **b)** El flujo correcto es: GET para comprobar si se puede → recibir token → POST con el token para ejecutar. El token garantiza que se realizo la comprobacion previa.

38. **c)** La propiedad `Permitido` (tipo `bool`) indica si la operacion se puede realizar. `Razon` explica el motivo y `TokenOperacion` contiene el token para el POST posterior.

39. **b)** `Microsoft.AspNetCore.OpenApi` es el paquete que habilita `AddOpenApi()`. No se necesita Swashbuckle.

40. **c)** `IExceptionHandler` captura excepciones no controladas y devuelve 500 con `ProblemDetails` generico que incluye un `traceId`, sin revelar detalles internos de la excepcion.

41. **b)** Al usar `new ApiTimingFilter()`, el filtro se instancia directamente sin pasar por el contenedor DI, por lo que no puede recibir `ILogger<ApiTimingFilter>` en su constructor. Se debe usar `Filters.Add<ApiTimingFilter>()` para que DI resuelva las dependencias.

42. **b)** `AllowAnonymous()` indica que los endpoints de documentacion (OpenAPI y Scalar) no requieren autenticacion. Esto no afecta a los endpoints de la API propiamente dichos.

43. **b)** En el contrato UA, cuando un recurso no se encuentra se devuelve 200 OK con un objeto vacio (Id=0). El frontend se encarga de detectar ese caso. No se usa 404.

44. **c)** `AddOpenApi()` nativo de .NET 9+ genera documentacion en formato OpenAPI 3.1, la version mas reciente del estandar.

45. **b)** `ValidationProblemDetails` hereda de `ProblemDetails` y anade la propiedad `Errors` (diccionario campo→mensajes[]), que permite informar de errores de validacion por campo especifico.

46. **b)** Con camelCase, `FlgActiva` se convierte a `flgActiva` (primera letra en minuscula). Es la convencion estandar para APIs JSON.

47. **b)** El test conecta directamente a `localhost:5001`, lo que requiere un servidor real corriendo. Deberia usar `WebApplicationFactory` para arrancar la app en memoria. Ademas, solo verifica el status code (200) pero no comprueba que el contenido sea un documento OpenAPI valido.

48. **b)** El idioma se obtiene del claim del usuario autenticado. El middleware de localizacion establece la cultura del hilo y `IStringLocalizer` selecciona automaticamente el fichero `.resx` correspondiente (es, ca o en).

49. **b)** `HandleResult()` es el metodo de `ApiControllerBase` que mapea `Result<T>` a la respuesta HTTP adecuada: 200 para exito, 400 para Validation, 500 para Failure.

50. **b)** Aunque `AddJsonOptions` con `null` hace que los controladores serialicen en PascalCase, `ProblemDetails` tiene su propia logica de serializacion. Se necesita ademas `ConfigureHttpJsonOptions` y un `IProblemDetailsWriter` personalizado para que todo sea consistente.
