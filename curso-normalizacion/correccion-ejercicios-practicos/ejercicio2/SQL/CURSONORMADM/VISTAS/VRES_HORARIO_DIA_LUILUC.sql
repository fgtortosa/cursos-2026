CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_HORARIO_DIA_LUILUC" ("ID_HORARIO_DIA", "ID_FRANJA", "ID_RECURSO", "DIA", "HORA_INICIO", "MINUTO_INICIO", "HORA_FIN", "MINUTO_FIN", "BLOQUEADO", "ORDEN", "FECHA_INICIO_FRANJA", "FECHA_FIN_FRANJA") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de consulta de horarios diarios asociados
           a franjas horarias o recursos genéricos.

         IMPORTANTE: Se aplica NVL(BLOQUEADO, 'N')
                     para simplificar el consumo desde .NET
                     y evitar repetir NVL en cada SELECT
                     del servicio.

         IMPORTANTE: El JOIN con TRES_FRANJA_HORARIO_LUILUC
                     es LEFT JOIN porque existen horarios
                     genéricos con ID_FRANJA NULL.

         IMPORTANTE: La vista no aplica ORDER BY.
                     Cada consumidor decide el orden
                     funcional que necesita.

  2026-05-11  LUILUC  Creación inicial de la vista.
                       */
       HD.ID_HORARIO_DIA,
       HD.ID_FRANJA,
       HD.ID_RECURSO,
       HD.DIA,
       HD.HORA_INICIO,
       HD.MINUTO_INICIO,
       HD.HORA_FIN,
       HD.MINUTO_FIN,
       NVL(HD.BLOQUEADO, 'N') AS BLOQUEADO,
       HD.ORDEN,
       FH.FECHA_INICIO AS FECHA_INICIO_FRANJA,
       FH.FECHA_FIN    AS FECHA_FIN_FRANJA
  FROM CURSONORMADM.TRES_HORARIO_DIA_LUILUC HD
       LEFT JOIN CURSONORMADM.TRES_FRANJA_HORARIO_LUILUC FH
              ON FH.ID_FRANJA = HD.ID_FRANJA;