CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_FRANJA_HORARIO_LUILUC" ("ID_FRANJA", "ID_RECURSO", "FECHA_INICIO", "FECHA_FIN", "ACTIVO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT /* Vista de consulta de franjas horarias asociadas a recursos.

         IMPORTANTE: La vista expone el flag ACTIVO sin filtrar.
                     La aplicación decide si consulta registros
                     activos, inactivos o ambos.

         IMPORTANTE: No se incorpora JOIN con TRES_RECURSO.
                     La vista representa únicamente la entidad
                     franja horaria para evitar acoplamiento
                     innecesario y consultas más pesadas.

  2026-05-11  LUILUC  Creación inicial de la vista.
                       */
       FH.ID_FRANJA,
       FH.ID_RECURSO,
       FH.FECHA_INICIO,
       FH.FECHA_FIN,
       FH.ACTIVO
  FROM CURSONORMADM.TRES_FRANJA_HORARIO_LUILUC FH;