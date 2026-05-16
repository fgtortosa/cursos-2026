CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_HORARIO_DIA_MAG" ("ID_HORARIO_DIA", "ID_FRANJA", "ID_RECURSO", "DIA", "HORA_INICIO", "MINUTO_INICIO", "HORA_FIN", "MINUTO_FIN", "BLOQUEADO", "ORDEN", "FECHA_INICIO_FRANJA", "FECHA_FIN_FRANJA", "NOMBRE_RECURSO_ES", "NOMBRE_RECURSO_CA", "NOMBRE_RECURSO_EN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de lectura: horarios por día con datos de franjas y recursos.

        IMPORTANTE: La vista trae los horarios por día tal cual están
        en `TRES_HORARIO_DIA` junto con los datos de franjas y recursos con LEFT JOIN a `TRES_FRANJA_HORARIO` y `TRES_RECURSO`.
        No aplico NVL(BLOQUEADO,'N') para evitar NULLs en consumidores porque el campo ya es NOT NULL y tiene un check
        que garantiza los valores 'S' o 'N'.

        12/05/2026  Manuel Arnaiz. Primera propuesta.*/
    hd.ID_HORARIO_DIA,
    hd.ID_FRANJA,
    hd.ID_RECURSO,
    hd.DIA,
    hd.HORA_INICIO,
    hd.MINUTO_INICIO,
    hd.HORA_FIN,
    hd.MINUTO_FIN,
    hd.BLOQUEADO,  /*Si hubiera decidido aplicar el NVL, sería: NVL(hd.BLOQUEADO, 'N') AS BLOQUEADO,*/
    hd.ORDEN,
    fh.FECHA_INICIO AS FECHA_INICIO_FRANJA,
    fh.FECHA_FIN    AS FECHA_FIN_FRANJA,
    r.NOMBRE_ES    AS NOMBRE_RECURSO_ES,
    r.NOMBRE_CA    AS NOMBRE_RECURSO_CA,
    r.NOMBRE_EN    AS NOMBRE_RECURSO_EN
  FROM CURSONORMADM.TRES_HORARIO_DIA hd
  LEFT JOIN CURSONORMADM.TRES_FRANJA_HORARIO fh ON fh.ID_FRANJA = hd.ID_FRANJA
  LEFT JOIN CURSONORMADM.TRES_RECURSO r ON r.ID_RECURSO = hd.ID_RECURSO;