---
title: "Ejercicio sesión 1 — Inspección del schema y diseño de un catálogo"
description: Ejercicio práctico de la sesión 1. Inspección del schema CURSONORMADM, análisis de conversiones de tipos, verificación de grants y diseño de un catálogo simple aplicando convenciones, IDENTITY y restricciones CHECK.
outline: [2, 4]
---

# Ejercicio sesión 1 — Inspección del schema y diseño de un catálogo

::: info CONTEXTO
En la sesión 1 has visto la arquitectura ADM/WEB, las convenciones de nombres, `IDENTITY`, las seis variantes de `CHECK` y el modelo de errores Oracle.

Este ejercicio aplica todo lo anterior en dos partes:

1. **Inspección guiada** del schema `CURSONORMADM` que ya está creado.
2. **Diseño de una tabla nueva** (un catálogo) aplicando las convenciones aprendidas.

No tocas todavía vistas ni paquetes: eso pertenece al ejercicio de la sesión 2.
:::

## Objetivos

Al terminar el ejercicio debes ser capaz de:

- Consultar el diccionario de datos de Oracle para listar tablas, constraints y permisos.
- Diferenciar visualmente PK, UK y CHECK (incluidos los `SYS_CK_*_NN` que representan `NOT NULL`).
- Identificar qué propiedades C# se mapearían automáticamente desde una vista.
- Comprobar que el usuario `CURSONORMWEB` solo tiene grants sobre vistas y paquetes.
- Diseñar una tabla de catálogo nueva con `IDENTITY`, sufijos multiidioma y al menos tres variantes de `CHECK`.

## Parte 1 — Inspección del schema

Conéctate primero como **CURSONORMADM** y ejecuta las consultas del paso 1. Después conéctate como **CURSONORMWEB** y ejecuta las del paso 2.

### Paso 1 — Listar tablas, vistas y paquetes del proyecto

Conectado como `CURSONORMADM`, completa esta tabla a partir del schema real:

```sql
-- Objetos del proyecto de reservas (prefijos TRES_, VRES_, PKG_RES_)
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_name LIKE 'TRES\_%'  ESCAPE '\'
    OR object_name LIKE 'VRES\_%'  ESCAPE '\'
    OR object_name LIKE 'PKG\_RES\_%' ESCAPE '\'
 ORDER BY object_type, object_name;
```

| Tipo           | Cuántos hay | Nombres encontrados |
| -------------- | ----------- | ------------------- |
| `TABLE`        |             |                     |
| `VIEW`         |             |                     |
| `PACKAGE`      |             |                     |
| `PACKAGE BODY` |             |                     |

::: tip BUENA PRÁCTICA
Usa siempre el operador `ESCAPE` cuando filtres por un prefijo que contiene guiones bajos. En Oracle, `_` es un comodín de un carácter dentro de `LIKE`.
:::

### Paso 2 — Identificar las constraints de `TRES_RECURSO`

```sql
SELECT constraint_name, constraint_type, search_condition
  FROM all_constraints
 WHERE owner = 'CURSONORMADM'
   AND table_name = 'TRES_RECURSO'
 ORDER BY constraint_type, constraint_name;
```

Clasifica cada constraint encontrada según su tipo:

| `constraint_type` | Significado                              |
| ----------------- | ---------------------------------------- |
| `P`               | Primary key                              |
| `U`               | Unique                                   |
| `C`               | Check (incluye los `NOT NULL` nombrados) |
| `R`               | Foreign key (referential)                |

A continuación, para cada constraint de tipo `C`, indica a cuál de las **seis variantes de CHECK** vistas en la sesión pertenece (NOT NULL nombrado, dominio `IN`, rango `BETWEEN`, `IS NULL OR ...`, comparación entre columnas, `REGEXP_LIKE`).

### Paso 3 — Comprobar el aislamiento del usuario WEB

Conectado ahora como `CURSONORMWEB`:

```sql
-- Esto debe funcionar
SELECT COUNT(*) FROM CURSONORMADM.VRES_TIPO_RECURSO;

-- Esto debe fallar con ORA-00942
SELECT COUNT(*) FROM CURSONORMADM.TRES_TIPO_RECURSO;
```

Documenta el código de error que recibes en el segundo `SELECT` y explica brevemente qué garantiza ese error desde el punto de vista de seguridad.

### Paso 4 — Listar los grants concedidos a WEB

Sigue conectado como `CURSONORMWEB`:

```sql
SELECT owner, table_name, privilege
  FROM all_tab_privs
 WHERE grantee = 'CURSONORMWEB'
 ORDER BY privilege, owner, table_name;
```

Comprueba que se cumplen estas dos reglas:

- [ ] No aparece ningún objeto cuyo nombre empiece por `TRES_` con privilegio `SELECT`, `INSERT`, `UPDATE` o `DELETE`.
- [ ] Todos los `SELECT` son sobre objetos `VRES_*` y todos los `EXECUTE` sobre `PKG_RES_*`.

Si encuentras alguna excepción, anótala y explícala.

### Paso 5 — Reflexionar sobre el mapeo .NET

Sobre la vista `VRES_TIPO_RECURSO`:

```sql
SELECT id_tipo_recurso,
       codigo,
       nombre_es,
       nombre_ca,
       nombre_en
  FROM CURSONORMADM.VRES_TIPO_RECURSO
 ORDER BY id_tipo_recurso;
```

Responde por escrito:

1. ¿Qué propiedades C# usaría una clase `ClaseTipoRecurso` para que el automapeo de `ClaseOracleBD3` funcione sin atributos `[Columna]`?
2. Si la vista incluyera una columna `FECHA_ALTA DATE`, ¿qué tipo C# elegirías y por qué?
3. ¿Qué pasaría si la propiedad C# se llamara `Identificador` en lugar de `IdTipoRecurso`?
4. ¿Cómo elegiría `ClaseOracleBD3` entre `NOMBRE_ES` y `NOMBRE_CA` si el usuario pide los datos en valenciano?

## Parte 2 — Diseño de un catálogo nuevo

Vas a diseñar una tabla de catálogo nueva: `TRES_TIPO_BLOQUEO`. Servirá más adelante (en otra sesión) para clasificar el motivo por el que un horario está bloqueado: mantenimiento, festivo, reservado para grupos, etc.

::: warning IMPORTANTE
Este es un **catálogo simple**, parecido a `TRES_TIPO_RECURSO`. No tiene relaciones todavía. El objetivo es aplicar las convenciones y los CHECKs sobre una entidad pequeña antes del ejercicio de la sesión 2, donde diseñarás tablas con relaciones y rangos temporales.
:::

### Requisitos funcionales

La tabla `TRES_TIPO_BLOQUEO` debe tener al menos las siguientes columnas:

| Columna              | Tipo y reglas funcionales                                    |
| -------------------- | ------------------------------------------------------------ |
| Identificador        | Numérico, generado por la base de datos. PK.                 |
| Código               | Texto corto. Único en la tabla. Obligatorio.                 |
| Nombre en castellano | Texto. Obligatorio.                                          |
| Nombre en valenciano | Texto. Obligatorio.                                          |
| Nombre en inglés     | Texto. Obligatorio.                                          |
| Color                | Texto opcional. Si tiene valor, debe ser un HEX `#RRGGBB`.   |
| Orden                | Numérico opcional. Si tiene valor, debe estar entre 1 y 999. |
| Activo               | Flag `S/N`. Obligatorio. Por defecto `'S'`.                  |

### Decisiones que debes tomar

- Cómo nombras la PK (`PK_TRES_TIPO_BLOQUEO`) y la columna de ID para que el automapeo .NET sea natural.
- Qué tamaños eliges para `CODIGO` y los nombres multiidioma. Justifica brevemente.
- Cuál de las modalidades de `IDENTITY` aplicas y por qué.
- Cómo cierras el dominio del flag `ACTIVO`.
- Cómo proteges el formato HEX del color.
- Cómo aceptas que `ORDEN` sea opcional pero, si llega, esté en rango.

### Restricciones que debe incluir el script

El script tiene que incluir **al menos** estas variantes de `CHECK`:

- [ ] `CHECK ... IS NOT NULL` para los campos obligatorios (vale como `NOT NULL` directo).
- [ ] `CHECK (ACTIVO IN ('S', 'N'))` para el flag.
- [ ] `CHECK (ORDEN IS NULL OR ORDEN BETWEEN 1 AND 999)` para el campo opcional con rango.
- [ ] `CHECK (COLOR IS NULL OR REGEXP_LIKE(COLOR, '^#[0-9A-Fa-f]{6}$'))` para el formato HEX.

Y al menos:

- [ ] `PK_TRES_TIPO_BLOQUEO` nombrada explícitamente.
- [ ] `UK_TRES_TIPO_BLOQUEO_CODIGO` para la unicidad funcional.

## Entregable

Entrega un fichero SQL completo, por ejemplo:

```text
sql/01_tres_tipo_bloqueo.sql
```

El script debe poder ejecutarse conectado como `CURSONORMADM` y debe contener, en este orden:

1. `CREATE TABLE CURSONORMADM.TRES_TIPO_BLOQUEO` con todas las columnas y constraints **nombradas**.
2. Un comentario de tabla (`COMMENT ON TABLE`) que describa el catálogo.
3. Comentarios de columna (`COMMENT ON COLUMN`) para `CODIGO`, `COLOR` y `ORDEN`.
4. Tres `INSERT` de prueba con valores válidos (al menos uno con `COLOR` y otro sin él).
5. Las consultas de verificación al final.

### Plantilla mínima del script

```sql
-- =========================================================
-- TRES_TIPO_BLOQUEO - catálogo de motivos de bloqueo horario
-- =========================================================

CREATE TABLE CURSONORMADM.TRES_TIPO_BLOQUEO (
    -- ... columnas con sus tipos y CHECKs
    --
    CONSTRAINT PK_TRES_TIPO_BLOQUEO       PRIMARY KEY (...),
    CONSTRAINT UK_TRES_TIPO_BLOQUEO_CODIGO UNIQUE (...)
);

COMMENT ON TABLE  CURSONORMADM.TRES_TIPO_BLOQUEO       IS '...';
COMMENT ON COLUMN CURSONORMADM.TRES_TIPO_BLOQUEO.CODIGO IS '...';
COMMENT ON COLUMN CURSONORMADM.TRES_TIPO_BLOQUEO.COLOR  IS '...';
COMMENT ON COLUMN CURSONORMADM.TRES_TIPO_BLOQUEO.ORDEN  IS '...';

-- Datos de prueba
INSERT INTO CURSONORMADM.TRES_TIPO_BLOQUEO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN, COLOR, ORDEN)
VALUES ('MANT', 'Mantenimiento', 'Manteniment', 'Maintenance', '#FF8800', 10);

INSERT INTO CURSONORMADM.TRES_TIPO_BLOQUEO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN, COLOR, ORDEN)
VALUES ('FEST', 'Festivo',       'Festiu',      'Holiday',     '#3366FF', 20);

INSERT INTO CURSONORMADM.TRES_TIPO_BLOQUEO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('OTROS', 'Otros',         'Altres',      'Others');

COMMIT;
```

### Consultas de verificación

Incluye al final del script consultas equivalentes a estas, adaptadas a tu nombre de tabla:

```sql
-- ¿Está creada la tabla?
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_name = 'TRES_TIPO_BLOQUEO'
 ORDER BY object_type;

-- ¿Cuántas constraints tiene y de qué tipo?
SELECT constraint_name, constraint_type, search_condition
  FROM user_constraints
 WHERE table_name = 'TRES_TIPO_BLOQUEO'
 ORDER BY constraint_type, constraint_name;

-- ¿Qué datos quedaron tras los INSERT?
SELECT id_tipo_bloqueo, codigo, nombre_es, color, orden, activo
  FROM CURSONORMADM.TRES_TIPO_BLOQUEO
 ORDER BY NVL(orden, 999), codigo;
```

### Pruebas que tu CHECK debe rechazar

Como parte del entregable, ejecuta estos `INSERT` que **deben fallar**, anota el `ORA-xxxxx` que devuelve cada uno y comprueba qué constraint salta:

```sql
-- Debe fallar: ACTIVO no es 'S' ni 'N'
INSERT INTO CURSONORMADM.TRES_TIPO_BLOQUEO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN, ACTIVO)
VALUES ('TEST1', 'Prueba', 'Prova', 'Test', 'X');

-- Debe fallar: COLOR no es HEX válido
INSERT INTO CURSONORMADM.TRES_TIPO_BLOQUEO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN, COLOR)
VALUES ('TEST2', 'Prueba', 'Prova', 'Test', 'rojo');

-- Debe fallar: ORDEN fuera de rango
INSERT INTO CURSONORMADM.TRES_TIPO_BLOQUEO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN, ORDEN)
VALUES ('TEST3', 'Prueba', 'Prova', 'Test', 5000);

-- Debe fallar: CODIGO duplicado
INSERT INTO CURSONORMADM.TRES_TIPO_BLOQUEO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('MANT', 'Otra cosa', 'Una altra', 'Other');
```

## Criterios de revisión

Usaremos esta lista para revisar el ejercicio:

- [ ] El alumno completa la inspección del schema (parte 1, pasos 1 a 5).
- [ ] El script de la parte 2 se ejecuta conectado como `CURSONORMADM` sin errores.
- [ ] La tabla usa el prefijo `TRES_` y la PK se llama `PK_TRES_TIPO_BLOQUEO`.
- [ ] El ID se genera con `GENERATED BY DEFAULT ON NULL AS IDENTITY`.
- [ ] Los nombres usan los sufijos `_ES`, `_CA`, `_EN` y nunca `_VAL`.
- [ ] La columna `ACTIVO` es `VARCHAR2(1)` con `DEFAULT 'S' NOT NULL` y CHECK `IN ('S', 'N')`.
- [ ] `COLOR` está protegido con `REGEXP_LIKE` y permite `NULL`.
- [ ] `ORDEN` admite `NULL` pero, si llega, está acotado por `BETWEEN`.
- [ ] Las constraints están **nombradas explícitamente** (no se aceptan nombres `SYS_*` generados por Oracle excepto los que vienen del export real).
- [ ] El script incluye `COMMENT ON TABLE` y al menos tres `COMMENT ON COLUMN`.
- [ ] La memoria breve documenta los cuatro `INSERT` que fallan y el código `ORA-xxxxx` recibido.

## Entrega final

Entrega:

1. El fichero `.sql` completo (parte 2).
2. Una memoria breve (10 a 15 líneas) con:
   - Las respuestas a las preguntas de los pasos 1 a 5 de la parte 1.
   - Los códigos `ORA-xxxxx` obtenidos en los `INSERT` que deben fallar.
   - Una decisión que dejarías para resolver más adelante en un package (por ejemplo, evitar borrar un tipo de bloqueo en uso).

::: tip SIGUIENTE PASO
Una vez entregado este ejercicio, estás listo para la [Sesión 2 — Tablas, vistas y paquetes](../3-tablas-vistas/), donde aplicarás el mismo patrón a un modelo con relaciones, rangos de fechas y un package CRUD completo.
:::
