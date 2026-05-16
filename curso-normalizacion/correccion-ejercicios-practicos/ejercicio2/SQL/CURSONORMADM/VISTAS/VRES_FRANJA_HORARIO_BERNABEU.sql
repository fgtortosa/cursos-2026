CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_BERNABEU" ("ID_FRANJA", "ID_RECURSO", "NOMBRE_RECURSO_ES", "NOMBRE_RECURSO_CA", "NOMBRE_RECURSO_EN", "DESCRIPCION_RECURSO_ES", "DESCRIPCION_RECURSO_CA", "DESCRIPCION_RECURSO_EN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT fh.id_franja, fh.id_recurso, r.nombre_es as nombre_recurso_es, r.nombre_ca as nombre_recurso_ca,  r.nombre_en as nombre_recurso_en,  r.descripcion_es as descripcion_recurso_es, r.descripcion_ca as descripcion_recurso_ca, r.descripcion_en as descripcion_recurso_en
  FROM CURSONORMADM.TRES_FRANJA_HORARIO fh, TRES_RECURSO r
   WHERE fh.id_recurso = r.id_recurso
     and fh.activo = 'S';