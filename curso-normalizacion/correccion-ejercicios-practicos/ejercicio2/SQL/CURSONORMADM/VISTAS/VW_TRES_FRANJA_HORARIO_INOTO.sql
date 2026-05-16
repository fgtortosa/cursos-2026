CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VW_TRES_FRANJA_HORARIO_INOTO" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT/* Vista de franjas horarias asociadas a un recurso.
        IMPORTANTE: Incluye ID_RECURSO para filtrar y gestionar las franjas por recurso.
		---------------------------------------------------------------
		11/05/2026  Francisco Javier Inoto-   Creacion de la vista
		---------------------------------------------------------------*/
    ID_FRANJA,
    ID_RECURSO,
    FECHA_INICIO,
    FECHA_FIN,
    NVL(ACTIVO,'N') AS ACTIVO
FROM CURSONORMADM.TRES_FRANJA_HORARIO;