CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_MAG" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO", "NOMBRE_RECURSO_ES", "NOMBRE_RECURSO_CA", "NOMBRE_RECURSO_EN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
/* Vista de lectura: franjas horarias de recursos.

             IMPORTANTE: La vista trae las franjas tal cual están
             en `TRES_FRANJA_HORARIO` junto con los nombres multiidioma de recursos con LEFT JOIN a `TRES_RECURSO`.
             No filtro por `ACTIVO` para permitir que la aplicación decida el criterio de filtrado.
             No aplico NVL(ACTIVO,'N') para evitar NULLs en consumidores porque el campo ya es NOT NULL y tiene un check
             que garantiza los valores 'S' o 'N'.

     12/05/2026  Manuel Arnaiz. Primera propuesta.*/
    fh.ID_FRANJA,
    fh.ID_RECURSO,
    fh.FECHA_INICIO,
    fh.FECHA_FIN,
    fh.ACTIVO,  /*Si hubiera decidido aplicar el NVL, sería: NVL(fh.ACTIVO,'N') AS ACTIVO,*/
    r.NOMBRE_ES   AS NOMBRE_RECURSO_ES,
    r.NOMBRE_CA   AS NOMBRE_RECURSO_CA,
    r.NOMBRE_EN   AS NOMBRE_RECURSO_EN
  FROM CURSONORMADM.TRES_FRANJA_HORARIO fh
  LEFT JOIN CURSONORMADM.TRES_RECURSO r ON r.ID_RECURSO = fh.ID_RECURSO;