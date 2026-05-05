---
title: "Ejercicio sesión 2B — Procedimientos en paquetes"
description: Ejercicio práctico de PL/SQL. Implementar ACTUALIZAR_BLOQUEADO, CREAR de horario por día y CREAR de reserva, apoyándose en validaciones reutilizables (VALIDAR_TEXTO, VALIDAR_ID_POSITIVO, VALIDAR_FLAG, VALIDAR_FECHAS).
outline: [2, 4]
---

# Ejercicio sesión 2B — Procedimientos en paquetes

::: info CONTEXTO
En la sesión 2 has visto el package `PKG_RES_TIPO_RECURSO` con `VALIDAR_TEXTO` y `VALIDAR_ID_POSITIVO`, los códigos `-20700`/`-20701`/`-20702`/`-20703` y el patrón `RETURNING ... INTO`.

Este ejercicio introduce dos validaciones nuevas que verás en el schema real (`VALIDAR_FLAG` y `VALIDAR_FECHAS`) y te pide implementar tres procedimientos del modelo de reservas.
:::

[[toc]]

## Por qué este ejercicio

La aplicación .NET no escribe directamente sobre las tablas: llama a `EjecutarParamsAsync` sobre procedimientos del package. Cada procedimiento debe **validar** antes de tocar datos y devolver el resultado por parámetros `OUT` que el servicio C# lee.

Trabajarás los tres patrones más frecuentes:

- Cambiar un único flag (`ACTUALIZAR_BLOQUEADO`).
- Insertar un registro con `OUT` del nuevo ID y manejo de errores (`CREAR` de horario por día).
- Insertar con detección de solapamiento (`CREAR` de reserva).

## Objetivos

Al terminar el ejercicio debes ser capaz de:

- Diseñar procedimientos con `IN` y `OUT` siguiendo la convención del schema (`P_<nombre>`, `OUT P_CODIGO_ERROR`, `OUT P_MENSAJE_ERROR`).
- Centralizar validaciones reutilizables (`VALIDAR_TEXTO`, `VALIDAR_ID_POSITIVO`, `VALIDAR_FLAG`, `VALIDAR_FECHAS`) y reusarlas desde varios procedimientos.
- Comprobar `SQL%ROWCOUNT` tras `UPDATE` y `DELETE` para distinguir "OK" de "no había nada que hacer".
- Devolver errores por `P_CODIGO_ERROR` / `P_MENSAJE_ERROR` con `EXCEPTION WHEN OTHERS` y `ROLLBACK`.
- Detectar solapamientos de reserva en el mismo recurso y fecha sin necesitar bloqueo de fila.

## Cómo .NET llama a estos procedimientos

Antes de implementar, observa el patrón que usa `ReservaService.cs` (proyecto `curso-normalizacion-codigo`):

```csharp
DynamicParameters parametros = new DynamicParameters();
parametros.Add("P_ID_RECURSO",  reserva.IdRecurso);
parametros.Add("P_CODPER",      reserva.Codper);
// ...
parametros.Add("P_ID_RESERVA",     0,  null, ParameterDirection.Output);
parametros.Add("P_CODIGO_ERROR",   0,  null, ParameterDirection.Output);
parametros.Add("P_MENSAJE_ERROR",  "", null, ParameterDirection.Output, 2000);

await _oracle.EjecutarParamsAsync("CURSONORMADM.PKG_RES_RESERVA.CREAR", parametros);

var codigoError = (int?)parametros.Get("P_CODIGO_ERROR") ?? 0;
if (codigoError != 0)
{
    var mensajeError = parametros.Get<string?>("P_MENSAJE_ERROR") ?? "Error desconocido.";
    return Result<int>.Negocio("Reserva.Crear", mensajeError, 500);
}
```

Conclusiones que afectan a tu diseño:

- **Cada procedimiento tiene `P_CODIGO_ERROR` y `P_MENSAJE_ERROR` OUT.** El bloque `EXCEPTION WHEN OTHERS` los rellena con `SQLCODE` y `SQLERRM`.
- **El servicio C# trata `0` como éxito** y cualquier otro valor como error funcional para mostrar al usuario.
- **Los flags `S/N` se mapean en .NET** con `OracleFlagMapper.ToFlag(bool) → "S" | "N"`. Por eso el package valida `IN ('S','N')` y nunca recibe `true/false`.

## Esqueleto del package

Empieza con esta plantilla. Solo tienes que añadir tres procedimientos.

```sql
CREATE OR REPLACE PACKAGE CURSONORMADM.PKG_EJERCICIO AS
  TYPE T_CURSOR IS REF CURSOR;

  -- Tres procedimientos públicos a implementar
  PROCEDURE ACTUALIZAR_BLOQUEADO( /* ... */ );
  PROCEDURE CREAR_HORARIO_DIA  ( /* ... */ );
  PROCEDURE CREAR_RESERVA      ( /* ... */ );
END PKG_EJERCICIO;
/

CREATE OR REPLACE PACKAGE BODY CURSONORMADM.PKG_EJERCICIO AS

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

END PKG_EJERCICIO;
/
GRANT EXECUTE ON CURSONORMADM.PKG_EJERCICIO TO CURSONORMWEB;
```

::: tip BUENA PRÁCTICA
Si tu package va a convivir con `PKG_RES_HORARIO_DIA` y `PKG_RES_RESERVA`, usa un rango `-20800..-20899` propio para no chocar con los códigos del schema (`-201xx`, `-203xx`, `-207xx`).
:::

## Procedimiento 1 — `ACTUALIZAR_BLOQUEADO`

Cambia el flag `BLOQUEADO` de un horario por día. Es el patrón "una sola operación de cambio de estado", el equivalente a `ACTUALIZAR_ACTIVO` que viste en `PKG_RES_TIPO_RECURSO` durante la sesión 2.

### Firma esperada

```sql
PROCEDURE ACTUALIZAR_BLOQUEADO(
  P_ID_HORARIO_DIA IN  CURSONORMADM.TRES_HORARIO_DIA.ID_HORARIO_DIA%TYPE,
  P_BLOQUEADO      IN  CURSONORMADM.TRES_HORARIO_DIA.BLOQUEADO%TYPE,
  P_CODIGO_ERROR   OUT NUMBER,
  P_MENSAJE_ERROR  OUT VARCHAR2
);
```

### Lo que debe hacer

1. Inicializar `P_CODIGO_ERROR := 0` y `P_MENSAJE_ERROR := NULL`.
2. Llamar a `VALIDAR_ID_POSITIVO('ID_HORARIO_DIA', P_ID_HORARIO_DIA)`.
3. Llamar a `VALIDAR_FLAG('BLOQUEADO', P_BLOQUEADO)`.
4. `UPDATE ... SET BLOQUEADO = P_BLOQUEADO WHERE ID_HORARIO_DIA = P_ID_HORARIO_DIA`.
5. Si `SQL%ROWCOUNT = 0`, `RAISE_APPLICATION_ERROR(-20810, 'El horario no existe.')`.
6. `COMMIT`.
7. `EXCEPTION WHEN OTHERS THEN ROLLBACK; P_CODIGO_ERROR := SQLCODE; P_MENSAJE_ERROR := SQLERRM;`

### Pruebas

```sql
-- Cambio correcto
DECLARE v_cod NUMBER; v_msg VARCHAR2(2000);
BEGIN
  CURSONORMADM.PKG_EJERCICIO.ACTUALIZAR_BLOQUEADO(1, 'N', v_cod, v_msg);
  DBMS_OUTPUT.PUT_LINE('cod=' || v_cod || ' msg=' || v_msg);
END;
/

-- Debe devolver -20801: ID no positivo
DECLARE v_cod NUMBER; v_msg VARCHAR2(2000);
BEGIN
  CURSONORMADM.PKG_EJERCICIO.ACTUALIZAR_BLOQUEADO(0, 'S', v_cod, v_msg);
  DBMS_OUTPUT.PUT_LINE('cod=' || v_cod || ' msg=' || v_msg);
END;
/

-- Debe devolver -20802: flag inválido
DECLARE v_cod NUMBER; v_msg VARCHAR2(2000);
BEGIN
  CURSONORMADM.PKG_EJERCICIO.ACTUALIZAR_BLOQUEADO(1, 'X', v_cod, v_msg);
END;
/

-- Debe devolver -20810: horario inexistente
DECLARE v_cod NUMBER; v_msg VARCHAR2(2000);
BEGIN
  CURSONORMADM.PKG_EJERCICIO.ACTUALIZAR_BLOQUEADO(9999999, 'S', v_cod, v_msg);
END;
/
```

## Procedimiento 2 — `CREAR_HORARIO_DIA`

Da de alta un tramo horario para un día concreto. Es el patrón "alta con muchos parámetros y `OUT` del nuevo ID".

### Firma esperada

```sql
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
```

### Validaciones requeridas

- `DIA` entre 1 y 7 (no se admite `NULL` en este procedimiento, aunque la tabla sí lo permita).
- `HORA_INICIO` y `HORA_FIN` entre 0 y 23.
- `MINUTO_INICIO` y `MINUTO_FIN` entre 0 y 59.
- La hora de fin no puede ser anterior a la de inicio. Compara con `(HORA_INICIO * 60) + MINUTO_INICIO`.
- `BLOQUEADO` solo `'S'` o `'N'` — usa `VALIDAR_FLAG`.
- Coherencia franja/recurso:
  - Si `P_ID_FRANJA` está informado, no exijas `P_ID_RECURSO`.
  - Si `P_ID_FRANJA` es `NULL`, valida `P_ID_RECURSO` con `VALIDAR_ID_POSITIVO`.

### Cuerpo

1. Inicializa OUT a `0` / `NULL`.
2. Aplica las validaciones anteriores. Levanta `RAISE_APPLICATION_ERROR(-20820..-20825, ...)` con mensajes funcionales.
3. `INSERT INTO TRES_HORARIO_DIA (...) VALUES (...) RETURNING ID_HORARIO_DIA INTO P_ID_HORARIO_DIA;`
4. `COMMIT`.
5. `EXCEPTION WHEN OTHERS THEN ROLLBACK; P_CODIGO_ERROR := SQLCODE; P_MENSAJE_ERROR := SQLERRM;`

### Mejora opcional

Como ampliación, plantea si se debería rechazar la creación si ya existe otro tramo del mismo recurso, franja y día con horas solapadas. **Tu decisión: ¿constraint, package, ambos?**

Pista: una constraint declarativa no puede comprobar solapamiento (necesita una subconsulta). Es el caso típico que vive en el package.

## Procedimiento 3 — `CREAR_RESERVA`

Registra una reserva sobre un recurso. Es el patrón más completo: validaciones de campo, validación de existencia, **detección de solapamiento** y `OUT` del nuevo ID.

### Firma esperada

```sql
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
```

### Validaciones requeridas

| Validación | Cómo |
|------------|------|
| `ID_RECURSO` positivo | `VALIDAR_ID_POSITIVO` |
| `CODPER` positivo | `VALIDAR_ID_POSITIVO` |
| `HORA_INICIO` 0–23, `MINUTO_INICIO` 0–59 | Inline o crea `VALIDAR_RANGO` |
| `MINUTOS_RESERVA > 0` | Inline |
| El recurso existe | `SELECT COUNT(*) FROM TRES_RECURSO WHERE ID_RECURSO = P_ID_RECURSO` |
| `FECHA_ALTA` por defecto | `COALESCE(P_FECHA_ALTA, SYSDATE)` |
| Sin solapamiento con otra reserva | Ver siguiente apartado |

### Detección de solapamiento (lo importante)

Dos reservas del mismo recurso en la misma fecha **se solapan** si sus rangos `[inicio, inicio+duración)` tienen intersección. La forma estándar es comparar minutos absolutos:

```sql
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
```

::: tip BUENA PRÁCTICA
La detección de solapamiento siempre es funcional, **no declarativa**: requiere una subconsulta y por tanto vive en el package. La constraint solo cubre rangos válidos individuales (`HORA BETWEEN 0 AND 23`), no relaciones entre filas.
:::

### Cuerpo

1. Inicializa OUT.
2. Valida campos individuales.
3. Comprueba que el recurso existe.
4. Detecta solapamiento.
5. `INSERT ... VALUES (..., COALESCE(P_FECHA_ALTA, SYSDATE), ...) RETURNING ID_RESERVA INTO P_ID_RESERVA;`
6. `COMMIT`.
7. `EXCEPTION WHEN OTHERS THEN ROLLBACK; P_CODIGO_ERROR := SQLCODE; P_MENSAJE_ERROR := SQLERRM;`

### Pruebas

```sql
-- Alta correcta
DECLARE v_id NUMBER; v_cod NUMBER; v_msg VARCHAR2(2000);
BEGIN
  CURSONORMADM.PKG_EJERCICIO.CREAR_RESERVA(
    P_ID_RECURSO         => 1,
    P_CODPER             => 12345,
    P_HORA_INICIO        => 10,
    P_MINUTO_INICIO      => 0,
    P_MINUTOS_RESERVA    => 30,
    P_FECHA_RESERVA      => DATE '2026-09-01',
    P_FECHA_ALTA         => NULL,
    P_FECHA_CONFIRMACION => NULL,
    P_OBSERVACIONES      => 'Prueba',
    P_ID_RESERVA         => v_id,
    P_CODIGO_ERROR       => v_cod,
    P_MENSAJE_ERROR      => v_msg
  );
  DBMS_OUTPUT.PUT_LINE('id=' || v_id || ' cod=' || v_cod || ' msg=' || v_msg);
END;
/

-- Debe devolver -20830: solapamiento (ejecuta la misma alta dos veces)
-- ...
```

## Reflexión obligatoria

Responde por escrito en la memoria:

1. ¿Qué validaciones has creado como procedimientos privados reutilizables y cuáles has dejado inline? Justifica.
2. ¿Por qué `CAMBIAR_CODPER` o `ACTUALIZAR_BLOQUEADO` van como procedimientos separados en lugar de pasar todos los campos a `ACTUALIZAR`?
3. ¿Comprobarías `SQL%ROWCOUNT` en `CREAR_RESERVA`? ¿Por qué (no) tiene sentido en un `INSERT`?
4. ¿Dónde colocarías validaciones que se reusen entre packages distintos: en cada package o en un `PKG_RES_VALIDACIONES` común? Justifica con el caso de `VALIDAR_FECHAS`.
5. Documenta cada procedimiento con cabecera `/* ... */` (propósito, IMPORTANTE, bitácora) igual que el schema real.

## Comparación con el schema real

Una vez tu package compile, **compara** con los reales del schema:

```sql
SELECT text
  FROM all_source
 WHERE owner = 'CURSONORMADM'
   AND name  = 'PKG_RES_RESERVA'
   AND type  = 'PACKAGE BODY'
 ORDER BY line;
```

Anota en la memoria al menos tres diferencias entre tu `CREAR_RESERVA` y `PKG_RES_RESERVA.CREAR`:

- ¿Qué hace el real con `P_ID_RESERVA_SERIE` y `P_ES_EXCEPCION` que tu versión simplificada omite?
- ¿Cómo factoriza `VALIDAR_DATOS` la detección de solapamiento para reusarla desde `ACTUALIZAR`?
- ¿Cómo informa la capacidad del recurso (`V_CAPACIDAD`)?

## Criterios de revisión

- [ ] El package SPEC declara solo los tres procedimientos públicos.
- [ ] El BODY contiene `VALIDAR_ID_POSITIVO`, `VALIDAR_FLAG`, `VALIDAR_FECHAS` como privadas, reutilizadas desde varios procedimientos.
- [ ] Cada procedimiento público tiene `P_CODIGO_ERROR` y `P_MENSAJE_ERROR` OUT, los inicializa al inicio y los rellena en el `EXCEPTION`.
- [ ] `ACTUALIZAR_BLOQUEADO` comprueba `SQL%ROWCOUNT` y lanza `-20810` si no afectó a filas.
- [ ] `CREAR_HORARIO_DIA` valida coherencia franja/recurso y horas con `(HORA*60)+MINUTO`.
- [ ] `CREAR_RESERVA` detecta solapamiento con la subconsulta del enunciado.
- [ ] El package está concedido a `CURSONORMWEB` con `GRANT EXECUTE`.
- [ ] La memoria responde a las cinco preguntas de reflexión y compara con el schema real.

## Entrega

Entrega:

1. `sql/03_pkg_ejercicio.sql` con SPEC + BODY + GRANT.
2. `sql/04_pruebas_pkg_ejercicio.sql` con los bloques anónimos de prueba.
3. Memoria breve (15–20 líneas) con las respuestas a la reflexión y las tres diferencias detectadas con el schema real.

::: tip SIGUIENTE PASO
Con esto cierras la parte Oracle. La siguiente sesión (parte .NET) toma estos packages y los conecta desde `ClaseOracleBd.EjecutarParamsAsync`, validando los parámetros `P_CODIGO_ERROR` / `P_MENSAJE_ERROR` exactamente como `ReservaService.cs` y `HorarioDiaService.cs` del proyecto de referencia.
:::
