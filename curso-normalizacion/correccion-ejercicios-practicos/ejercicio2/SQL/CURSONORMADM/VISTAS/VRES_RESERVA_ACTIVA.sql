CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_RESERVA_ACTIVA" ("ID_RESERVA", "ID_RECURSO", "FECHA_RESERVA", "HORA_INICIO", "MINUTO_INICIO", "MINUTOS_RESERVA", "FECHA_HORA_INICIO", "FECHA_HORA_FIN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista especializada para CHEQUEO DE SOLAPAMIENTOS.

           Por que existe:
             - TRES_RESERVA guarda la hora de inicio descompuesta (HORA_INICIO,
               MINUTO_INICIO) y la duracion en MINUTOS_RESERVA. Para detectar
               solapamientos hay que trabajar con dos DATE: inicio y fin.
             - Calcular esos DATE en cada consulta desde .NET es repetitivo y
               propenso a errores. La vista los expone ya calculados.
             - Solo se incluyen reservas a partir de HOY: las pasadas no pueden
               solapar con una reserva nueva. Asi reducimos el conjunto que
               recorre el indice.

           Que NO expone:
             - CODPER, OBSERVACIONES, FECHA_ALTA, FECHA_CONFIRMACION. La vista
               sirve a una unica funcion (detectar solape) y limita los campos
               al minimo necesario. CODPER especialmente: no debe salir de la
               BD hacia capas que no lo necesiten.

           Aritmetica de fechas Oracle:
             - DATE + N suma N dias.
             - HORA_INICIO/24 + MINUTO_INICIO/1440 da el desfase en dias hasta
               las HH:MM correspondientes.

   14/05/2026  SERVICIOINFORMATICA  Creacion para soportar ReservaCrearValidator.
                       */
    ID_RESERVA,
    ID_RECURSO,
    FECHA_RESERVA,
    HORA_INICIO,
    MINUTO_INICIO,
    MINUTOS_RESERVA,
    FECHA_RESERVA + (HORA_INICIO / 24) + (MINUTO_INICIO / 1440)
        AS FECHA_HORA_INICIO,
    FECHA_RESERVA + (HORA_INICIO / 24) + (MINUTO_INICIO / 1440)
                  + (MINUTOS_RESERVA / 1440)
        AS FECHA_HORA_FIN
  FROM CURSONORMADM.TRES_RESERVA
  WHERE FECHA_RESERVA >= TRUNC(SYSDATE);