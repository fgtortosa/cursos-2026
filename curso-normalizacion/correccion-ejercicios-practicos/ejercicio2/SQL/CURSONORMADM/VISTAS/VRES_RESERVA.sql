CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_RESERVA" ("ID_RESERVA", "ID_RECURSO", "CODPER", "HORA_INICIO", "MINUTO_INICIO", "MINUTOS_RESERVA", "FECHA_RESERVA", "FECHA_ALTA", "FECHA_CONFIRMACION", "OBSERVACIONES") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select /* Vista de reservas base de la aplicacion.

           IMPORTANTE: Expone las columnas de TRES_RESERVA para lectura desde .NET. Las escrituras se delegan a PKG_RES_RESERVA.

   29/04/2026  SERVICIOINFORMATICA  Creacion de la vista.
                       */ id_reserva,
          id_recurso,
          codper,
          hora_inicio,
          minuto_inicio,
          minutos_reserva,
          fecha_reserva,
          fecha_alta,
          fecha_confirmacion,
          observaciones
     from cursonormadm.tres_reserva;