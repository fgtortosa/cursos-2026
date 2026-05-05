CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de franjas horarias asociadas a un recurso.


           IMPORTANTE: Incluye ID_RECURSO para filtrar y gestionar las franjas por recurso.


   26/02/2026  SERVICIOINFORMATICA  Se actualiza la vista para incluir ID_RECURSO.
   01/03/2026  SERVICIOINFORMATICA  Se normaliza el formato de definición y documentación de la vista.
                       */
  ID_FRANJA,
  ID_RECURSO,
  FECHA_INICIO,
  FECHA_FIN,
  ACTIVO
FROM CURSONORMADM.TRES_FRANJA_HORARIO;