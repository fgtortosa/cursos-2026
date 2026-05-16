CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_AIV" ("ID_FRANJA", "ID_RECURSO", "NOMBRE_RECURSO_ES", "NOMBRE_RECURSO_CA", "NOMBRE_RECURSO_EN", "GRANULIDAD_RECURSO", "DURACION_RECURSO", "FLG_RECURSO_ACTIVO", "FLG_RECURSO_VISIBLE", "ID_TIPO_RECURSO", "CODIGO_TIPO_RECURSO", "NOMBRE_TIPO_RECURSO_ES", "NOMBRE_TIPO_RECURSO_CA", "NOMBRE_TIPO_RECURSO_EN", "FECHA_INICIO_FRANJA", "FECHA_FIN_FRANJA", "FLG_FRANJA_ACTIVA") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT 
        /* Vista de consulta de las franjas horarias asociadas a los recursos
            IMPORTANTE: <invariante o decisión clave>.
            2026-05-11  Ana Illanas  Creación de la vista.
        */
    frh.id_franja as ID_FRANJA,
    frh.id_recurso as ID_RECURSO,
    rec.nombre_es as NOMBRE_RECURSO_ES,
    rec.nombre_ca as NOMBRE_RECURSO_CA,
    rec.nombre_en as NOMBRE_RECURSO_EN,
    rec.granulidad as GRANULIDAD_RECURSO,
    rec.duracion as DURACION_RECURSO,
    rec.activo as FLG_RECURSO_ACTIVO,
    rec.visible as FLG_RECURSO_VISIBLE,
    rec.id_tipo_recurso as ID_TIPO_RECURSO,
    tip.codigo as CODIGO_TIPO_RECURSO,
    tip.nombre_es as NOMBRE_TIPO_RECURSO_ES,
    tip.nombre_ca as NOMBRE_TIPO_RECURSO_CA,
    tip.nombre_en as NOMBRE_TIPO_RECURSO_EN,
    frh.fecha_inicio as FECHA_INICIO_FRANJA,
    frh.fecha_fin as FECHA_FIN_FRANJA,
    frh.activo as FLG_FRANJA_ACTIVA
   FROM CURSONORMADM.TRES_FRANJA_HORARIO frh
   LEFT JOIN TRES_RECURSO rec ON rec.id_recurso = frh.id_recurso
   JOIN TRES_TIPO_RECURSO tip ON tip.id_tipo_recurso = rec.id_tipo_recurso;