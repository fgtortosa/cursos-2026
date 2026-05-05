# Respuestas -- Test Sesion 1: DTOs y APIs

1. **c)** El DTO transporta datos entre capas sin logica de negocio; la entidad representa una fila de la BD con mapeo directo. Los DTOs son objetos planos con solo propiedades, sin metodos de acceso a datos ni logica de negocio.

2. **c)** `FECHA_NACIMIENTO`. ClaseOracleBD3 mapea automaticamente PascalCase a SNAKE_CASE: cada mayuscula inicia un nuevo segmento separado por guion bajo.

3. **b)** `[Columna("NOMBRE_REAL")]`. Es el atributo especifico de ClaseOracleBD3 para cuando la columna Oracle no sigue la convencion automatica de SNAKE_CASE.

4. **c)** Valida automaticamente el ModelState y devuelve 400 si no es valido. Con `[ApiController]`, si un DTO tiene DataAnnotations y los datos no son validos, .NET devuelve un `ValidationProblemDetails` sin escribir codigo de validacion en la accion.

5. **b)** `/api/Herramientas/activas`. El placeholder `[controller]` se reemplaza por el nombre del controlador sin el sufijo "Controller", y `"activas"` es la subruta del `[HttpGet]`.

6. **c)** 404. El metodo `NotFound()` de `ControllerBase` devuelve un HTTP 404 Not Found.

7. **d)** POST. En REST, POST se usa para crear recursos nuevos, mientras que PUT se usa para actualizar recursos existentes.

8. **c)** 404 Not Found. `FirstOrDefault` devuelve null si no encuentra el elemento, y el `if` comprueba null para devolver `NotFound()`.

9. **c)** `ControllerBase`. En el patron UA, los controladores API heredan de `ControllerBase` (no de `Controller`, que anade soporte para vistas MVC innecesario en APIs).

10. **b)** Un JSON con formato `ProblemDetails` (RFC 7807). El metodo `Problem()` genera una respuesta estandar con campos `type`, `title`, `status` y `detail`.

11. **b)** .NET devuelve automaticamente un 400 Bad Request con `ValidationProblemDetails`. El atributo `[ApiController]` intercepta el ModelState invalido antes de que se ejecute la accion del controlador.

12. **b)** La ruta deberia ser `"api/[controller]"` con corchetes para usar el nombre del controlador. Sin corchetes, la ruta literal seria `/api/controller` en vez de `/api/Reservas`.

13. **b)** `[Range(5, 120)]`. Este atributo valida que el valor numerico este entre el minimo y maximo indicados. `[MinLength]`/`[MaxLength]` son para longitud de strings o colecciones.

14. **b)** Solo `NombreEs`. Es el unico campo con `[Required]`. `Granularidad` tiene `[Range]` pero no `[Required]` (aunque al ser `int` no puede ser null, el valor 0 pasaria sin `[Range]`). `EmailContacto` valida formato solo si tiene valor.

15. **b)** `@"^[^@]+@(ua\.es|alu\.ua\.es)$"`. Ancla el patron con `^` y `$`, escapa los puntos con `\.`, y usa un grupo con alternancia para ambos dominios.

16. **b)** 400 Bad Request con `ValidationProblemDetails`. El atributo `[ApiController]` valida el ModelState automaticamente antes de ejecutar la accion, por lo que el codigo dentro de `Validar` nunca llega a ejecutarse.

17. **c)** `llamadaAxios`. Es la funcion principal de `vueua-useaxios/services/useAxios` para realizar llamadas HTTP en el patron Vue UA.

18. **b)** El verbo deberia ser `verbosAxios.POST` ya que envia datos en el body. El endpoint `Eco/validar` es un `[HttpPost]` y se envia un formulario como tercer parametro.

19. **b)** `error.response.data.errors`. El `ValidationProblemDetails` tiene la propiedad `errors` que es un diccionario campo-mensajes. No confundir con `error.response.data` que contiene todo el ProblemDetails.

20. **c)** `bool`. ClaseOracleBD3 convierte automaticamente los valores `'S'`/`'N'` de Oracle a `true`/`false` en C#.

21. **b)** El tipo de retorno es `IActionResult` pero se devuelve una lista directamente sin envolverla en `Ok()`. Se necesita `return Ok(_reservas);` para que se serialice correctamente con codigo 200.

22. **c)** `[FromBody]`. Este atributo indica que el parametro se deserializa del cuerpo de la peticion HTTP (tipicamente JSON). `[FromQuery]` es para parametros de URL y `[FromRoute]` para segmentos de la ruta.

23. **a)** `Ok()` devuelve 200 con datos y `NoContent()` devuelve 204 sin datos. El 204 se usa cuando la operacion fue exitosa pero no hay contenido que devolver (ej: un DELETE exitoso).

24. **c)** Se identifica que el codigo no tiene validaciones y acepta datos invalidos. En la sesion, se demuestra enviando un DTO con campos vacios que la API acepta sin validar.

25. **b)** Se anaden atributos `[Required]` y .NET rechaza automaticamente datos vacios con 400. La fase Verde es cuando el codigo pasa de aceptar todo a rechazar datos invalidos.

26. **b)** Falta `ErrorMessage` en `[Required]` y falta `MinimumLength` en `[StringLength]`. Sin `ErrorMessage` se muestra un mensaje generico en ingles, y sin `MinimumLength` se aceptan strings de 1 caracter.

27. **b)** `status: 400` y `errors` es un diccionario donde la clave es el nombre del campo y el valor es un array de mensajes. Este es el formato estandar de `ValidationProblemDetails`.

28. **b)** En `Models/` con prefijo `Clase` (ej: `ClasePermiso`) y propiedades en PascalCase. Es la convencion UA: nombres en espanol, prefijo `Clase`, carpeta `Models/` organizada por entidad.

29. **b)** Es una propiedad de solo lectura que concatena Nombre y Url sin almacenarse en BD. La sintaxis `=>` define una propiedad calculada (expression-bodied member) que no tiene setter.

30. **c)** `[IgnorarMapeo]`. Es el atributo de ClaseOracleBD3 que evita que una propiedad se mapee a una columna Oracle. `[NotMapped]` es de Entity Framework.

31. **c)** 400. `BadRequest()` devuelve siempre un codigo HTTP 400 Bad Request, indicando un error en la solicitud del cliente.

32. **b)** No hereda de `ControllerBase`, por lo que `Ok()` no esta disponible. Sin la herencia, el metodo `Ok()` y otros metodos helper de HTTP no estan accesibles en el controlador.

33. **c)** PUT. En REST, PUT se usa para reemplazar completamente un recurso existente. PATCH se usa para actualizaciones parciales.

34. **b)** Comprobando `error.response?.status === 400 && error.response?.data?.errors`. Se verifica que el status sea 400 y que exista la propiedad `errors` en la respuesta para distinguir validacion de otros errores.

35. **c)** Gestiona el error de forma centralizada mostrando un toast automatico. A diferencia de `avisarError` que es manual, `gestionarError` maneja el error de forma estandar.

36. **b)** 400 con errores en `NombreEs` (longitud minima 3), `Granularidad` (minimo 5) y `EmailContacto` (dominio no permitido). "AB" tiene 2 caracteres (minimo 3), 3 esta fuera del rango 5-120, y gmail.com no es ua.es ni alu.ua.es.

37. **b)** `public ActionResult<ClaseEcoUnidad> Eco([FromBody] ClaseEcoUnidad dto)`. Usa `ActionResult<T>` para tipar la respuesta y `[FromBody]` para deserializar el body JSON al DTO.

38. **b)** `is-invalid`. Es la clase de Bootstrap 5 que muestra borde rojo y activa la visibilidad del `invalid-feedback`. Se aplica condicionalmente con `:class` cuando existen errores para ese campo.

39. **c)** `[EmailAddress]`. Valida formato de email segun RFC estandar. Es un atributo de `System.ComponentModel.DataAnnotations`.

40. **b)** El tipo de `id` deberia ser `int` Y no se comprueba si `reserva` es null. Son dos errores: `string` no se puede comparar con `int CodReserva`, y si no se encuentra la reserva se devuelve `Ok(null)` en vez de `NotFound()`.

41. **b)** `NoContent()`. Devuelve HTTP 204 No Content, indicando que la operacion fue exitosa pero no hay cuerpo de respuesta.

42. **c)** `errors`. Es un diccionario `Dictionary<string, string[]>` donde las claves son los nombres de las propiedades del DTO y los valores son arrays con los mensajes de error.

43. **b)** Se devuelve un 400 con el mensaje de error de StringLength. El `MinimumLength = 3` rechaza strings menores de 3 caracteres y el `[ApiController]` devuelve automaticamente el `ValidationProblemDetails`.

44. **b)** Automaticamente resuelve `NOMBRE_ES`, `NOMBRE_CA` o `NOMBRE_EN` segun el idioma pasado al metodo. ClaseOracleBD3 anade el sufijo del idioma a las columnas multiidioma de forma transparente.

45. **c)** El verbo deberia ser POST, falta limpiar errores anteriores, y los errores de validacion estan en `error.response.data.errors` no en `error.response.data`. Son tres errores: verbo incorrecto (GET vs POST), no se limpian `errores` y `respuesta` antes de la llamada, y se accede al nivel equivocado del objeto de error.

46. **b)** `[Produces("application/json")]`. Este atributo declara el content-type de las respuestas y es util para la documentacion OpenAPI.

47. **b)** Documenta que la accion puede devolver un 500 con formato ProblemDetails (para OpenAPI/Swagger). Es un atributo declarativo para la generacion de documentacion, no afecta al comportamiento en runtime.

48. **b)** `return Ok(_reservas.Where(r => r.Activo));`. Se envuelve el resultado filtrado en `Ok()` para devolver un 200 con la lista serializada como JSON. Las opciones a) y c)/d) no usan el patron estandar de `IActionResult`.

49. **b)** Si, un campo puede tener multiples mensajes de error en el array de `errors`. En el ejemplo, si el email tiene formato invalido Y no es del dominio correcto, ambos mensajes aparecen en el array de errores del campo `EmailContacto`.

50. **c)** `avisarError`. Es la funcion de `vueua-usetoast/services/useToast` que muestra un toast con titulo y mensaje personalizados, a diferencia de `gestionarError` que es automatico.
