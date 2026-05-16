CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_HORARIO_DIA_ANAFR" ("ID_HORARIO_DIA", "ID_FRANJA", "ID_RECURSO", "DIA", "HORA_INICIO", "MINUTO_INICIO", "HORA_FIN", "MINUTO_FIN", "BLOQUEADO", "ORDEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT  /* Vista de Tramos horarios por dia de semana para recursos, ya sea sobre una franja especifica o como horario general del recurso.

           IMPORTANTE: No aplica ordenacion ni filtros de negocio

   14/05/2026  anafr  Creación de la vista.
      */
    hd.ID_HORARIO_DIA,
    hd.ID_FRANJA,
    hd.ID_RECURSO,
    hd.DIA,
    hd.HORA_INICIO,
    hd.MINUTO_INICIO,
    hd.HORA_FIN,
    hd.MINUTO_FIN,
    NVL(hd.BLOQUEADO, 'N') AS BLOQUEADO,
    hd.ORDEN
FROM CURSONORMADM.TRES_HORARIO_DIA hd;