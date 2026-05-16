CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_HORARIO_DIA_MAJOBLA" ("ID_HORARIO_DIA", "ID_FRANJA", "ID_RECURSO", "NOMBRE_ES", "NOMBRE_CA", "NOMBRE_EN", "FECHA_INICIO_FRANJA", "FECHA_FIN_FRANJA", "DIA", "HORA_INICIO", "MINUTO_INICIO", "HORA_FIN", "MINUTO_FIN", "ORDEN", "BLOQUEADO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de consulta de tramos horarios asociados
          a recursos y franjas horarias.

         IMPORTANTE: La vista devuelve tanto horarios genéricos
                     de recurso como horarios específicos de franja.

                     No se filtran franjas activas ni bloqueos.
                     La aplicación decide el filtrado según el
                     caso de uso funcional.

        2026-05-13  mblanes  Creación inicial de la vista.
                       */
       HD.ID_HORARIO_DIA,
       HD.ID_FRANJA,
       HD.ID_RECURSO,
       R.NOMBRE_ES,
       R.NOMBRE_CA,
       R.NOMBRE_EN,
       FH.FECHA_INICIO AS FECHA_INICIO_FRANJA,
       FH.FECHA_FIN    AS FECHA_FIN_FRANJA,
       HD.DIA,
       HD.HORA_INICIO,
       HD.MINUTO_INICIO,
       HD.HORA_FIN,
       HD.MINUTO_FIN,
       HD.ORDEN,
       NVL(HD.BLOQUEADO, 'N') AS BLOQUEADO
FROM CURSONORMADM.TRES_HORARIO_DIA HD
     LEFT JOIN CURSONORMADM.TRES_FRANJA_HORARIO FH
         ON FH.ID_FRANJA = HD.ID_FRANJA
     LEFT JOIN CURSONORMADM.TRES_RECURSO R
         ON R.ID_RECURSO =
              NVL(HD.ID_RECURSO, FH.ID_RECURSO);