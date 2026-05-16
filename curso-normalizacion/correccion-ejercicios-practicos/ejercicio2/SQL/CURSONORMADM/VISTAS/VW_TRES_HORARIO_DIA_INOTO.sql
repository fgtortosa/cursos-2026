CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VW_TRES_HORARIO_DIA_INOTO" ("ID_HORARIO_DIA", "ID_FRANJA", "ID_RECURSO", "DIA", "HORA_INICIO", "MINUTO_INICIO", "HORA_FIN", "MINUTO_FIN", "ORDEN", "BLOQUEADO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de franjas horarias del dia         
		---------------------------------------------------------------
		11/05/2026  Francisco Javier Inoto-   Creacion de la vista
		---------------------------------------------------------------*/
    ID_HORARIO_DIA,
    ID_FRANJA,
    ID_RECURSO,
    DIA,
    HORA_INICIO,
    MINUTO_INICIO,
    HORA_FIN,
    MINUTO_FIN,
    ORDEN,
    NVL(BLOQUEADO,'N') AS BLOQUEADO
FROM CURSONORMADM.TRES_HORARIO_DIA;