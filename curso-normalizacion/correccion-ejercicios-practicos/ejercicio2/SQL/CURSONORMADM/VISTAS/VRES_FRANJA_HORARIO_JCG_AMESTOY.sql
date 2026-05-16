CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_JCG_AMESTOY" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT 
  /*
    11/05/2026 Juan Carlos González Amestoy 
    No se muestran mas datos ya que cruzar implica rendimiento y no se ha pedido
    Añado activo y que decida el consumidor
  */
    ID_FRANJA,
    ID_RECURSO,
    FECHA_INICIO,
    FECHA_FIN,
    ACTIVO
   FROM CURSONORMADM.TRES_FRANJA_HORARIO;