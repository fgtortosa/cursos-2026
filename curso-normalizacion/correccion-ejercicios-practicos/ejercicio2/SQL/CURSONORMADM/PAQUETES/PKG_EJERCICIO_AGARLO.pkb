CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CURSONORMADM"."PKG_EJERCICIO_AGARLO" AS

  -- Validaciones privadas reutilizables
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

  -- TODO: implementa los tres procedimientos públicos aquí.
  PROCEDURE ACTUALIZAR_BLOQUEADO(
  P_ID_HORARIO_DIA IN  CURSONORMADM.TRES_HORARIO_DIA.ID_HORARIO_DIA%TYPE,
  P_BLOQUEADO      IN  CURSONORMADM.TRES_HORARIO_DIA.BLOQUEADO%TYPE,
  P_CODIGO_ERROR   OUT NUMBER,
  P_MENSAJE_ERROR  OUT VARCHAR2
) as

begin
  p_codigo_error := 0;
  p_mensaje_error := NULL;
  
  -- Validaciones previas : 
      VALIDAR_ID_POSITIVO('ID_HORARIO_DIA', P_ID_HORARIO_DIA);
      VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO);
      
  -- Actualizar
      UPDATE CURSONORMADM.TRES_HORARIO_DIA
        SET BLOQUEADO = P_BLOQUEADO 
      WHERE ID_HORARIO_DIA = P_ID_HORARIO_DIA;
      IF SQL%ROWCOUNT = 0 THEN
    -- Formato '# mensaje #': el extractor de .NET lo clasifica como EnumBDException.Usuario.
    RAISE_APPLICATION_ERROR(-20810, '#El horario no existe#');
  END IF;

  COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_CODIGO_ERROR  := SQLCODE;
    P_MENSAJE_ERROR := SQLERRM;
    
  END ACTUALIZAR_BLOQUEADO;

PROCEDURE CREAR_HORARIO_DIA(
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
)as
-- Varialbes temporales
    V_TOTAL_MIN_INI NUMBER;
    V_TOTAL_MIN_FIN   NUMBER;
begin
   p_id_horario_dia := 0;
   p_codigo_error := 0;
   p_mensaje_error := NULL;
-- Validaciones requeridas : dia entre 1 y 7
    if p_dia is null or p_dia not between 0 and 7 then 
          RAISE_APPLICATION_ERROR(-20820, P_dia || ' es obligatorio y debe estar entre 0 y 7');
    END IF;
  -- Validación hora inicio 
    if p_hora_inicio not between 0 and 23 then 
          RAISE_APPLICATION_ERROR(-20821, P_hora_inicio || ' debe estar entre 0 y 23');
    END IF;
    
    -- Validación hora fin
    if p_hora_fin not between 0 and 23 then 
          RAISE_APPLICATION_ERROR(-20822, P_hora_fin || ' debe estar entre 0 y 23');
    END IF;
     -- Validación minuto inicio 
    if p_minuto_inicio not between 0 and 59 then 
          RAISE_APPLICATION_ERROR(-20823, P_minuto_inicio || ' debe estar entre 0 y 59');
    END IF;
    
    -- Validación minuto fin
    if p_minuto_fin not between 0 and 23 then 
          RAISE_APPLICATION_ERROR(-20824, P_minuto_fin || ' debe estar entre 0 y 59');
    END IF;
    -- Validación hora fin no puede ser mayor que hora inicio
      v_total_min_ini := (P_HORA_INICIO * 60) + P_MINUTO_INICIO;
      V_total_min_fin := (P_HORA_FIN * 60) + P_MINUTO_FIN;
      
      IF V_TOTAL_MIN_FIN < V_TOTAL_MIN_INI THEN
        RAISE_APPLICATION_ERROR(-20825, 'La hora de fin no puede ser anterior a la de inicio.');
    END IF;
    
    -- Validar BLOQUEADO 
      VALIDAR_FLAG('BLOQUEADO',P_BLOQUEADO);
      
      --- VALIDAMOS P_DI_RECURSO
      IF P_ID_FRANJA IS NULL THEN   
             IF P_ID_RECURSO IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20826, 'Id_recurso obligatorio para id_franja no informado');
        END IF;
       
        VALIDAR_ID_POSITIVO('ID_RECURSO',P_ID_RECURSO);
    END IF;

    
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
        P_BLOQUEADO,
        P_ORDEN
    ) RETURNING ID_HORARIO_DIA INTO P_ID_HORARIO_DIA;

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
)AS
  
  V_INICIO    NUMBER := (P_HORA_INICIO * 60) + P_MINUTO_INICIO;
  V_FIN       NUMBER := V_INICIO + P_MINUTOS_RESERVA;
  V_OCUPACION NUMBER;
  V_CONTEO NUMBER;

begin
   p_id_RESERVA := 0;
   p_codigo_error := 0;
   p_mensaje_error := NULL;
   
-- Validacion ID_RECURSO POSITIVO
       VALIDAR_ID_POSITIVO('ID_RECURSO',P_ID_RECURSO);
-- Validacion codper
        VALIDAR_ID_POSITIVO('CODPER',P_CODPER);
        
  -- Validación hora inicio 
    if p_hora_inicio not between 0 and 23 then 
          RAISE_APPLICATION_ERROR(-20830, P_hora_inicio || ' debe estar entre 0 y 23');
    END IF;
     -- Validación minuto inicio 
    if p_minuto_inicio not between 0 and 59 then 
          RAISE_APPLICATION_ERROR(-20831, P_minuto_inicio || ' debe estar entre 0 y 59');
    END IF;
  
   -- Validación minutos reserva mayor que 0
      IF P_MINUTOS_RESERVA < 0 THEN
        RAISE_APPLICATION_ERROR(-20832, P_minutoS_RESERVA || 'debe ser mayor que 0');
    END IF;
    
      --- El recurso existe
               SELECT COUNT(*) 
               INTO V_CONTEO 
               FROM TRES_RECURSO 
               WHERE ID_RECURSO = P_ID_RECURSO;

               IF V_CONTEO = 0 THEN
                      RAISE_APPLICATION_ERROR(-20833, 'El recurso especificado no existe.');
               END IF;
        
      -- Detección de solapamiento
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
   
  END PKG_EJERCICIO_agarlo;
/