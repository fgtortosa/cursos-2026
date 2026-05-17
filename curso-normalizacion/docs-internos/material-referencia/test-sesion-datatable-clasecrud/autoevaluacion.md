# Autoevaluación — Sesión 4

## Preguntas rápidas

### 1. ¿Para qué sirve `CamposFiltros` en `ClaseCrudUtils`?

::: details Respuesta
Mapea campos frontend (camelCase) a columnas Oracle (MAYÚSCULAS) y **previene SQL injection** rechazando cualquier campo que no esté en la lista. El campo especial `ALL` permite búsqueda general en múltiples columnas separadas por `|`.
:::

### 2. ¿Qué hace `SQLWhereBase` y cuándo se aplica?

::: details Respuesta
Aplica una condición permanente a **todas** las consultas del DataTable: `NumeroRegistrosTotales`, `NumeroRegistrosFiltrados` y `RegistrosFiltrados`. Se define en el constructor. Ejemplo: `SQLWhereBase = "FLG_ACTIVA = 'S'"` filtra solo registros activos en las tres consultas.
:::

### 3. ¿Qué tres valores devuelve `ClaseDataTable` y para qué los necesita el frontend?

::: details Respuesta
- `NumeroRegistros` — total sin filtrar (para "Mostrando X de Y")
- `NumeroRegistrosFiltrados` — total con filtros (para calcular número de páginas)
- `Registros` — solo los datos de la página actual

Opcionalmente también puede incluir `DatosAdicionales` para combos/selects.
:::

### 4. ¿Por qué se recomienda un endpoint `/datatable` separado del CRUD básico?

::: details Respuesta
Tienen responsabilidades y firmas diferentes. El GET básico (`/api/unidades`) devuelve todas las unidades activas como `Result<List<T>>`, útil para combos. El DataTable (`/api/unidades/datatable`) devuelve `ClaseDataTable` con metadatos de paginación. Mezclarlos complicaría la API y confundiría a los consumidores.
:::

### 5. ¿Por qué `SetIdioma` reconfigura `CamposFiltros`?

::: details Respuesta
Porque el campo `nombre` se mapea a `NOMBRE_{idioma}`. Cuando el usuario está en catalán, `nombre` debe apuntar a `NOMBRE_CA`, no a `NOMBRE_ES`. Sin reconfigurar, el filtrado y la búsqueda general (ALL) buscarían en la columna del idioma anterior.
:::
