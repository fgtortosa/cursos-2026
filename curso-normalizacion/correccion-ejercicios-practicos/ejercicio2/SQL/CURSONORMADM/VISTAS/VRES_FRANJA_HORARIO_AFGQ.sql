CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_AFGQ" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /******************************************************************************
                      NAME:       VRES_FRANJA_HORARIO_AFGQ
                      PURPOSE:  Obtiene las franjas horarias asociadas a los recursos.
                                       El campo ACTIVO se incluye para que su pueda activar en un mantenimiento de registros

                      REVISIONS:
                      Ver        Date        Author           Description
                      ---------  ----------  ---------------  ------------------------------------
                      1.0        11/052026  Antonio            1. Created this package.
                   ******************************************************************************/
          ID_FRANJA,
          ID_RECURSO,
          FECHA_INICIO,
          FECHA_FIN,
          ACTIVO
     FROM CURSONORMADM.TRES_FRANJA_HORARIO;