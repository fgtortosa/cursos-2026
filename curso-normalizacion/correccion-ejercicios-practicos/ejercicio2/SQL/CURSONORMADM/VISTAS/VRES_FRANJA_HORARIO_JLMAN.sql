CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_JLMAN" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT 
  /*
    Vista de franjas horarias asociadas a un recurso.
    14/05/2026 	JLMAN	 Creación de vista 
    No conviene JOIN, no se especifica su necesidad 
    Dejamos activo y lo filtra el usuario
  */
    ID_FRANJA,
    ID_RECURSO,
    FECHA_INICIO,
    FECHA_FIN,
    ACTIVO
   FROM CURSONORMADM.TRES_FRANJA_HORARIO;