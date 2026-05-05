# Práctica IA-fix — Sesión 4

## Objetivo

Corregir un servicio DataTable con múltiples errores de seguridad, configuración y lógica. Usa Copilot o Claude para identificar y arreglar todos los fallos.

## Código con errores

```csharp
// ⚠️ CÓDIGO CON 10 ERRORES - Encuentra y corrige todos
public class ClaseReservas : ClaseCrudUtils
{
    private ClaseOracleBd _bd;

    // ERROR 1: Constructor sin base(claseoraclebd)
    public ClaseReservas(ClaseOracleBd bd)
    {
        _bd = bd;
        // ERROR 2: No configura SQLWhereBase
        // ERROR 3: No configura CamposFiltros
    }

    public ClaseDataTable Obtener(int primerregistro, int numeroregistros,
        string campoorden, string orden, string filtro, string campofiltro)
    {
        var salida = new ClaseDataTable();

        // ERROR 4: Usa tabla directa en vez de vista (TCTS_ en lugar de VCTS_)
        salida.NumeroRegistros = NumeroRegistrosTotales("TCTS_RESERVAS");

        // ERROR 5: SELECT * en vez de campos explícitos
        // ERROR 6: campoorden sin transformar (viene camelCase del frontend)
        // ERROR 7: No pasa idioma al mapeo
        salida.Registros = RegistrosFiltrados<ClaseReserva>(
            "VCTS_RESERVAS", "*", campofiltro, filtro,
            campoorden, orden, numeroregistros, primerregistro);

        // ERROR 8: Falta NumeroRegistrosFiltrados
        return salida;
    }

    private void ConfigurarCamposFiltros(string idioma)
    {
        // ERROR 9: No hace CamposFiltros.Clear() antes de añadir
        CamposFiltros.Add(new ClaseCrudUtilsCampos {
            NombreIni = "fecha",
            NombreFinal = "FECHA_RESERVA"
        });
        // ERROR 10: Falta campo ALL para búsqueda general
        // Además: faltan campos sala, persona, estado
    }
}
```

## Rúbrica de evaluación (10 puntos)

| Criterio | Puntos | Descripción |
|----------|--------|-------------|
| Constructor con `base()` | 1 | Llamar a `base(claseoraclebd)` |
| `SQLWhereBase` configurado | 1 | Ej: `"FLG_CANCELADA = 'N'"` |
| `CamposFiltros` invocado en constructor | 1 | Llamar a `ConfigurarCamposFiltros` |
| Vista en lugar de tabla | 1 | Cambiar `TCTS_` por `VCTS_` |
| Campos explícitos (no `*`) | 1 | Listar columnas necesarias |
| `TransformarCampoOrden` | 1 | Traducir camelCase → Oracle |
| Pasar idioma a `RegistrosFiltrados` | 1 | Último parámetro = `_idioma` |
| `NumeroRegistrosFiltrados` | 1 | Añadir la segunda consulta |
| `CamposFiltros.Clear()` | 0.5 | Evitar acumulación |
| Campo `ALL` con pipe | 0.5 | Para búsqueda general |
| Campos completos en filtros | 1 | Al menos sala, persona, estado, fecha |

## Qué debe arreglar la IA

1. **Constructor**: llamar a `base(claseoraclebd)` y configurar `SQLWhereBase` + `CamposFiltros`
2. **Vista**: usar `VCTS_RESERVAS` en todas las consultas (no `TCTS_`)
3. **Campos**: listar explícitamente (ej: `"ID, FECHA_RESERVA, SALA, PERSONA, ESTADO"`)
4. **Orden**: implementar `TransformarCampoOrden` que busque en `CamposFiltros`
5. **Filtrados**: añadir `NumeroRegistrosFiltrados` como segunda consulta
6. **CamposFiltros**: limpiar antes de añadir, incluir todos los campos + `ALL`
7. **Multiidioma**: pasar `_idioma` a `RegistrosFiltrados`
