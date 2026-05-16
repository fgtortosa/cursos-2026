CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_SANT" ("ID_FRANJA", "ID_RECURSO", "FECHA_INI", "FECHA_FIN", "ACTIVO", "NOMREC_ES", "NOMREC_CA", "NOMREC_EN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de franjas horarias asociadas a un recurso.
           IMPORTANTE: Incluye ID_RECURSO para filtrar y gestionar las franjas por recurso.
---------------------------------------------------------------
   11/05/2026  SANTIAGO MOYA -   Creacion de la vista
 ---------------------------------------------------------------
      */
  f.ID_FRANJA,
  f.ID_RECURSO,
  f.FECHA_INICIO AS FECHA_INI,
  f.FECHA_FIN AS,
  f.ACTIVO
  ---
  ,r.NOMBRE_ES AS NOMREC_ES
  ,r.NOMBRE_CA AS NOMREC_CA
  ,r.NOMBRE_EN AS NOMREC_EN
  
FROM CURSONORMADM.TRES_FRANJA_HORARIO f
JOIN CURSONORMADM.TRES_RECURSO r ON f.ID_RECURSO = r.ID_RECURSO

-- WHERE ACTIVO = 'S' ---> NO, la vista debe devolver todas las FRANJAS, no solo las activas;