create or replace force editionable view "CURSONORMADM"."VRES_FRANJA_HORARIO" (
   "ID_FRANJA",
   "ID_RECURSO",
   "FECHA_INICIO",
   "FECHA_FIN",
   "ACTIVO"
) default collation "USING_NLS_COMP" as
   select /* Franjas especificas por recurso acotadas por fechas, usadas para definir
           disponibilidad o bloqueos puntuales del recurso.

           IMPORTANTE: Incluye ID_RECURSO para filtrar las franjas por recurso y ACTIVO
           para distinguir franjas vigentes de las dadas de baja logicamente.

   26/02/2026  SERVICIOINFORMATICA  Creacion de la vista.
   01/03/2026  SERVICIOINFORMATICA  Se normaliza el formato de definicion y documentacion de la vista.
   11/05/2026  SERVICIOINFORMATICA  Se actualiza el comentario con la descripcion oficial de la tabla.
                       */ id_franja,
          id_recurso,
          fecha_inicio,
          fecha_fin,
          activo
     from cursonormadm.tres_franja_horario;