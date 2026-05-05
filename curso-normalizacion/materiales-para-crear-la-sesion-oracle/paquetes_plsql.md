# Documentacion de Paquetes PL/SQL

Guia base para documentar y estructurar paquetes Oracle del proyecto `ReserUA`.

Esta guia toma como referencia el formato que ya se ha definido para las vistas y lo adapta a `PACKAGE` y `PACKAGE BODY`, con el objetivo de que cualquier paquete nuevo tenga:

- historial funcional visible al principio del fichero
- contrato claro entre especificacion y cuerpo
- reglas consistentes de validacion y errores
- una plantilla reutilizable para futuros desarrollos

## Objetivo

Todo paquete del proyecto debe permitir que un desarrollador pueda identificar rapidamente:

- que hace el paquete
- que procedimientos expone
- que validaciones relevantes aplica
- que dependencias tiene con tablas, vistas u otros paquetes
- que cambios funcionales se han ido incorporando con fecha

## Formato recomendado del fichero

Cada bloque de paquete debe seguir este esquema:

1. Historial funcional al inicio del fichero.
2. `CREATE OR REPLACE PACKAGE {ESQUEMA}.{NOMBRE}`.
3. Comentario corto dentro de la especificacion con la finalidad del paquete.
4. Declaracion ordenada de tipos, funciones y procedimientos publicos.
5. `CREATE OR REPLACE PACKAGE BODY {ESQUEMA}.{NOMBRE}`.
6. Comentario corto al inicio del body con reglas internas, validaciones o consideraciones relevantes.
7. Procedimientos privados primero (validaciones, utilidades).
8. Procedimientos publicos despues, en el mismo orden que en la especificacion.

## Historial funcional recomendado

El historial debe ir al principio del fichero, antes del `PACKAGE`, con el mismo criterio que ya se esta usando:

```sql
/* [01/03/2026 09:30:00] Alta paquete PKG_RES_EJEMPLO */
/* [02/03/2026 12:10:00] Modificacion PKG_RES_EJEMPLO (se añade validacion de capacidad) */
/* [03/03/2026 08:45:00] Modificacion PKG_RES_EJEMPLO (se incorpora procedimiento CAMBIAR_ESTADO) */
```

Reglas:

- Usar fecha y hora.
- Describir el cambio funcional, no solo el cambio tecnico.
- Si se añade un procedimiento nuevo, nombrarlo explicitamente.
- Si se cambia la firma publica, indicarlo.

## Mini documentacion dentro del PACKAGE

Igual que en las vistas, conviene dejar un bloque de descripcion breve al principio de la especificacion.

Plantilla recomendada:

```sql
CREATE OR REPLACE PACKAGE "CURSONORMADM".PKG_RES_EJEMPLO AS
  /* Paquete de gestion de ejemplo para altas, consultas, cambios y borrados.

     IMPORTANTE: Este paquete centraliza las validaciones de negocio que deben cumplirse
     antes de insertar o actualizar en la tabla principal.

     01/03/2026  SERVICIOINFORMATICA  Creacion del paquete.
     02/03/2026  SERVICIOINFORMATICA  Se añade validacion de capacidad.
  */

  TYPE T_CURSOR IS REF CURSOR;

  ...
END PKG_RES_EJEMPLO;
/
```

## Mini documentacion dentro del PACKAGE BODY

El `PACKAGE BODY` debe incluir un bloque equivalente, orientado a la implementacion.

Plantilla recomendada:

```sql
CREATE OR REPLACE PACKAGE BODY "CURSONORMADM".PKG_RES_EJEMPLO AS
  /* Implementacion del paquete PKG_RES_EJEMPLO.

     IMPORTANTE: Las validaciones privadas deben ejecutarse antes de cualquier INSERT o UPDATE.
     IMPORTANTE: Los mensajes de RAISE_APPLICATION_ERROR deben ser claros y reutilizables desde la API.

     01/03/2026  SERVICIOINFORMATICA  Creacion del body del paquete.
     02/03/2026  SERVICIOINFORMATICA  Se añade procedimiento privado VALIDAR_DATOS.
  */

  ...
END PKG_RES_EJEMPLO;
/
```

## Convenciones recomendadas para futuros paquetes

### 1. Nombres de procedimientos

Mantener verbos simples y sin prefijo `PRC_`:

- `CREAR`
- `OBTENER_TODOS`
- `OBTENER_POR_ID`
- `ACTUALIZAR`
- `ACTUALIZAR_ACTIVO`
- `CAMBIAR_CODPER`
- `ELIMINAR`

Si la accion es muy especifica, usar un nombre funcional y directo:

- `REEMPLAZAR_POR_FRANJA`
- `REEMPLAZAR_GENERICO_POR_RECURSO`
- `ACTUALIZAR_BLOQUEADO`

### 2. Orden recomendado en la especificacion

Ordenar siempre asi:

1. Tipos (`T_CURSOR`, tipos auxiliares)
2. Altas
3. Consultas
4. Modificaciones
5. Acciones especificas
6. Borrados

Esto reduce el coste de lectura y deja todos los paquetes con la misma estructura mental.

### 3. Orden recomendado en el body

Ordenar siempre asi:

1. Utilidades privadas
2. Validaciones privadas
3. Procedimientos publicos en el mismo orden que el `PACKAGE`

### 4. Parametros

Reglas recomendadas:

- Prefijo `P_` para todos los parametros.
- Tipar con `%TYPE` de tabla cuando aplique.
- Si devuelve un identificador creado, usar un `OUT`.
- Si devuelve listados o lecturas, usar `T_CURSOR`.
- Evitar usar `NULL` como valor semantico especial cuando el dominio tenga una codificacion explicita disponible.

Ejemplo:

```sql
PROCEDURE CREAR(
  P_ID_RECURSO IN  CURSONORMADM.TRES_RECURSO.ID_RECURSO%TYPE,
  P_NOMBRE     IN  CURSONORMADM.TRES_TABLA.NOMBRE%TYPE,
  P_ID_SALIDA  OUT CURSONORMADM.TRES_TABLA.ID%TYPE
);
```

### 5. Validaciones

Las validaciones de negocio repetibles deben extraerse a un procedimiento privado.

Ejemplo:

- `VALIDAR_DATOS`
- `VALIDAR_CAPACIDAD`
- `VALIDAR_RELACION`

Ventajas:

- una sola fuente de verdad
- menos duplicidad entre `CREAR` y `ACTUALIZAR`
- mensajes de error consistentes

Si el dominio exige valores cerrados, validarlos de forma estricta.

Ejemplo:

- para dias de la semana, exigir siempre `1..7`
- no reutilizar `NULL` como equivalente a "todos los dias"

### 6. Errores de negocio

Usar `RAISE_APPLICATION_ERROR` para errores funcionales.

Recomendaciones:

- Mensajes claros y orientados a usuario o API.
- No usar mensajes ambiguos como `Error de validacion`.
- Mantener coherencia entre procedimientos del mismo paquete.
- Reutilizar el mismo mensaje cuando la misma regla falle en distintas operaciones.

Formato recomendado:

```sql
RAISE_APPLICATION_ERROR(-20306, 'No hay capacidad disponible para la reserva en la franja horaria seleccionada.');
```

Buenas practicas:

- Reservar rangos de error por paquete o dominio funcional si es posible.
- Documentar en el comentario del body si un paquete ya usa un rango concreto.

### 7. SELECT de lectura

Cuando un paquete exponga datos para la aplicacion:

- Priorizar `VRES_*` frente a repetir joins complejos.
- Hacer que `OBTENER_TODOS` y `OBTENER_POR_ID` lean de la vista funcional.
- Dejar el `ORDER BY` en el paquete cuando forme parte del contrato esperado.

### 8. Dependencias

Si un paquete depende de tablas o vistas criticas, conviene documentarlo en la cabecera.

Ejemplo:

- tabla principal: `TRES_RESERVA`
- vista de lectura: `VRES_RESERVA`
- tabla auxiliar: `TRES_RECURSO`

Esto ayuda a revisar impactos cuando cambia el modelo de datos.

## Plantilla base recomendada

```sql
/* [01/03/2026 09:30:00] Alta paquete PKG_RES_EJEMPLO */

CREATE OR REPLACE PACKAGE "CURSONORMADM".PKG_RES_EJEMPLO AS
  /* Paquete de gestion de la entidad EJEMPLO.

     IMPORTANTE: Centraliza las reglas de negocio previas a insertar, actualizar o borrar.

     01/03/2026  SERVICIOINFORMATICA  Creacion del paquete.
  */

  TYPE T_CURSOR IS REF CURSOR;

  PROCEDURE CREAR(
    P_NOMBRE IN CURSONORMADM.TRES_EJEMPLO.NOMBRE%TYPE,
    P_ID     OUT CURSONORMADM.TRES_EJEMPLO.ID%TYPE
  );

  PROCEDURE OBTENER_TODOS(
    P_CURSOR OUT T_CURSOR
  );

  PROCEDURE OBTENER_POR_ID(
    P_ID     IN  CURSONORMADM.TRES_EJEMPLO.ID%TYPE,
    P_CURSOR OUT T_CURSOR
  );

  PROCEDURE ACTUALIZAR(
    P_ID     IN CURSONORMADM.TRES_EJEMPLO.ID%TYPE,
    P_NOMBRE IN CURSONORMADM.TRES_EJEMPLO.NOMBRE%TYPE
  );

  PROCEDURE ELIMINAR(
    P_ID IN CURSONORMADM.TRES_EJEMPLO.ID%TYPE
  );
END PKG_RES_EJEMPLO;
/

CREATE OR REPLACE PACKAGE BODY "CURSONORMADM".PKG_RES_EJEMPLO AS
  /* Implementacion del paquete PKG_RES_EJEMPLO.

     IMPORTANTE: VALIDAR_DATOS debe ejecutarse antes de CREAR y ACTUALIZAR.

     01/03/2026  SERVICIOINFORMATICA  Creacion del body del paquete.
  */

  PROCEDURE VALIDAR_DATOS(
    P_NOMBRE IN CURSONORMADM.TRES_EJEMPLO.NOMBRE%TYPE
  ) AS
  BEGIN
    IF P_NOMBRE IS NULL THEN
      RAISE_APPLICATION_ERROR(-20400, 'El nombre es obligatorio.');
    END IF;
  END VALIDAR_DATOS;

  PROCEDURE CREAR(
    P_NOMBRE IN CURSONORMADM.TRES_EJEMPLO.NOMBRE%TYPE,
    P_ID     OUT CURSONORMADM.TRES_EJEMPLO.ID%TYPE
  ) AS
  BEGIN
    VALIDAR_DATOS(P_NOMBRE);

    INSERT INTO CURSONORMADM.TRES_EJEMPLO (NOMBRE)
    VALUES (P_NOMBRE)
    RETURNING ID INTO P_ID;
  END CREAR;

  PROCEDURE OBTENER_TODOS(
    P_CURSOR OUT T_CURSOR
  ) AS
  BEGIN
    OPEN P_CURSOR FOR
      SELECT ID, NOMBRE
      FROM CURSONORMADM.VRES_EJEMPLO
      ORDER BY ID;
  END OBTENER_TODOS;

  PROCEDURE OBTENER_POR_ID(
    P_ID     IN  CURSONORMADM.TRES_EJEMPLO.ID%TYPE,
    P_CURSOR OUT T_CURSOR
  ) AS
  BEGIN
    OPEN P_CURSOR FOR
      SELECT ID, NOMBRE
      FROM CURSONORMADM.VRES_EJEMPLO
      WHERE ID = P_ID;
  END OBTENER_POR_ID;

  PROCEDURE ACTUALIZAR(
    P_ID     IN CURSONORMADM.TRES_EJEMPLO.ID%TYPE,
    P_NOMBRE IN CURSONORMADM.TRES_EJEMPLO.NOMBRE%TYPE
  ) AS
  BEGIN
    VALIDAR_DATOS(P_NOMBRE);

    UPDATE CURSONORMADM.TRES_EJEMPLO
       SET NOMBRE = P_NOMBRE
     WHERE ID = P_ID;
  END ACTUALIZAR;

  PROCEDURE ELIMINAR(
    P_ID IN CURSONORMADM.TRES_EJEMPLO.ID%TYPE
  ) AS
  BEGIN
    DELETE FROM CURSONORMADM.TRES_EJEMPLO
     WHERE ID = P_ID;
  END ELIMINAR;
END PKG_RES_EJEMPLO;
/
```

## Checklist para revisar un paquete antes de darlo por valido

- El historial funcional del fichero esta actualizado.
- La especificacion y el body tienen mini documentacion.
- Los procedimientos publicos estan ordenados de forma consistente.
- Las validaciones repetibles se han extraido a procedimientos privados.
- Los mensajes de `RAISE_APPLICATION_ERROR` son claros.
- Las consultas publicas leen de `VRES_*` cuando aplica.
- Los nombres de procedimientos son funcionales y no usan `PRC_`.
- El paquete y sus cambios funcionales estan alineados con `Services/`.

## Recomendacion para la documentacion general

Si esta guia se incorpora a la documentacion general del proyecto, conviene añadir estas reglas como obligatorias:

- Todo paquete nuevo debe incluir historial funcional al inicio del fichero.
- Todo `PACKAGE` y `PACKAGE BODY` debe incluir un bloque corto de descripcion.
- Toda validacion de negocio relevante debe estar centralizada en el propio paquete si afecta a integridad de datos.
- Todo cambio de firma publica debe reflejarse en el historial del fichero y en el servicio C# asociado.
- Todo paquete debe intentar exponer un contrato estable y predecible para la capa `Services`.

Con esto, las vistas y los paquetes quedan documentados con una misma filosofia: descripcion funcional, puntos importantes, historial de cambios y estructura estable.

