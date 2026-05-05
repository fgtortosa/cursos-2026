---
title: "Material de referencia: DataTable server-side con ClaseCrud"
description: Implementación de DataTable server-side en .NET con ClaseCrudUtils, filtros, paginación y ordenación para Vue
outline: deep
---

# Material de referencia: DataTable server-side con ClaseCrud

::: warning REORGANIZACIÓN DEL TEMARIO
Este contenido se ha integrado en la **Sesión 14 — DataTable de extremo a extremo**, donde se cubre tanto el lado .NET como el componente `vueua-datatable` de Vue en una sola sesión.

Este fichero se mantiene como material de consulta y referencia.
:::

[[toc]]

## 4.1 ¿Qué es un DataTable server-side?

::: info CONTEXTO
En sesiones anteriores hemos creado endpoints que devuelven **listas completas** de registros (`ObtenerActivas`, `ObtenerPorId`). Esto funciona para decenas de registros, pero **¿qué pasa cuando la tabla tiene miles o decenas de miles de filas?**

- Descargar 10.000 registros al navegador consume ancho de banda y memoria
- El frontend se ralentiza renderizando miles de filas
- No podemos filtrar ni ordenar eficientemente en JavaScript

La solución es **DataTable server-side**: el servidor se encarga de paginar, filtrar y ordenar, y solo envía al frontend los registros de la página actual.
:::

### Diferencia entre listado simple y DataTable

|                   | Listado simple           | DataTable server-side                         |
| ----------------- | ------------------------ | --------------------------------------------- |
| **Datos**         | Todos los registros      | Solo página actual                            |
| **Filtrado**      | En JavaScript (frontend) | En SQL (servidor/Oracle)                      |
| **Ordenación**    | En JavaScript            | En SQL con `ORDER BY`                         |
| **Paginación**    | Cortar array en frontend | `OFFSET/FETCH` en Oracle                      |
| **Cuándo usarlo** | < 100 registros          | > 100 registros o pantallas de administración |

### Qué devuelve el endpoint DataTable

```json
// GET /api/Unidades/datatable?primerregistro=0&numeroregistros=10&campofiltro=ALL&filtro=biblioteca
{
  "numeroRegistros": 250, // Total en BD (sin filtros)
  "numeroRegistrosFiltrados": 12, // Total con filtros aplicados
  "registros": [
    // Solo los 10 de esta página
    { "id": 1, "nombre": "Biblioteca General", "granularidad": 15 },
    { "id": 5, "nombre": "Biblioteca de Ciencias", "granularidad": 30 }
    // ... 8 más
  ]
}
```

::: tip TRES NÚMEROS CLAVE
El frontend necesita tres datos para pintar la paginación:

1. **`numeroRegistros`** — total sin filtrar (para "Mostrando X de Y")
2. **`numeroRegistrosFiltrados`** — total con filtro (para el número de páginas)
3. **`registros`** — la página actual de datos
   :::

## 4.2 ClaseCrudUtils: la base del patrón

`ClaseCrudUtils` es una clase base de la librería `PlantillaMVCCore.DataTable` que proporciona métodos para las tres consultas necesarias: contar totales, contar filtrados y obtener página.

### Herencia y contrato

```csharp
// El servicio hereda de ClaseCrudUtils e implementa `CrudAPIClaseInterface&lt;T&gt;`
public class ClaseUnidades : ClaseCrudUtils, IClaseUnidades, `CrudAPIClaseInterface&lt;ClaseUnidad&gt;`
{
    // ClaseCrudUtils proporciona:
    // - NumeroRegistrosTotales(vista)
    // - NumeroRegistrosFiltrados(vista, campofiltro, filtro, campoorden)
    // - `RegistrosFiltrados&lt;T&gt;`(vista, campos, campofiltro, filtro, campoorden, orden, limite, offset, ?, idioma)
    // - CamposFiltros (lista de campos permitidos)
    // - SQLWhereBase (condición base para todas las consultas)
}
```

::: warning IMPORTANTE
`CrudAPIClaseInterface&lt;T&gt;` exige implementar varios métodos (`Obtener`, `BuscarxId`, `Crear`, `Actualizar`, `Eliminar`, `ObtenerSimple`, `Inicializar`). Si no los necesitas todos, devuelve `throw new NotSupportedException()` en los que no apliquen. Solo `Obtener` es obligatorio para DataTable.
:::

### Arquitectura del servicio

```
┌──────────────────────┐     ┌───────────────────────┐     ┌──────────────┐
│  UnidadesController  │────▶│     ClaseUnidades      │────▶│    Oracle    │
│  (API endpoint)      │     │  : ClaseCrudUtils       │     │ VCTS_UNIDADES│
│                      │     │  + IClaseUnidades       │     │              │
│  GET /datatable      │     │  + CrudAPIClaseInterface│     │  SELECT con  │
│  parámetros query    │     │                         │     │  paginación  │
└──────────────────────┘     └───────────────────────┘     └──────────────┘
```

## 4.3 CamposFiltros: seguridad y mapeo camelCase → UPPERCASE

::: danger SEGURIDAD CRÍTICA
`CamposFiltros` es la **línea de defensa contra SQL injection** en DataTable. El frontend envía nombres de campos en camelCase (ej: `nombre`, `flgActiva`), y `CamposFiltros` los traduce a columnas Oracle válidas (ej: `NOMBRE_ES`, `FLG_ACTIVA`).

**Si un campo no está en `CamposFiltros`, se rechaza.** Esto impide que un atacante inyecte nombres de columna arbitrarios en la consulta SQL.
:::

### Implementación real del curso

```csharp
// Models/Unidad/ClaseUnidades.cs
private void ConfigurarCamposFiltros(string idiomaUpper)
{
    CamposFiltros.Clear();                                        // [!code highlight]

    // Cada entrada mapea: frontend (camelCase) → Oracle (MAYÚSCULAS)
    CamposFiltros.Add(new ClaseCrudUtilsCampos {
        NombreIni = "id",                                         // [!code highlight]
        NombreFinal = "ID",                                       // [!code highlight]
        Tipo = "number"
    });
    CamposFiltros.Add(new ClaseCrudUtilsCampos {
        NombreIni = "nombre",
        NombreFinal = $"NOMBRE_{idiomaUpper}"                     // [!code highlight]
    });
    CamposFiltros.Add(new ClaseCrudUtilsCampos {
        NombreIni = "flgActiva",
        NombreFinal = "FLG_ACTIVA",
        Tipo = "boolean"
    });
    CamposFiltros.Add(new ClaseCrudUtilsCampos {
        NombreIni = "granularidad",
        NombreFinal = "GRANULARIDAD",
        Tipo = "number"
    });
    CamposFiltros.Add(new ClaseCrudUtilsCampos {
        NombreIni = "duracionMax",
        NombreFinal = "DURACION_MAX"
    });
    CamposFiltros.Add(new ClaseCrudUtilsCampos {
        NombreIni = "flgRequiereConfirmacion",
        NombreFinal = "FLG_REQUIERE_CONFIRMACION",
        Tipo = "boolean"
    });
    CamposFiltros.Add(new ClaseCrudUtilsCampos {
        NombreIni = "numCitasSimultaneas",
        NombreFinal = "NUM_CITAS_SIMULTANEAS",
        Tipo = "number"
    });

    // Campo especial ALL: búsqueda general en múltiples columnas
    CamposFiltros.Add(new ClaseCrudUtilsCampos {                  // [!code highlight]
        NombreIni = "ALL",                                        // [!code highlight]
        NombreFinal = $"ID|NOMBRE_{idiomaUpper}|DURACION_MAX"     // [!code highlight]
    });
}
```

### Anatomía de `ClaseCrudUtilsCampos`

| Propiedad        | Descripción                              | Ejemplo                                       |
| ---------------- | ---------------------------------------- | --------------------------------------------- |
| `NombreIni`      | Nombre que envía el frontend (camelCase) | `"nombre"`, `"flgActiva"`                     |
| `NombreFinal`    | Columna Oracle real (MAYÚSCULAS)         | `"NOMBRE_ES"`, `"FLG_ACTIVA"`                 |
| `Tipo`           | Tipo de dato para filtro correcto        | `"number"`, `"boolean"`, `"string"` (default) |
| `PermitirFiltro` | Si se permite filtrar por este campo     | `true` (default)                              |

### El campo especial `ALL`

Cuando el frontend envía `campofiltro=ALL`, ClaseCrudUtils busca en **todas las columnas** separadas por `|` en `NombreFinal`:

```
"ALL" → "ID|NOMBRE_ES|DURACION_MAX"
```

Esto genera un `WHERE` con `OR`:

```sql
WHERE (ID LIKE '%biblioteca%' OR NOMBRE_ES LIKE '%biblioteca%' OR DURACION_MAX LIKE '%biblioteca%')
```

### Multiidioma en CamposFiltros

Fíjate en que `nombre` se mapea a `NOMBRE_{idiomaUpper}`. Cuando el usuario cambia el idioma, se reconfigura el mapeo:

```csharp
public void SetIdioma(string idioma)
{
    _idioma = string.IsNullOrWhiteSpace(idioma) ? "ES" : idioma.Trim().ToUpperInvariant();
    ConfigurarCamposFiltros(_idioma);                            // [!code highlight]
}
```

Así, si el usuario está en catalán (`CA`), filtrar por `nombre` busca en `NOMBRE_CA`, no en `NOMBRE_ES`.

## 4.4 SQLWhereBase y TransformarCampoOrden

### SQLWhereBase: filtro base permanente

`SQLWhereBase` aplica una condición a **todas** las consultas del DataTable (totales, filtrados y registros). Se define en el constructor:

```csharp
public ClaseUnidades(ClaseOracleBd claseoraclebd, `ILogger&lt;ClaseUnidades&gt;` logger)
    : base(claseoraclebd)
{
    bd = claseoraclebd;
    _logger = logger;

    SQLWhereBase = "FLG_ACTIVA = 'S'";                           // [!code highlight]
    ConfigurarCamposFiltros(_idioma);
}
```

::: tip USOS HABITUALES DE SQLWhereBase

- `"FLG_ACTIVA = 'S'"` — solo registros activos
- `"TIPO = 'PUBLICO'"` — solo registros de un tipo
- `"FLG_ELIMINADO = 'N'"` — excluir eliminados lógicos
  :::

### TransformarCampoOrden: camelCase → Oracle

El frontend envía el campo de ordenación en camelCase (`nombre`, `granularidad`). Necesitamos traducirlo a la columna Oracle real:

```csharp
private string TransformarCampoOrden(string campoorden)
{
    if (string.IsNullOrWhiteSpace(campoorden))
        return "ID";                                             // [!code highlight]

    var campo = CamposFiltros.FirstOrDefault(x =>
        string.Equals(x.NombreIni, campoorden, StringComparison.OrdinalIgnoreCase));

    if (campo == null || string.IsNullOrWhiteSpace(campo.NombreFinal))
        return "ID";                                             // [!code highlight]

    var campoFinal = campo.NombreFinal;
    // Si es un campo ALL con pipes, tomar el primero
    return campoFinal.Contains('|') ? campoFinal.Split('|')[0] : campoFinal;
}
```

::: warning SIEMPRE un campo por defecto
Si el frontend no envía `campoorden` o envía uno inválido, devolvemos `"ID"` como campo por defecto. **Nunca construyas un ORDER BY vacío**: Oracle lanzará error.
:::

## 4.5 El método Obtener: las tres consultas

El método `Obtener` es el corazón del DataTable. Ejecuta tres consultas Oracle en secuencia:

```csharp
// Models/Unidad/ClaseUnidades.cs
public ClaseDataTable Obtener(
    int primerregistro = 0,
    int numeroregistros = 50,
    string campoorden = "",
    string orden = "ASC",
    string? filtro = "",
    string? campofiltro = "ALL",
    bool? cargardatosadicionales = false)
{
    var salida = new ClaseDataTable();
    var campoOrdenReal = TransformarCampoOrden(campoorden);      // [!code highlight]

    // PASO 1: Total de registros (sin filtros, con SQLWhereBase)
    salida.NumeroRegistros = NumeroRegistrosTotales(              // [!code highlight]
        VistaUnidades);

    if (salida.NumeroRegistros > 0)
    {
        // PASO 2: Total de registros filtrados
        salida.NumeroRegistrosFiltrados = NumeroRegistrosFiltrados(// [!code highlight]
            VistaUnidades,
            campofiltro ?? "ALL",
            filtro ?? "",
            campoOrdenReal);

        // PASO 3: Registros paginados, filtrados y ordenados
        salida.Registros = `RegistrosFiltrados&lt;ClaseUnidad&gt;`(       // [!code highlight]
            VistaUnidades,       // Vista Oracle
            CamposVistaUnidades, // Campos SELECT (no usar *)
            campofiltro ?? "ALL",// Campo de filtro
            filtro ?? "",        // Texto del filtro
            campoOrdenReal,      // Campo de ordenación (ya traducido)
            orden,               // ASC o DESC
            numeroregistros,     // Límite (registros por página)
            primerregistro,      // Offset (desde qué registro)
            null,                // Datos adicionales (no usado aquí)
            _idioma);            // Idioma para mapeo multiidioma
    }
    else
    {
        salida.NumeroRegistrosFiltrados = 0;
        salida.Registros = new List<ClaseUnidad>();
    }

    return salida;
}
```

### Las tres consultas que genera internamente

| Paso | Método `ClaseCrudUtils`       | SQL generado (simplificado)                                                                                                                                      |
| ---- | ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `NumeroRegistrosTotales`      | `SELECT COUNT(*) FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'`                                                                                                      |
| 2    | `NumeroRegistrosFiltrados`    | `SELECT COUNT(*) FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S' AND NOMBRE_ES LIKE '%biblio%'`                                                                        |
| 3    | `RegistrosFiltrados&lt;T&gt;` | `SELECT ID, NOMBRE_ES, ... FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S' AND NOMBRE_ES LIKE '%biblio%' ORDER BY NOMBRE_ES ASC OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY` |

::: info NOTA SOBRE RENDIMIENTO
Las tres consultas se ejecutan secuencialmente en la misma conexión Oracle. `SQLWhereBase` se aplica automáticamente a las tres. Si no hay registros en el paso 1, nos ahorramos los pasos 2 y 3.
:::

### Constantes de la vista

```csharp
private const string VistaUnidades = "VCTS_UNIDADES";
private const string CamposVistaUnidades =
    "ID, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN, FLG_ACTIVA, GRANULARIDAD, " +
    "DURACION_MAX, FLG_REQUIERE_CONFIRMACION, NUM_CITAS_SIMULTANEAS";
```

::: danger NUNCA USAR `SELECT *`
En `RegistrosFiltrados&lt;T&gt;` debemos listar explícitamente los campos, no usar `*`. Razones:

- Seguridad: no exponer columnas internas (fechas de auditoría, usuarios de sistema)
- Rendimiento: solo traer lo necesario
- Estabilidad: si alguien añade una columna a la vista, no rompe el mapeo
  :::

## 4.6 Servicio completo con DataTable + CRUD

El servicio `ClaseUnidades` combina dos patrones:

1. **DataTable** (heredando de `ClaseCrudUtils`) para listados paginados
2. **CRUD con Result&lt;T&gt;** (de la sesión 2) para operaciones individuales

```csharp [Constructor y configuración]
// Models/Unidad/ClaseUnidades.cs
public class ClaseUnidades : ClaseCrudUtils, IClaseUnidades,
    CrudAPIClaseInterface<ClaseUnidad>
{
    private readonly ClaseOracleBd bd;
    private readonly ILogger<ClaseUnidades> _logger;
    private string _idioma = "ES";

    private const string VistaUnidades = "VCTS_UNIDADES";
    public ClaseUnidades(ClaseOracleBd claseoraclebd,
        ILogger<ClaseUnidades> logger) : base(claseoraclebd)
    {
        bd = claseoraclebd;
        _logger = logger;
        SQLWhereBase = "FLG_ACTIVA = 'S'";
        ConfigurarCamposFiltros(_idioma);
    }

    public void SetIdioma(string idioma)
    {
        _idioma = string.IsNullOrWhiteSpace(idioma)
            ? "ES"
            : idioma.Trim().ToUpperInvariant();
        ConfigurarCamposFiltros(_idioma);
    }
}
```

```csharp [Métodos DataTable]
// Método principal: DataTable con paginación
public ClaseDataTable Obtener(
    int primerregistro = 0, int numeroregistros = 50,
    string campoorden = "", string orden = "ASC",
    string? filtro = "", string? campofiltro = "ALL",
    bool? cargardatosadicionales = false)
{
    var salida = new ClaseDataTable();
    var campoOrdenReal = TransformarCampoOrden(campoorden);

    salida.NumeroRegistros = NumeroRegistrosTotales(VistaUnidades);

    if (salida.NumeroRegistros > 0)
    {
        salida.NumeroRegistrosFiltrados = NumeroRegistrosFiltrados(
            VistaUnidades, campofiltro ?? "ALL",
            filtro ?? "", campoOrdenReal);

        salida.Registros = RegistrosFiltrados<ClaseUnidad>(
            VistaUnidades, CamposVistaUnidades,
            campofiltro ?? "ALL", filtro ?? "",
            campoOrdenReal, orden, numeroregistros,
            primerregistro, null, _idioma);
    }
    else
    {
        salida.NumeroRegistrosFiltrados = 0;
        salida.Registros = new List<ClaseUnidad>();
    }

    return salida;
}

// Versión simple sin metadatos de paginación
public List<ClaseUnidad> ObtenerSimple(
    int primerregistro = 0, int numeroregistros = 50,
    string campoorden = "", string orden = "ASC",
    string? filtro = "", string? campofiltro = "ALL")
{
    var campoOrdenReal = TransformarCampoOrden(campoorden);
    return RegistrosFiltrados<ClaseUnidad>(
        VistaUnidades, CamposVistaUnidades,
        campofiltro ?? "ALL", filtro ?? "",
        campoOrdenReal, orden, numeroregistros,
        primerregistro, null, _idioma);
}
```

```csharp [Métodos CRUD con Result<T>]
// Métodos CRUD ya conocidos de la sesión 2
public Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES")
{
    const string sql = "SELECT * FROM VCTS_UNIDADES WHERE FLG_ACTIVA = 'S'";
    var unidades = bd.ObtenerTodosMap<ClaseUnidad>(
        sql, param: null, idioma: idioma)?.ToList()
        ?? new List<ClaseUnidad>();
    return Result<List<ClaseUnidad>>.Success(unidades);
}

public Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES")
{
    const string sql = "SELECT * FROM VCTS_UNIDADES WHERE ID = :id";
    var unidad = bd.ObtenerPrimeroMap<ClaseUnidad>(
        sql, new { id }, idioma: idioma);
    // Si no existe, devolvemos objeto vacío con Id=0
    return Result<ClaseUnidad>.Success(unidad ?? new ClaseUnidad { Id = 0 });
}

public Result<int> Guardar(ClaseGuardarUnidad dto) { /* sesión 2 */ }
public Result<bool> Eliminar(int id, int codPer, string ip) { /* sesión 2 */ }
```

```csharp [Métodos de interfaz no implementados]
// CrudAPIClaseInterface exige estos métodos.
// Los que no usamos lanzan NotSupportedException.

public ClaseUnidad Inicializar() => new();

public ClaseUnidad? BuscarxId(object id)
{
    if (!int.TryParse(id?.ToString(), out var idUnidad))
        return null;
    const string sql = "SELECT * FROM VCTS_UNIDADES WHERE ID = :id";
    return bd.ObtenerPrimeroMap<ClaseUnidad>(sql,
        new { id = idUnidad }, idioma: _idioma);
}

// Estos métodos redirigen a los métodos tipados (con Result<T>)
public object Crear(ClaseUnidad item)
    => throw new NotSupportedException(
        "Para alta usar Guardar(ClaseGuardarUnidad dto).");
public void Actualizar(object id, ClaseUnidad item)
    => throw new NotSupportedException(
        "Para edición usar Guardar(ClaseGuardarUnidad dto).");
public void Eliminar(object id)
    => throw new NotSupportedException(
        "Para eliminación usar Eliminar(int id, int codPer, string ip).");
```

### Interfaz del servicio

```csharp
// Models/Unidad/IClaseUnidades.cs
public interface IClaseUnidades
{
    // DataTable
    void SetIdioma(string idioma);
    ClaseDataTable Obtener(int primerregistro = 0, int numeroregistros = 50,
        string campoorden = "", string orden = "ASC",
        string? filtro = "", string? campofiltro = "ALL",
        bool? cargardatosadicionales = false);
    List<ClaseUnidad> ObtenerSimple(int primerregistro = 0,
        int numeroregistros = 50, string campoorden = "",
        string orden = "ASC", string? filtro = "",
        string? campofiltro = "ALL");

    // CRUD con Result<T>
    Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES");
    Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES");
    Result<int> Guardar(ClaseGuardarUnidad dto);
    Result<bool> Eliminar(int id, int codPer, string ip);
}
```

## 4.7 Endpoint API para DataTable

El controlador expone un endpoint `datatable` **separado** del CRUD básico:

```csharp
// Controllers/Apis/UnidadesController.cs
[Route("api/[controller]")]
[ApiController]
public class UnidadesController : ApiControllerBase
{
    private readonly IClaseUnidades _unidades;

    public UnidadesController(IClaseUnidades unidades)
        => _unidades = unidades;

    // CRUD básico (sesión 2)
    [HttpGet]
    public ActionResult Listar([FromQuery] string idioma = "ES")
        => HandleResult(_unidades.ObtenerActivas(idioma));

    [HttpGet("{id}")]
    public ActionResult ObtenerPorId(int id, [FromQuery] string idioma = "ES")
        => HandleResult(_unidades.ObtenerPorId(id, idioma));

    // DataTable server-side — endpoint separado                  // [!code highlight]
    [HttpGet("datatable")]                                        // [!code highlight]
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
        _unidades.SetIdioma(idioma);                              // [!code highlight]
        var salida = _unidades.Obtener(
            primerregistro, numeroregistros, campoorden,
            orden, filtro, campofiltro, cargardatosadicionales);
        return Ok(salida);
    }

    [HttpPost]
    public ActionResult Guardar([FromBody] ClaseGuardarUnidad dto)
    {
        dto.CodPer = 0; // En producción: del usuario autenticado
        dto.Ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
        return HandleResult(_unidades.Guardar(dto));
    }

    [HttpDelete("{id}")]
    public ActionResult Eliminar(int id)
    {
        var codPer = 0;
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
        return HandleResult(_unidades.Eliminar(id, codPer, ip));
    }
}
```

### Parámetros del endpoint DataTable

| Parámetro                | Tipo    | Default | Descripción                                  |
| ------------------------ | ------- | ------- | -------------------------------------------- |
| `primerregistro`         | int     | 0       | Offset (desde qué registro empezar)          |
| `numeroregistros`        | int     | 50      | Límite (registros por página)                |
| `campoorden`             | string  | ""      | Campo para ORDER BY (camelCase del frontend) |
| `orden`                  | string  | "ASC"   | Dirección: `ASC` o `DESC`                    |
| `filtro`                 | string? | ""      | Texto de búsqueda                            |
| `campofiltro`            | string? | "ALL"   | En qué campo buscar (`ALL` = todos)          |
| `cargardatosadicionales` | bool?   | false   | Cargar datos para combos/selects             |
| `idioma`                 | string  | "ES"    | Idioma para multiidioma                      |

::: warning ¿POR QUÉ ENDPOINT SEPARADO?
No mezclamos DataTable con el CRUD básico porque:

- **Firma diferente**: DataTable devuelve `ClaseDataTable` (con metadatos), el CRUD devuelve `Result&lt;T&gt;`
- **Responsabilidad diferente**: DataTable es para listados paginados, CRUD es para operaciones individuales
- **El GET básico** (`/api/unidades`) devuelve todas las activas — útil para combos/selects
- **El GET datatable** (`/api/unidades/datatable`) devuelve paginado — para tablas grandes
  :::

## 4.8 Integración en Vue

### Interfaces TypeScript

```typescript
// En el componente Vue (o en un archivo interfaces/Unidad.ts)
interface Unidad {
  id: number;
  nombre: string; // Viene de NOMBRE_ES/CA/EN (multiidioma)
  flgActiva: boolean;
  granularidad: number;
  duracionMax: string;
  flgRequiereConfirmacion: boolean;
  numCitasSimultaneas: number;
}

interface DataTableResponse {
  numeroRegistros: number; // Total sin filtrar
  numeroRegistrosFiltrados: number; // Total filtrado
  registros: Unidad[]; // Página actual
}
```

### Llamada al endpoint DataTable

```typescript
import {
  llamadaAxios,
  verbosAxios,
  gestionarError,
} from "vueua-useaxios/services/useAxios";

const dataTable = ref<DataTableResponse | null>(null);
const primerRegistro = ref(0);
const numeroRegistros = ref(10);

const cargarDataTable = () => {
  llamadaAxios(
    `Unidades/datatable?primerregistro=${primerRegistro.value}` +
      `&numeroregistros=${numeroRegistros.value}` +
      `&campofiltro=ALL&idioma=ES`,
    verbosAxios.GET,
  )
    .then(({ data }) => {
      dataTable.value = data.value as DataTableResponse;
    })
    .catch((error) => {
      gestionarError(error, t("Unidades.error-cargar"), "DataTable");
    });
};
```

### Vista con tabla y metadatos de paginación

```html
<!-- Vista con tabla y metadatos de paginación -->
<template>
  <!-- Botón para cargar -->
  <button class="btn btn-outline-primary" @click="cargarDataTable">
    Cargar DataTable
  </button>

  <!-- Tabla con resultados -->
  <div class="card mt-4" v-if="dataTable">
    <div class="card-header">DataTable server-side</div>
    <div class="card-body">
      <p class="mb-2">
        Total: {{ dataTable.numeroRegistros }} | Filtrados: {{
        dataTable.numeroRegistrosFiltrados }}
      </p>

      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>ID</th>
            <th>{{ t("Unidades.nombre") }}</th>
            <th>{{ t("Unidades.granularidad") }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="u in dataTable.registros" :key="`dt-${u.id}`">
            <td>{{ u.id }}</td>
            <td>{{ u.nombre }}</td>
            <td>{{ u.granularidad }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
```

### Gestión de errores en el frontend

```typescript
// En la función guardar — manejo de errores de validación por campo
const guardar = () => {
  errores.value = null;

  llamadaAxios("Unidades", verbosAxios.POST, formulario)
    .then(({ data }) => {
      avisar(
        t("Unidades.guardada"),
        `${t("Unidades.guardada-detalle")} ${data.value}`,
      );
      cargarUnidades();
    })
    .catch((error) => {
      if (error.response?.status === 400 && error.response?.data?.errors) {
        // Errores de validación — pintar por campo            // [!code highlight]
        errores.value = error.response.data.errors; // [!code highlight]
      } else {
        gestionarError(error, t("Unidades.error-guardar"), "guardar");
      }
    });
};
```

```vue
<!-- Pintar error de validación junto al campo -->
<input
  v-model="formulario.nombreEs"
  type="text"
  class="form-control"
  :class="{ 'is-invalid': errores?.NombreEs }"
/>
<div class="invalid-feedback" v-if="errores?.NombreEs">
  {{ errores.NombreEs.join(", ") }}
</div>
```

::: tip PATRÓN DE ERRORES POR CAMPO
Los errores de `ValidationProblemDetails` vienen como `{ errors: { "NombreEs": ["Mensaje 1"], "Granularidad": ["Mensaje 2"] } }`. El frontend los almacena en un `Record&lt;string, string[]&gt;` y los pinta junto a cada campo con la clase `is-invalid` de Bootstrap.
:::

## 4.9 Componente DataTable UA (vueua-datatable)

En aplicaciones reales UA se usa el componente `DataTableComponente` del paquete `vueua-datatable`, que gestiona automáticamente paginación, filtros y ordenación:

```vue
<script setup lang="ts">
import DataTableComponente from "vueua-datatable/components/DataTable.vue";
import { Datatable } from "vueua-datatable/interfaces/datatable";

const dtUnidades = `ref&lt;Datatable&gt;`({
  campos: [
    {
      nombre: "id", // Nombre del campo (camelCase)
      descripcion: t("Unidades.id"), // Texto cabecera
      tipo: "number",
      ancho: "10%",
      ordenable: true,
      filtrable: true,
      movil: true, // Visible en móvil
    },
    {
      nombre: "nombre",
      descripcion: t("Unidades.nombre"),
      tipo: "string",
      ancho: "40%",
      ordenable: true,
      filtrable: true,
      movil: true,
    },
    {
      nombre: "granularidad",
      descripcion: t("Unidades.granularidad"),
      tipo: "number",
      ancho: "15%",
      ordenable: true,
      filtrable: true,
      movil: false,
    },
  ],
  key: "id", // Campo clave (PK)
  url: "Unidades/datatable", // URL SIN /api/
  campoprincipal: "nombre", // Columna con menú acciones
  accesibilidad: {
    descripcion: t("Unidades.tabla-descripcion"),
  },
  filtrosDatatable: {
    filtroGeneral: true, // Búsqueda general (ALL)
    filtrosCampos: true, // Filtros individuales
  },
});
</script>

<template>
  <DataTableComponente
    ref="dataTableRef"
    id="dataTableUnidades"
    :datatable="dtUnidades"
    :botonescrud="{ ver: false, editar: true, borrar: false }"
    @editar="editar"
  >
  </DataTableComponente>
</template>
```

::: info COMPONENTE UA vs IMPLEMENTACIÓN MANUAL
En el curso usamos una **implementación manual** (tabla HTML + llamadaAxios) para entender cómo funciona por dentro. En producción, usarás el componente `DataTableComponente` que gestiona todo automáticamente. La clave es que **ambos consumen el mismo endpoint** (`GET /api/Unidades/datatable`) con los mismos parámetros.
:::

## 4.10 Tests del DataTable

### Test del controlador con FakeService

```csharp
// CursoTest/Controllers/UnidadesControllerTests.cs
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

    var result = controller.DataTable(idioma: "CA");             // [!code highlight]

    var ok = Assert.IsType<OkObjectResult>(result.Result);
    _ = Assert.IsType<ClaseDataTable>(ok.Value);
    Assert.Equal("CA", service.UltimoIdioma);                    // [!code highlight]
}
```

### FakeService para tests

```csharp
private sealed class FakeUnidadesService : IClaseUnidades
{
    public string UltimoIdioma { get; private set; } = "ES";
    public ClaseDataTable ObtenerDataTableResult { get; set; } = new();

    // Métodos DataTable
    public void SetIdioma(string idioma) => UltimoIdioma = idioma;
    public ClaseDataTable Obtener(int primerregistro = 0,
        int numeroregistros = 50, string campoorden = "",
        string orden = "ASC", string? filtro = "",
        string? campofiltro = "ALL",
        bool? cargardatosadicionales = false)
        => ObtenerDataTableResult;

    // Métodos CRUD
    public Result<List<ClaseUnidad>> ObtenerActivas(string idioma = "ES")
        => ObtenerActivasResult;
    public Result<ClaseUnidad> ObtenerPorId(int id, string idioma = "ES")
        => ObtenerPorIdResult;
    // ... etc
}
```

::: tip PATRÓN DE TEST
El `FakeService` implementa `IClaseUnidades` con propiedades configurables. En cada test, asignamos el resultado esperado y verificamos que el controlador:

1. Pasa el idioma correcto al servicio (`SetIdioma`)
2. Devuelve 200 con `ClaseDataTable` para respuestas exitosas
3. No mezcla la lógica de `HandleResult` (que es para `Result<T>`)
   :::

## 4.11 Práctica guiada: Rojo-Verde-Refactor

### Paso 1: ROJO — DataTable sin validar campos

```csharp
// ⚠️ Versión ROJA — sin seguridad ni validación
public ClaseDataTable Obtener(int primerregistro, int numeroregistros,
    string campoorden, string orden)
{
    var salida = new ClaseDataTable();
    // 🐛 Usa tabla directa en vez de vista
    salida.NumeroRegistros = NumeroRegistrosTotales("TCTS_UNIDADES");
    // 🐛 Usa SELECT *, no transforma campoorden, no filtra
    salida.Registros = RegistrosFiltrados<ClaseUnidad>(
        "VCTS_UNIDADES", "*", "ALL", "",
        campoorden, orden, numeroregistros, primerregistro);
    // 🐛 Falta NumeroRegistrosFiltrados
    return salida;
}
```

::: danger ESTO ES ROJO

1. Usa tabla directa para contar → el usuario web no tiene permiso SELECT en tablas
2. Usa `*` → expone columnas internas
3. No transforma `campoorden` → el frontend envía camelCase, Oracle espera MAYÚSCULAS
4. Falta `NumeroRegistrosFiltrados` → el frontend no puede calcular páginas
   :::

### Paso 2: VERDE — Con las tres consultas y seguridad

```csharp
// ✅ Versión VERDE — con las tres consultas
public ClaseDataTable Obtener(int primerregistro = 0,
    int numeroregistros = 50, string campoorden = "",
    string orden = "ASC", string? filtro = "",
    string? campofiltro = "ALL",
    bool? cargardatosadicionales = false)
{
    var salida = new ClaseDataTable();
    var campoOrdenReal = TransformarCampoOrden(campoorden);      // [!code highlight]

    salida.NumeroRegistros = NumeroRegistrosTotales(VistaUnidades);

    if (salida.NumeroRegistros > 0)
    {
        salida.NumeroRegistrosFiltrados = NumeroRegistrosFiltrados(// [!code highlight]
            VistaUnidades, campofiltro ?? "ALL",
            filtro ?? "", campoOrdenReal);

        salida.Registros = RegistrosFiltrados<ClaseUnidad>(
            VistaUnidades,
            CamposVistaUnidades,                                 // [!code highlight]
            campofiltro ?? "ALL", filtro ?? "",
            campoOrdenReal, orden, numeroregistros,
            primerregistro, null, _idioma);
    }
    else
    {
        salida.NumeroRegistrosFiltrados = 0;
        salida.Registros = new List<ClaseUnidad>();
    }

    return salida;
}
```

### Paso 3: REFACTOR — Datos adicionales y ObtenerSimple

```csharp
// 🔄 Versión REFACTOR — añade DatosAdicionales para combos
if (cargardatosadicionales == true)
{
    salida.DatosAdicionales = ObtenerDatosAdicionales();
}

private Dictionary<string, List<ClaseDatosAdicionalesDataTable>>
    ObtenerDatosAdicionales()
{
    var salida = new Dictionary<string, List<ClaseDatosAdicionalesDataTable>>();
    // Ejemplo: cargar lista de tipos para un select
    salida["tipos"] = new List<ClaseDatosAdicionalesDataTable>
    {
        new() { Id = "1", Texto = "Tipo A" },
        new() { Id = "2", Texto = "Tipo B" }
    };
    return salida;
}
```

## Preguntas de repaso

### Pregunta 1

**¿Cuál es el propósito principal de `CamposFiltros` en `ClaseCrudUtils`?**

a) Definir las columnas que se muestran en la tabla HTML
b) Mapear campos frontend (camelCase) a columnas Oracle (MAYÚSCULAS) y prevenir SQL injection
c) Configurar las validaciones de cada campo
d) Establecer los valores por defecto de cada columna

::: details Respuesta
**b)** `CamposFiltros` es la línea de defensa contra SQL injection. Mapea nombres camelCase del frontend a columnas Oracle reales, y rechaza cualquier campo que no esté en la lista. Sin este mapeo, un atacante podría inyectar nombres de columna arbitrarios.
:::

### Pregunta 2

**¿Qué tres valores devuelve `ClaseDataTable` y para qué los usa el frontend?**

a) `Total`, `Paginas`, `Datos` — para renderizar la tabla
b) `NumeroRegistros`, `NumeroRegistrosFiltrados`, `Registros` — para paginación y tabla
c) `Count`, `FilteredCount`, `Items` — para la API REST
d) `PageSize`, `PageNumber`, `Records` — para el componente DataTable

::: details Respuesta
**b)** `NumeroRegistros` es el total sin filtrar (para "Mostrando X de Y"), `NumeroRegistrosFiltrados` es el total con filtros aplicados (para calcular número de páginas), y `Registros` contiene solo los datos de la página actual.
:::

### Pregunta 3

**¿Por qué el endpoint DataTable es `GET /api/unidades/datatable` y no se mezcla con `GET /api/unidades`?**

a) Porque .NET no permite dos métodos GET en el mismo controlador
b) Porque DataTable devuelve `ClaseDataTable` con metadatos, mientras que el GET básico devuelve `Result&lt;List&lt;T&gt;&gt;` para combos/selects
c) Porque DataTable requiere autenticación y el GET básico no
d) Porque son dos servicios diferentes con inyección de dependencias separada

::: details Respuesta
**b)** Tienen responsabilidades diferentes: el GET básico (`/api/unidades`) devuelve todas las unidades activas envueltas en `Result&lt;T&gt;`, útil para combos y selects. El DataTable (`/api/unidades/datatable`) devuelve `ClaseDataTable` con `NumeroRegistros`, `NumeroRegistrosFiltrados` y la página actual de `Registros`.
:::

### Pregunta 4

**¿Qué hace `SQLWhereBase = "FLG_ACTIVA = 'S'"` en el constructor?**

a) Filtra solo al ejecutar `NumeroRegistrosTotales`
b) Aplica una condición permanente a las tres consultas del DataTable (totales, filtrados y registros)
c) Reemplaza el WHERE que envía el frontend
d) Solo afecta a la ordenación

::: details Respuesta
**b)** `SQLWhereBase` se añade como condición base a **todas** las consultas que genera `ClaseCrudUtils`: `NumeroRegistrosTotales`, `NumeroRegistrosFiltrados` y `RegistrosFiltrados`. Es útil para filtros permanentes como "solo activos" o "solo públicos".
:::

### Pregunta 5

**¿Por qué no debemos usar `SELECT *` en `RegistrosFiltrados&lt;T&gt;`?**

a) Porque Oracle no soporta `*` en subconsultas
b) Porque `ClaseCrudUtils` requiere la lista explícita
c) Por seguridad (no exponer columnas internas), rendimiento (solo traer lo necesario) y estabilidad (no romper si cambia la vista)
d) Porque el mapeo automático no funciona con `*`

::: details Respuesta
**c)** Listar explícitamente los campos evita exponer columnas de auditoría o sistema, mejora el rendimiento al traer solo lo necesario, y mantiene la estabilidad si alguien añade columnas a la vista Oracle.
:::

### Pregunta 6

**¿Qué ocurre si el frontend envía `campofiltro=email` pero `email` no está en `CamposFiltros`?**

a) Oracle busca en la columna EMAIL automáticamente
b) `ClaseCrudUtils` ignora el filtro y devuelve todos los registros
c) `VerificarFiltros()` rechaza el campo y lanza error
d) Se aplica un filtro LIKE genérico

::: details Respuesta
**c)** Si el campo no está en `CamposFiltros`, `VerificarFiltros()` lo rechaza. Esto es una protección de seguridad contra SQL injection: solo se permiten filtros en campos explícitamente definidos.
:::

### Pregunta 7

**¿Qué pasa cuando el campo especial `ALL` tiene `NombreFinal = "ID|NOMBRE_ES|DURACION_MAX"` y el usuario busca "biblioteca"?**

a) Busca solo en la primera columna (ID)
b) Genera un WHERE con OR: `(ID LIKE '%biblioteca%' OR NOMBRE_ES LIKE '%biblioteca%' OR DURACION_MAX LIKE '%biblioteca%')`
c) Busca la columna ALL en Oracle
d) Concatena todas las columnas y busca en el resultado

::: details Respuesta
**b)** El campo `ALL` genera una búsqueda con `OR` en todas las columnas separadas por `|`. Esto permite que la búsqueda general del frontend busque en múltiples columnas simultáneamente.
:::

### Pregunta 8

**¿Por qué `SetIdioma` reconfigura `CamposFiltros` cada vez que cambia el idioma?**

a) Para recargar los datos de la base de datos
b) Porque el campo `nombre` se mapea a `NOMBRE_{idioma}` y debe apuntar a la columna correcta según el idioma activo
c) Para limpiar la caché de resultados
d) Porque `SQLWhereBase` depende del idioma

::: details Respuesta
**b)** Cuando el usuario cambia a catalán (`CA`), el campo `nombre` debe buscar en `NOMBRE_CA`, no en `NOMBRE_ES`. Por eso `SetIdioma` llama a `ConfigurarCamposFiltros` con el nuevo idioma, actualizando el mapeo.
:::

## Ejercicio Sesión 4

**Objetivo:** Implementar un DataTable server-side completo para la entidad Unidades, con filtrado, paginación, ordenación y multiidioma.

1. En `ClaseUnidades.cs`, configurar `CamposFiltros` con al menos 5 campos mapeados y el campo `ALL`
2. Implementar `Obtener` con las tres consultas (`NumeroRegistrosTotales`, `NumeroRegistrosFiltrados`, `RegistrosFiltrados`)
3. Implementar `TransformarCampoOrden` que traduzca camelCase → columna Oracle
4. Aplicar `SQLWhereBase = "FLG_ACTIVA = 'S'"` en el constructor
5. En `UnidadesController`, crear endpoint `GET /api/unidades/datatable` con todos los parámetros
6. En Vue, crear tabla que consuma el endpoint y muestre `NumeroRegistros`, `NumeroRegistrosFiltrados` y los registros

::: details Solución

**Servicio (`Models/Unidad/ClaseUnidades.cs`):**

```csharp
public class ClaseUnidades : ClaseCrudUtils, IClaseUnidades,
    CrudAPIClaseInterface<ClaseUnidad>
{
    private readonly ClaseOracleBd bd;
    private readonly ILogger<ClaseUnidades> _logger;
    private string _idioma = "ES";

    private const string VistaUnidades = "VCTS_UNIDADES";
    private const string CamposVistaUnidades =
        "ID, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN, FLG_ACTIVA, GRANULARIDAD, " +
        "DURACION_MAX, FLG_REQUIERE_CONFIRMACION, NUM_CITAS_SIMULTANEAS";

    public ClaseUnidades(ClaseOracleBd claseoraclebd,
        ILogger<ClaseUnidades> logger) : base(claseoraclebd)
    {
        bd = claseoraclebd;
        _logger = logger;
        SQLWhereBase = "FLG_ACTIVA = 'S'";
        ConfigurarCamposFiltros(_idioma);
    }

    public void SetIdioma(string idioma)
    {
        _idioma = string.IsNullOrWhiteSpace(idioma)
            ? "ES" : idioma.Trim().ToUpperInvariant();
        ConfigurarCamposFiltros(_idioma);
    }

    public ClaseDataTable Obtener(int primerregistro = 0,
        int numeroregistros = 50, string campoorden = "",
        string orden = "ASC", string? filtro = "",
        string? campofiltro = "ALL",
        bool? cargardatosadicionales = false)
    {
        var salida = new ClaseDataTable();
        var campoOrdenReal = TransformarCampoOrden(campoorden);

        salida.NumeroRegistros = NumeroRegistrosTotales(VistaUnidades);
        if (salida.NumeroRegistros > 0)
        {
            salida.NumeroRegistrosFiltrados = NumeroRegistrosFiltrados(
                VistaUnidades, campofiltro ?? "ALL",
                filtro ?? "", campoOrdenReal);
            salida.Registros = RegistrosFiltrados<ClaseUnidad>(
                VistaUnidades, CamposVistaUnidades,
                campofiltro ?? "ALL", filtro ?? "",
                campoOrdenReal, orden, numeroregistros,
                primerregistro, null, _idioma);
        }
        else
        {
            salida.NumeroRegistrosFiltrados = 0;
            salida.Registros = new List<ClaseUnidad>();
        }
        return salida;
    }

    private void ConfigurarCamposFiltros(string idiomaUpper)
    {
        CamposFiltros.Clear();
        CamposFiltros.Add(new ClaseCrudUtilsCampos
            { NombreIni = "id", NombreFinal = "ID", Tipo = "number" });
        CamposFiltros.Add(new ClaseCrudUtilsCampos
            { NombreIni = "nombre", NombreFinal = $"NOMBRE_{idiomaUpper}" });
        CamposFiltros.Add(new ClaseCrudUtilsCampos
            { NombreIni = "flgActiva", NombreFinal = "FLG_ACTIVA", Tipo = "boolean" });
        CamposFiltros.Add(new ClaseCrudUtilsCampos
            { NombreIni = "granularidad", NombreFinal = "GRANULARIDAD", Tipo = "number" });
        CamposFiltros.Add(new ClaseCrudUtilsCampos
            { NombreIni = "duracionMax", NombreFinal = "DURACION_MAX" });
        CamposFiltros.Add(new ClaseCrudUtilsCampos
            { NombreIni = "ALL", NombreFinal = $"ID|NOMBRE_{idiomaUpper}|DURACION_MAX" });
    }

    private string TransformarCampoOrden(string campoorden)
    {
        if (string.IsNullOrWhiteSpace(campoorden)) return "ID";
        var campo = CamposFiltros.FirstOrDefault(x =>
            string.Equals(x.NombreIni, campoorden,
                StringComparison.OrdinalIgnoreCase));
        if (campo == null || string.IsNullOrWhiteSpace(campo.NombreFinal))
            return "ID";
        var campoFinal = campo.NombreFinal;
        return campoFinal.Contains('|') ? campoFinal.Split('|')[0] : campoFinal;
    }
}
```

**Controlador:**

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

**Vue:**

```vue
<script setup lang="ts">
import { ref } from "vue";
import {
  llamadaAxios,
  verbosAxios,
  gestionarError,
} from "vueua-useaxios/services/useAxios";

interface DataTableResponse {
  numeroRegistros: number;
  numeroRegistrosFiltrados: number;
  registros: `Array&lt;{ id: number; nombre: string; granularidad: number }&gt;`;
}

const dataTable = ref<DataTableResponse | null>(null);

const cargarDataTable = () => {
  llamadaAxios(
    "Unidades/datatable?primerregistro=0&numeroregistros=10&idioma=ES",
    verbosAxios.GET,
  )
    .then(({ data }) => {
      dataTable.value = data.value as DataTableResponse;
    })
    .catch((error) => {
      gestionarError(error, "Error al cargar DataTable", "DataTable");
    });
};
</script>

<template>
  <button @click="cargarDataTable" class="btn btn-primary">Cargar</button>
  <div v-if="dataTable" class="mt-3">
    <p>
      Total: {{ dataTable.numeroRegistros }} | Filtrados:
      {{ dataTable.numeroRegistrosFiltrados }}
    </p>
    <table class="table table-bordered">
      <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>Granularidad</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="u in dataTable.registros" :key="u.id">
          <td>{{ u.id }}</td>
          <td>{{ u.nombre }}</td>
          <td>{{ u.granularidad }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
```

:::

::: details Código con fallos para Copilot

```csharp
// ⚠️ CÓDIGO CON FALLOS - Usa Copilot para encontrar y arreglar los errores

public class ClaseUnidades : ClaseCrudUtils
{
    // 🐛 No implementa IClaseUnidades ni CrudAPIClaseInterface<ClaseUnidad>
    private ClaseOracleBd _bd;

    // 🐛 Constructor sin llamar a base(claseoraclebd)
    public ClaseUnidades(ClaseOracleBd bd)
    {
        _bd = bd;
        // 🐛 No configura SQLWhereBase ni CamposFiltros
    }

    public ClaseDataTable Obtener(int primerregistro, int numeroregistros,
        string campoorden, string orden)
    {
        var salida = new ClaseDataTable();

        // 🐛 Usa tabla directa (sin permiso SELECT) en vez de vista
        salida.NumeroRegistros = NumeroRegistrosTotales("TCTS_UNIDADES");

        // 🐛 Usa SELECT * en vez de campos explícitos
        // 🐛 campoorden no transformado — el frontend envía camelCase
        // 🐛 Falta filtro y campofiltro en la llamada
        salida.Registros = RegistrosFiltrados<ClaseUnidad>(
            "VCTS_UNIDADES", "*", "ALL", "",
            campoorden, orden, numeroregistros, primerregistro);

        // 🐛 Falta NumeroRegistrosFiltrados — el frontend no puede paginar
        return salida;
    }

    private void ConfigurarCamposFiltros()
    {
        // 🐛 No limpia la lista anterior con CamposFiltros.Clear()
        CamposFiltros.Add(new ClaseCrudUtilsCampos {
            NombreIni = "nombre",
            // 🐛 Hardcoded a NOMBRE_ES — no soporta multiidioma
            NombreFinal = "NOMBRE_ES"
        });
        // 🐛 Faltan campos: id, flgActiva, granularidad, etc.
        // 🐛 Falta campo ALL para búsqueda general
    }

    // 🐛 TransformarCampoOrden no existe — la ordenación fallará
}
```

:::

::: tip CHECKLIST DATATABLE
Cuando implementes un nuevo DataTable:

- [ ] Servicio hereda de `ClaseCrudUtils` e implementa `CrudAPIClaseInterface&lt;T&gt;`
- [ ] `CamposFiltros` con todos los campos filtrables + campo `ALL`
- [ ] `CamposFiltros.Clear()` al inicio de `ConfigurarCamposFiltros`
- [ ] `SQLWhereBase` configurado en el constructor
- [ ] `TransformarCampoOrden` con fallback a campo por defecto
- [ ] Método `Obtener` con las tres consultas obligatorias
- [ ] Lista explícita de campos (nunca `*`)
- [ ] Endpoint `datatable` separado del CRUD básico
- [ ] `SetIdioma` reconfigura `CamposFiltros` para multiidioma
- [ ] Tests con `FakeService` que verifican idioma y respuesta
- [ ] Frontend maneja `NumeroRegistros`, `NumeroRegistrosFiltrados` y `Registros`
      :::

---

## Tests y práctica IA

- [Ver tests y práctica de la sesión](../../test/sesion-4/)
- [Autoevaluación sesión 4](../../test/sesion-4/autoevaluacion.md)
- [Preguntas de test sesión 4](../../test/sesion-4/preguntas.md)
- [Respuestas del test sesión 4](../../test/sesion-4/respuestas.md)
- [Práctica IA-fix sesión 4](../../test/sesion-4/practica-ia-fix.md)

---

**Anterior:** [Sesión 3: Validación y errores](../sesion-3-validacion-errores/) | **Siguiente:** [Sesión 5: OpenAPI, Scalar y testing API](../sesion-5-openapi-scalar/) | **Inicio:** [APIs en .NET Core 10](../../index.md)
