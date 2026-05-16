CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_JPUIG" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista que permite consultar las franjas horarias asociadas
            a los recursos

         IMPORTANTE: ID_RECURSO se usa para filtrar el recurso

        20260511  JAVIER PUIG Creación de la vista
                       */
    ID_FRANJA,
    ID_RECURSO,
    FECHA_INICIO,
    FECHA_FIN,
    ACTIVO
FROM CURSONORMADM.TRES_FRANJA_HORARIO;