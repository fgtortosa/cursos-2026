CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_HORARIO_DIA_SANT" ("ID_HORARIO_DIA", "ID_FRANJA", "ID_RECURSO", "DIA", "HORA_INICIO", "MINUTO_INICIO", "HORA_FIN", "MINUTO_FIN", "BLOQUEADO", "ORDEN", "NOMREC_ES", "NOMREC_CA", "NOMREC_EN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de horarios por día para franjas y horarios genéricos de recurso.
           IMPORTANTE: Expone tanto ID_FRANJA como ID_RECURSO para soportar horarios específicos y genéricos.
---------------------------------------------------------------
   11/05/2026  SANTIAGO MOYA -   Creacion de la vista
 ----------------------------------------------------------------                  
       */
  h.ID_HORARIO_DIA,
  h.ID_FRANJA,
  h.ID_RECURSO,
  h.DIA,
  h.HORA_INICIO,
  h.MINUTO_INICIO,
  h.HORA_FIN,
  h.MINUTO_FIN,
  h.BLOQUEADO,
  h.ORDEN
  ---
  ,r.NOMBRE_ES AS NOMREC_ES
  ,r.NOMBRE_CA AS NOMREC_CA
  ,r.NOMBRE_EN AS NOMREC_EN
  
FROM CURSONORMADM.TRES_HORARIO_DIA h
LEFT JOIN CURSONORMADM.TRES_RECURSO r ON h.ID_RECURSO = r.ID_RECURSO;