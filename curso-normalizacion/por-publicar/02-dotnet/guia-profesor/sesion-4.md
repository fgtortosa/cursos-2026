# Guia del profesor — Material de referencia: DataTable server-side y ClaseCrud

> **Nota:** Este contenido se ha integrado en la sesion 14 (DataTable de extremo a extremo) del bloque de Integracion full-stack.

## Objetivo

Que el alumno sepa implementar un endpoint DataTable server-side completo: servicio con `ClaseCrudUtils`, configuracion de `CamposFiltros`, `SQLWhereBase`, paginacion con `OFFSET/FETCH`, `TransformarCampoOrden`, campo `ALL`, `SetIdioma` y vistas Oracle. Al terminar, debe poder replicar el patron para cualquier entidad del ejercicio de citas.

| | |
|---|---|
| **Duracion** | ~45 minutos |
| **Material** | `sesion-4-datatable-clasecrud.md`, `preguntas.md`, `practica-ia-fix.md`, proyecto abierto en VS 2022 |
| **Prerequisitos** | Sesiones 1-3 completadas (DTOs, Result\<T\>, HandleResult, FluentValidation, ClaseOracleBD3) |

**Mensaje clave:** Cuando una tabla tiene cientos o miles de registros, el servidor pagina, filtra y ordena con SQL, y solo envia la pagina actual. `ClaseCrudUtils` encapsula ese patron con tres consultas.

---

## Parte 1: Teoria con codigo real (~20 min)

### Bloque 1.1 -- Por que DataTable server-side (3 min)

Abrir con esta pregunta al grupo:

> "Tenemos `GET /api/Unidades` que devuelve todas las unidades activas. Funciona con 20 registros. Que pasa si tenemos 15.000?"

Dejar que respondan. Guiar hacia: ancho de banda, memoria del navegador, renderizado lento, filtrado ineficiente en JS.

📂 **Abrir** `sesion-4-datatable-clasecrud.md`, seccion 4.1 -- tabla comparativa listado simple vs DataTable server-side.

👉 **Senalar** las 4 diferencias clave: datos, filtrado, ordenacion, paginacion.

💡 **Pregunta rapida:**

> "Si el frontend pide `primerregistro=20` y `numeroregistros=10`, que registros devuelve Oracle?"

Respuesta: del 21 al 30 (OFFSET 20, FETCH NEXT 10).

### Bloque 1.2 -- ClaseCrudUtils y la estructura del servicio (4 min)

📂 **Abrir** `Curso/Models/Unidad/ClaseUnidades.cs` -- linea 11.

👉 **Senalar** la declaracion de clase:

- Hereda de `ClaseCrudUtils` (proporciona los tres metodos de DataTable)
- Implementa `IClaseUnidades` (contrato propio)
- Implementa `CrudAPIClaseInterface<ClaseUnidad>` (contrato de la plantilla UA)

📂 **Abrir** `Curso/Models/Unidad/IClaseUnidades.cs` -- linea 9.

👉 **Senalar** la firma de `Obtener` vs `ObtenerActivas`:

- `Obtener` devuelve `ClaseDataTable` con metadatos de paginacion
- `ObtenerActivas` devuelve `Result<List<ClaseUnidad>>` con todas las activas

💡 **Pregunta:**

> "Para que necesita el frontend `numeroRegistrosFiltrados` ademas de `registros`?"

Respuesta: para calcular el numero total de paginas de la paginacion.

⚡ **Explicar** los tres metodos que proporciona `ClaseCrudUtils`:

1. `NumeroRegistrosTotales(vista)` -- `SELECT COUNT(*)` con `SQLWhereBase`
2. `NumeroRegistrosFiltrados(vista, campofiltro, filtro, campoorden)` -- `SELECT COUNT(*)` con filtro del usuario
3. `RegistrosFiltrados<T>(vista, campos, ...)` -- `SELECT ... ORDER BY ... OFFSET/FETCH`

### Bloque 1.3 -- CamposFiltros: seguridad y mapeo (5 min)

**Empezar con seguridad:**

> "El frontend envia `campofiltro=nombre`. Que pasa si alguien inyecta `campofiltro=1; DROP TABLE TCTS_UNIDADES--`?"

Respuesta: `CamposFiltros` rechaza cualquier campo no registrado. Es la defensa contra SQL injection en DataTable.

📂 **Abrir** `Curso/Models/Unidad/ClaseUnidades.cs` -- metodo `ConfigurarCamposFiltros` (linea 218).

👉 **Senalar** los 4 elementos clave de cada campo:

1. `CamposFiltros.Clear()` al inicio -- evita acumulacion si se llama varias veces
2. `NombreIni` = lo que envia el frontend (camelCase)
3. `NombreFinal` = la columna Oracle real (MAYUSCULAS)
4. `Tipo` = `"number"`, `"boolean"`, `"string"` (afecta al filtro SQL generado)

💡 **Dibujar en pizarra el mapeo:**

```
Frontend: "nombre"       -->  Oracle: "NOMBRE_ES"
Frontend: "flgActiva"    -->  Oracle: "FLG_ACTIVA"
Frontend: "granularidad"  --> Oracle: "GRANULARIDAD"
```

👉 **Senalar** el campo `ALL` (linea 229):

```
NombreIni = "ALL", NombreFinal = "ID|NOMBRE_ES|DURACION_MAX"
```

💡 **Pregunta:**

> "Que SQL genera `campofiltro=ALL` con `filtro=biblioteca`?"

Respuesta: `WHERE (ID LIKE '%biblioteca%' OR NOMBRE_ES LIKE '%biblioteca%' OR DURACION_MAX LIKE '%biblioteca%')`.

📂 **Abrir** `Curso/Models/Unidad/ClaseUnidades.cs` -- metodo `SetIdioma` (linea 29).

👉 **Senalar** como `SetIdioma("CA")` reconfigura `CamposFiltros` para que `nombre` apunte a `NOMBRE_CA` en lugar de `NOMBRE_ES`.

### Bloque 1.4 -- SQLWhereBase y TransformarCampoOrden (3 min)

📂 **Abrir** `Curso/Models/Unidad/ClaseUnidades.cs` -- constructor (linea 20).

👉 **Senalar** la linea `SQLWhereBase = "FLG_ACTIVA = 'S'"`.

💡 **Pregunta:**

> "A cuantas de las tres consultas afecta `SQLWhereBase`?"

Respuesta: a las tres (totales, filtrados y registros). Es un filtro permanente.

📂 **Mismo fichero** -- metodo `TransformarCampoOrden` (linea 232).

👉 **Senalar** dos puntos clave:

1. Si el campo no existe en `CamposFiltros`, devuelve `"ID"` por defecto (nunca un ORDER BY vacio)
2. Si el campo tiene pipes (como `ALL`), toma solo el primer elemento del split

💡 **Pregunta:**

> "Que devuelve `TransformarCampoOrden('ALL')`?"

Respuesta: `"ID"` (primer campo del split por `|`).

### Bloque 1.5 -- El metodo Obtener completo (5 min)

📂 **Abrir** `Curso/Models/Unidad/ClaseUnidades.cs` -- metodo `Obtener` (linea 37).

👉 **Recorrer paso a paso:**

1. `TransformarCampoOrden(campoorden)` -- traduce camelCase a Oracle
2. `NumeroRegistrosTotales(VistaUnidades)` -- usa la constante `VistaUnidades = "VCTS_UNIDADES"`
3. Comprobacion: si total es 0, devuelve lista vacia (optimizacion, evita 2 consultas innecesarias)
4. `NumeroRegistrosFiltrados(...)` -- segunda consulta con filtro del usuario
5. `RegistrosFiltrados<ClaseUnidad>(...)` -- tercera consulta con `CamposVistaUnidades` (campos explicitos, linea 18), `OFFSET/FETCH`

👉 **Senalar** las constantes (lineas 17-18):

- `VistaUnidades = "VCTS_UNIDADES"` -- nombre de la vista Oracle
- `CamposVistaUnidades = "ID, NOMBRE_ES, NOMBRE_CA, ..."` -- campos explicitos, NO `SELECT *`

⚡ **Dos errores tipicos que destacar:**

- Usar `TCTS_UNIDADES` (tabla directa) en vez de `VCTS_UNIDADES` (vista) -- el usuario web no tiene permisos SELECT sobre tablas
- Usar `SELECT *` en vez de campos explicitos -- expone columnas internas, peor rendimiento, rompe si cambia la vista

🔗 **Conexion con el controlador:**

📂 **Abrir** `Curso/Controllers/Apis/UnidadesController.cs` -- metodo `DataTable` (linea 25).

👉 **Senalar:**

- `SetIdioma(idioma)` se llama ANTES de `Obtener` para reconfigurar `CamposFiltros`
- Devuelve `Ok(salida)` directamente, NO usa `HandleResult` (porque `Obtener` devuelve `ClaseDataTable`, no `Result<T>`)

---

## Parte 2: Practica guiada -- Rojo-Verde-Refactor (~10 min)

### Version ROJA (5 min)

📂 **Abrir** `sesion-4-datatable-clasecrud.md`, seccion 4.11 -- version ROJA con errores.

👉 **Proyectar el codigo** y pedir al grupo que identifique los errores. Dar 2 minutos.

💡 **Ir listando con el grupo:**

| # | Error | Correccion |
|---|-------|------------|
| 1 | Usa `TCTS_UNIDADES` (tabla directa) | Cambiar a `VCTS_UNIDADES` (vista) |
| 2 | Usa `SELECT *` | Cambiar a `CamposVistaUnidades` con campos explicitos |
| 3 | No transforma `campoorden` | Anadir `TransformarCampoOrden(campoorden)` |
| 4 | Falta `NumeroRegistrosFiltrados` | Anadir la segunda consulta |

### Version VERDE (5 min)

📂 **Abrir** `Curso/Models/Unidad/ClaseUnidades.cs` -- metodo `Obtener` (linea 37).

👉 **Senalar** como el codigo real ya incorpora todas las correcciones: vista, campos explicitos, transformacion de orden, las tres consultas.

⚡ **Si sobra tiempo**, senalar la posibilidad de `DatosAdicionales` para cargar listas de combos/selects junto con el DataTable (parametro `cargardatosadicionales`).

---

## Parte 3: Test de autoevaluacion (~5 min)

📂 **Abrir** `sesion-4/tests/preguntas.md`.

Seleccion de 10 preguntas. Proyectar una a una, 20-30 segundos por pregunta:

| # Test | Pregunta | Tema | Respuesta |
|--------|----------|------|-----------|
| 1 | P1 | Donde se pagina | b) SQL en Oracle con OFFSET/FETCH |
| 2 | P4 | Que es NombreIni | b) Nombre que envia el frontend en camelCase |
| 3 | P5 | Campo no registrado | c) ClaseCrudUtils rechaza el campo |
| 4 | P6 | SQL del campo ALL | c) WHERE con OR en todas las columnas |
| 5 | P7 | Proposito de SQLWhereBase | b) Condicion permanente en TODAS las consultas |
| 6 | P11 | TransformarCampoOrden con ALL | c) "ID" (primer campo del split) |
| 7 | P16 | Orden de las tres consultas | b) Totales -> Filtrados -> Registros |
| 8 | P17 | Por que SetIdioma antes de Obtener | b) Reconfigura CamposFiltros con el idioma correcto |
| 9 | P19 | Errores en version ROJA | d) 4 errores |
| 10 | P23 | Por que no usa HandleResult | b) Obtener devuelve ClaseDataTable, no Result\<T\> |

⚡ **Si algun alumno falla la P19**, repasar los 4 errores de la version ROJA.

---

## Parte 4: Ejercicio con Copilot -- Codigo con fallos (~10 min)

📂 **Abrir** `sesion-4/tests/practica-ia-fix.md`.

👉 **Instrucciones para los alumnos:**

1. Copiar el codigo del bloque "Codigo con errores" en un archivo `.cs`
2. Pedir a Copilot/Claude que identifique y corrija los 10 errores
3. Comparar la respuesta de la IA con la rubrica

### Los 10 errores (referencia rapida para el profesor)

| # | Error | Pista para guiar |
|---|-------|------------------|
| 1 | Constructor sin `base(claseoraclebd)` | Sin esto, `ClaseCrudUtils` no tiene conexion Oracle |
| 2 | No configura `SQLWhereBase` | Deberia filtrar reservas no canceladas |
| 3 | No llama a `ConfigurarCamposFiltros` | Los campos quedan vacios |
| 4 | Usa `TCTS_RESERVAS` (tabla) | Cambiar a `VCTS_RESERVAS` (vista) |
| 5 | Usa `SELECT *` | Listar campos explicitos |
| 6 | `campoorden` sin transformar | Implementar `TransformarCampoOrden` |
| 7 | No pasa idioma a `RegistrosFiltrados` | Ultimo parametro = `_idioma` |
| 8 | Falta `NumeroRegistrosFiltrados` | Anadir la segunda consulta |
| 9 | No hace `CamposFiltros.Clear()` | Provoca acumulacion al cambiar idioma |
| 10 | Falta campo `ALL` | Anadir con pipes para busqueda general |

⚡ **Errores que vigilar:**

- **Mas dificil de detectar:** #7 (idioma). El parametro esta al final y queda lejos visualmente
- **La IA suele fallar:** #2 (SQLWhereBase). A veces sugiere un valor generico sin sentido de negocio
- **La IA suele acertar:** #1, #4, #5, #8

---

## Resumen y cierre

5 conceptos clave de la sesion:

1. **DataTable server-side** = paginar, filtrar y ordenar en Oracle, enviar solo la pagina actual
2. **ClaseCrudUtils** = clase base con tres metodos: `NumeroRegistrosTotales`, `NumeroRegistrosFiltrados`, `RegistrosFiltrados<T>`
3. **CamposFiltros** = mapeo camelCase a Oracle + proteccion contra SQL injection. Campo `ALL` para busqueda global
4. **SQLWhereBase** = filtro permanente que aplica a las tres consultas
5. **TransformarCampoOrden** = traduce el campo de ordenacion del frontend a Oracle, con fallback a `"ID"`

🔗 **Conexion con el frontend:**

📂 **Abrir** `Curso/ClientApp/src/views/apis/Unidades.vue` -- metodo `cargarDataTable` (linea 74).

👉 **Senalar** como el frontend construye la URL con `primerregistro`, `numeroregistros`, `campofiltro=ALL`, `idioma=ES` y recibe `DataTableResponse` con los tres campos (`numeroRegistros`, `numeroRegistrosFiltrados`, `registros`).

---

## Si sobra tiempo

- Mostrar `ObtenerSimple` en `ClaseUnidades.cs` (linea 73): misma consulta de `RegistrosFiltrados` pero devuelve solo la lista, sin metadatos de paginacion. Util para selects/combos
- Mostrar el componente Vue `DataTableComponente` de UA (si el proyecto tiene ejemplo): propiedades `url`, `campos`, `filtroGeneral`, `filtrosCampos`
- Pedir que implementen `SetIdioma` + `ConfigurarCamposFiltros` para la entidad de reservas del ejercicio

## Si falta tiempo

- Saltar el bloque 1.4 (SQLWhereBase y TransformarCampoOrden) -- los alumnos lo veran en el ejercicio con Copilot
- Reducir el test a 5 preguntas: P1, P5, P6, P16, P19
- Asignar la practica IA-fix como tarea para casa

---

## Preguntas dificiles

### "No entiendo la diferencia entre NumeroRegistros y NumeroRegistrosFiltrados"

Ejemplo: 250 unidades totales, el usuario busca "biblioteca" y coinciden 12. `NumeroRegistros = 250`, `NumeroRegistrosFiltrados = 12`. El frontend muestra "1-10 de 12 resultados (250 totales)" y calcula 2 paginas.

### "Por que no usar HandleResult en el endpoint DataTable?"

`HandleResult` mapea `Result<T>` a HTTP. `Obtener` devuelve `ClaseDataTable` directamente (siempre devuelve algo, aunque sea lista vacia con contadores a 0). Las excepciones no controladas las captura `IExceptionHandler`.

### "Se puede hacer el DataTable con POST en vez de GET?"

No es correcto REST. GET es para consultas idempotentes. POST se reserva para crear recursos. Con GET los parametros van en URL (se puede copiar/compartir/cachear).

### "Que pasa si alguien envia `orden=DELETE`?"

`ClaseCrudUtils` solo acepta `ASC` o `DESC`. Cualquier otro valor se trata como `ASC`. No hay riesgo de inyeccion.

### "Por que CamposFiltros.Clear() si se llama desde el constructor?"

Porque `SetIdioma` tambien llama a `ConfigurarCamposFiltros`. Sin `Clear()`, los campos del idioma anterior se acumularian con los del nuevo.

### "El alumno no distingue entre vista (VCTS_) y tabla (TCTS_)"

El usuario web de Oracle tiene `SELECT` solo sobre vistas, no sobre tablas. Las tablas solo las modifican los SPs. Si usas `TCTS_` en un SELECT, Oracle dara error de permisos en produccion.

### "Un alumno termina muy rapido el ejercicio con Copilot"

Pedirle que implemente `SetIdioma` para reservas y verifique que `ConfigurarCamposFiltros` se llama con el idioma correcto. O que anada un test unitario con `FakeService` para el endpoint DataTable de reservas.
