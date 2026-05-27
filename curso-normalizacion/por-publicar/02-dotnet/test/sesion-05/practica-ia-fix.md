# Práctica IA-fix — Sesión 2

## Objetivo

Corregir un servicio con errores de acceso Oracle y patrón de resultado.

```csharp
public ClaseUnidad ObtenerPorId(int id)
{
    var sql = $"SELECT * FROM TCTS_UNIDADES WHERE ID = {id}"; // BUG: SQL injection + tabla directa
    var unidad = bd.ObtenerPrimeroMap<ClaseUnidad>(sql);
    return unidad; // BUG: no usa Result<T>, no gestiona null
}
```

## Qué debe arreglar la IA

1. Parametrizar query (`:id`) y usar vista `VCTS_UNIDADES`.
2. Devolver `Result<ClaseUnidad>`.
3. Devolver `Result<ClaseUnidad>.NotFound(...)` cuando no exista (el controlador lo convierte en `404 Not Found` vía `HandleResult`).
4. Añadir logging contextual.
