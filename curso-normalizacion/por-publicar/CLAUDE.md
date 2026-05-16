# Curso Normalización — Guía para Claude

Material docente de la Universidad de Alicante (UA) para normalizar el desarrollo de aplicaciones internas con el stack **Oracle + .NET 10 + Vue 3 (TypeScript)**.

Este documento da contexto suficiente para trabajar con eficacia sobre el curso sin tener que explorar el árbol entero. Para la lista completa y actualizada de sesiones consulta [`organizacion-del-curso.md`](./organizacion-del-curso.md).

---

## 1. Directorio del curso

Raíz: `C:\Users\Tortosa.CAMPUS\source\repos\documentacion\cursos\2026\curso-normalizacion\por-publicar`

Es un sitio **VitePress** servido por el portal de documentación de la UA. Cada bloque tiene su `index.md`, su `_sidebar.json` y una subcarpeta `sesiones/`.

```
por-publicar/
├── index.md                       # Portada (landing cards)
├── organizacion-del-curso.md      # Índice maestro de 22 sesiones
├── _sidebar.json                  # Orden global de bloques
├── 00-preparacion/                # Bloque 0: entorno (Git, SSH, npm, NuGet, VS, VS Code)
├── 01-oracle/
│   ├── SQL/                       # Snippets SQL de apoyo a las sesiones
│   └── sesiones/
│       ├── 1-fundamentos-oracle/
│       ├── 2-ejercicio-fundamentos/
│       ├── 3-tablas-vistas/
│       ├── 4-ejercicio-tablas-vistas/
│       └── 5-paquetes/
├── 02-dotnet/
│   ├── test/                      # Material de pruebas de la API
│   └── sesiones/
│       ├── sesion-0-introduccion-dotnet/
│       ├── sesion-1-dtos-apis/
│       ├── sesion-2-servicios-oracle/
│       ├── sesion-3-validacion-errores/
│       ├── sesion-4-datatable-clasecrud/
│       └── sesion-5-openapi-scalar/
├── 03-vue/
│   ├── guia-profesor/
│   └── sesiones/
│       ├── sesion-1-vue-typescript-fundamentos/
│       ├── sesion-2-directivas-eventos/
│       ├── sesion-3-componentes-estado/
│       ├── sesion-4-arquitectura-apis/
│       └── sesion-5-componentes-ua/
├── 04-integracion/sesiones/       # Sesiones 11-14 (API+auth, validación, errores, DataTable)
├── 05-avanzadas/sesiones/         # Sesiones 15-22 (i18n, seguridad, Pinia, tests, ficheros, logs, accesibilidad, Copilot)
├── profesor/                      # Guías internas (no publicadas a alumnos)
└── public/                        # Assets estáticos
```

### Convenciones de las páginas

- Frontmatter YAML al inicio: `title`, `description`, `outline`.
- Markdown con sintaxis VitePress: admonitions (`::: tip`, `::: warning`, `::: details`), tablas, mermaid.
- El skill **`ua-docs-vitepress`** es la referencia para generar o transformar páginas.

---

## 2. Mapa de sesiones (22 en total)

| Bloque | Sesiones | Foco |
|---|---|---|
| Preparación | Sesión previa | Entorno UA: Git/SSH, npm/NuGet con PAT, .NET SDK 10, VS 2022, VS Code, MCP/Skills |
| Oracle | 1–2 | Arquitectura ADM/WEB, tablas, vistas, packages CRUD, mapeo Oracle ↔ .NET ↔ TS |
| .NET 10 | 3–5 | Plantilla MVC UA, DTOs, controladores API, servicios, `ClaseOracleBD3` |
| Vue 3 + TS | 6–10 | Componente, directivas, computed, props/emits/v-model, composables, componentes UA |
| Integración | 11–14 | Auth CAS/JWT, `useAxios`/`HttpApi`, validación (DataAnnotations + FluentValidation + `useGestionFormularios`), errores `ErrorHandlerMiddleware`, DataTable servidor |
| Avanzadas | 15–22 | i18n (`IStringLocalizer` + `vue-i18n`), roles/políticas, Pinia, xUnit + `WebApplicationFactory`, ficheros, Serilog (sinks UA), accesibilidad/ENS, Copilot |

### Estado actual (al cierre del último commit)

- Sesión 1 §1.5–§1.9: alineada con `Home.vue` real, ER en mermaid, soluciones extraídas.
- Sesión 2 §2.5–§2.6: tests reales del proyecto + solución del ejercicio.
- Bloque Vue: enlaces a sesiones reparados (commit `0cd2099`).
- Cambios pendientes sin commit: `01-oracle/sesiones/1-fundamentos-oracle/index.md`, `02-dotnet/index.md`.

---

## 3. Aplicación de apoyo: `uaReservas`

Ruta: `C:\Users\Tortosa.CAMPUS\source\repos\documentacion\cursos\CursoNormalizacionApps\uaReservas`

Aplicación **completa de referencia** que el alumnado replica/extiende durante el curso. Es lo que demuestra "cómo queda al final" cada sesión. Cualquier ejemplo de código del curso debe ser **compatible** con su estructura real — si difieres, alinea el material con la app, no al revés.

### 3.1 Stack

- **Backend**: ASP.NET Core (`net10.0`), namespace raíz `ua`, configuraciones `Local | Debug | Preproduccion | Release | FUERA_UA`.
- **Paquetes UA clave** (ver `uaReservas.csproj`):
  - `PlantillaMVCCore.{Configuracion, Idioma, Plantilla, Errores, Identificacion, Seguridad}`
  - `ClaseOracleBD3` (acceso a datos Oracle) — skill `ua-oracle-datos`
  - `ClaseToken`, `ClaseCorreo2`
  - `Scalar.AspNetCore` (UI OpenAPI; Swagger sustituido por Scalar)
- **Frontend** (`ClientApp/`): Vue 3.5, TypeScript, Vite 7, `vue-i18n`, `pinia`, `vue-router`, `@vueua/components`, `@vueua/plantilla-core`, `@vueua/plantilla-uacloud`, `axios`.
- **SPA servida por .NET** vía `UseViteDevelopmentServer(true)` en Debug; `pnpm run build` en Release/Preproduccion. Política: **nunca** `pnpm install` automático desde MSBuild.

### 3.2 Estructura

```
uaReservas/
├── Program.cs                     # DI, middleware, OpenAPI/Scalar, ErrorHandler
├── appsettings*.json              # Local / development / staging / production
├── Controllers/
│   ├── Apis/
│   │   ├── ApiControllerBase.cs
│   │   ├── ControladorBase.cs
│   │   ├── InfoController.cs
│   │   ├── RecursosController.cs
│   │   ├── TipoRecursosController.cs
│   │   └── ReservasController.cs
│   ├── HomeController.cs
│   └── PlantillaController.cs
├── Models/
│   ├── Plantilla/                 # Modelos de la plantilla UA
│   ├── EndPoints/
│   ├── Errors/
│   └── Reservas/                  # DTOs del dominio: TipoRecurso / Recurso / Reserva
│       ├── *Lectura.cs            # DTO de lectura (mapea VRES_*)
│       ├── *CrearDto.cs           # DTO de entrada para POST
│       ├── *ActualizarDto.cs      # DTO de entrada para PUT
│       └── RecursoActualizarFlagsDto.cs / ReservaFiltroDto.cs
├── Services/Reservas/             # IXxxServicio + XxxServicio (acceso a Oracle)
├── SQL/CURSONORMADM/              # Esquema propietario de datos
│   ├── TABLAS/                    # TRES_* (TIPO_RECURSO, RECURSO, RESERVA, HORARIO_DIA, FRANJA_HORARIO, OBSERVACION_RESERVA) + vistas externas (VPERSONAS, VRES_FESTIVOS)
│   ├── VISTAS/                    # VRES_* orientadas al usuario WEB (con alias para automapeo)
│   ├── PAQUETES/                  # PKG_RES_* con INSERTAR/ACTUALIZAR/ELIMINAR/LISTAR/OBTENER_POR_ID + PKG_RES_VALIDACIONES + PKG_EJERCICIO
│   ├── SEGURIDAD/                 # Grants WEB
│   └── PARCHES/
├── Resources/                     # .resx para IStringLocalizer
├── Views/                         # Razor (capa MVC residual de la plantilla)
└── ClientApp/                     # SPA Vue
    ├── vite.config.ts
    ├── package.json               # @vueua/* + ecosistema Vue 3
    ├── copy-assets.js             # Copia el build a wwwroot
    └── src/
        ├── App.vue / main.ts / router.ts / i18n.ts
        ├── views/
        │   ├── Home.vue           # Página de inicio real (la sesión 1 §1.8 se alinea con esta)
        │   ├── Vista1.vue
        │   └── sesiones-vue/      # Ejercicios y demostraciones de cada sesión Vue
        ├── components/Plantilla/  # Cabecera, menú, layout UA
        ├── services/              # (vacío; se llenará durante el curso)
        ├── locales/               # Traducciones vue-i18n
        └── assets/
```

### 3.3 Dominio: reservas de recursos

- **TIPO_RECURSO** → **RECURSO** → **RESERVA**
- Tablas auxiliares: `HORARIO_DIA`, `FRANJA_HORARIO`, `OBSERVACION_RESERVA`.
- Reglas de negocio en `PKG_RES_VALIDACIONES` (incluye detección de solapamiento entre reservas — base del ejercicio 3 del bloque Oracle).
- Vistas `VRES_*` proyectan columnas con alias listos para el automapeo de `ClaseOracleBD3` a los DTOs `*Lectura`.
- `VRES_RESERVA_ACTIVA` aplica el filtro de eliminación lógica (`ACTIVO = 'S'`).

### 3.4 Esquemas Oracle

- **`CURSONORMADM`** — propietario de datos (todas las tablas, vistas y paquetes viven aquí).
- **`CURSONORMWEB`** — usuario de aplicación: solo `EXECUTE` sobre paquetes y `SELECT` sobre vistas. Es el que usa la API.

Esta separación es la columna vertebral del bloque Oracle y debe respetarse en cualquier ejemplo nuevo.

### 3.5 Cómo arrancar

- `run.ps1` lanza la app; `Leeme.txt` documenta cómo personalizar `appsettings.json` (`App.Version`, `DirApp`) y `launchSettings.json` (`launchUrl` = `app` para SPA o `swagger`/`scalar` para la API).
- En desarrollo: dotnet sirve la API, Vite sirve el SPA en caliente.
- En `Release`/`Preproduccion`: MSBuild ejecuta `pnpm run build` y publica en `wwwroot/`.

---

## 4. Skills UA aplicables

Cuando edites material o código alineado con la app, usa los skills correspondientes:

| Skill | Cuándo |
|---|---|
| `ua-docs-vitepress` | Crear/transformar páginas del curso |
| `ua-oracle-crud-plsql` | Paquetes CRUD nuevos en `SQL/CURSONORMADM/PAQUETES/` |
| `ua-oracle-datos` | Ejemplos de `ClaseOracleBD3` en servicios |
| `ua-dotnet-datatable` | CRUD full-stack con paginación servidor (sesión 14) |
| `ua-dotnet-errores` | Sesión 13 — `ErrorHandlerMiddleware`, `ClaseErrores` |
| `ua-dotnet-seguridad` | Sesión 16 — Claims/roles/políticas, CAS |
| `ua-dotnet-serilog` | Sesión 20 — sinks Console/Oracle/File/Email |
| `ua-dotnet-test` | Sesión 18 — xUnit + `WebApplicationFactory` |
| `ua-validacion` | Sesión 12 — DataAnnotations + FluentValidation + `useGestionFormularios` v2. **Reemplaza** a `ua-vue-formularios` (obsoleto). |
| `ua-playwright-cas` | Pruebas E2E con login CAS de preproducción |

---

## 5. Reglas de trabajo sobre el curso

- **Alinea siempre con la app real** (`uaReservas`). Si un fragmento de código difiere de lo que hay en `Models/Reservas/`, `Services/Reservas/`, `SQL/CURSONORMADM/` o `ClientApp/src/`, corrige el curso, no inventes una variante.
- **No introduzcas piezas obsoletas**: TanStack Form está fuera; el formato de errores es `ValidationProblemDetails`, no `ClaseErroresWebAPI` legacy.
- Las **soluciones de ejercicios** van en ficheros aparte dentro de la sesión correspondiente, no inline en el enunciado (patrón seguido en commits recientes).
- **Diagramas ER**: mermaid.
- Idioma del material: **español**, sin tildes en identificadores ni en nombres de archivo/skill.
- El sidebar global solo enumera los 6 bloques top-level; cada bloque gestiona su propio `_sidebar.json`.
