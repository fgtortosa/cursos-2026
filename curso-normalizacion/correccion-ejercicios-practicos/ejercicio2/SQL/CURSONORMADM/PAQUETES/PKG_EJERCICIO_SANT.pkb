CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CURSONORMADM"."PKG_EJERCICIO_SANT" AS

---------------------------------------------------------
-- Validaciones privadas reutilizables
---------------------------------------------------------
 
  PROCEDURE VALIDAR_ID_POSITIVO(
    P_NOMBRE_CAMPO IN VARCHAR2,
    P_VALOR        IN NUMBER
  ) AS
  BEGIN
    IF P_VALOR IS NULL OR P_VALOR <= 0 THEN
      RAISE_APPLICATION_ERROR(-20801, P_NOMBRE_CAMPO || ' debe ser mayor que 0.');
    END IF;
  END VALIDAR_ID_POSITIVO;

  PROCEDURE VALIDAR_FLAG(
    P_NOMBRE_CAMPO IN VARCHAR2,
    P_VALOR        IN VARCHAR2
  ) AS
  BEGIN
    IF P_VALOR IS NOT NULL AND P_VALOR NOT IN ('S', 'N') THEN
      RAISE_APPLICATION_ERROR(-20802, P_NOMBRE_CAMPO || ' debe ser S o N.');
    END IF;
  END VALIDAR_FLAG;

  PROCEDURE VALIDAR_FECHAS(
    P_FECHA_INICIO IN DATE,
    P_FECHA_FIN    IN DATE
  ) AS
  BEGIN
    IF P_FECHA_FIN < P_FECHA_INICIO THEN
      RAISE_APPLICATION_ERROR(-20803, 'FECHA_FIN no puede ser menor que FECHA_INICIO.');
    END IF;
  END VALIDAR_FECHAS;


 ---------------------------------------------------------
  -- TODO: implementa los tres procedimientos públicos aquí.
  ---------------------------------------------------------

PROCEDURE ACTUALIZAR_BLOQUEADO
/*
     IMPORTANTE: Cambia el flag BLOQUEADO de un horario por día. Es el patrón "una sola operación de cambio de estado", 
     --------------------
     12/05/2026  SANTIAGO   Crear PROCEDURE
*/
(
  P_ID_HORARIO_DIA IN  CURSONORMADM.TRES_HORARIO_DIA.ID_HORARIO_DIA%TYPE,
  P_BLOQUEADO      IN  CURSONORMADM.TRES_HORARIO_DIA.BLOQUEADO%TYPE,
  P_CODIGO_ERROR   OUT NUMBER,
  P_MENSAJE_ERROR  OUT VARCHAR2
)  
AS 
    BEGIN
/*
Cambia el flag BLOQUEADO de un horario por día. 
Es el patrón "una sola operación de cambio de estado", el equivalente a ACTUALIZAR_ACTIVO que viste en PKG_RES_TIPO_RECURSO durante la sesión 2.
*/
/* Lo que debe hacer:
=====================
1.-Inicializar P_CODIGO_ERROR := 0 y P_MENSAJE_ERROR := NULL.
2.-Llamar a VALIDAR_ID_POSITIVO('ID_HORARIO_DIA', P_ID_HORARIO_DIA).
3.-Llamar a VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO).
4.-UPDATE ... SET BLOQUEADO = P_BLOQUEADO WHERE ID_HORARIO_DIA = P_ID_HORARIO_DIA.
5.-Si SQL%ROWCOUNT = 0, RAISE_APPLICATION_ERROR(-20810, 'El horario no existe.').
6.-COMMIT.
7.-EXCEPTION WHEN OTHERS THEN ROLLBACK; P_CODIGO_ERROR := SQLCODE; P_MENSAJE_ERROR := SQLERRM;
*/
        P_CODIGO_ERROR  := 0;
        P_MENSAJE_ERROR := NULL;
        -- Validaciones previas: ID positivo y todos los campos obligatorios informados.
        VALIDAR_ID_POSITIVO('ID_HORARIO_DIA', P_ID_HORARIO_DIA);
        VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO);
        --
        UPDATE CURSONORMADM.TRES_HORARIO_DIA
        SET BLOQUEADO = P_BLOQUEADO
        WHERE ID_HORARIO_DIA = P_ID_HORARIO_DIA;    
        -- SQL%ROWCOUNT contiene cuántas filas afectó el último DML implícito.
        -- Si vale 0, el ID no existía: convertimos ese silencio en un error funcional.
        IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20810, 'El horario no existe.');
        END IF;  
        --
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN  
                ROLLBACK;
                P_CODIGO_ERROR  := SQLCODE;
                P_MENSAJE_ERROR := SQLERRM;

END ACTUALIZAR_BLOQUEADO;



PROCEDURE CREAR_HORARIO_DIA
/*
     IMPORTANTE: Da de alta un tramo horario para un día concreto. Es el patrón "alta con muchos parámetros y OUT del nuevo ID". 
     --------------------
     12/05/2026  SANTIAGO   Crear PROCEDURE
*/
(
  P_ID_FRANJA      IN  CURSONORMADM.TRES_HORARIO_DIA.ID_FRANJA%TYPE,    -- puede ser NULL
  P_ID_RECURSO     IN  CURSONORMADM.TRES_HORARIO_DIA.ID_RECURSO%TYPE,   -- obligatorio si la franja es NULL
  P_DIA            IN  CURSONORMADM.TRES_HORARIO_DIA.DIA%TYPE,
  P_HORA_INICIO    IN  CURSONORMADM.TRES_HORARIO_DIA.HORA_INICIO%TYPE,
  P_MINUTO_INICIO  IN  CURSONORMADM.TRES_HORARIO_DIA.MINUTO_INICIO%TYPE,
  P_HORA_FIN       IN  CURSONORMADM.TRES_HORARIO_DIA.HORA_FIN%TYPE,
  P_MINUTO_FIN     IN  CURSONORMADM.TRES_HORARIO_DIA.MINUTO_FIN%TYPE,
  P_BLOQUEADO      IN  CURSONORMADM.TRES_HORARIO_DIA.BLOQUEADO%TYPE,
  P_ORDEN          IN  CURSONORMADM.TRES_HORARIO_DIA.ORDEN%TYPE,
  P_ID_HORARIO_DIA OUT CURSONORMADM.TRES_HORARIO_DIA.ID_HORARIO_DIA%TYPE,
  P_CODIGO_ERROR   OUT NUMBER,
  P_MENSAJE_ERROR  OUT VARCHAR2
)  
AS
BEGIN
/*
Da de alta un tramo horario para un día concreto. 
Es el patrón "alta con muchos parámetros y OUT del nuevo ID".
*/
/*
Validaciones requeridas
=======================
- DIA entre 1 y 7 (no se admite NULL en este procedimiento, aunque la tabla sí lo permita).
- HORA_INICIO y HORA_FIN entre 0 y 23.
- MINUTO_INICIO y MINUTO_FIN entre 0 y 59.
- La hora de fin no puede ser anterior a la de inicio. Compara con (HORA_INICIO * 60) + MINUTO_INICIO.
- BLOQUEADO solo 'S' o 'N' ¿ usa VALIDAR_FLAG.
- Coherencia franja/recurso:
    * Si P_ID_FRANJA está informado, no exijas P_ID_RECURSO.
    * Si P_ID_FRANJA es NULL, valida P_ID_RECURSO con VALIDAR_ID_POSITIVO.

Cuerpo
======
1.- Inicializa OUT a 0 / NULL.
2.- Aplica las validaciones anteriores. Levanta RAISE_APPLICATION_ERROR(-20820..-20825, ...) con mensajes funcionales.
3.- INSERT INTO TRES_HORARIO_DIA (...) VALUES (...) RETURNING ID_HORARIO_DIA INTO P_ID_HORARIO_DIA;
4.- COMMIT.
5.- EXCEPTION WHEN OTHERS THEN ROLLBACK; P_CODIGO_ERROR := SQLCODE; P_MENSAJE_ERROR := SQLERRM;

Mejora opcional
===============
Como ampliación, plantea si se debería rechazar la creación si ya existe otro tramo del mismo recurso, franja y día con horas solapadas. 
Tu decisión: ¿constraint, package, ambos?
*/
-- 1) Inicializamos los OUT de error: 0 / NULL significa "todo OK".
    P_CODIGO_ERROR  := 0;
    P_MENSAJE_ERROR := NULL;
-- 2.- Aplica las validaciones anteriores. Levanta RAISE_APPLICATION_ERROR(-20820..-20825, ...) con mensajes funcionales.
    IF NOT ( P_DIA BETWEEN 1 AND 7 )  
    THEN
        RAISE_APPLICATION_ERROR(-20820, 'DIA entre 1 y 7.');
    END IF;
    IF NOT ( P_HORA_INICIO BETWEEN 0 AND 23 )  
    THEN
        RAISE_APPLICATION_ERROR(-20821, 'HORA INICIO entre 0 y 23.');
    END IF;   
    IF NOT ( P_HORA_FIN BETWEEN 0 AND 23 )  
    THEN
        RAISE_APPLICATION_ERROR(-20822, 'HORA FIN entre 0 y 23.');
    END IF;   
    IF NOT ( P_MINUTO_INICIO BETWEEN 0 AND 59 )  
    THEN
        RAISE_APPLICATION_ERROR(-20823, 'MINUTO INICIO entre 0 y 59.');
    END IF;   
    IF NOT ( P_MINUTO_FIN BETWEEN 0 AND 59 )  
    THEN
        RAISE_APPLICATION_ERROR(-20824, 'MINUTO FIN entre 0 y 59.');
    END IF;   
    -- La hora de fin no puede ser anterior a la de inicio.
    IF  ( ((P_HORA_INICIO*60)+P_MINUTO_INICIO) > ((P_HORA_FIN*60)+P_MINUTO_FIN) )   
    THEN
        RAISE_APPLICATION_ERROR(-20825, 'La hora de fin no puede ser anterior a la de inicio.');
    END IF;  
    --
    VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO);
    --
    IF P_ID_FRANJA IS NULL AND P_ID_RECURSO IS NULL 
    THEN   
        RAISE_APPLICATION_ERROR(-20826, 'P_ID_FRANJA está informado, no exijas P_ID_RECURSO.');
    END IF;
    IF P_ID_FRANJA IS NULL  
    THEN
       VALIDAR_ID_POSITIVO('ID_RECURSO', P_ID_RECURSO);
    END IF; 
-- 3.-  INSERT INTO TRES_HORARIO_DIA (...) VALUES (...) RETURNING ID_HORARIO_DIA INTO P_ID_HORARIO_DIA;
    INSERT INTO CURSONORMADM.TRES_HORARIO_DIA (
      ID_FRANJA,
      ID_RECURSO,
      DIA,
      HORA_INICIO,
      MINUTO_INICIO,
      HORA_FIN,
      MINUTO_FIN,
      BLOQUEADO,
      ORDEN
    ) VALUES (
      P_ID_FRANJA,
      P_ID_RECURSO,
      P_DIA,
      P_HORA_INICIO,
      P_MINUTO_INICIO,
      P_HORA_FIN,
      P_MINUTO_FIN,
      COALESCE(P_BLOQUEADO, 'S'),
      P_ORDEN
    )
    RETURNING ID_HORARIO_DIA INTO P_ID_HORARIO_DIA;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      P_CODIGO_ERROR  := SQLCODE;
      P_MENSAJE_ERROR := SQLERRM;

END CREAR_HORARIO_DIA;



PROCEDURE CREAR_RESERVA(
  P_ID_RECURSO         IN  CURSONORMADM.TRES_RESERVA.ID_RECURSO%TYPE,
  P_CODPER             IN  CURSONORMADM.TRES_RESERVA.CODPER%TYPE,
  P_HORA_INICIO        IN  CURSONORMADM.TRES_RESERVA.HORA_INICIO%TYPE,
  P_MINUTO_INICIO      IN  CURSONORMADM.TRES_RESERVA.MINUTO_INICIO%TYPE,
  P_MINUTOS_RESERVA    IN  CURSONORMADM.TRES_RESERVA.MINUTOS_RESERVA%TYPE,
  P_FECHA_RESERVA      IN  CURSONORMADM.TRES_RESERVA.FECHA_RESERVA%TYPE,
  P_FECHA_ALTA         IN  CURSONORMADM.TRES_RESERVA.FECHA_ALTA%TYPE,
  P_FECHA_CONFIRMACION IN  CURSONORMADM.TRES_RESERVA.FECHA_CONFIRMACION%TYPE,
  P_OBSERVACIONES      IN  CURSONORMADM.TRES_RESERVA.OBSERVACIONES%TYPE,
  P_ID_RESERVA         OUT CURSONORMADM.TRES_RESERVA.ID_RESERVA%TYPE,
  P_CODIGO_ERROR       OUT NUMBER,
  P_MENSAJE_ERROR      OUT VARCHAR2
)
AS
  V_INICIO  NUMBER := (P_HORA_INICIO * 60) + P_MINUTO_INICIO;
  V_FIN     NUMBER := V_INICIO + P_MINUTOS_RESERVA;
  V_OCUPACION NUMBER;
  V_CONTADOR NUMBER;
  
BEGIN
/*
Registra una reserva sobre un recurso. 
Es el patrón más completo: validaciones de campo, validación de existencia, detección de solapamiento y OUT del nuevo ID.
*/
/*
Validaciones requeridas
=======================
Validación	                            Cómo
----------                              -----------------------
- ID_RECURSO positivo	                VALIDAR_ID_POSITIVO
- CODPER positivo	                    VALIDAR_ID_POSITIVO
- HORA_INICIO 0¿23, MINUTO_INICIO 0¿59	Inline o crea VALIDAR_RANGO
- MINUTOS_RESERVA > 0	                Inline
- El recurso existe	                    SELECT COUNT(*) FROM TRES_RECURSO WHERE ID_RECURSO = P_ID_RECURSO
- FECHA_ALTA por defecto	            COALESCE(P_FECHA_ALTA, SYSDATE)

- Sin solapamiento con otra reserva
Dos reservas del mismo recurso en la misma fecha se solapan si sus rangos [inicio, inicio+duración) tienen intersección. La forma estándar es comparar minutos absolutos:
DECLARE
  V_INICIO    NUMBER := (P_HORA_INICIO * 60) + P_MINUTO_INICIO;
  V_FIN       NUMBER := V_INICIO + P_MINUTOS_RESERVA;
  V_OCUPACION NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO V_OCUPACION
    FROM CURSONORMADM.TRES_RESERVA
   WHERE ID_RECURSO = P_ID_RECURSO
     AND TRUNC(FECHA_RESERVA) = TRUNC(P_FECHA_RESERVA)
     AND ((HORA_INICIO * 60) + MINUTO_INICIO) < V_FIN
     AND (((HORA_INICIO * 60) + MINUTO_INICIO) + MINUTOS_RESERVA) > V_INICIO;

  IF V_OCUPACION > 0 THEN
    RAISE_APPLICATION_ERROR(-20830, 'Ya existe una reserva solapada para ese recurso y fecha.');
  END IF;
END;
*/

  -- Inicializa OUT a 0 / NULL.
    P_ID_RESERVA:= 0;
    P_CODIGO_ERROR:= 0;
    P_MENSAJE_ERROR:= NULL;

  -- VALIDACIONES
  -- ID_RECURSO positivo    
  VALIDAR_ID_POSITIVO('ID_RECURSO',P_ID_RECURSO);

  -- - CODPER positivo
  VALIDAR_ID_POSITIVO('CODPER',P_CODPER);

  -- HORA_INICIO 0-23, MINUTO_INICIO 0-59
  IF P_HORA_INICIO NOT BETWEEN 0 AND 23 THEN
        RAISE_APPLICATION_ERROR(-20830, P_HORA_INICIO || ' debe estar entre 0 y 23.');
  END IF;

  IF P_MINUTO_INICIO NOT BETWEEN 0 AND 59 THEN
        RAISE_APPLICATION_ERROR(-20831, P_MINUTO_INICIO ||  ' debe estar en el rango (0-59)');
  END IF;

  -- MINUTOS_RESERVA > 0     
  IF P_MINUTOS_RESERVA < 0 THEN
        RAISE_APPLICATION_ERROR(-20832, P_MINUTOS_RESERVA || ' debe ser mayor que 0');
  END IF;

  -- El recurso existe 
  V_CONTADOR:=0;
  SELECT COUNT(*) 
    INTO V_CONTADOR 
    FROM CURSONORMADM.TRES_RECURSO 
    WHERE ID_RECURSO = P_ID_RECURSO;

  IF V_CONTADOR = 0 THEN
        RAISE_APPLICATION_ERROR(-20833, 'El recurso no existe.');
  END IF;

  -- Sin solapamiento con otra reserva
  SELECT COUNT(*) 
    INTO V_OCUPACION
    FROM CURSONORMADM.TRES_RESERVA
   WHERE ID_RECURSO = P_ID_RECURSO
     AND TRUNC(FECHA_RESERVA) = TRUNC(P_FECHA_RESERVA)
     AND ((HORA_INICIO * 60) + MINUTO_INICIO) < V_FIN
     AND (((HORA_INICIO * 60) + MINUTO_INICIO) + MINUTOS_RESERVA) > V_INICIO;

  IF V_OCUPACION > 0 THEN
      RAISE_APPLICATION_ERROR(-20834, 'Ya existe una reserva solapada para ese recurso y fecha.');
  END IF;

  INSERT INTO CURSONORMADM.TRES_RESERVA (
        ID_RECURSO,
        CODPER,
        HORA_INICIO,
        MINUTO_INICIO,
        MINUTOS_RESERVA,
        FECHA_RESERVA,
        FECHA_ALTA,
        FECHA_CONFIRMACION,
        OBSERVACIONES
    ) VALUES (
        P_ID_RECURSO,
        P_CODPER,
        P_HORA_INICIO,
        P_MINUTO_INICIO,
        P_MINUTOS_RESERVA,
        P_FECHA_RESERVA,
        COALESCE(P_FECHA_ALTA, SYSDATE),
        P_FECHA_CONFIRMACION,
        P_OBSERVACIONES
    ) RETURNING ID_RESERVA INTO P_ID_RESERVA;

    COMMIT;

   EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_CODIGO_ERROR  := SQLCODE;
        P_MENSAJE_ERROR := SQLERRM;

END CREAR_RESERVA;



END PKG_EJERCICIO_SANT;

--- Si tu package va a convivir con PKG_RES_HORARIO_DIA y PKG_RES_RESERVA, 
--- usa un rango -20800..-20899 propio para no chocar con los códigos del schema (-201xx, -203xx, -207xx).
/