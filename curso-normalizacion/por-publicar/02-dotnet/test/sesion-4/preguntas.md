# Test de autoevaluacion — Sesion 4: DataTable y ClaseCrud

## Pregunta 1

En un DataTable server-side, la paginacion se realiza en:

a) JavaScript en el navegador con `Array.slice()`
b) SQL en Oracle con `OFFSET/FETCH`
c) El middleware de ASP.NET Core
d) El componente Vue con `v-for` y un indice

## Pregunta 2

Dado el siguiente endpoint DataTable:

```
GET /api/Unidades/datatable?primerregistro=20&numeroregistros=10
```

Que registros devolvera Oracle?

a) Los registros del 1 al 10
b) Los registros del 20 al 30
c) Los registros del 21 al 30 (OFFSET 20, FETCH 10)
d) Todos los registros y el frontend recorta

## Pregunta 3

Cual es la clase base de la que hereda `ClaseUnidades` para disponer de la funcionalidad DataTable?

a) `ApiControllerBase`
b) `ControllerBase`
c) `ClaseCrudUtils`
d) `ClaseOracleBd`

## Pregunta 4

El siguiente codigo configura un campo en `CamposFiltros`:

```csharp
CamposFiltros.Add(new ClaseCrudUtilsCampos {
    NombreIni = "flgActiva",
    NombreFinal = "FLG_ACTIVA",
    Tipo = "boolean"
});
```

Que representa `NombreIni`?

a) El nombre de la columna Oracle en la vista
b) El nombre que envia el frontend en camelCase
c) El alias SQL que se usa en el SELECT
d) El nombre de la propiedad en el DTO de C#

## Pregunta 5

Que ocurre si el frontend envia `campofiltro=email` y `email` NO esta definido en `CamposFiltros`?

a) Oracle busca en una columna EMAIL automaticamente
b) Se ignora el filtro y se devuelven todos los registros
c) `ClaseCrudUtils` rechaza el campo como medida de seguridad contra SQL injection
d) Se aplica un filtro LIKE generico en todas las columnas

## Pregunta 6

Dado el siguiente `CamposFiltros`:

```csharp
CamposFiltros.Add(new ClaseCrudUtilsCampos {
    NombreIni = "ALL",
    NombreFinal = "ID|NOMBRE_ES|DURACION_MAX"
});
```

Que SQL genera internamente cuando el usuario busca "biblioteca" con `campofiltro=ALL`?

a) `WHERE ALL LIKE '%biblioteca%'`
b) `WHERE CONCAT(ID, NOMBRE_ES, DURACION_MAX) LIKE '%biblioteca%'`
c) `WHERE (ID LIKE '%biblioteca%' OR NOMBRE_ES LIKE '%biblioteca%' OR DURACION_MAX LIKE '%biblioteca%')`
d) `WHERE ID = 'biblioteca' AND NOMBRE_ES = 'biblioteca' AND DURACION_MAX = 'biblioteca'`

## Pregunta 7

Cual es el proposito principal de `SQLWhereBase`?

a) Definir el ORDER BY por defecto
b) Aplicar una condicion permanente a TODAS las consultas del DataTable (totales, filtrados y registros)
c) Filtrar solo en la consulta de `NumeroRegistrosTotales`
d) Reemplazar el filtro que envia el frontend

## Pregunta 8

En el constructor de `ClaseUnidades`:

```csharp
public ClaseUnidades(ClaseOracleBd claseoraclebd,
    ILogger<ClaseUnidades> logger) : base(claseoraclebd)
{
    bd = claseoraclebd;
    _logger = logger;
    SQLWhereBase = "FLG_ACTIVA = 'S'";
    ConfigurarCamposFiltros(_idioma);
}
```

Que consulta SQL genera `NumeroRegistrosTotales(VistaUnidades)` con este `SQLWhereBase`?

a) `SELECT COUNT(*) FROM VCTS_UNIDADES`
b) `SELECT COUNT(*) FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'`
c) `SELECT COUNT(*) FROM TCTS_UNIDADES WHERE FLG_ACTIVA = 'S'`
d) `SELECT * FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'`

## Pregunta 9

Que tres propiedades contiene `ClaseDataTable` y que representan?

a) `Count`, `FilteredCount`, `Items` — conteos y datos
b) `NumeroRegistros`, `NumeroRegistrosFiltrados`, `Registros` — total sin filtrar, total filtrado y pagina actual
c) `Total`, `Paginas`, `Datos` — total, numero de paginas y registros
d) `PageSize`, `PageNumber`, `Records` — tamano de pagina, pagina actual y registros

## Pregunta 10

En el metodo `Obtener`, que pasa si `NumeroRegistrosTotales` devuelve 0?

```csharp
salida.NumeroRegistros = NumeroRegistrosTotales(VistaUnidades);
if (salida.NumeroRegistros > 0)
{
    // Paso 2 y 3...
}
else
{
    salida.NumeroRegistrosFiltrados = 0;
    salida.Registros = new List<ClaseUnidad>();
}
```

a) Se ejecutan las tres consultas igualmente
b) Se omiten los pasos 2 y 3, devolviendo 0 filtrados y lista vacia
c) Se lanza una excepcion `MantenimientoException`
d) Se devuelve null

## Pregunta 11

En el metodo `TransformarCampoOrden`:

```csharp
private string TransformarCampoOrden(string campoorden)
{
    if (string.IsNullOrWhiteSpace(campoorden))
        return "ID";

    var campo = CamposFiltros.FirstOrDefault(x =>
        string.Equals(x.NombreIni, campoorden, StringComparison.OrdinalIgnoreCase));

    if (campo == null || string.IsNullOrWhiteSpace(campo.NombreFinal))
        return "ID";

    var campoFinal = campo.NombreFinal;
    return campoFinal.Contains('|') ? campoFinal.Split('|')[0] : campoFinal;
}
```

Que devuelve `TransformarCampoOrden("ALL")`?

a) `"ALL"`
b) `"ID|NOMBRE_ES|DURACION_MAX"`
c) `"ID"` (primer campo del split por `|`)
d) `null`

## Pregunta 12

Si el frontend envia `campoorden=nombreInvalido` (campo no registrado en `CamposFiltros`), que campo de ordenacion se usa?

a) Se lanza una excepcion
b) Se ordena por `NOMBRE_ES` como fallback
c) Se devuelve `"ID"` como campo por defecto
d) No se aplica ORDER BY

## Pregunta 13

Por que NO debemos usar `SELECT *` en `RegistrosFiltrados<T>`?

a) Porque Oracle no soporta `*` con `OFFSET/FETCH`
b) Porque `ClaseCrudUtils` no puede parsear `*`
c) Por seguridad (no exponer columnas internas), rendimiento (solo traer lo necesario) y estabilidad (no romper si cambia la vista)
d) Porque el mapeo PascalCase a SNAKE_CASE falla con `*`

## Pregunta 14

Dado el siguiente codigo:

```csharp
CamposFiltros.Add(new ClaseCrudUtilsCampos {
    NombreIni = "nombre",
    NombreFinal = $"NOMBRE_{idiomaUpper}"
});
```

Si `idiomaUpper` es `"CA"`, en que columna Oracle se busca al filtrar por `nombre`?

a) `NOMBRE_ES`
b) `NOMBRE`
c) `NOMBRE_CA`
d) `nombre_ca`

## Pregunta 15

El metodo `SetIdioma` tiene este codigo:

```csharp
public void SetIdioma(string idioma)
{
    _idioma = string.IsNullOrWhiteSpace(idioma)
        ? "ES"
        : idioma.Trim().ToUpperInvariant();
    ConfigurarCamposFiltros(_idioma);
}
```

Que sucede si se llama `SetIdioma("")`?

a) Se establece `_idioma = ""` y se reconfigura `CamposFiltros` con idioma vacio
b) Se lanza una `ArgumentException`
c) Se establece `_idioma = "ES"` y se reconfigura `CamposFiltros` con `"ES"`
d) No se hace nada

## Pregunta 16

En que orden se ejecutan las tres consultas del metodo `Obtener`?

a) `RegistrosFiltrados` -> `NumeroRegistrosFiltrados` -> `NumeroRegistrosTotales`
b) `NumeroRegistrosTotales` -> `NumeroRegistrosFiltrados` -> `RegistrosFiltrados`
c) Las tres se ejecutan en paralelo
d) `NumeroRegistrosFiltrados` -> `NumeroRegistrosTotales` -> `RegistrosFiltrados`

## Pregunta 17

En el endpoint del controlador:

```csharp
[HttpGet("datatable")]
public ActionResult<ClaseDataTable> DataTable(
    [FromQuery] int primerregistro = 0,
    [FromQuery] int numeroregistros = 50,
    [FromQuery] string campoorden = "",
    [FromQuery] string orden = "ASC",
    [FromQuery] string? filtro = "",
    [FromQuery] string? campofiltro = "ALL",
    [FromQuery] bool? cargardatosadicionales = false,
    [FromQuery] string idioma = "ES")
{
    _unidades.SetIdioma(idioma);
    var salida = _unidades.Obtener(primerregistro, numeroregistros,
        campoorden, orden, filtro, campofiltro, cargardatosadicionales);
    return Ok(salida);
}
```

Por que se llama a `SetIdioma` ANTES de `Obtener`?

a) Porque `SetIdioma` abre la conexion a Oracle
b) Porque `SetIdioma` reconfigura `CamposFiltros` con el idioma correcto, y `Obtener` usa esos campos
c) Porque `SetIdioma` valida que el idioma sea correcto
d) Porque `SetIdioma` establece el `SQLWhereBase` con el idioma

## Pregunta 18

Cual es la URL completa para obtener la segunda pagina de 10 registros, ordenados por nombre descendente, filtrando por "biblioteca" en todos los campos?

a) `GET /api/Unidades/datatable?primerregistro=10&numeroregistros=10&campoorden=nombre&orden=DESC&filtro=biblioteca&campofiltro=ALL`
b) `GET /api/Unidades?page=2&size=10&sort=nombre&dir=DESC&search=biblioteca`
c) `GET /api/Unidades/datatable?offset=2&limit=10&order=nombre&direction=DESC&filter=biblioteca`
d) `GET /api/Unidades/datatable?primerregistro=1&numeroregistros=10&campoorden=NOMBRE_ES&orden=DESC&filtro=biblioteca`

## Pregunta 19

En la version "ROJA" (incorrecta) del metodo `Obtener`:

```csharp
salida.NumeroRegistros = NumeroRegistrosTotales("TCTS_UNIDADES");
salida.Registros = RegistrosFiltrados<ClaseUnidad>(
    "VCTS_UNIDADES", "*", "ALL", "",
    campoorden, orden, numeroregistros, primerregistro);
```

Cuantos errores hay en este codigo?

a) 1 — solo usa tabla directa en vez de vista
b) 2 — usa tabla directa y SELECT *
c) 3 — usa tabla directa, SELECT * y no transforma campoorden
d) 4 — usa tabla directa, SELECT *, no transforma campoorden y falta NumeroRegistrosFiltrados

## Pregunta 20

La propiedad `PermitirFiltro` de `ClaseCrudUtilsCampos`:

```csharp
CamposFiltros.Add(new ClaseCrudUtilsCampos {
    NombreIni = "id",
    NombreFinal = "ID",
    Tipo = "number",
    PermitirFiltro = true
});
```

Que valor tiene por defecto `PermitirFiltro`?

a) `false` — hay que activarlo explicitamente
b) `true` — se permite filtrar por defecto
c) `null` — depende del Tipo
d) Depende de si el campo es `number` o `string`

## Pregunta 21

En el test del controlador:

```csharp
[Fact]
public void DataTable_ConIdioma_CA_AplicaIdiomaYDevuelve200()
{
    var service = new FakeUnidadesService
    {
        ObtenerDataTableResult = new ClaseDataTable
        {
            NumeroRegistros = 0,
            NumeroRegistrosFiltrados = 0,
            Registros = []
        }
    };
    var controller = new UnidadesController(service);

    var result = controller.DataTable(idioma: "CA");

    var ok = Assert.IsType<OkObjectResult>(result.Result);
    _ = Assert.IsType<ClaseDataTable>(ok.Value);
    Assert.Equal("CA", service.UltimoIdioma);
}
```

Que patron de test se esta usando aqui?

a) Integration test con `WebApplicationFactory`
b) Test con mock usando Moq
c) Test con FakeService (implementacion manual de la interfaz)
d) Test end-to-end con Selenium

## Pregunta 22

En el `FakeUnidadesService`, que hace la propiedad `UltimoIdioma`?

```csharp
private sealed class FakeUnidadesService : IClaseUnidades
{
    public string UltimoIdioma { get; private set; } = "ES";
    public void SetIdioma(string idioma) => UltimoIdioma = idioma;
    // ...
}
```

a) Almacena el idioma del sistema operativo
b) Registra el ultimo idioma que paso el controlador, para poder verificarlo con Assert
c) Configura el idioma de los mensajes de error
d) Define el idioma de la base de datos Oracle

## Pregunta 23

Por que el endpoint DataTable NO usa `HandleResult`?

```csharp
[HttpGet("datatable")]
public ActionResult<ClaseDataTable> DataTable(...)
{
    _unidades.SetIdioma(idioma);
    var salida = _unidades.Obtener(...);
    return Ok(salida);  // No usa HandleResult
}
```

a) Porque `HandleResult` solo existe en .NET 8
b) Porque `Obtener` devuelve `ClaseDataTable` directamente, no `Result<T>`
c) Porque DataTable no necesita control de errores
d) Porque `HandleResult` no soporta listas

## Pregunta 24

En la interfaz `IClaseUnidades`:

```csharp
public interface IClaseUnidades
{
    void SetIdioma(string idioma);
    ClaseDataTable Obtener(int primerregistro = 0, int numeroregistros = 50,
        string campoorden = "", string orden = "ASC",
        string? filtro = "", string? campofiltro = "ALL",
        bool? cargardatosadicionales = false);
    List<ClaseUnidad> ObtenerSimple(...);
    Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES");
    Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES");
    Result<int> Guardar(ClaseGuardarUnidad dto);
    Result<bool> Eliminar(int id, int codPer, string ip);
}
```

Cual es la diferencia entre `Obtener` y `ObtenerActivas`?

a) Son iguales pero con distinto nombre
b) `Obtener` devuelve `ClaseDataTable` con paginacion y metadatos; `ObtenerActivas` devuelve `Result<List<T>>` con todas las activas
c) `Obtener` conecta a Oracle; `ObtenerActivas` usa cache
d) `Obtener` es sincrono y `ObtenerActivas` es asincrono

## Pregunta 25

Que valor por defecto tiene `campofiltro` en el metodo `Obtener`?

```csharp
public ClaseDataTable Obtener(
    int primerregistro = 0,
    int numeroregistros = 50,
    string campoorden = "",
    string orden = "ASC",
    string? filtro = "",
    string? campofiltro = "ALL",
    bool? cargardatosadicionales = false)
```

a) `""` (cadena vacia)
b) `null`
c) `"ALL"`
d) `"ID"`

## Pregunta 26

En un DataTable server-side, cuando se recomienda usar este patron en lugar de un listado simple?

a) Siempre, independientemente del numero de registros
b) Cuando hay mas de 100 registros o en pantallas de administracion
c) Solo cuando hay millones de registros
d) Solo cuando se necesita ordenacion

## Pregunta 27

El frontend envia los nombres de campos en camelCase. Cual de los siguientes mapeos es CORRECTO segun el patron de `CamposFiltros`?

a) `NombreIni = "FLG_ACTIVA"`, `NombreFinal = "flgActiva"`
b) `NombreIni = "flgActiva"`, `NombreFinal = "FLG_ACTIVA"`
c) `NombreIni = "flg_activa"`, `NombreFinal = "flgActiva"`
d) `NombreIni = "FlgActiva"`, `NombreFinal = "flg_activa"`

## Pregunta 28

Que constante define los campos seleccionados en la consulta SQL?

```csharp
private const string VistaUnidades = "VCTS_UNIDADES";
private const string CamposVistaUnidades =
    "ID, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN, FLG_ACTIVA, GRANULARIDAD, " +
    "DURACION_MAX, FLG_REQUIERE_CONFIRMACION, NUM_CITAS_SIMULTANEAS";
```

a) `VistaUnidades` contiene los campos y `CamposVistaUnidades` la vista
b) `VistaUnidades` es el nombre de la vista Oracle y `CamposVistaUnidades` es la lista explicita de columnas para el SELECT
c) Ambas contienen nombres de tablas Oracle
d) `CamposVistaUnidades` contiene el WHERE y `VistaUnidades` el FROM

## Pregunta 29

Que SQL genera la tercera consulta (`RegistrosFiltrados`) cuando se pide la primera pagina de 10 registros ordenados por NOMBRE_ES ASC, filtrando por "biblio"?

a) `SELECT * FROM VCTS_UNIDADES WHERE NOMBRE_ES LIKE '%biblio%' LIMIT 10`
b) `SELECT ID, NOMBRE_ES, ... FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S' AND NOMBRE_ES LIKE '%biblio%' ORDER BY NOMBRE_ES ASC OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY`
c) `SELECT TOP 10 ID, NOMBRE_ES, ... FROM VCTS_UNIDADES WHERE NOMBRE_ES LIKE '%biblio%'`
d) `SELECT ID, NOMBRE_ES, ... FROM VCTS_UNIDADES WHERE NOMBRE_ES = 'biblio' ORDER BY NOMBRE_ES ROWNUM <= 10`

## Pregunta 30

El parametro `orden` del endpoint DataTable acepta:

a) `"asc"`, `"desc"`, `"none"`
b) `"ASC"` o `"DESC"`
c) `1` para ascendente y `-1` para descendente
d) `"ascending"` o `"descending"`

## Pregunta 31

Que interfaz debe implementar `ClaseUnidades` ademas de `IClaseUnidades` y heredar de `ClaseCrudUtils`?

a) `IDisposable`
b) `CrudAPIClaseInterface<ClaseUnidad>`
c) `IActionFilter`
d) `IClaseOracleBd`

## Pregunta 32

En `CrudAPIClaseInterface<ClaseUnidad>`, que metodos se implementan con `throw new NotSupportedException()`?

```csharp
public object Crear(ClaseUnidad item)
    => throw new NotSupportedException(
        "Para alta usar Guardar(ClaseGuardarUnidad dto).");
public void Actualizar(object id, ClaseUnidad item)
    => throw new NotSupportedException(...);
public void Eliminar(object id)
    => throw new NotSupportedException(...);
```

a) Los metodos que no se necesitan para DataTable y ya estan cubiertos por metodos tipados con `Result<T>`
b) Los metodos que aun no se han desarrollado
c) Los metodos que requieren autenticacion
d) Los metodos que solo funcionan en produccion

## Pregunta 33

En la interfaz TypeScript del frontend:

```typescript
interface DataTableResponse {
  numeroRegistros: number;
  numeroRegistrosFiltrados: number;
  registros: Unidad[];
}
```

Para que usa el frontend `numeroRegistrosFiltrados`?

a) Para saber cuantas filas renderizar en la tabla
b) Para calcular el numero total de paginas de la paginacion
c) Para mostrar el total de registros en la base de datos
d) Para determinar si hay errores de validacion

## Pregunta 34

En el componente Vue DataTable UA (`vueua-datatable`):

```typescript
const dtUnidades = ref<Datatable>({
  campos: [...],
  key: "id",
  url: "Unidades/datatable",
  campoprincipal: "nombre",
  filtrosDatatable: {
    filtroGeneral: true,
    filtrosCampos: true,
  },
});
```

Que hace la propiedad `filtroGeneral: true`?

a) Activa un filtro de seguridad XSS
b) Habilita la busqueda general en todos los campos (campo `ALL`)
c) Filtra registros eliminados
d) Activa la busqueda por expresiones regulares

## Pregunta 35

La propiedad `Tipo` en `ClaseCrudUtilsCampos` puede ser `"number"`, `"boolean"` o `"string"` (default). Para que se usa?

a) Para validar el formato del valor en el frontend
b) Para aplicar el filtro SQL correcto segun el tipo de dato (por ejemplo, comparacion numerica vs LIKE)
c) Para generar el HTML del input en la tabla
d) Para definir el tipo de columna en Oracle

## Pregunta 36

Dado el siguiente endpoint:

```csharp
[HttpGet("datatable")]
public ActionResult<ClaseDataTable> DataTable(
    [FromQuery] int primerregistro = 0,
    [FromQuery] int numeroregistros = 50, ...)
```

Si el frontend no envia el parametro `numeroregistros`, cuantos registros por pagina devuelve por defecto?

a) 10
b) 25
c) 50
d) 100

## Pregunta 37

Por que se usan vistas Oracle (`VCTS_UNIDADES`) en lugar de tablas directas (`TCTS_UNIDADES`) para las consultas DataTable?

a) Las vistas son mas rapidas que las tablas
b) Por permisos: el usuario web normalmente solo tiene `SELECT` sobre vistas, no sobre tablas
c) Las vistas soportan `OFFSET/FETCH` y las tablas no
d) Las vistas permiten usar `SELECT *`

## Pregunta 38

En el metodo `ConfigurarCamposFiltros`, cual es la primera linea que se ejecuta?

```csharp
private void ConfigurarCamposFiltros(string idiomaUpper)
{
    CamposFiltros.Clear();
    // ... Add campos
}
```

a) Se anaden los nuevos campos
b) Se comprueba el idioma
c) Se limpia la lista de campos existente con `CamposFiltros.Clear()`
d) Se establece `SQLWhereBase`

## Pregunta 39

Cual es la diferencia entre `Obtener` y `ObtenerSimple` en `ClaseUnidades`?

```csharp
public ClaseDataTable Obtener(...) { /* con NumeroRegistros, NumeroRegistrosFiltrados */ }
public List<ClaseUnidad> ObtenerSimple(...) { /* solo RegistrosFiltrados */ }
```

a) `Obtener` es asincrono y `ObtenerSimple` sincrono
b) `Obtener` devuelve `ClaseDataTable` con metadatos de paginacion; `ObtenerSimple` devuelve solo la lista de registros sin metadatos
c) `Obtener` aplica filtros y `ObtenerSimple` no
d) `Obtener` usa vista y `ObtenerSimple` usa tabla

## Pregunta 40

En el manejo de errores de validacion en Vue:

```typescript
.catch((error) => {
    if (error.response?.status === 400 && error.response?.data?.errors) {
        errores.value = error.response.data.errors;
    } else {
        gestionarError(error, t("Unidades.error-guardar"), "guardar");
    }
});
```

Que formato tienen los errores de `ValidationProblemDetails`?

a) `{ message: "Error global" }`
b) `{ errors: { "NombreEs": ["Mensaje 1"], "Granularidad": ["Mensaje 2"] } }`
c) `{ code: 400, errors: ["Mensaje 1", "Mensaje 2"] }`
d) `{ field: "NombreEs", message: "Mensaje 1" }`

## Pregunta 41

En el template Vue para pintar errores por campo:

```html
<input v-model="formulario.nombreEs" type="text" class="form-control"
  :class="{ 'is-invalid': errores?.NombreEs }" />
<div class="invalid-feedback" v-if="errores?.NombreEs">
  {{ errores.NombreEs.join(", ") }}
</div>
```

Por que se usa `.join(", ")`?

a) Porque siempre hay exactamente dos errores por campo
b) Porque un campo puede tener multiples mensajes de error en un array y se unen para mostrarlos todos
c) Porque los errores vienen en idiomas separados
d) Porque el API devuelve los errores como cadena con comas

## Pregunta 42

Al configurar el componente `DataTableComponente` de UA:

```typescript
{
  nombre: "granularidad",
  descripcion: t("Unidades.granularidad"),
  tipo: "number",
  ancho: "15%",
  ordenable: true,
  filtrable: true,
  movil: false,
}
```

Que significa `movil: false`?

a) El campo no se guarda en la base de datos desde movil
b) La columna NO se muestra en la vista movil de la tabla
c) El filtro de este campo no funciona en movil
d) El campo se convierte a solo lectura en pantallas pequenas

## Pregunta 43

En la respuesta JSON del DataTable, si hay 250 registros totales, 12 coinciden con el filtro y pedimos pagina de 10:

```json
{
  "numeroRegistros": 250,
  "numeroRegistrosFiltrados": 12,
  "registros": [/* ... */]
}
```

Cuantos elementos tendra el array `registros`?

a) 250
b) 12
c) 10 (o menos si estamos en la ultima pagina)
d) Siempre exactamente 10

## Pregunta 44

Si `SQLWhereBase = "FLG_ACTIVA = 'S'"` y el usuario filtra por `nombre = "biblioteca"`, que WHERE genera la consulta de `NumeroRegistrosFiltrados`?

a) `WHERE NOMBRE_ES LIKE '%biblioteca%'`
b) `WHERE FLG_ACTIVA = 'S'`
c) `WHERE FLG_ACTIVA = 'S' AND NOMBRE_ES LIKE '%biblioteca%'`
d) `WHERE FLG_ACTIVA = 'S' OR NOMBRE_ES LIKE '%biblioteca%'`

## Pregunta 45

En `TransformarCampoOrden`, si el campo encontrado en `CamposFiltros` tiene `NombreFinal` con pipes (`|`):

```csharp
var campoFinal = campo.NombreFinal;
return campoFinal.Contains('|') ? campoFinal.Split('|')[0] : campoFinal;
```

Por que se toma solo el primer elemento del split?

a) Porque `ORDER BY` no soporta multiples columnas
b) Porque Oracle no puede ordenar por `|`
c) Porque un campo con pipes (como `ALL`) tiene multiples columnas y `ORDER BY` necesita un solo campo, asi que se toma el primero
d) Porque el primer campo siempre es el ID

## Pregunta 46

El servicio `ClaseUnidades` se registra en el contenedor de inyeccion de dependencias como:

a) `AddSingleton<IClaseUnidades, ClaseUnidades>()`
b) `AddTransient<IClaseUnidades, ClaseUnidades>()`
c) `AddScoped<IClaseUnidades, ClaseUnidades>()`
d) `AddHostedService<ClaseUnidades>()`

## Pregunta 47

La propiedad `url` del componente `DataTableComponente`:

```typescript
url: "Unidades/datatable",
```

Que particularidad tiene respecto a la ruta real de la API?

a) Incluye el prefijo `/api/`
b) NO incluye el prefijo `/api/` — el componente lo anade automaticamente
c) Es una ruta relativa al archivo Vue
d) Es el nombre del servicio en el backend

## Pregunta 48

En el siguiente codigo de la llamada axios desde Vue:

```typescript
llamadaAxios(
    `Unidades/datatable?primerregistro=${primerRegistro.value}` +
    `&numeroregistros=${numeroRegistros.value}` +
    `&campofiltro=ALL&idioma=ES`,
    verbosAxios.GET,
)
```

Que metodo HTTP se utiliza para el DataTable?

a) POST
b) PUT
c) GET
d) PATCH

## Pregunta 49

En la practica Rojo-Verde-Refactor, la version "verde" del metodo `Obtener` anade respecto a la "roja":

a) Solo la transformacion de campo de orden
b) La transformacion de campo de orden, `NumeroRegistrosFiltrados`, uso de vista en vez de tabla, y campos explicitos en vez de `*`
c) Unicamente el uso de vista en vez de tabla
d) Solo la propiedad `NumeroRegistrosFiltrados`

## Pregunta 50

Que hace `DatosAdicionales` en la fase de refactor del DataTable?

```csharp
if (cargardatosadicionales == true)
{
    salida.DatosAdicionales = ObtenerDatosAdicionales();
}
```

a) Carga las imagenes asociadas a cada registro
b) Carga datos adicionales como listas para combos/selects que se necesitan junto con la tabla
c) Ejecuta consultas de auditoria adicionales
d) Carga los datos de la siguiente pagina para mejorar rendimiento
