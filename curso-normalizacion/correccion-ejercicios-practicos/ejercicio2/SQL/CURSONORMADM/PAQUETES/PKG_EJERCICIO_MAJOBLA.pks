CREATE OR REPLACE EDITIONABLE PACKAGE "CURSONORMADM"."PKG_EJERCICIO_MAJOBLA" AS
  TYPE T_CURSOR IS REF CURSOR;

  -- Tres procedimientos públicos a implementar
  /* Cambia el flag BLOQUEADO de un tramo horario por día.
       Patrón "cambio de un único flag": equivalente a ACTUALIZAR_ACTIVO
       de PKG_RES_TIPO_RECURSO. No recibe todos los campos, solo el que cambia.

       IMPORTANTE: devuelve -20810 si el ID no existe (SQL%ROWCOUNT = 0).

      2026-05-14  MAJOBLA  Creación.
    */
  PROCEDURE ACTUALIZAR_BLOQUEADO(
    P_ID_HORARIO_DIA IN  CURSONORMADM.TRES_HORARIO_DIA.ID_HORARIO_DIA%TYPE,
    P_BLOQUEADO      IN  CURSONORMADM.TRES_HORARIO_DIA.BLOQUEADO%TYPE,
    P_CODIGO_ERROR   OUT NUMBER,
    P_MENSAJE_ERROR  OUT VARCHAR2
    );

 /* Da de alta un tramo horario para un día concreto.
       Soporta dos modos:
         - Horario de franja  : P_ID_FRANJA informado, P_ID_RECURSO puede ser NULL.
         - Horario genérico   : P_ID_FRANJA NULL, P_ID_RECURSO obligatorio.

       IMPORTANTE: la hora de fin se valida como (HORA_FIN*60+MINUTO_FIN) >=
       (HORA_INICIO*60+MINUTO_INICIO) para evitar tramos invertidos.

       IMPORTANTE: devuelve el nuevo ID por P_ID_HORARIO_DIA (RETURNING INTO).

      2026-05-14  MAJOBLA  Creación.
    */
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
    );

/* Registra una reserva sobre un recurso.
       Patrón más completo: valida campos, comprueba existencia del recurso
       y detecta solapamiento con reservas existentes antes de insertar.

       IMPORTANTE: el solapamiento se detecta comparando minutos absolutos
       (HORA*60+MINUTO) para no depender de tipos TIME que Oracle no tiene.

       IMPORTANTE: P_FECHA_ALTA admite NULL; el procedimiento usa
       COALESCE(P_FECHA_ALTA, SYSDATE) para que la BD rellene la fecha actual
       si el cliente no la informa.

       IMPORTANTE: no se comprueba SQL%ROWCOUNT tras el INSERT porque
       un INSERT que completa sin excepción siempre afecta exactamente 1 fila.
       SQL%ROWCOUNT es útil tras UPDATE y DELETE, no tras INSERT.

      2026-05-14  MAJOBLA  Creación.
    */
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
    );

END PKG_EJERCICIO_MAJOBLA;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CURSONORMADM"."PKG_EJERCICIO_MAJOBLA" AS

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


-- VALIDAR_RANGO: reutilizable para horas (0-23) y minutos (0-59).
    -- Se crea como privada porque solo la usan los procedimientos de este package.
    -- Si en el futuro otro package necesitara validar rangos, se movería a
    -- un PKG_RES_VALIDACIONES compartido.
    PROCEDURE VALIDAR_RANGO(
        P_NOMBRE_CAMPO IN VARCHAR2,
        P_VALOR        IN NUMBER,
        P_MIN          IN NUMBER,
        P_MAX          IN NUMBER
    ) AS
    BEGIN
        IF P_VALOR IS NULL OR P_VALOR < P_MIN OR P_VALOR > P_MAX THEN
            RAISE_APPLICATION_ERROR(
                -20804,
                P_NOMBRE_CAMPO || ' debe estar entre ' || P_MIN || ' y ' || P_MAX || '.'
            );
        END IF;
    END VALIDAR_RANGO;


  -- TODO: implementa los tres procedimientos públicos aquí.
  -- ----------------------------------------------------------
    -- PROCEDIMIENTO 1: ACTUALIZAR_BLOQUEADO
    -- ----------------------------------------------------------
    PROCEDURE ACTUALIZAR_BLOQUEADO(
        P_ID_HORARIO_DIA IN  CURSONORMADM.TRES_HORARIO_DIA.ID_HORARIO_DIA%TYPE,
        P_BLOQUEADO      IN  CURSONORMADM.TRES_HORARIO_DIA.BLOQUEADO%TYPE,
        P_CODIGO_ERROR   OUT NUMBER,
        P_MENSAJE_ERROR  OUT VARCHAR2
    ) AS
    BEGIN
        P_CODIGO_ERROR  := 0;
        P_MENSAJE_ERROR := NULL;

        -- Validaciones antes de tocar datos
        VALIDAR_ID_POSITIVO('ID_HORARIO_DIA', P_ID_HORARIO_DIA);
        VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO);

        UPDATE CURSONORMADM.TRES_HORARIO_DIA
           SET BLOQUEADO = P_BLOQUEADO
         WHERE ID_HORARIO_DIA = P_ID_HORARIO_DIA;

        -- Si el WHERE no encuentra ninguna fila, el ID no existe
        -- Como Oracle no lanza error en este caso lo detectamos nosotros
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20810, '# El horario no existe. #');
        END IF;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            P_CODIGO_ERROR  := SQLCODE;
            P_MENSAJE_ERROR := SQLERRM;
    END ACTUALIZAR_BLOQUEADO;

     -- ----------------------------------------------------------
    -- PROCEDIMIENTO 2: CREAR_HORARIO_DIA
    -- ----------------------------------------------------------
    PROCEDURE CREAR_HORARIO_DIA(
        P_ID_FRANJA      IN  CURSONORMADM.TRES_HORARIO_DIA.ID_FRANJA%TYPE,
        P_ID_RECURSO     IN  CURSONORMADM.TRES_HORARIO_DIA.ID_RECURSO%TYPE,
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
    ) AS
        V_MIN_INICIO NUMBER;
        V_MIN_FIN    NUMBER;
    BEGIN
        P_CODIGO_ERROR  := 0;
        P_MENSAJE_ERROR := NULL;

        -- Validar DIA (1=lunes ¿ 7=domingo, convención ISO).
        VALIDAR_RANGO('DIA', P_DIA, 1, 7);

        -- Validar horas y minutos individualmente.
        VALIDAR_RANGO('HORA_INICIO',   P_HORA_INICIO,   0, 23);
        VALIDAR_RANGO('MINUTO_INICIO', P_MINUTO_INICIO, 0, 59);
        VALIDAR_RANGO('HORA_FIN',      P_HORA_FIN,      0, 23);
        VALIDAR_RANGO('MINUTO_FIN',    P_MINUTO_FIN,    0, 59);

        -- Validar que el tramo no esté invertido comparando minutos absolutos.
        V_MIN_INICIO := (P_HORA_INICIO * 60) + P_MINUTO_INICIO;
        V_MIN_FIN    := (P_HORA_FIN    * 60) + P_MINUTO_FIN;

        IF V_MIN_FIN <= V_MIN_INICIO THEN
            RAISE_APPLICATION_ERROR(
                -20820,
                '# La hora de fin debe ser posterior a la hora de inicio. #'
            );
        END IF;

        -- Validar flag BLOQUEADO.
        VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO);

        -- Coherencia franja/recurso:
        -- Si no hay franja, el recurso es obligatorio (es un horario genérico).
        -- Si hay franja, el recurso es opcional (el horario pertenece a la franja).
        IF P_ID_FRANJA IS NULL THEN
            VALIDAR_ID_POSITIVO('ID_RECURSO', P_ID_RECURSO);
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
            NVL(P_BLOQUEADO, 'N'),  -- si llega NULL, por defecto no bloqueado
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


    -- ----------------------------------------------------------
    -- PROCEDIMIENTO 3: CREAR_RESERVA
    -- ----------------------------------------------------------
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
    ) AS
        V_TOTAL_RECURSOS NUMBER;
        V_INICIO         NUMBER;
        V_FIN            NUMBER;
        V_OCUPACION      NUMBER;
        V_FECHA_ALTA     CURSONORMADM.TRES_RESERVA.FECHA_ALTA%TYPE;
    BEGIN
        P_CODIGO_ERROR  := 0;
        P_MENSAJE_ERROR := NULL;

        -- 1) Validaciones de campos individuales.
        VALIDAR_ID_POSITIVO('ID_RECURSO', P_ID_RECURSO);
        VALIDAR_ID_POSITIVO('CODPER',     P_CODPER);
        VALIDAR_RANGO('HORA_INICIO',   P_HORA_INICIO,   0, 23);
        VALIDAR_RANGO('MINUTO_INICIO', P_MINUTO_INICIO, 0, 59);

        IF P_MINUTOS_RESERVA IS NULL OR P_MINUTOS_RESERVA <= 0 THEN
            RAISE_APPLICATION_ERROR(-20821, '# MINUTOS_RESERVA debe ser mayor que 0. #');
        END IF;

        -- 2) Comprobar que el recurso existe.
        -- Si no existe, el INSERT violaría la FK y el mensaje de Oracle sería
        -- técnico (ORA-02291). Mejor detectarlo antes con un mensaje funcional.
        SELECT COUNT(*)
          INTO V_TOTAL_RECURSOS
          FROM CURSONORMADM.TRES_RECURSO
         WHERE ID_RECURSO = P_ID_RECURSO;

        IF V_TOTAL_RECURSOS = 0 THEN
            RAISE_APPLICATION_ERROR(-20822, '# El recurso no existe. #');
        END IF;

        -- 3) Detección de solapamiento.
        -- Dos reservas se solapan si sus rangos [inicio, fin) se cruzan.
        -- La condición es: inicio_nueva < fin_existente AND fin_nueva > inicio_existente.
        -- Se trabaja en minutos absolutos para no depender de tipos TIME.
        V_INICIO := (P_HORA_INICIO * 60) + P_MINUTO_INICIO;
        V_FIN    := V_INICIO + P_MINUTOS_RESERVA;

        SELECT COUNT(*)
          INTO V_OCUPACION
          FROM CURSONORMADM.TRES_RESERVA
         WHERE ID_RECURSO           = P_ID_RECURSO
           AND TRUNC(FECHA_RESERVA) = TRUNC(P_FECHA_RESERVA)
           AND ((HORA_INICIO * 60) + MINUTO_INICIO)                  < V_FIN
           AND ((HORA_INICIO * 60) + MINUTO_INICIO + MINUTOS_RESERVA) > V_INICIO;

        IF V_OCUPACION > 0 THEN
            RAISE_APPLICATION_ERROR(
                -20830,
                '# Ya existe una reserva solapada para ese recurso y fecha. #'
            );
        END IF;

        -- 4) FECHA_ALTA: si el cliente no la informa, usamos SYSDATE.
        V_FECHA_ALTA := COALESCE(P_FECHA_ALTA, SYSDATE);

        -- 5) Inserción. No se comprueba SQL%ROWCOUNT porque un INSERT sin excepción
        --    siempre afecta exactamente 1 fila (a diferencia de UPDATE/DELETE).
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
            V_FECHA_ALTA,
            P_FECHA_CONFIRMACION,
            P_OBSERVACIONES
        )
        RETURNING ID_RESERVA INTO P_ID_RESERVA;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            P_CODIGO_ERROR  := SQLCODE;
            P_MENSAJE_ERROR := SQLERRM;
    END CREAR_RESERVA;

END PKG_EJERCICIO_MAJOBLA;
/