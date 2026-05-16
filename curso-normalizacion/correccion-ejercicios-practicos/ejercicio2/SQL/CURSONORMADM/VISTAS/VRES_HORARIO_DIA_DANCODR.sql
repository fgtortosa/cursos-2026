CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_HORARIO_DIA_DANCODR" ("ID_HORARIO_DIA", "ID_FRANJA", "ID_RECURSO", "DIA", "HORA_INICIO", "MINUTO_INICIO", "HORA_FIN", "MINUTO_FIN", "ORDEN", "BLOQUEADO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT 
    /* 
      Vista de tramos horarios asociados a cada día.
         IMPORTANTE: 
            1. Minimizamos la vista, no la unimos con 
                otras tablas o vistas para obtener descriptores de recursos o fechas de inicio y fin de franjas.
            2. No filtramos para mostrar solo las activas.  
            3. No incorporamos control sobre si el valor ACTIVO es nulo ya que entendemos
                que está controlado.
            4. No ordenamos por día y orden, dejando que lo haga la aplicación cuando sea necesario.
       2026-05-12  Daniel Codina.
    */ 
    ID_HORARIO_DIA,
    ID_FRANJA,
    ID_RECURSO,
    DIA,
    HORA_INICIO,
    MINUTO_INICIO,
    HORA_FIN,
    MINUTO_FIN,
    ORDEN,
    BLOQUEADO
FROM CURSONORMADM.TRES_HORARIO_DIA;