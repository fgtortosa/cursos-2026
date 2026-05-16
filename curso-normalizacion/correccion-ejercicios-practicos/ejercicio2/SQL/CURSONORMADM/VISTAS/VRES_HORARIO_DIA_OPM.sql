CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_HORARIO_DIA_OPM" ("ID_HORARIO_DIA", "ID_FRANJA", "ID_RECURSO", "DIA", "HORA_INICIO", "MINUTO_INICIO", "HORA_FIN", "MINUTO_FIN", "BLOQUEADO", "ORDEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de horarios por día para franjas y horarios genéricos de recurso.

         IMPORTANTE: Expone tanto ID_FRANJA como ID_RECURSO para soportar 
                     horarios específicos (con franja) y genéricos (solo recurso).
                     NVL(BLOQUEADO, 'N') evita NULL en la aplicación .NET.

 2026-05-11  Óscar Pina  Creación de la vista.
                       */
  ID_HORARIO_DIA,
  ID_FRANJA,
  ID_RECURSO,
  DIA,
  HORA_INICIO,
  MINUTO_INICIO,
  HORA_FIN,
  MINUTO_FIN,
  NVL(BLOQUEADO, 'N') AS BLOQUEADO,
  ORDEN
FROM CURSONORMADM.TRES_HORARIO_DIA;