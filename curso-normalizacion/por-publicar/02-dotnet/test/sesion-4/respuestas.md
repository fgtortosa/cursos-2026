# Respuestas — Test Sesion 4: DataTable y ClaseCrud

1. **b)** SQL en Oracle con `OFFSET/FETCH`. En DataTable server-side, toda la paginacion se realiza en el servidor mediante consultas SQL, no en el navegador.

2. **c)** Los registros del 21 al 30 (OFFSET 20, FETCH 10). Oracle salta los primeros 20 registros (`OFFSET 20 ROWS`) y devuelve los siguientes 10 (`FETCH NEXT 10 ROWS ONLY`).

3. **c)** `ClaseCrudUtils`. Esta clase base de la libreria `PlantillaMVCCore.DataTable` proporciona los metodos `NumeroRegistrosTotales`, `NumeroRegistrosFiltrados` y `RegistrosFiltrados<T>`.

4. **b)** El nombre que envia el frontend en camelCase. `NombreIni` es el nombre del campo tal como lo envia el cliente (ej: `"flgActiva"`), y `NombreFinal` es la columna Oracle real (`"FLG_ACTIVA"`).

5. **c)** `ClaseCrudUtils` rechaza el campo como medida de seguridad contra SQL injection. Si el campo no esta en `CamposFiltros`, se rechaza para evitar que un atacante inyecte nombres de columna arbitrarios.

6. **c)** `WHERE (ID LIKE '%biblioteca%' OR NOMBRE_ES LIKE '%biblioteca%' OR DURACION_MAX LIKE '%biblioteca%')`. El campo `ALL` con pipes genera una clausula OR buscando en todas las columnas indicadas.

7. **b)** Aplicar una condicion permanente a TODAS las consultas del DataTable. `SQLWhereBase` se anade automaticamente a `NumeroRegistrosTotales`, `NumeroRegistrosFiltrados` y `RegistrosFiltrados`.

8. **b)** `SELECT COUNT(*) FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'`. `SQLWhereBase` se aplica automaticamente a todas las consultas, incluida la de totales.

9. **b)** `NumeroRegistros` (total sin filtrar), `NumeroRegistrosFiltrados` (total filtrado) y `Registros` (pagina actual). El frontend necesita los tres para pintar la paginacion correctamente.

10. **b)** Se omiten los pasos 2 y 3, devolviendo 0 filtrados y lista vacia. Es una optimizacion: si no hay registros, no tiene sentido ejecutar las otras dos consultas.

11. **c)** `"ID"` (primer campo del split por `|`). El campo `ALL` tiene `NombreFinal = "ID|NOMBRE_ES|DURACION_MAX"`, y como contiene `|`, se hace split y se toma el primer elemento.

12. **c)** Se devuelve `"ID"` como campo por defecto. `TransformarCampoOrden` busca en `CamposFiltros`; si no encuentra el campo, devuelve `"ID"` para evitar un ORDER BY vacio que causaria error en Oracle.

13. **c)** Por seguridad (no exponer columnas internas), rendimiento (solo traer lo necesario) y estabilidad (no romper si cambia la vista). Son las tres razones documentadas en el curso.

14. **c)** `NOMBRE_CA`. La interpolacion `$"NOMBRE_{idiomaUpper}"` con `idiomaUpper = "CA"` produce `"NOMBRE_CA"`.

15. **c)** Se establece `_idioma = "ES"` y se reconfigura `CamposFiltros` con `"ES"`. `string.IsNullOrWhiteSpace("")` devuelve `true`, asi que se usa el valor por defecto `"ES"`.

16. **b)** `NumeroRegistrosTotales` -> `NumeroRegistrosFiltrados` -> `RegistrosFiltrados`. Se ejecutan secuencialmente: primero el total, luego el filtrado (solo si hay registros), y finalmente los datos paginados.

17. **b)** Porque `SetIdioma` reconfigura `CamposFiltros` con el idioma correcto, y `Obtener` usa esos campos. Si no se llama antes, los campos multiidioma (como `nombre` -> `NOMBRE_ES/CA/EN`) apuntarian al idioma anterior.

18. **a)** La URL correcta usa `primerregistro=10` (offset para la segunda pagina de 10), `numeroregistros=10`, `campoorden=nombre` (camelCase del frontend), `orden=DESC` y `campofiltro=ALL`.

19. **d)** 4 errores: (1) usa tabla directa `TCTS_UNIDADES` en vez de vista, (2) usa `SELECT *`, (3) no transforma `campoorden` de camelCase a Oracle, y (4) falta asignar `NumeroRegistrosFiltrados`.

20. **b)** `true` — se permite filtrar por defecto. Segun la documentacion, `PermitirFiltro` tiene valor por defecto `true`.

21. **c)** Test con FakeService (implementacion manual de la interfaz). Se crea una clase `FakeUnidadesService` que implementa `IClaseUnidades` con propiedades configurables para cada test.

22. **b)** Registra el ultimo idioma que paso el controlador, para poder verificarlo con Assert. En el test se comprueba `Assert.Equal("CA", service.UltimoIdioma)` para verificar que el controlador llamo a `SetIdioma` con el idioma correcto.

23. **b)** Porque `Obtener` devuelve `ClaseDataTable` directamente, no `Result<T>`. `HandleResult` esta disenado para mapear `Result<T>` a respuestas HTTP; el DataTable devuelve su propio tipo sin envolver en Result.

24. **b)** `Obtener` devuelve `ClaseDataTable` con metadatos de paginacion (`NumeroRegistros`, `NumeroRegistrosFiltrados`, `Registros`); `ObtenerActivas` devuelve `Result<List<T>>` con todas las unidades activas, util para combos/selects.

25. **c)** `"ALL"`. El valor por defecto del parametro `campofiltro` es `"ALL"`, que indica busqueda general en todas las columnas definidas con pipes.

26. **b)** Cuando hay mas de 100 registros o en pantallas de administracion. Para menos de 100 registros, un listado simple en el frontend es suficiente.

27. **b)** `NombreIni = "flgActiva"`, `NombreFinal = "FLG_ACTIVA"`. El patron es: `NombreIni` recibe el nombre camelCase del frontend y `NombreFinal` lo mapea a la columna Oracle en MAYUSCULAS.

28. **b)** `VistaUnidades` es el nombre de la vista Oracle (`"VCTS_UNIDADES"`) y `CamposVistaUnidades` es la lista explicita de columnas para el SELECT, evitando usar `*`.

29. **b)** Incluye `SQLWhereBase` (`FLG_ACTIVA = 'S'`), el filtro LIKE, campos explicitos, ORDER BY y `OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY` para paginacion Oracle.

30. **b)** `"ASC"` o `"DESC"`. Son los dos valores validos para la direccion de ordenacion en el endpoint DataTable.

31. **b)** `CrudAPIClaseInterface<ClaseUnidad>`. Esta interfaz exige implementar metodos como `Obtener`, `BuscarxId`, `Crear`, `Actualizar`, `Eliminar`, `ObtenerSimple` e `Inicializar`.

32. **a)** Los metodos que no se necesitan para DataTable y ya estan cubiertos por metodos tipados con `Result<T>`. Los metodos `Crear`, `Actualizar` y `Eliminar` de la interfaz generica se redirigen a versiones tipadas (`Guardar(ClaseGuardarUnidad)`, `Eliminar(int, int, string)`).

33. **b)** Para calcular el numero total de paginas de la paginacion. Dividiendo `numeroRegistrosFiltrados` entre el tamano de pagina, el frontend sabe cuantas paginas hay.

34. **b)** Habilita la busqueda general en todos los campos (campo `ALL`). Activa el input de busqueda global que envia `campofiltro=ALL` al backend.

35. **b)** Para aplicar el filtro SQL correcto segun el tipo de dato. Por ejemplo, los campos `number` usan comparacion numerica, los `boolean` comparan contra `'S'/'N'`, y los `string` usan `LIKE`.

36. **c)** 50. El valor por defecto del parametro `numeroregistros` es 50.

37. **b)** Por permisos: el usuario web normalmente solo tiene `SELECT` sobre vistas, no sobre tablas. Es una practica de seguridad estandar en las aplicaciones UA.

38. **c)** Se limpia la lista de campos existente con `CamposFiltros.Clear()`. Esto es necesario para reconstruir los campos desde cero cuando cambia el idioma.

39. **b)** `Obtener` devuelve `ClaseDataTable` con metadatos de paginacion (`NumeroRegistros`, `NumeroRegistrosFiltrados`, `Registros`); `ObtenerSimple` devuelve solo `List<ClaseUnidad>` sin metadatos, llamando unicamente a `RegistrosFiltrados`.

40. **b)** `{ errors: { "NombreEs": ["Mensaje 1"], "Granularidad": ["Mensaje 2"] } }`. Es el formato estandar de `ValidationProblemDetails` con errores agrupados por campo.

41. **b)** Porque un campo puede tener multiples mensajes de error en un array y se unen para mostrarlos todos. `ValidationProblemDetails` devuelve un `string[]` por cada campo.

42. **b)** La columna NO se muestra en la vista movil de la tabla. Es una propiedad del componente DataTable UA para controlar la visibilidad responsive.

43. **c)** 10 (o menos si estamos en la ultima pagina). El servidor devuelve como maximo `numeroregistros` elementos. En la segunda pagina del ejemplo (12 filtrados, pagina de 10), devolveria 2.

44. **c)** `WHERE FLG_ACTIVA = 'S' AND NOMBRE_ES LIKE '%biblioteca%'`. `SQLWhereBase` se combina con AND con el filtro del usuario.

45. **c)** Porque un campo con pipes (como `ALL`) tiene multiples columnas y `ORDER BY` necesita un solo campo, asi que se toma el primero. No se puede ordenar por varias columnas concatenadas con `|`.

46. **c)** `AddScoped<IClaseUnidades, ClaseUnidades>()`. Los servicios UA se registran como Scoped (una instancia por peticion HTTP), porque dependen de `ClaseOracleBd` que tambien es Scoped.

47. **b)** NO incluye el prefijo `/api/` — el componente lo anade automaticamente. La URL en la configuracion del componente es relativa y el componente gestiona el prefijo.

48. **c)** GET. El DataTable server-side usa `verbosAxios.GET` porque es una consulta de lectura con parametros en query string.

49. **b)** La version verde anade las cuatro correcciones: transformacion de campo de orden con `TransformarCampoOrden`, calculo de `NumeroRegistrosFiltrados`, uso de la constante `VistaUnidades` en vez de tabla directa, y `CamposVistaUnidades` en vez de `*`.

50. **b)** Carga datos adicionales como listas para combos/selects que se necesitan junto con la tabla. Por ejemplo, listas de tipos o categorias que el frontend necesita para filtros desplegables.
