---
url: /curso-normalizacion/02-dotnet/test/sesion-05/practica-ia-fix.md
description: >-
  Corregir un servicio Oracle que no respeta los patrones de la sesión 5
  (parametrización, vista de lectura, Result<T> con NotFound).
---

# Práctica IA-fix — Sesión 5

## Objetivo

Pide a la IA que corrija el siguiente servicio. **Antes de aceptar la solución**, comprueba que la IA haya aplicado los tres patrones canónicos de la sesión:

1. **Parametrizar** las queries (`:nombre` o `:0`, `:1`, …), nunca interpolar valores en SQL.
2. **Leer contra la vista** filtrada (`VRES_TIPO_RECURSO`, etc.), no contra la tabla.
3. Devolver **`Result<T>`** desde el servicio, usando `Result<T>.NotFound(...)` cuando la fila no existe — el controlador lo traducirá a `404` con `HandleResult`.

## Código con errores

```csharp
public async Task<TipoRecursoLectura> ObtenerPorIdAsync(int id, string idioma)
{
    // ERROR 1: SQL injection (interpolacion directa de id en la query)
    // ERROR 2: lee de la tabla, no de la vista (no respeta ACTIVO='S')
    var sql = $"SELECT * FROM TRES_TIPO_RECURSO WHERE ID_TIPO_RECURSO = {id}";

    var tipo = await _bd.ObtenerPrimeroMapAsync<TipoRecursoLectura>(sql, idioma);

    // ERROR 3: si no existe, devuelve null y el controlador devolveria 200 OK con body vacio
    return tipo;
}
```

## Errores que debe detectar la IA

| # | Problema | Corrección esperada |
| --- | --- | --- |
| 1 | El id se concatena en la query (SQL injection + plan de ejecución no reutilizable) | Parametrizar: `WHERE ID_TIPO_RECURSO = :0` y pasar `id` como parámetro a `ObtenerPrimeroMapAsync`. |
| 2 | Lee de la tabla `TRES_TIPO_RECURSO` directamente | Leer de la vista `VRES_TIPO_RECURSO`, que ya filtra `ACTIVO='S'` y resuelve el idioma. |
| 3 | El método devuelve `TipoRecursoLectura` (potencialmente `null`) | Cambiar la firma a `Task<Result<TipoRecursoLectura>>`. Si la fila existe → `Result<TipoRecursoLectura>.Success(tipo)`. Si no existe → `Result<TipoRecursoLectura>.NotFound("TIPO_RECURSO_NO_ENCONTRADO", $"No existe el tipo de recurso {id}.")`. |

## Solución de referencia

```csharp
public async Task<Result<TipoRecursoLectura>> ObtenerPorIdAsync(int id, string idioma)
{
    // Vista filtrada + parametro :0 → seguro frente a SQL injection y reutilizable por el plan.
    var sql = "SELECT * FROM VRES_TIPO_RECURSO WHERE ID_TIPO_RECURSO = :0";

    var tipo = await _bd.ObtenerPrimeroMapAsync<TipoRecursoLectura>(sql, idioma, id);

    // null → 404 explicito (no un 200 con body vacio).
    if (tipo is null)
    {
        return Result<TipoRecursoLectura>.NotFound(
            "TIPO_RECURSO_NO_ENCONTRADO",
            $"No existe el tipo de recurso con id {id}.");
    }

    return Result<TipoRecursoLectura>.Success(tipo);
}
```

::: tip BUENA PRÁCTICA
El controlador queda inalterado: sigue siendo `HandleResult(await _tiposRecurso.ObtenerPorIdAsync(id, Idioma))`. Es el servicio el que decide entre `Success` y `NotFound`; el `HandleResult` traduce ambos al HTTP que toca (`200` o `404 ProblemDetails`).
:::

::: warning OJO CON LA IA
Es habitual que Copilot proponga `throw new Exception("No encontrado")` o `throw new KeyNotFoundException()`. **No lo aceptes**: en este curso las "no encontrado" son flujos esperables, no excepciones. Si dejas la excepción, acabará como `500` técnico en lugar de `404 ProblemDetails` y el log se ensucia con falsos errores.
:::
