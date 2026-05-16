CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_RECURSO" ("ID_RECURSO", "NOMBRE_ES", "NOMBRE_CA", "NOMBRE_EN", "DESCRIPCION_ES", "DESCRIPCION_CA", "DESCRIPCION_EN", "GRANULIDAD", "DURACION", "VISIBLE", "ATIENDE_MISMA_PERSONA", "ID_TIPO_RECURSO", "TIPO_CODIGO", "TIPO_NOMBRE_ES", "TIPO_NOMBRE_CA", "TIPO_NOMBRE_EN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de recursos reservables enriquecida con su tipo.

           IMPORTANTE:
             - Solo se exponen recursos ACTIVOS (borrado logico aplicado en el WHERE).
             - NO se proyectan ACTIVO ni FECHA_MODIFICACION: son metadatos internos
               de auditoria/borrado que no deben llegar al cliente. La vista es el
               primer filtro de "que datos viajan al exterior".
             - JOIN con TRES_TIPO_RECURSO en formato plano (TIPO_CODIGO, TIPO_NOMBRE_xx)
               para poder mapearla directamente a una clase plana en .NET, util para
               DataTable. La composicion anidada (objeto Tipo dentro) se hace, si se
               necesita, en la capa de API al proyectar a un DTO de detalle.
             - LEFT JOIN: ID_TIPO_RECURSO es opcional, no perdemos recursos sin tipo.

   04/03/2026  SERVICIOINFORMATICA  Creacion de la vista para alimentar el DataTable
                                    de recursos (sesion 1 del curso de normalizacion).
                       */
    R.ID_RECURSO,
    R.NOMBRE_ES,
    R.NOMBRE_CA,
    R.NOMBRE_EN,
    R.DESCRIPCION_ES,
    R.DESCRIPCION_CA,
    R.DESCRIPCION_EN,
    R.GRANULIDAD,
    R.DURACION,
    R.VISIBLE,
    R.ATIENDE_MISMA_PERSONA,
    R.ID_TIPO_RECURSO,
    T.CODIGO     AS TIPO_CODIGO,
    T.NOMBRE_ES  AS TIPO_NOMBRE_ES,
    T.NOMBRE_CA  AS TIPO_NOMBRE_CA,
    T.NOMBRE_EN  AS TIPO_NOMBRE_EN
  FROM CURSONORMADM.TRES_RECURSO R
  LEFT JOIN CURSONORMADM.TRES_TIPO_RECURSO T
         ON T.ID_TIPO_RECURSO = R.ID_TIPO_RECURSO
  WHERE R.ACTIVO = 'S';