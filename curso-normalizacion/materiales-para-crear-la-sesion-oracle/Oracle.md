# Manual Oracle y PL/SQL (Referencia Programador + Codex)

## 1. Objetivo
Este manual unifica:
- Metodología de Oracle/PLSQL usada en este proyecto.
- Buenas prácticas de la Universidad recogidas en `Manuales/Oracle.docx`.

Debe servir como guía única para diseñar, implementar, revisar y desplegar cambios de base de datos con Oracle.

## 2. Principios rectores
1. Separación clara de responsabilidades.
2. Seguridad y mínimo privilegio.
3. Rendimiento desde el diseño.
4. Trazabilidad y mantenimiento a largo plazo.
5. Compatibilidad con evolución funcional sin romper la web.

## 3. Organización de esquemas y accesos
### 3.1 Esquemas
- Objetos de BD en esquema `...ADM` (en este proyecto: `C##FOTOSADM` / `FOTOSADM` según entorno).
- Conexión de aplicación con usuario `...WEB` (en este proyecto: `C##FOTOSWEB` / `FOTOSWEB`).

### 3.2 Regla clave
- La aplicación web NO debe consultar tablas directamente.
- La aplicación debe leer por VISTAS (`V...`) y ejecutar lógica por PAQUETES (`PKG_...`).

### 3.3 Prohibiciones/restricciones
- No usar sinónimos.
- Restringir uso de secuencias al mínimo.
- En Oracle moderno, preferir `IDENTITY` cuando proceda.

## 4. Convenciones de nombres
## 4.1 Recomendación universitaria (general)
- Tablas: `T<ACRO>_...`
- Vistas: `V<ACRO>_...`
- Procedimientos: `P<ACRO>_...`
- Funciones: `F<ACRO>_...`
- Paquetes: `PKG_<ACRO>_...`
- Índices: `IDX_...`
- PK/FK: `PK_...`, `FK_...`
- Secuencias: `SEQ_...`

## 4.2 Convención aplicada en este proyecto (actual)
- Tablas/vistas con nombres semánticos directos: `FOTOS`, `CATEGORIAS`, `VCATEGORIAS_FOTO`, etc.
- Paquetes de dominio: `PKG_FOTO`, `PKG_ALBUM`, `PKG_CATEGORIAS`, etc.
- Constraints explícitas: `PK_...`, `FK_...`, `CK_...`, `UK_...`.
- Índices descriptivos (respetando límite de longitud de nombre).

Regla práctica: mantener consistencia dentro del mismo proyecto aunque difiera del formato de otro sistema.

## 5. Modelo de capas (aplicación)
- `Models`: POCOs, sin lógica de negocio ni SQL.
- `Services`: lógica de negocio + acceso Oracle + SQL.
- `Controllers`: orquestación, sin SQL embebido.

## 6. Acceso Oracle desde .NET (regla obligatoria)
- Usar `ClaseOracleBD` / `ClaseOracleBd`.
- No usar EF Core / Dapper / OracleConnection directo para lógica de negocio estándar.

Patrones de uso:
- SELECT múltiple: `GetAllObjectsMap<T>` / `ObtenerTodosMap<T>`.
- SELECT único: `GetFirstObjectsMap<T>` / `ObtenerPrimeroMap<T>`.
- Procedimientos/funciones: `EjecutarParams` + `DynamicParameters`.

## 7. Diseño de tablas
1. Definir PK clara (`IDENTITY` cuando aplique).
2. Definir FKs y checks de integridad.
3. Definir UNIQUE para reglas de negocio (evitar duplicados funcionales).
4. Crear índices para columnas de búsqueda y join.
5. Evitar índices redundantes.

Checklist por tabla:
- PK
- FK necesarias
- UK de negocio
- CHECK de dominio (flags 0/1, rangos, etc.)
- Índices de soporte

## 8. Diseño de vistas
Principios:
- Exponer shape estable para la aplicación.
- Incluir alias orientados al mapeo .NET.
- Evitar `SELECT *` en código de aplicación.

Buenas prácticas:
- Crear vistas específicas para casos de uso de alto volumen.
- Revisar joins y cardinalidades.
- Documentar propósito y cambios relevantes.

## 9. Diseño de paquetes PL/SQL
## 9.1 Estructura recomendada
- `PACKAGE` (spec): contratos públicos.
- `PACKAGE BODY`: implementación.
- Helpers privados: validación, existencia, normalización.

## 9.2 Estándar de errores
Definir constantes internas:
- `C_ERR_PARAMETRO_INVALIDO`
- `C_ERR_NO_ENCONTRADO`
- `C_ERR_DUPLICADO`
- `C_ERR_INTEGRIDAD`
- `C_ERR_TAMANO`
- `C_ERR_INTERNO`

Encapsular excepciones Oracle (`-1400`, `-12899`, `-2291`, etc.) en errores funcionales claros.

## 9.3 Validación
Validar SIEMPRE antes de DML:
- IDs > 0
- textos obligatorios no vacíos
- flags válidos (0/1)
- existencia de FK
- reglas de negocio (ej. no autoreferencia)

## 9.4 Operaciones CRUD
Para entidades y relaciones, incluir normalmente:
- `INSERTAR`
- `OBTENER_POR_ID`
- `LISTAR`
- `ACTUALIZAR`
- `ACTUALIZAR_ESTADO` (si aplica; usar un único procedimiento con parámetro de nuevo estado)
- `ELIMINAR`
- `EXISTE`

Para relaciones N:M añadir procedimientos dedicados (`INSERTAR_FOTO`, `ELIMINAR_FOTO`, etc.).

Regla de diseño para estados:
- No crear pares de acciones separadas (`ACTIVAR`/`DESACTIVAR`, `HACER_VISIBLE`/`OCULTAR`).
- Usar una única acción con parámetro explícito de estado, por ejemplo:
  - `PRC_ACTUALIZAR_ACTIVO(P_ID, P_ACTIVO)`
  - `PRC_ACTUALIZAR_VISIBLE(P_ID, P_VISIBLE)`

## 10. Contratos para .NET y parámetros
- En procedimientos, nombres de parámetros estables y explícitos.
- Para OUT usar `DynamicParameters` y recuperar salida por nombre.
- En funciones con `RETURN_VALUE`, debe ir primero cuando aplique.

## 11. Multiidioma en datos
Campos descriptivos en 3 idiomas cuando aplique:
- `..._ES`, `..._CA`, `..._EN`

No mezclar semánticas en un único campo si el dominio exige i18n.

Regla obligatoria de sufijos:
- Castellano: `_ES`
- Valenciano/Catalán: `_CA`
- Inglés: `_EN`
- No usar `_VAL` para valenciano.

## 11.1 Campos booleanos de estado
Convención obligatoria para flags de estado (`ACTIVO`, `VISIBLE` y similares):
- Tipo lógico/booleano.
- Persistencia con valores `1` (true) y `0` (false).
- Validar siempre dominio `IN (0,1)` en tablas y parámetros.
- En operaciones de paquete, exponer un parámetro de estado (`P_ACTIVO`, `P_VISIBLE`) en lugar de crear procedimientos duplicados por cada transición.

## 12. SQL de despliegue y versionado
Repositorio SQL manual (obligatorio):
- `sql/tablas.sql`
- `sql/vistas.sql`
- `sql/paquetes.sql`
- carpetas temáticas (`sql/views`, `sql/packages`, etc. si procede)

Orden recomendado de despliegue:
1. tablas + constraints base
2. índices
3. vistas
4. paquetes
5. grants

Nunca asumir auto-ejecución por la aplicación.

## 13. Documentación mínima por objeto
Cada vista/paquete crítico debe incluir:
- propósito funcional
- dependencias
- cambios relevantes (fecha, autor, cambio)

Formato de histórico recomendado:
- `YYYY-MM-DD NOMBRE -> cambio`

## 14. Optimización y calidad SQL
## 14.1 Consultas
- Evitar `SELECT *`.
- Traer solo campos necesarios.
- Revisar planes (`EXPLAIN PLAN`) en consultas críticas.
- Filtrar pronto y con columnas indexadas.

## 14.2 WHERE y búsqueda
- Diseñar filtros coherentes con índices.
- Considerar paginación siempre en listados.
- Tener en cuenta búsquedas acento/case-insensitive según requisitos.

## 14.3 Joins
- Revisar tipo de join y cardinalidad.
- Evitar joins innecesarios en vistas generalistas.

## 15. Trabajo con lotes (objetos/arrays)
Cuando haya alta/actualización masiva:
- Preferir tipos Oracle (`OBJECT`, `TABLE OF OBJECT`) y un procedimiento batch.
- Evitar N llamadas individuales si el caso es masivo.

## 16. Seguridad y grants
- Otorgar solo permisos necesarios al esquema `...WEB`.
- Grants típicos:
  - `GRANT SELECT ON V... TO ...WEB`
  - `GRANT EXECUTE ON PKG_... TO ...WEB`
- Regla obligatoria del proyecto:
  - `...WEB` NO recibe `SELECT/INSERT/UPDATE/DELETE` sobre tablas `T...`.
  - `...WEB` solo accede por vistas (`V...`) y paquetes (`PKG_...`).
  - Si existe un grant a tabla para `...WEB`, debe eliminarse (`REVOKE`) y documentarse la excepción si fuera imprescindible.

No conceder acceso directo a tablas salvo caso excepcional justificado.

## 17. Metodología práctica usada en este proyecto
Patrón aplicado y recomendado:
1. Diseñar entidad/relación con constraints + índices.
2. Exponer vista de lectura para web.
3. Añadir operaciones en paquete de dominio con validación y control de errores.
4. Dar grants al usuario web.
5. Integrar en `Service` .NET usando `ClaseOracleBD`.
6. Consumir desde `Controller` sin SQL embebido.
7. Probar flujo end-to-end.

## 18. Checklist final (obligatorio)
- [ ] Sinónimos no utilizados.
- [ ] Acceso web por vistas/paquetes (no tablas).
- [ ] Usuario `...WEB` sin grants DML/SELECT directos sobre tablas `T...`.
- [ ] SQL solo en Services (backend).
- [ ] Paquete con validaciones y errores de negocio.
- [ ] Constraints e índices adecuados.
- [ ] Grants mínimos a usuario WEB.
- [ ] Scripts en repositorio `/sql`.
- [ ] Naming consistente con el proyecto.
- [ ] Documentación de cambios relevante.

## 19. Plantilla rápida para nuevas funcionalidades
1. `tablas.sql`: tabla/relación + PK/FK/UK/CK + índices.
2. `vistas.sql`: vista específica de lectura + `GRANT SELECT`.
3. `paquetes.sql`: spec/body + `GRANT EXECUTE`.
4. `Services/*.cs`: métodos Oracle (`Obtener...`, `EjecutarParams`).
5. `Controllers/Apis/*.cs`: endpoints finos.
6. Frontend: consumir API y validar flujo.

## 20. Criterio de resolución de conflictos entre guías
Si hay diferencia entre guía general y proyecto:
1. Primero reglas de seguridad/arquitectura del proyecto.
2. Luego consistencia con convención ya existente en el repo.
3. Si persiste duda, consultar antes de introducir una convención nueva.

---
Documento base de referencia universitaria incorporado: `Manuales/Oracle.docx`.
