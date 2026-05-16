CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CURSONORMADM"."PKG_EJERCICIO_MARILOLT" AS

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
  
 PROCEDURE ACTUALIZAR_BLOQUEADO2(
  P_ID_HORARIO_DIA IN  CURSONORMADM.TRES_HORARIO_DIA.ID_HORARIO_DIA%TYPE,
  P_BLOQUEADO      IN  CURSONORMADM.TRES_HORARIO_DIA.BLOQUEADO%TYPE,
  P_CODIGO_ERROR   OUT NUMBER,
  P_MENSAJE_ERROR  OUT VARCHAR2
)  
AS
BEGIN
  -- Inicializar variables de salida
  P_CODIGO_ERROR  := 0;
  P_MENSAJE_ERROR := NULL;
  
  -- Validar ID_HORARIO_DIA (debe ser positivo)
  VALIDAR_ID_POSITIVO('ID_HORARIO_DIA', P_ID_HORARIO_DIA);
  
  -- Validar BLOQUEADO (debe ser flag válido: 'S', 'N' o NULL)
  VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO);
  
  -- Actualizar el horario
  UPDATE CURSONORMADM.TRES_HORARIO_DIA
  SET BLOQUEADO = P_BLOQUEADO
  WHERE ID_HORARIO_DIA = P_ID_HORARIO_DIA;
  
  -- Verificar si se actualizó alguna fila
  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20810, 'El horario no existe.');
  END IF;
  
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_CODIGO_ERROR  := SQLCODE;
    P_MENSAJE_ERROR := SQLERRM;
END ACTUALIZAR_BLOQUEADO2;
  
  
  
  PROCEDURE ACTUALIZAR_BLOQUEADO(P_ID_HORARIO_DIA IN  CURSONORMADM.TRES_HORARIO_DIA.ID_HORARIO_DIA%TYPE,
                                 P_BLOQUEADO      IN  CURSONORMADM.TRES_HORARIO_DIA.BLOQUEADO%TYPE,
                                 P_CODIGO_ERROR   OUT NUMBER,
                                 P_MENSAJE_ERROR  OUT VARCHAR2 ) 
  AS
    E_HORARIO_NO_EXISTE EXCEPTION;
  BEGIN
          P_CODIGO_ERROR  := 0;
          P_MENSAJE_ERROR := NULL;
        
          VALIDAR_ID_POSITIVO('ID_HORARIO_DIA', P_ID_HORARIO_DIA);
          VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO);
        
          UPDATE CURSONORMADM.TRES_HORARIO_DIA
             SET BLOQUEADO = P_BLOQUEADO
           WHERE ID_HORARIO_DIA = P_ID_HORARIO_DIA;
        
          IF SQL%ROWCOUNT = 0 THEN
            RAISE E_HORARIO_NO_EXISTE;
          END IF;
          
        EXCEPTION
          WHEN E_HORARIO_NO_EXISTE THEN           
            RAISE_APPLICATION_ERROR(-20810, 'El horario no existe.');        
          WHEN OTHERS THEN            
            P_CODIGO_ERROR  := SQLCODE;
            P_MENSAJE_ERROR := SQLERRM;
            
  END ACTUALIZAR_BLOQUEADO;

  PROCEDURE CREAR_HORARIO_DIA(P_ID_FRANJA      IN  CURSONORMADM.TRES_HORARIO_DIA.ID_FRANJA%TYPE,    -- puede ser NULL
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
                                  P_MENSAJE_ERROR  OUT VARCHAR2)
      
     AS
          E_DIA_INVALIDO EXCEPTION;
          E_HORA_INICIO_INVALIDA EXCEPTION;
          E_HORA_FIN_INVALIDA EXCEPTION;
          E_MINUTO_INICIO_INVALIDO EXCEPTION;
          E_MINUTO_FIN_INVALIDO EXCEPTION;
          E_HORA_FIN_ANTERIOR EXCEPTION;
          E_FRANJA_RECURSO_INCONSISTENTE EXCEPTION;
    BEGIN
          -- Inicializar variables de salida
          P_CODIGO_ERROR  := 0;
          P_MENSAJE_ERROR := NULL;
          P_ID_HORARIO_DIA := NULL;
        
          -- Validar DIA (1 a 7)
          IF P_DIA IS NULL OR P_DIA < 1 OR P_DIA > 7 THEN
            RAISE E_DIA_INVALIDO;
          END IF;
        
          -- Validar HORA_INICIO (0 a 23)
          IF P_HORA_INICIO IS NULL OR P_HORA_INICIO < 0 OR P_HORA_INICIO > 23 THEN
            RAISE E_HORA_INICIO_INVALIDA;
          END IF;
        
          -- Validar HORA_FIN (0 a 23)
          IF P_HORA_FIN IS NULL OR P_HORA_FIN < 0 OR P_HORA_FIN > 23 THEN
            RAISE E_HORA_FIN_INVALIDA;
          END IF;
        
          -- Validar MINUTO_INICIO (0 a 59)
          IF P_MINUTO_INICIO IS NULL OR P_MINUTO_INICIO < 0 OR P_MINUTO_INICIO > 59 THEN
            RAISE E_MINUTO_INICIO_INVALIDO;
          END IF;
        
          -- Validar MINUTO_FIN (0 a 59)
          IF P_MINUTO_FIN IS NULL OR P_MINUTO_FIN < 0 OR P_MINUTO_FIN > 59 THEN
            RAISE E_MINUTO_FIN_INVALIDO;
          END IF;
        
          -- Validar que HORA_FIN no sea anterior a HORA_INICIO (en minutos totales)
          IF (P_HORA_FIN * 60 + P_MINUTO_FIN) < (P_HORA_INICIO * 60 + P_MINUTO_INICIO) THEN
            RAISE E_HORA_FIN_ANTERIOR;
          END IF;
        
          -- Validar BLOQUEADO (solo 'S' o 'N')
          VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO);
        
          -- Validar coherencia franja/recurso
          -- Si ID_FRANJA es NULL, ID_RECURSO es obligatorio
          IF P_ID_FRANJA IS NULL AND P_ID_RECURSO IS NULL THEN
            RAISE E_FRANJA_RECURSO_INCONSISTENTE;
          END IF;
        
          -- Si ID_FRANJA es NULL, valida que ID_RECURSO sea positivo
          IF P_ID_FRANJA IS NULL THEN
            VALIDAR_ID_POSITIVO('ID_RECURSO', P_ID_RECURSO);
          END IF;
    
          -- Insertar el nuevo horario
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
            NVL(P_BLOQUEADO, 'N'),
            P_ORDEN
          ) RETURNING ID_HORARIO_DIA INTO P_ID_HORARIO_DIA;
    
    EXCEPTION
      WHEN E_DIA_INVALIDO THEN       
        P_CODIGO_ERROR  := -20820;
        P_MENSAJE_ERROR := 'El día debe estar entre 1 y 7.';
    
      WHEN E_HORA_INICIO_INVALIDA THEN
        P_CODIGO_ERROR  := -20821;
        P_MENSAJE_ERROR := 'La hora de inicio debe estar entre 0 y 23.';
    
      WHEN E_HORA_FIN_INVALIDA THEN
        P_CODIGO_ERROR  := -20822;
        P_MENSAJE_ERROR := 'La hora de fin debe estar entre 0 y 23.';
    
      WHEN E_MINUTO_INICIO_INVALIDO THEN
        P_CODIGO_ERROR  := -20823;
        P_MENSAJE_ERROR := 'El minuto de inicio debe estar entre 0 y 59.';
    
      WHEN E_MINUTO_FIN_INVALIDO THEN
        P_CODIGO_ERROR  := -20824;
        P_MENSAJE_ERROR := 'El minuto de fin debe estar entre 0 y 59.';
    
      WHEN E_HORA_FIN_ANTERIOR THEN
        P_CODIGO_ERROR  := -20825;
        P_MENSAJE_ERROR := 'La hora de fin no puede ser anterior a la de inicio.';
    
      WHEN E_FRANJA_RECURSO_INCONSISTENTE THEN
        P_CODIGO_ERROR  := -20826;
        P_MENSAJE_ERROR := 'Si la franja es NULL, el recurso es obligatorio.';
    
      WHEN OTHERS THEN
        P_CODIGO_ERROR  := SQLCODE;
        P_MENSAJE_ERROR := SQLERRM;
        
  END CREAR_HORARIO_DIA;
  
  PROCEDURE CREAR_RESERVA(P_ID_RECURSO         IN  CURSONORMADM.TRES_RESERVA.ID_RECURSO%TYPE,
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
                          P_MENSAJE_ERROR      OUT VARCHAR2)
  AS   
          E_HORA_INICIO_INVALIDA        EXCEPTION;
          E_MINUTO_INICIO_INVALIDO      EXCEPTION;
          E_MINUTOS_RESERVA_INVALIDO    EXCEPTION;
          E_FECHA_RESERVA_NULL          EXCEPTION;
          E_RECURSO_NO_EXISTE           EXCEPTION;
          E_RESERVA_SOLAPADA            EXCEPTION;
          -- Variables auxiliares
          V_INICIO      NUMBER;
          V_FIN         NUMBER;
          V_OCUPACION   NUMBER;
          V_RECURSO_EXI NUMBER;
  BEGIN
          -- Inicializar salidas
          P_CODIGO_ERROR  := 0;
          P_MENSAJE_ERROR := NULL;
          P_ID_RESERVA    := NULL;
        
          -- Validaciones individuales
          VALIDAR_ID_POSITIVO('ID_RECURSO', P_ID_RECURSO);
          VALIDAR_ID_POSITIVO('CODPER', P_CODPER);
        
          IF P_HORA_INICIO IS NULL OR P_HORA_INICIO < 0 OR P_HORA_INICIO > 23 THEN
            RAISE E_HORA_INICIO_INVALIDA;
          END IF;
        
          IF P_MINUTO_INICIO IS NULL OR P_MINUTO_INICIO < 0 OR P_MINUTO_INICIO > 59 THEN
            RAISE E_MINUTO_INICIO_INVALIDO;
          END IF;
        
          IF P_MINUTOS_RESERVA IS NULL OR P_MINUTOS_RESERVA <= 0 THEN
            RAISE E_MINUTOS_RESERVA_INVALIDO;
          END IF;
        
          IF P_FECHA_RESERVA IS NULL THEN
            RAISE E_FECHA_RESERVA_NULL;
          END IF;
        
          -- Comprobar que el recurso existe (si no existe, lanzar excepción nominal)
          SELECT COUNT(*) INTO V_RECURSO_EXI
            FROM CURSONORMADM.TRES_RECURSO
           WHERE ID_RECURSO = P_ID_RECURSO;
        
          IF V_RECURSO_EXI = 0 THEN
            RAISE E_RECURSO_NO_EXISTE;
          END IF;
        
          -- Detectar solapamiento (si hay solapamiento, lanzar excepción nominal)
          V_INICIO := (P_HORA_INICIO * 60) + P_MINUTO_INICIO;
          V_FIN    := V_INICIO + P_MINUTOS_RESERVA;
        
          SELECT COUNT(*) INTO V_OCUPACION
            FROM CURSONORMADM.TRES_RESERVA
           WHERE ID_RECURSO = P_ID_RECURSO
             AND TRUNC(FECHA_RESERVA) = TRUNC(P_FECHA_RESERVA)
             AND ((HORA_INICIO * 60) + MINUTO_INICIO) < V_FIN
             AND (((HORA_INICIO * 60) + MINUTO_INICIO) + MINUTOS_RESERVA) > V_INICIO;
        
          IF V_OCUPACION > 0 THEN
            RAISE E_RESERVA_SOLAPADA;
          END IF;
        
          -- Insertar reserva (FECHA_ALTA por defecto COALESCE)
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
          
        EXCEPTION
          WHEN E_HORA_INICIO_INVALIDA THEN
            P_CODIGO_ERROR  := -20831;
            P_MENSAJE_ERROR := 'La hora de inicio debe estar entre 0 y 23.';          
        
          WHEN E_MINUTO_INICIO_INVALIDO THEN
            ROLLBACK;
            P_CODIGO_ERROR  := -20832;
            P_MENSAJE_ERROR := 'El minuto de inicio debe estar entre 0 y 59.';
        
          WHEN E_MINUTOS_RESERVA_INVALIDO THEN
            P_CODIGO_ERROR  := -20833;
            P_MENSAJE_ERROR := 'La duración de la reserva debe ser mayor a 0 minutos.';
        
          WHEN E_FECHA_RESERVA_NULL THEN
            P_CODIGO_ERROR  := -20836;
            P_MENSAJE_ERROR := 'La fecha de reserva no puede ser NULL.';
        
          WHEN E_RECURSO_NO_EXISTE THEN
            P_CODIGO_ERROR  := -20834;
            P_MENSAJE_ERROR := 'El recurso no existe.';
        
          WHEN E_RESERVA_SOLAPADA THEN
            P_CODIGO_ERROR  := -20835;
            P_MENSAJE_ERROR := 'Ya existe una reserva solapada para ese recurso y fecha.';
        
          WHEN OTHERS THEN
            P_CODIGO_ERROR  := SQLCODE;
            P_MENSAJE_ERROR := SQLERRM;
            
  END CREAR_RESERVA;   

END PKG_EJERCICIO_MARILOLT;
/