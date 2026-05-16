CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_MARILOLT" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de franjas horarias asociadas a un recurso.


           IMPORTANTE: Incluye ID_RECURSO para filtrar y gestionar las franjas por recurso.

            2026-05-11  MARILO LT  Creación de la vista.
                       */
  ID_FRANJA,
  ID_RECURSO,
  FECHA_INICIO,
  FECHA_FIN,
  ACTIVO
FROM CURSONORMADM.VRES_FRANJA_HORARIO;