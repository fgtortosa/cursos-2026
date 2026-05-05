---
title: Como trabajamos con Oracle
description: Introduccion a la relacion entre los esquemas Oracle y el codigo .NET en la Universidad de Alicante. Arquitectura ADM/WEB, convenciones de nombres y conversiones de tipos, con un bloque final de profundizacion para consulta.
outline: [2, 4]
---

# Como trabajamos con Oracle

::: info CONTEXTO
Esta es una **introduccion** pensada para una sesion breve de unos 45 minutos. El objetivo no es que domines Oracle y .NET al terminar, sino que entiendas **como se relacionan** los objetos de la base de datos con el codigo de la aplicacion.

Todo lo que aparece en la seccion **Contenido para profundizar** queda como material de consulta. Puedes saltartelo en esta sesion y retomarlo mas adelante o en el curso posterior de normalizacion de aplicaciones.
:::

[[toc]]

## Objetivos de esta sesion

::: info CONTEXTO
Al terminar esta sesion deberias ser capaz de:

- Entender por que trabajamos con dos esquemas Oracle (`ADM` y `WEB`)
- Reconocer las convenciones basicas de nombres entre Oracle, C# y Vue
- Identificar cuando basta el automapeo y cuando hace falta mapeo manual
- Entender por que la lectura va por vistas y la escritura por packages
- Saber que partes quedan como consulta para profundizar mas adelante
:::

## Dos esquemas, dos responsabilidades {#arquitectura-adm-web}

Todos los proyectos Oracle de la UA utilizan **dos esquemas separados**:

| Esquema | Rol | Que posee | Ejemplo |
|---------|-----|-----------|---------|
| **ADM** | Propietario de los datos | Tablas, vistas, packages | `CURSONET` |
| **WEB** | Consumidor (la aplicacion) | Nada propio; usa objetos de ADM | `CURSONETWEB` |

::: warning IMPORTANTE
`CURSONETWEB` **nunca** accede a las tablas directamente. Solo puede:
- `SELECT` sobre **vistas** (lectura)
- `EXECUTE` sobre **packages** (escritura)

Si alguien obtiene las credenciales del usuario WEB, no puede modificar las tablas.
:::

El flujo completo tiene este aspecto:

```
TABLA (ADM) → VISTA (ADM, leida por WEB) → DTO (.NET) → API (JSON) → Vue
```

## Convenciones de nombres {#convenciones-nombres}

Cada capa tiene su propio estilo de nombres. `ClaseOracleBD3` traduce automaticamente entre Oracle y C#:

| Oracle (SNAKE_CASE) | C# (PascalCase) | Vue/TypeScript (camelCase) | Notas |
|---------------------|-----------------|---------------------------|-------|
| `ID_PRACTICA` | `IdPractica` | `idPractica` | Automatico |
| `TITULO_ES` | `TituloEs` | `tituloEs` | Automatico |
| `PUBLICADA_SN` | `PublicadaSn` | `publicadaSn` | Automatico + conversion `bool` |
| `NUM_RECURSOS` | `NumeroRecursos` | `numeroRecursos` | Requiere `[Columna("NUM_RECURSOS")]` |

### Prefijos en Oracle

| Prefijo | Objeto | Ejemplo |
|---------|--------|---------|
| `T` | Tabla | `TCURSO_BIENVENIDA_ORACLE_PRACTICA` |
| `V` | Vista | `VCURSO_BIENVENIDA_ORACLE_PRACTICAS` |
| `PKG_` | Package | `PKG_CURSO_BIENVENIDA_ORACLE_PRACTICAS` |
| `PK_` | Primary key | `PK_TCURSO_BIENVENIDA_ORACLE_PRACTICA` |
| `FK_` | Foreign key | `FK_TCURSO_BIENVENIDA_ORACLE_PRACTICA_MODULO` |
| `UX_` | Indice unico | `UX_TCURSO_BIENVENIDA_ORACLE_PRACTICA_CODIGO` |
| `IDX_` | Indice no unico | `IDX_TCURSO_BIENVENIDA_ORACLE_PRACTICA_MODULO` |
| `CK_` | Check constraint | `CK_TCURSO_BIENVENIDA_ORACLE_PRACTICA_ACTIVO` |

### Convenciones en C# (UA)

| Tipo de clase | Nombre | Ejemplo |
|---------------|--------|---------|
| DTO de lectura | `Clase` + entidad singular | `ClasePractica` |
| DTO de detalle | `Clase` + entidad + `Detalle` | `ClasePracticaDetalle` |
| DTO de escritura | `ClaseGuardar` + entidad | `ClaseGuardarPractica` |
| Servicio | `Clase` + entidad plural | `ClasePracticas` |

## Las conversiones "conflictivas" {#conversiones-conflictivas}

La mayoria de columnas se mapean solas (NUMBER → int, VARCHAR2 → string). Pero hay tres casos que requieren atencion:

### 1. `CHAR(1) 'S'/'N'` → `bool` {#conversion-sn-bool}

En Oracle no existe un tipo booleano. Usamos `CHAR(1)` con valores `'S'` (si) y `'N'` (no).

| Oracle | C# con automapeo | C# con mapeo manual |
|--------|------------------|---------------------|
| `PUBLICADA_SN CHAR(1)` | `bool PublicadaSn` | `ClaseOracleBd.ToBool(rs["publicada_sn"])` |

::: tip BUENA PRACTICA
Si la propiedad C# es `bool`, ClaseOracleBD3 convierte `'S'/'N'` automaticamente. El mapeo manual solo es necesario cuando no usamos automapeo.
:::

### 2. `DATE` → `DateTime` o `DateOnly` {#conversion-date}

Oracle `DATE` llega a .NET como `DateTime`. Si queremos `DateOnly` (solo fecha, sin hora), necesitamos mapeo manual:

| Oracle | C# con automapeo | C# con mapeo manual |
|--------|------------------|---------------------|
| `FECHA_PUBLICACION DATE` | `DateTime? FechaPublicacion` | `DateOnly.FromDateTime(fecha.Value)` |

### 3. `BLOB` → `byte[]` {#conversion-blob}

Los campos binarios (imagenes, documentos, etc.) siempre requieren mapeo manual:

| Oracle | C# |
|--------|----|
| `CONTENIDO BLOB` | `(byte[])rs["contenido_recurso_principal"]` |

## Antes y despues del automapeo {#automapeo-vs-manual}

Esta es la diferencia fundamental que queremos que se entienda. El automapeo resuelve el 80% de los casos; el 20% requiere mapeo manual.

::: code-group

```csharp [Con automapeo (ClasePractica)]
// ClaseOracleBD3 convierte SNAKE_CASE -> PascalCase automaticamente.
// Solo escribimos las propiedades y el SELECT.

public class ClasePractica
{
    public int IdPractica { get; set; }           // ID_PRACTICA -> IdPractica
    public string TituloEs { get; set; }          // TITULO_ES -> TituloEs
    public bool PublicadaSn { get; set; }          // PUBLICADA_SN 'S'/'N' -> bool
    public DateTime? FechaPublicacion { get; set; } // DATE -> DateTime

    [Columna("NUM_RECURSOS")]                      // Nombre diferente: atributo [Columna]
    public int NumeroRecursos { get; set; }
}

// En el servicio: una linea
var practicas = await _bd.ObtenerTodosMapAsync<ClasePractica>(sql);
```

```csharp [Con mapeo manual (ClasePracticaDetalle)]
// Cuando necesitamos DateOnly, BLOB o control total,
// usamos un constructor con IDataRecord.

public ClasePracticaDetalle(IDataRecord rs)
{
    IdPractica = Convert.ToInt32(rs["id_practica"]);
    TituloEs = rs["titulo_es"] as string ?? string.Empty;

    // Conversion 1: DATE -> DateOnly (el automapeo solo llega a DateTime)
    var fecha = ClaseOracleBd.ToNullableDateTime(rs["fecha_publicacion"]);
    FechaPublicacion = fecha.HasValue ? DateOnly.FromDateTime(fecha.Value) : null;

    // Conversion 2: CHAR(1) 'S'/'N' -> bool (aqui lo hacemos a mano)
    Publicada = ClaseOracleBd.ToBool(rs["publicada_sn"]);

    // Conversion 3: BLOB -> byte[]
    ContenidoRecursoPrincipal = rs["contenido_recurso_principal"] == DBNull.Value
        ? null
        : (byte[])rs["contenido_recurso_principal"];
}
```

:::

::: details Cuando usar cada enfoque

- **Automapeo**: cuando la vista esta bien nombrada y todos los tipos se mapean directamente (string, int, bool, DateTime). Es la opcion preferente.
- **Mapeo manual**: cuando necesitamos `DateOnly`, `BLOB -> byte[]`, o transformaciones especiales. No es una rareza; es la herramienta correcta para el 20% de casos.
:::

## El package como contrato de escritura {#package-contrato}

La lectura va por vistas. La escritura va por **packages PL/SQL**. Cada procedimiento del package sigue un contrato estandar:

```sql
PROCEDURE SP_CURSO_BIENVENIDA_ORACLE_PRACTICA_INSERTAR(
    p_id_modulo         IN NUMBER,        -- Parametros de entrada
    p_codigo            IN VARCHAR2,
    p_titulo_es         IN VARCHAR2,
    -- ...
    p_id_practica       OUT NUMBER,        -- ID generado (solo en INSERT)
    p_codigo_error      OUT NUMBER,        -- 0 = ok, < 0 = error
    p_mensaje_error     OUT VARCHAR2       -- Mensaje descriptivo
);
```

| `p_codigo_error` | Significado | Ejemplo |
|------------------|-------------|---------|
| `0` | Exito | "Practica insertada correctamente" |
| `-1` | Error de negocio | "El modulo indicado no existe" |
| `-2` | Error de validacion | "La dificultad debe estar entre 1 y 5" |
| `> 0` | Error Oracle inesperado | SQLCODE del error |

En C#, la respuesta se recoge en un DTO:

```csharp
public class ClaseRespuestaPackage
{
    public int CodigoError { get; init; }
    public string MensajeError { get; init; } = string.Empty;
    public int? IdPractica { get; init; }
    public bool EsOk => CodigoError == 0;
}
```

::: tip BUENA PRACTICA
Las conversiones "conflictivas" tambien aparecen al **escribir**: un `bool` en C# hay que convertirlo a `'S'/'N'` antes de pasarlo como parametro al package.

```csharp
// bool de C# -> 'S'/'N' para Oracle
_bd.CrearParametro("p_publicada_sn", command.Publicada ? "S" : "N");
```
:::

## Grants: quien puede hacer que {#grants}

El script de permisos es sencillo y resume toda la arquitectura:

```sql
-- El usuario WEB NO tiene acceso directo a las tablas
REVOKE SELECT, INSERT, UPDATE, DELETE ON CURSONET.TCURSO_..._PRACTICA FROM CURSONETWEB;

-- Solo puede leer vistas
GRANT SELECT ON CURSONET.VCURSO_BIENVENIDA_ORACLE_PRACTICAS TO CURSONETWEB;

-- Y ejecutar el package (para escribir)
GRANT EXECUTE ON CURSONET.PKG_CURSO_BIENVENIDA_ORACLE_PRACTICAS TO CURSONETWEB;
```

## Correspondencia completa {#correspondencia-completa}

Esta tabla resume **toda la relacion** entre Oracle y .NET para nuestro ejemplo:

| Objeto Oracle | Tipo | Clase C# | Metodo en ClasePracticas |
|---------------|------|----------|--------------------------|
| `VCURSO_BIENVENIDA_ORACLE_PRACTICAS` | Vista (listado) | `ClasePractica` | `ObtenerTodasAsync()` |
| `VCURSO_BIENVENIDA_ORACLE_PRACTICAS_DETALLE` | Vista (detalle) | `ClasePracticaDetalle` | `ObtenerPorId()` |
| `PKG_..._PRACTICAS.SP_..._INSERTAR` | Procedure | `ClaseGuardarPractica` → `ClaseRespuestaPackage` | `Insertar()` |
| `PKG_..._PRACTICAS.SP_..._ACTUALIZAR` | Procedure | `ClaseGuardarPractica` → `ClaseRespuestaPackage` | `Actualizar()` |
| `PKG_..._PRACTICAS.SP_..._ELIMINAR` | Procedure | `ClaseRespuestaPackage` | `Eliminar()` |

Y la tabla de conversiones de tipos:

| Oracle | C# (automapeo) | C# (manual) | Direccion |
|--------|----------------|-------------|-----------|
| `NUMBER` | `int` / `decimal` | `Convert.ToInt32()` | Lectura |
| `VARCHAR2` | `string` | `as string` | Lectura |
| `CHAR(1) 'S'/'N'` | `bool` | `ClaseOracleBd.ToBool()` | Lectura |
| `DATE` | `DateTime?` | `DateOnly.FromDateTime()` | Lectura |
| `BLOB` | — | `(byte[])rs[...]` | Lectura |
| `bool` | — | `? "S" : "N"` | Escritura |
| `DateTime?` | — | `OracleDbType.Date` | Escritura |

## Caso practico: proyecto de consola {#caso-practico}

El proyecto `CursoBienvenidaOracle.Console` demuestra todo lo anterior con una aplicacion de consola .NET 10 que:

1. **Lista** practicas activas con automapeo (`ClasePractica`)
2. **Busca** una practica por ID con mapeo manual (`ClasePracticaDetalle`)
3. **Inserta** una practica nueva via package (`ClaseGuardarPractica`)
4. **Modifica** esa practica via package
5. **Elimina** logicamente la practica y comprueba que desaparece de la vista

::: warning IMPORTANTE
La cadena de conexion de `appsettings.json` debe usar `CURSONETWEB`, no `CURSONET`. Queremos que el alumno vea que con el usuario WEB tambien se puede trabajar, siempre que existan vistas y packages bien diseñados.
:::

### Estructura del proyecto

```
CursoBienvenidaOracle.Console/
├── Models/
│   ├── ClasePractica.cs            ← DTO lectura, automapeo
│   ├── ClasePracticaDetalle.cs     ← DTO lectura, mapeo manual
│   ├── ClaseGuardarPractica.cs     ← DTO escritura (insert/update)
│   └── ClaseRespuestaPackage.cs    ← Respuesta del package
├── Services/
│   ├── ClasePracticas.cs           ← Servicio (lectura + escritura)
│   └── DemoRunner.cs               ← Orquestador de la demo
├── Program.cs                      ← Punto de entrada + inyeccion de dependencias
└── appsettings.json                ← Cadena de conexion CURSONETWEB
```

## Siguiente paso {#siguiente-paso}

En el **curso de normalizacion de aplicaciones** veremos todo esto en un proyecto web real con API REST y Vue:

- DTOs con validacion (DataAnnotations y FluentValidation)
- Patron Result&lt;T&gt; para gestionar errores
- DataTable con paginacion en servidor
- OpenAPI y Scalar para documentar APIs

Por ahora, lo importante es que entiendas la relacion:

```
TABLA → VISTA → DTO → SERVICIO → API → VUE
```

Y las tres conversiones que hay que tener en cuenta:

- `'S'/'N'` ↔ `bool`
- `DATE` ↔ `DateTime` / `DateOnly`
- `BLOB` ↔ `byte[]`

## Contenido para profundizar {#profundizar}

::: info SOLO CONSULTA
Lo que sigue amplia el contenido de la sesion. No hace falta recorrerlo entero ahora, pero conviene dejarlo por escrito porque son decisiones, patrones y ejemplos que aparecen en proyectos Oracle reales de la UA.
:::

### Diseno del esquema y restricciones de base

Cuando arranca un proyecto nuevo, conviene decidir desde el principio donde van a vivir los objetos Oracle:

1. **Usuario ADM**: propietario de tablas, vistas y packages.
2. **Usuario WEB**: usuario de aplicacion, con permisos minimos.

La regla operativa es siempre la misma:

- WEB **no** lee tablas directamente.
- WEB **lee** a traves de vistas.
- WEB **escribe** ejecutando packages.
- Desde .NET evitamos `SELECT *` y solo pedimos las columnas necesarias.

Tambien hay una serie de decisiones de proyecto que conviene respetar:

- No usamos **sinonimos** de Oracle.
- No creamos **secuencias nuevas** en desarrollos actuales.
- Para IDs automaticos preferimos `IDENTITY`.
- Si una tabla cambia, adaptamos la **vista**, no el acceso directo desde la aplicacion.

Estas son las modalidades de `IDENTITY` que conviene conocer:

| Modalidad | Comportamiento | Uso recomendado |
|-----------|----------------|-----------------|
| `GENERATED BY DEFAULT ON NULL AS IDENTITY` | Genera ID si no se informa o si llega `NULL` | **La recomendada** en proyectos nuevos |
| `GENERATED ALWAYS AS IDENTITY` | Oracle genera siempre el ID | Cuando nunca se debe forzar manualmente |
| `GENERATED BY DEFAULT AS IDENTITY` | Genera ID si la columna no aparece en el `INSERT` | Menos comoda si alguien envia `NULL` |

::: tip BUENA PRACTICA
Usamos `GENERATED BY DEFAULT ON NULL AS IDENTITY` porque permite trabajar con normalidad y, si hace falta en una migracion, admite forzar un ID manual.
:::

```sql
ID_RECURSO NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY
```

::: warning IMPORTANTE
Si alguien inserta manualmente un ID alto, la secuencia interna de `IDENTITY` no "salta" automaticamente hasta ese valor. En una migracion puede tener sentido; en el trabajo habitual no deberiamos informar el ID.
:::

::: details Contenido para profundizar: comportamiento de INSERT segun la modalidad `IDENTITY`

```sql
CREATE TABLE ESQUEMA_ADM.TRES_EJEMPLO (
    ID     NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    NOMBRE VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_TRES_EJEMPLO PRIMARY KEY (ID)
);

-- Oracle genera el ID
INSERT INTO TRES_EJEMPLO (NOMBRE) VALUES ('Registro auto');

-- Oracle tambien genera el ID
INSERT INTO TRES_EJEMPLO (ID, NOMBRE) VALUES (NULL, 'Otro registro auto');

-- Oracle respeta el valor manual
INSERT INTO TRES_EJEMPLO (ID, NOMBRE) VALUES (500, 'Registro con ID forzado');
```

Para comparar:

```sql
-- GENERATED ALWAYS: no admite forzar el ID
INSERT INTO TABLA_ALWAYS (ID, NOMBRE) VALUES (500, 'Falla');

-- GENERATED BY DEFAULT: admite un valor manual,
-- pero si enviamos NULL no siempre dispara la generacion
INSERT INTO TABLA_DEFAULT (ID, NOMBRE) VALUES (500, 'OK');
INSERT INTO TABLA_DEFAULT (ID, NOMBRE) VALUES (NULL, 'Falla');
```
:::

::: details Contenido para profundizar: ejemplo legacy con secuencia

En proyectos antiguos podras encontrar secuencias y triggers. Es valido para entender codigo legacy, pero no es el patron que queremos repetir:

```sql
CREATE SEQUENCE SALASRECADM.SEQ_SALASREC
  INCREMENT BY 1 MINVALUE 1
  MAXVALUE 999999999999999999999999999;

CREATE OR REPLACE TRIGGER SALASRECADM.TR_RES_UNIDAD
BEFORE INSERT ON RES_UNIDAD
  FOR EACH ROW
  WHEN (NEW.ID IS NULL)
BEGIN
  SELECT SEQ_SALASREC.NEXTVAL INTO :NEW.ID FROM DUAL;
END;
```
:::

### Convenciones adicionales que veras en proyectos reales

En el curso nos hemos quedado con las convenciones esenciales. En documentacion y codigo real tambien veras estos patrones:

| Tipo de objeto | Prefijo | Ejemplo |
|----------------|---------|---------|
| Tabla | `T` | `TMAT_ALUMNOS` |
| Vista | `V` | `VTUT_RESPUESTAS` |
| Package | `PKG_` | `PKG_KRON_SINCRONIZACION` |
| Procedimiento | `P` o `SP_` | `PMAT_PROCESAR_NOTAS`, `SP_HERRAMIENTA_INSERTAR` |
| Funcion | `F` | `FMAT_CALCULAR_MEDIA` |
| Indice | `IDX_` | `IDX_MAT_ALUMNOS_DNI` |
| Clave primaria | `PK_` | `PK_TRES_RECURSO` |
| Clave ajena | `FK_` | `FK_TRES_RECURSO_SALA` |

En los textos multiidioma usamos siempre estos sufijos:

| Idioma | Sufijo | Ejemplo |
|--------|--------|---------|
| Castellano | `_ES` | `TITULO_ES` |
| Valenciano/Catalan | `_CA` | `TITULO_CA` |
| Ingles | `_EN` | `TITULO_EN` |

::: warning IMPORTANTE
El sufijo correcto para valenciano es `_CA`, no `_VAL`.
:::

Otras dos reglas utiles:

- Los flags de estado se modelan como `S/N`, `0/1` o el tipo booleano disponible en el proyecto, pero siempre con dominio de valores controlado.
- En packages preferimos nombres explicitos (`INS_PERMISO`, `UPD_PERMISO`, `DEL_PERMISO` o `SP_ENTIDAD_ACCION`) en lugar de operaciones genericas ambiguas.

Cuando una vista une varias tablas, conviene renombrar los alias para que el mapeo a .NET sea evidente:

```sql
SELECT usu.nombre    AS nombre_usuario,
       uni.nombre_es AS nombre_unidad_es,
       adm.rol_es
  FROM RES_USUARIO usu, RES_UNIDAD uni, RES_ADMINISTRAR adm
 WHERE usu.id = adm.id_usuario
   AND uni.id = adm.id_unidad;
```

### Tablas y vistas: lo que queda fuera de la sesion

Al disenar una tabla, estas son las piezas que deberiamos revisar siempre:

1. **Clave primaria** (`PK`)
2. **Claves ajenas** (`FK`)
3. **Restricciones de unicidad** (`UNIQUE`)
4. **Restricciones `CHECK`** para validar dominios
5. **Indices** en columnas de filtro y de `JOIN`

Cuando el proyecto lo requiera, usamos estos tablespaces:

| Uso | Tablespace |
|-----|------------|
| Tablas | `OTRAS_APP_DAT` |
| Indices | `OTRAS_APP_IND` |

En las vistas nos interesa mantener cuatro ideas:

- Exponer una interfaz estable para la aplicacion.
- Incluir alias orientados al mapeo .NET.
- Evitar vistas demasiado generales para casos de uso masivos.
- Documentar el proposito y el historico del objeto.

```sql
CREATE OR REPLACE FORCE VIEW ESQUEMA_ADM.VAPPS_PERSONAS_COLECTIVO
(CODPER, COLECTIVO)
BEQUEATH DEFINER
AS
SELECT /* Dado un CodPer nos dice los colectivos a los que pertenece.

IMPORTANTE: ESTA VISTA ES CRITICA PARA EL CONTROL DE ACCESO.

10/06/2017 PROGRAMADOR1 Anadido el COLECTIVO ADM_EMPEXT
04/06/2019 PROGRAMADOR2 Anadido perfil FUEPAS, FUEPDI e INSTITUCIONAL
25/01/2024 PROGRAMADOR3 Control de bloqueados
*/
CODPER, 'CIUDADANO'
FROM APP_PERSONAS
WHERE PKG_UAAPPS_CTLACC.esINSTITUCIONAL(CODPER) = 'N';
```

::: details Contenido para profundizar: ejemplo de vista con `GRANT SELECT`

```sql
CREATE OR REPLACE FORCE VIEW "CURSONORMADM"."VRES_RECURSO"
(
    "ID_RECURSO",
    "NOMBRE_ES",
    "NOMBRE_CA",
    "NOMBRE_EN",
    "DESCRIPCION_ES",
    "DESCRIPCION_CA",
    "DESCRIPCION_EN",
    "ACTIVO",
    "VISIBLE",
    "ATIENDE_MISMA_PERSONA",
    "ID_TIPO_RECURSO",
    "GRANULIDAD",
    "DURACION",
    "FECHA_MODIFICACION"
)
AS
SELECT ID_RECURSO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
       DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
       ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA,
       ID_TIPO_RECURSO, GRANULIDAD, DURACION,
       FECHA_MODIFICACION
FROM CURSONORMADM.TRES_RECURSO;

GRANT SELECT ON "CURSONORMADM"."VRES_RECURSO" TO "CURSONORMWEB";
```
:::

::: details Contenido para profundizar: checklist rapido de tabla y vista

- [ ] La tabla tiene PK, FKs, `UNIQUE`, `CHECK` e indices donde toca.
- [ ] Los campos descriptivos usan `_ES`, `_CA`, `_EN`.
- [ ] La tabla y sus indices van al tablespace correcto si aplica.
- [ ] La vista evita `SELECT *` y expone nombres utiles para .NET.
- [ ] La vista documenta su finalidad y deja historico de cambios.
- [ ] El usuario WEB solo recibe `GRANT SELECT` sobre la vista.
:::

### Packages PL/SQL mas alla del ejemplo basico

En Oracle, un package tiene dos partes:

| Parte | Que contiene | Visibilidad |
|-------|--------------|-------------|
| `PACKAGE` | Firma publica: procedimientos, funciones y tipos | Publica |
| `PACKAGE BODY` | Implementacion real y metodos auxiliares | Interna |

Ademas del contrato basico que ya hemos visto, conviene recordar estas pautas:

1. SQL Developer puede generar una API base a partir de una tabla.
2. Esa generacion es solo el punto de partida: luego renombramos, simplificamos y unificamos.
3. Solemos agrupar por **dominio funcional**, no por tabla aislada.
4. Para un CRUD completo suelen aparecer estas operaciones:

| Operacion | Uso habitual |
|-----------|--------------|
| `CREAR` / `INSERTAR` | Alta con `RETURNING ... INTO` |
| `OBTENER_TODOS` / `LISTAR` | Lectura multiple |
| `OBTENER_POR_ID` | Lectura individual |
| `ACTUALIZAR` | Modificacion completa |
| `ACTUALIZAR_FLAGS` | Cambio parcial de estado |
| `ELIMINAR` | Borrado fisico o logico |
| `EXISTE` | Comprobacion previa |

::: warning IMPORTANTE
No solemos crear pares como `ACTIVAR`/`DESACTIVAR` o `MOSTRAR`/`OCULTAR`. Preferimos una unica operacion con parametros de estado, por ejemplo `ACTUALIZAR_FLAGS(P_ID, P_ACTIVO, P_VISIBLE)`.
:::

Cuando el ID lo genera Oracle, el package deberia devolverlo:

```sql
PROCEDURE CREAR(
    P_NOMBRE_ES  IN TRES_RECURSO.NOMBRE_ES%TYPE,
    P_NOMBRE_CA  IN TRES_RECURSO.NOMBRE_CA%TYPE,
    P_ID_RECURSO OUT TRES_RECURSO.ID_RECURSO%TYPE
) AS
BEGIN
    INSERT INTO TRES_RECURSO (NOMBRE_ES, NOMBRE_CA)
    VALUES (P_NOMBRE_ES, P_NOMBRE_CA)
    RETURNING ID_RECURSO INTO P_ID_RECURSO;
END CREAR;
```

Y antes de escribir, validamos siempre:

- IDs mayores que `0`
- Campos obligatorios informados
- Flags con valores validos
- Existencia de claves ajenas
- Reglas de negocio del dominio

```sql
PROCEDURE VALIDAR_FLAG(
    P_NOMBRE IN VARCHAR2,
    P_VALOR  IN NUMBER
) AS
BEGIN
    IF P_VALOR IS NOT NULL AND P_VALOR NOT IN (0, 1) THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Valor invalido para ' || P_NOMBRE || '. Debe ser 0 o 1.');
    END IF;
END VALIDAR_FLAG;
```

::: details Contenido para profundizar: ejemplo de package documentado

```sql
CREATE OR REPLACE PACKAGE "CURSONORMADM".PKG_RES_RECURSO AS
/* Paquete de gestion de recursos reservables.

   IMPORTANTE: Centraliza altas, consultas, modificaciones
   y cambio de flags de visibilidad y activacion.

   01/03/2026  PROGRAMADOR1  Creacion inicial.
*/

TYPE T_CURSOR IS REF CURSOR;

PROCEDURE CREAR(..., P_ID_RECURSO OUT TRES_RECURSO.ID_RECURSO%TYPE);
PROCEDURE OBTENER_TODOS(P_CURSOR OUT T_CURSOR);
PROCEDURE OBTENER_POR_ID(P_ID_RECURSO IN ..., P_CURSOR OUT T_CURSOR);
PROCEDURE ACTUALIZAR(...);
PROCEDURE ACTUALIZAR_FLAGS(...);
PROCEDURE ELIMINAR(...);
END PKG_RES_RECURSO;
/

GRANT EXECUTE ON "CURSONORMADM".PKG_RES_RECURSO TO "CURSONORMWEB";
```
:::

### Gestion de errores, logs y operaciones por lotes

En paquetes PL/SQL aparecen con frecuencia dos estrategias de error:

1. Lanzar excepciones con `raise_application_error`.
2. Devolver `p_codigo_error` y `p_mensaje_error` como parametros `OUT`.

Esta convencion historica sigue apareciendo en algunos paquetes:

| Formato del mensaje | Quien lo ve | Uso |
|---------------------|-------------|-----|
| Texto entre `#...#` | Usuario final | Mensajes controlados de validacion |
| Texto sin `#` | Equipo tecnico | Diagnostico interno, auditoria o seguridad |

```sql
raise_application_error(-20001,
    '# No se ha podido dar de alta el permiso al usuario #');
```

Despues de un `UPDATE` o `DELETE`, revisar `SQL%ROWCOUNT` evita silencios peligrosos:

```sql
UPDATE RES_ADMIN_PERMISOS
   SET ID_USUARIO = p_ID_USUARIO,
       ID_RECURSO = p_ID_RECURSO
 WHERE ID = p_ID;

IF SQL%ROWCOUNT = 0 THEN
    raise_application_error(-20001,
        'Se ha intentado modificar el permiso: ' || p_ID);
END IF;
```

Si el package sigue el contrato con parametros `OUT`, estos codigos son habituales:

| Codigo | Significado |
|--------|-------------|
| `0` | Exito |
| `-1` | No encontrado o duplicado |
| `-2` | Validacion de negocio |
| `-3` | Colision de ID manual |
| `SQLCODE` | Error Oracle inesperado |

En paquetes grandes puede ayudar definir constantes:

```sql
C_ERR_PARAMETRO_INVALIDO  CONSTANT NUMBER := -20001;
C_ERR_NO_ENCONTRADO       CONSTANT NUMBER := -20002;
C_ERR_DUPLICADO           CONSTANT NUMBER := -20003;
C_ERR_INTEGRIDAD          CONSTANT NUMBER := -20004;
C_ERR_TAMANO              CONSTANT NUMBER := -20005;
C_ERR_INTERNO             CONSTANT NUMBER := -20006;
```

Para auditoria, suele venir bien una tabla de log con transaccion autonoma:

```sql
PROCEDURE INSERTA_LOG (
    pCODPER_UAAPPS IN NUMBER,
    pIP            IN VARCHAR2,
    pACCION        IN VARCHAR2,
    pERROR         IN VARCHAR2
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO TAPP_LOG (CODPER_UAAPPS, IP, ACCION, MSG_ERROR)
    VALUES (pCODPER_UAAPPS, pIP, pACCION, pERROR);
    COMMIT;
END INSERTA_LOG;
```

::: tip BUENA PRACTICA
`PRAGMA AUTONOMOUS_TRANSACTION` permite guardar el log aunque la transaccion principal falle y haga `ROLLBACK`.
:::

Si alguna vez necesitas mandar lotes de registros en una sola llamada, Oracle permite definir tipos objeto y tipos tabla:

```sql
CREATE OR REPLACE TYPE your_object_type AS OBJECT (
    PROPERTY1 VARCHAR2(50),
    PROPERTY2 NUMBER
);

CREATE OR REPLACE TYPE your_object_type_table AS TABLE OF your_object_type;
```

::: details Contenido para profundizar: ejemplo completo de array en un package

```sql
CREATE OR REPLACE PACKAGE PKG_ARRAYS AS
    PROCEDURE your_procedure(p_array IN your_object_type_table);
END PKG_ARRAYS;
/

CREATE OR REPLACE PACKAGE BODY PKG_ARRAYS AS
    PROCEDURE your_procedure(p_array IN your_object_type_table) IS
    BEGIN
        FOR i IN 1 .. p_array.COUNT LOOP
            INSERT INTO YOUR_OBJECT_TABLE
            VALUES (p_array(i).PROPERTY1, p_array(i).PROPERTY2);
        END LOOP;
    END your_procedure;
END PKG_ARRAYS;
```

```sql
DECLARE
    v_objeto1 your_object_type := your_object_type('111', 111);
    v_objeto2 your_object_type := your_object_type('222', 222);
    v_array   your_object_type_table := your_object_type_table(v_objeto1, v_objeto2);
BEGIN
    PKG_ARRAYS.your_procedure(v_array);
END;
```
:::

### Integracion con .NET, despliegue y checklist

La aplicacion .NET sigue conectando siempre con el usuario **WEB**:

```json
{
  "ConnectionStrings": {
    "oradb": "User ID=ESQUEMA_WEB;Password=...;Data Source=SERVIDOR/SERVICIO;"
  }
}
```

::: warning IMPORTANTE
En el curso usamos `ClaseOracleBD3`. En documentacion antigua tambien puedes encontrar `ClaseOracleBD` o `ClaseOracleBd`. La idea es la misma: centralizar el acceso a Oracle y evitar soluciones ad hoc para la logica de negocio estandar.
:::

Patrones de uso frecuentes:

| Operacion | Metodo habitual |
|-----------|-----------------|
| SELECT multiple | `GetAllObjectsMap<T>` / `ObtenerTodosMap<T>` |
| SELECT unico | `GetFirstObjectsMap<T>` / `ObtenerPrimeroMap<T>` |
| Procedure o function | `EjecutarParams` + parametros |

Y la separacion de capas sigue esta regla:

| Capa | Responsabilidad | Lleva SQL |
|------|-----------------|:---------:|
| **Models** | Representacion de datos | No |
| **Services** | Logica y acceso a Oracle | Si |
| **Controllers** | Exposicion HTTP | No |

En despliegue, el orden importa:

1. Tablas y restricciones
2. Indices
3. Vistas
4. Packages (`PACKAGE` y despues `PACKAGE BODY`)
5. Grants al usuario WEB

Tambien conviene mantener estos criterios de calidad:

- Evitar `SELECT *`.
- Revisar `EXPLAIN PLAN` en consultas criticas.
- Filtrar por columnas indexadas siempre que sea posible.
- Pensar en paginacion para listados.
- Evitar `JOIN` innecesarios en vistas generalistas.

Si tuvieras que anadir una entidad nueva, la plantilla de trabajo seria esta:

1. Crear tabla e indices.
2. Crear vista de lectura y `GRANT SELECT`.
3. Crear package y `GRANT EXECUTE`.
4. Escribir el servicio .NET que llama a Oracle.
5. Exponer la API.
6. Validar el flujo completo desde frontend.

::: details Contenido para profundizar: checklist final

- [ ] No se han creado sinonimos.
- [ ] WEB no tiene permisos directos sobre tablas.
- [ ] La aplicacion usa vistas para leer y packages para escribir.
- [ ] El SQL esta en `Services`, no en `Controllers` ni en `Models`.
- [ ] Los packages validan y gestionan errores de forma consistente.
- [ ] Tablas, vistas y packages dejan documentado su proposito e historico.
- [ ] Los scripts SQL estan versionados en el repositorio.
- [ ] Se han respetado las convenciones de nombres y los sufijos multiidioma.
- [ ] Se han aplicado indices y tablespaces donde corresponde.
:::

## Referencias para profundizar

- Documento interno: *Oracle - Buenas practicas* (Servicio de Informatica UA)
- Documento interno: *Elementos basicos para una API - Oracle* (Andres Valles)
- Documento interno: *ClaseOracleBD* (acceso Oracle desde .NET Core)

