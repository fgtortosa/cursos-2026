---
title: "Guia profesor - Sesion 2 Oracle"
description: Guia de imparticion para la segunda sesion Oracle usando TRES_TIPO_RECURSO, VRES_TIPO_RECURSO y PKG_RES_TIPO_RECURSO del schema real.
outline: [2, 3]
---

# Guia profesor - Sesion 2 Oracle

## Objetivo docente

La sesion debe dejar claro que **manda el SQL real**. La entidad guia es:

- Tabla: `CURSONORMADM.TRES_TIPO_RECURSO`
- Vista: `CURSONORMADM.VRES_TIPO_RECURSO`
- Package: `CURSONORMADM.PKG_RES_TIPO_RECURSO`

No usar entidades que no aparezcan en la carpeta `SQL` ni explicar borrado logico sobre esta entidad: `TRES_TIPO_RECURSO` no tiene columna `ACTIVO`.

## Preparacion previa

Antes de la sesion, comprueba:

```sql
SELECT object_name, object_type, status
  FROM all_objects
 WHERE owner = 'CURSONORMADM'
   AND object_name IN (
       'TRES_TIPO_RECURSO',
       'VRES_TIPO_RECURSO',
       'PKG_RES_TIPO_RECURSO'
   )
 ORDER BY object_name, object_type;
```

Tambien conviene revisar que `CURSONORMWEB` puede leer la vista y ejecutar el package:

```sql
SELECT *
  FROM CURSONORMADM.VRES_TIPO_RECURSO;
```

## Guion de 1 hora

| Bloque | Min | Contenido |
|--------|-----|-----------|
| Arranque | 5 | Recordar ADM/WEB y que el SQL exportado es la fuente canonica |
| Tabla | 12 | Revisar columnas, `IDENTITY`, `PK_TRES_TIPO_RECURSO`, `UK_TRES_TIPO_RECURSO_CODIGO` y checks `SYS_CK_TTR_*` |
| Vista | 8 | Explicar `VRES_TIPO_RECURSO`: columnas explicitas, sin `SELECT *`, sin filtro `ACTIVO` |
| Package | 18 | Revisar SPEC, validaciones privadas, `RETURNING ... INTO`, `SQL%ROWCOUNT` y proteccion de `ELIMINAR` |
| Practica | 12 | Ejecutar verificaciones con `all_constraints`, `all_objects`, prueba de lectura y prueba controlada de alta/borrado |
| Cierre | 5 | Conectar con el ejercicio entregable de reservas |

## Momentos clave

### 1. La PK real no se llama `ID`

Recalcar que la clave primaria es `ID_TIPO_RECURSO`. Esto es importante para:

- Automapeo en .NET.
- Parametros del package (`P_ID_TIPO_RECURSO`).
- FKs desde `TRES_RECURSO`.

### 2. No hay borrado logico en esta entidad

Frase recomendada:

> "No todas las tablas tienen `ACTIVO`. En `TRES_TIPO_RECURSO`, el SQL real no lo tiene. Por tanto, no inventamos un `ACTUALIZAR_ACTIVO` ni un filtro `WHERE ACTIVO = 'S'`."

### 3. `ELIMINAR` no es libre

Mostrar esta idea del package:

```sql
SELECT COUNT(*)
  INTO V_TOTAL_RECURSOS
  FROM CURSONORMADM.TRES_RECURSO
 WHERE ID_TIPO_RECURSO = P_ID_TIPO_RECURSO;
```

Si hay recursos asociados, el package lanza `-20703`. Es una regla funcional que protege el catalogo.

### 4. La vista es contrato, no comodidad

Aunque la vista expone las mismas columnas que la tabla, sigue siendo necesaria:

- WEB lee vistas, no tablas.
- El contrato de lectura queda estabilizado.
- Si mañana se añade una columna interna, no se expone automaticamente.

## Practica guiada

### Ejercicio 1 - Estructura de tabla

Pedir que ejecuten:

```sql
DESCRIBE CURSONORMADM.TRES_TIPO_RECURSO;

SELECT constraint_name, constraint_type, status
  FROM all_constraints
 WHERE owner = 'CURSONORMADM'
   AND table_name = 'TRES_TIPO_RECURSO'
 ORDER BY constraint_name;
```

Resultado esperado:

- PK `PK_TRES_TIPO_RECURSO`
- UK `UK_TRES_TIPO_RECURSO_CODIGO`
- checks `SYS_CK_TTR_*`

### Ejercicio 2 - Acceso ADM/WEB

Como `CURSONORMWEB`:

```sql
SELECT ID_TIPO_RECURSO, CODIGO, NOMBRE_ES
  FROM CURSONORMADM.VRES_TIPO_RECURSO;
```

Despues intentar:

```sql
SELECT *
  FROM CURSONORMADM.TRES_TIPO_RECURSO;
```

Debe fallar si los grants estan correctamente separados.

### Ejercicio 3 - Package valido

```sql
SELECT object_name, object_type, status
  FROM all_objects
 WHERE owner = 'CURSONORMADM'
   AND object_name = 'PKG_RES_TIPO_RECURSO'
 ORDER BY object_type;
```

Si aparece `INVALID`, revisar:

```sql
SELECT name, type, line, position, text
  FROM all_errors
 WHERE owner = 'CURSONORMADM'
   AND name = 'PKG_RES_TIPO_RECURSO'
 ORDER BY sequence;
```

### Ejercicio 4 - Alta controlada y limpieza

Usar el bloque de la sesion para crear `TEST_CURSO`, imprimir el ID y eliminarlo. Insistir en revisar antes si ya existe.

## Errores frecuentes

| Sintoma | Causa | Respuesta docente |
|---------|-------|-------------------|
| Buscan `ACTIVO` | Arrastran el patron generico de borrado logico | Recordar que esta entidad no tiene estado en el SQL real |
| Usan `ID` en lugar de `ID_TIPO_RECURSO` | Copian plantillas genericas | Volver al `DESCRIBE` de la tabla |
| `ORA-00942` como WEB al leer tabla | Intentan acceder a tabla ADM directamente | Explicar que WEB solo lee `VRES_TIPO_RECURSO` |
| `ORA-00001` al crear | `CODIGO` duplicado | Mostrar `UK_TRES_TIPO_RECURSO_CODIGO` |
| `ORA-20703` al eliminar | Hay recursos asociados | Explicar la regla funcional del package |

## Cierre hacia el ejercicio

Mensaje recomendado:

> "Ahora hemos visto una entidad real de catalogo. El ejercicio no consiste en copiarla: vais a diseñar tablas de reservas, franjas y horarios, donde aparecen FKs, rangos de fechas, horas y decisiones que no se resuelven con un catalogo simple."

Recordar que el ejercicio se entrega como SQL completo y que la solucion de referencia queda oculta hasta que se decida publicarla.
