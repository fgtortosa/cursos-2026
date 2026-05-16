CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_DAN_PAS" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO", "RECURSO_NOMBRE_ES", "RECURSO_NOMBRE_CA", "RECURSO_NOMBRE_EN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  (SELECT /* Vista de franjas horarias.

             IMPORTANTE:  vista que permita a la aplicación .NET consultar las franjas horarias asociadas a los recursos.

      2026-05-11  AUTOR  Descripción del cambio.
                           */
          fh.ID_FRANJA,
           fh.ID_RECURSO,
           fh.FECHA_INICIO,
           fh.FECHA_FIN,
           NVL (fh.ACTIVO, 'N') AS ACTIVO,
           r.NOMBRE_ES,
           r.NOMBRE_CA,
           r.NOMBRE_EN
      FROM CURSONORMADM.TRES_FRANJA_HORARIO fh, CURSONORMADM.TRES_RECURSO r
     WHERE fh.ID_RECURSO = r.ID_RECURSO AND fh.activo = 'S');