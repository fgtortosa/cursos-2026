CREATE OR REPLACE FORCE EDITIONABLE VIEW "CURSONORMADM"."VRES_TIPO_RECURSO" ("ID_TIPO_RECURSO", "CODIGO", "NOMBRE_ES", "NOMBRE_CA", "NOMBRE_EN") DEFAULT COLLATION "USING_NLS_COMP"  AS
  SELECT /* Vista de catalogo de tipos de recurso para clasificar recursos reservables.

           IMPORTANTE: Vista simple sobre una sola tabla (sin JOIN, sin agregados, sin DISTINCT).
                       Oracle la considera key-preserved, por lo que admite UPDATE / INSERT / DELETE
                       directos. La aplicacion NO los usa: WEB recibe solo GRANT SELECT y escribe
                       siempre a traves de PKG_RES_TIPO_RECURSO. La capacidad de DML directo se
                       reserva para scripts de mantenimiento desde ADM (sesion 2 lo demuestra en
                       clase activando temporalmente los GRANTs comentados mas abajo).

   04/03/2026  SERVICIOINFORMATICA  Creacion de la vista.
   08/05/2026  SERVICIOINFORMATICA  Documentado el comportamiento como vista actualizable y
                                    anadidos los GRANTs de demostracion (comentados por defecto).
                       */
  ID_TIPO_RECURSO,
  CODIGO,
  NOMBRE_ES,
  NOMBRE_CA,
  NOMBRE_EN
FROM CURSONORMADM.TRES_TIPO_RECURSO;

-- =====================================================================
--  GRANTs sobre la vista
-- =====================================================================
--  Lectura: la aplicacion WEB siempre puede leer la vista.
GRANT SELECT ON CURSONORMADM.VRES_TIPO_RECURSO TO CURSONORMWEB;

--  Demo de "vista que actua como tabla" (sesion 2 - paso 2.5).
--  Activar SOLO durante la clase para que los alumnos puedan ejecutar
--  UPDATE / INSERT / DELETE directos contra la vista. Tras la demo,
--  REVOKE inmediato: en la app productiva la unica via de escritura es
--  el package PKG_RES_TIPO_RECURSO.
--
-- GRANT INSERT, UPDATE, DELETE ON CURSONORMADM.VRES_TIPO_RECURSO TO CURSONORMWEB;
-- REVOKE INSERT, UPDATE, DELETE ON CURSONORMADM.VRES_TIPO_RECURSO FROM CURSONORMWEB;
