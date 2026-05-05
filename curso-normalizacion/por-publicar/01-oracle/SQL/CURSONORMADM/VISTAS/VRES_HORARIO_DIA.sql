CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_HORARIO_DIA" ("ID_HORARIO_DIA", "ID_FRANJA", "ID_RECURSO", "DIA", "HORA_INICIO", "MINUTO_INICIO", "HORA_FIN", "MINUTO_FIN", "BLOQUEADO", "ORDEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de horarios por día para franjas y horarios genéricos de recurso.


           IMPORTANTE: Expone tanto ID_FRANJA como ID_RECURSO para soportar horarios específicos y genéricos.


   26/02/2026  SERVICIOINFORMATICA  Creación de la vista.
   01/03/2026  SERVICIOINFORMATICA  Se normaliza el formato de definición y documentación de la vista.
   10/03/2026  SERVICIOINFORMATICA  Se confirma su uso exclusivo para lecturas desde .NET; las escrituras quedan delegadas a PKG_RES_HORARIO_DIA.
                       */
  ID_HORARIO_DIA,
  ID_FRANJA,
  ID_RECURSO,
  DIA,
  HORA_INICIO,
  MINUTO_INICIO,
  HORA_FIN,
  MINUTO_FIN,
  BLOQUEADO,
  ORDEN
FROM CURSONORMADM.TRES_HORARIO_DIA;