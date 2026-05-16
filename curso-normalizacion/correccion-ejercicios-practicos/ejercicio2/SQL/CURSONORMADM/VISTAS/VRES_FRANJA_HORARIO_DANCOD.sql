CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_DANCOD" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select 
    /* 
      Vista de horarios de franjas asociadas a los recursos.
         IMPORTANTE: 
            1. Minimizamos la vista, no la unimos con 
                otras tablas o vistas para obtener descriptores de recursos.
            2. No filtramos para mostrar solo las activas.  
            3. No incorporamos control sobre si el valor ACTIVO es nulo ya que entendemos
                que está controlado.
       2026-05-11  Daniel Codina.
    */ 
       id_franja,
       id_recurso,
       fecha_inicio,
       fecha_fin,
       activo     
  from cursonormadm.tres_franja_horario franja;