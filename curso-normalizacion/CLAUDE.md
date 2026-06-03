# CLAUDE.md — Curso de Normalización (revisión Vue y posteriores)

Material docente VitePress de la Universidad de Alicante para normalizar el desarrollo de
aplicaciones internas con el stack **Oracle + .NET 10 + Vue 3 (TypeScript)**.

Este documento se centra en **revisar las sesiones de Vue y las posteriores** (sesiones 9 a 25
del temario global) y en cómo se relacionan con dos piezas de apoyo que viven **fuera** de esta
carpeta, dentro de `cursos/`:

- **App demo:** `CursoNormalizacionApps/uaReservas` (.NET + Vue), con un sandbox de demos por sesión.
- **Librería de componentes:** `vueua-components` (paquete `@vueua/components`).

> Para la guía interna del profesor y el detalle de las partes Oracle/.NET, ver
> [`docs-internos/CLAUDE.md`](./docs-internos/CLAUDE.md). Este fichero **no** la sustituye.

---

## 1. Dónde está cada cosa

```
cursos/                                  (raíz del workspace)
├── cursos-2026/curso-normalizacion/     ← ESTA carpeta (el material VitePress)
│   ├── por-publicar/                    ← sitio publicado (sesiones de los alumnos)
│   │   ├── 03-vue/sesiones/             ← Vue: sesiones 9–13
│   │   ├── 04-integracion/sesiones/     ← Integración full-stack: sesiones 14–17
│   │   ├── 05-avanzadas/sesiones/       ← Avanzadas: sesiones 18–25
│   │   └── 06-proyecto-final/index.md   ← proyecto de reservas (4 módulos progresivos)
│   └── docs-internos/                   ← guías del profesor (no se publican)
├── CursoNormalizacionApps/uaReservas/   ← app demo de referencia
│   └── ClientApp/src/views/sesiones-vue/  ← demos visuales por sesión
└── vueua-components/                    ← código fuente de @vueua/components
```

Cada sesión publicada es un `index.md` dentro de `por-publicar/<bloque>/sesiones/sesion-NN-.../`.
Cada bloque tiene además `_sidebar.json`, un `index.md` de bloque y una carpeta `test/`.

---

## 2. ⚠️ Tres numeraciones distintas (leer antes de tocar nada)

El curso ha cambiado de estructura y conviven **tres esquemas de numeración** que NO coinciden.
Esta es la causa de errores más habitual al revisar. **El esquema canónico es el del nombre de
carpeta** (`sesion-09`, `sesion-10`, …); lo demás puede estar desactualizado.

| Fuente | Ejemplo | Estado |
|--------|---------|--------|
| **Nombre de carpeta** (`por-publicar/.../sesion-NN-...`) | `sesion-14-api-autenticacion` | ✅ Canónico — usar este |
| **`title:` del frontmatter** | `"Sesión 11: Llamadas a la API..."` en `sesion-14-...` | ⚠️ Desfasado en varios ficheros |
| **Carpetas de la app demo** (`ClientApp/src/views/sesiones-vue/sesion-N`) | `sesion-6` … `sesion-10` | ℹ️ Esquema interno antiguo |
| **Tabla maestra** de `06-proyecto-final/index.md` | numeración de 28 filas | ℹ️ Otro esquema más |

**Frontmatter conocido como inconsistente** (el `title:` no concuerda con la carpeta):

- `04-integracion`: sesiones 14–17 llevan títulos "Sesión 11–14".
- `05-avanzadas`: 18→"15", 19→"16", 20→"17", 22→"19", 23→"20", 24→"21", 25→"22"
  (la 21 y la 18 sí coinciden por casualidad).

Al revisar, **señala estas discrepancias** en lugar de "arreglarlas" a ciegas: puede que el equipo
quiera renumerar el frontmatter para alinearlo con la carpeta, o al revés.

---

## 3. Contenido de los grupos de sesiones

### 03-vue — Vue 3 con TypeScript (sesiones 9–13)

Fundamentos de Vue 3. Cierra con los componentes internos de la UA.

| Sesión (carpeta) | Contenido |
|---|---|
| `sesion-09-vue-typescript-fundamentos` | Estructura `.vue`, TypeScript básico, reactividad (`ref`/`reactive`), interpolación |
| `sesion-10-directivas-eventos` | Interfaces, directivas (`v-if`/`v-show`/`v-bind`), `v-model`, eventos, métodos de arrays |
| `sesion-11-componentes-estado` | `computed`, Props, Emits, `defineModel`, watchers, lifecycle, slots |
| `sesion-12-arquitectura-apis` | Composables vs Servicios, patrón **Vista → Composable → Servicio**, depuración |
| `sesion-13-componentes-ua` | `@vueua/components`: modales, toasts, `BotonLoading`, Teleport |

> Las llamadas reales a la API (`useAxios`), validación (`useGestionFormularios`) y estado global
> (Pinia) se ven en los bloques siguientes, de extremo a extremo.

### 04-integracion — Full-stack Oracle → .NET → Vue (sesiones 14–17)

Cada sesión recorre un tema transversal de extremo a extremo.

| Sesión (carpeta) | Contenido |
|---|---|
| `sesion-14-api-autenticacion` | Cómo Vue habla con .NET, CAS/JWT, OpenAPI y Scalar |
| `sesion-15-validacion` | DataAnnotations, FluentValidation, ModelState, errores en Vue |
| `sesion-16-errores` | `Result<T>`, `ProblemDetails` (RFC 7807), `IExceptionHandler`, toasts y modales |
| `sesion-17-datatable` | `ClaseCrudUtils` en .NET + `DataTable` de `@vueua/components` |

### 05-avanzadas — Temas especializados (sesiones 18–25)

| Sesión (carpeta) | Contenido |
|---|---|
| `sesion-18-internacionalizacion` | `vue-i18n`, `.resx`, idioma del JWT |
| `sesion-19-seguridad-menus` | Roles, políticas, rutas protegidas, layout |
| `sesion-20-estado-persistencia` | Pinia, `localStorage`, `provide`/`inject` |
| `sesion-21-tests-calidad` | xUnit, `WebApplicationFactory`, `httpRepl` |
| `sesion-22-ficheros` | Upload/download, BLOB, validaciones |
| `sesion-23-logs-diagnostico` | Serilog, sinks, consultas Oracle |
| `sesion-24-accesibilidad-ens` | WCAG 2.1 AA, ENS, documentación, CAU |
| `sesion-25-copilot-organizacion` | Copilot agente, organización del repositorio, checklist final |

### 06-proyecto-final — Aplicación de reservas

No es una entrega aislada: son **4 módulos progresivos** que el alumno construye a lo largo del curso.
El dominio crece de izquierda a derecha: **Tipo de recurso → Recurso → Horario → Reserva**
(+ `Festivos` que bloquea reservas). El `index.md` contiene la tabla maestra de hitos por sesión y
los criterios de aceptación por módulo. La app demo es la **referencia visual** de este proyecto.

---

## 4. Relación con la app demo (`CursoNormalizacionApps/uaReservas`)

La app es un sandbox ejecutable: para cada sesión hay demos navegables en
`ClientApp/src/views/sesiones-vue/` (y `sesiones-dotnet/` para los bloques previos). El material
publicado las cita como "la demo equivalente está en `ClientApp/src/views/sesiones-vue/sesion-N/`".

**🔑 Las carpetas de la app usan numeración antigua: `app sesión N = publicada N+3`.**

| App (`sesiones-vue/`) | Publicada | Demos incluidas |
|---|---|---|
| `sesion-6` (*"Vue 3 y primer componente"*) | **Sesión 9** | HolaVue, TypeScriptBasico, RefVsReactive, Interpolacion, DemoTipoRecurso, Depuracion |
| `sesion-7` (*"Directivas, eventos y datos"*) | **Sesión 10** | Semaforo, VifVshow, VBind, ListaReservas, MetodosArrays, SpreadDestructuring, TablaRecursos |
| `sesion-8` (*"Componentes y comunicación"*) | **Sesión 11** | Computed, PropsEmits(+Modal), DefineModel, Watchers, Lifecycle, Slots, FormularioReserva |
| `sesion-9` (*"Arquitectura: composables y servicios"*) | **Sesión 12** | ContadorComposable, UseUtils, UseToast, BotonLoading, ArquitecturaTresCapas |
| `sesion-10` (*"Componentes internos UA"*) | **Sesión 13** | PopUpModal, DialogModal, SpinnerModal, Checkbox3estados, Teleport, **CrudRecursos** |

`Sesion10CrudRecursos.vue` es la **referencia visual del CRUD completo** del Módulo 1 del proyecto.

Estructura cliente relevante de la app:

- `ClientApp/src/composables/` — `useContador`, `useCrudResource`, `useRecursos`.
- `ClientApp/src/services/` — `api/` (cliente real) y `recursosServicioMock.ts` (mock que sustituye
  a la API hasta la sesión 14, donde se cambia el mock por `useAxios`).
- `ClientApp/src/views/sesiones-dotnet/` — demos de los bloques Oracle/.NET (probador de API,
  CRUD real de TipoRecurso/Recurso/Reserva/Observaciones).
- Backend .NET en la raíz de `uaReservas/` (`Controllers/`, `Services/`, `Models/`, `Program.cs`,
  `SQL/`), con tests en `uaReservas.Tests/`.

Stack del cliente (`ClientApp/package.json`): Vue 3.5, vue-router 4, Pinia 3, vue-i18n 11,
axios, Bootstrap 5, zod, y los paquetes `@vueua/*`.

---

## 5. Relación con `vueua-components` (`@vueua/components`)

`cursos/vueua-components/` es el **código fuente** de la librería unificada de componentes Vue 3 de
la UA (`package.json` → `"name": "@vueua/components"`). Es lo que las sesiones 13–17+ enseñan a usar.

> ⚠️ **Ojo a la ruta de consumo.** La app NO importa desde `cursos/vueua-components` directamente:
> en `ClientApp/package.json` el paquete apunta a
> `"@vueua/components": "file:../../../uacloud2026/packages/componentes"` (un espejo/build externo
> al workspace). Si revisas comportamiento de un componente, la **fuente de verdad** es
> `cursos/vueua-components/src/`, pero la versión que ejecuta la app puede diferir de ese espejo.

Contenido del paquete (`src/`), que es lo que demuestran las sesiones:

- **`composables/`** — `useAxios` (HTTP con renovación CAS/JWT, `peticion<T>`), `useToast`,
  `useUtils` (`generateUniqueId`, `deepClone`), `useGestionFormularios` (validación HTML5 +
  `ProblemDetails`), `use-carga-datos-api`, `use-theme`.
- **`ui/`** — `DialogModal`, `PopUpModal`, `SpinnerModal`, `BotonLoading` (+ directiva `v-loading`),
  `Checkbox3Estados`, `Autocomplete`, `QuillEditor`, `SelectorFicheros`, `Select`.
- **`advanced/`** — `DataTable` (CRUD con paginación servidor, filtros, ordenación),
  `GestorDocumentacion`.
- **`core/`** — `errores-app` (store Pinia de errores, `ErrorPage.vue`), `plantilla-mvc`,
  `plantilla-uacloud`.
- **`uacloud2026/`** — design system 2026 (alerta, avatar, barra-lateral/superior, boton, campo-texto,
  modal, tabla, toast, selector-idioma…). Se consume aparte vía `@vueua/components/uacloud2026`
  (no se reexporta desde el índice para evitar colisiones con componentes legacy).

Mapa sesión ↔ pieza de la librería:

| Sesión publicada | Pieza de `@vueua/components` |
|---|---|
| 13 (componentes UA) | `DialogModal`, `PopUpModal`, `SpinnerModal`, `BotonLoading`, `Checkbox3Estados`, Teleport |
| 12 (arquitectura) | `useToast`, `useUtils`, `BotonLoading` |
| 14 (API/auth) | `useAxios` / `peticion<T>` |
| 15 (validación) | `useGestionFormularios` (+ `ProblemDetails`) |
| 16 (errores) | `core/errores-app` (store Pinia, `ErrorPage.vue`), toasts |
| 17 (DataTable) | `advanced/DataTable` |

---

## 6. Trabajar con el material

- Es un sitio **VitePress** con **pnpm 10.22.0**. Desde `por-publicar/`: `pnpm install` y
  `pnpm run docs:dev` (URL típica `http://localhost:5173/curso-normalizacion/`). Ver `README.md`.
- Páginas en Markdown VitePress: frontmatter YAML (`title`, `description`, `outline`), admonitions
  (`::: tip|warning|info|details`), `::: code-group`, tablas, mermaid.
- El skill **`ua-docs-vitepress`** es la referencia para crear o transformar páginas de documentación.
- Al revisar una sesión Vue+, contrasta el contenido con: (1) su demo en la app (recordando el
  offset **N+3**), (2) la API real de `@vueua/components` en `cursos/vueua-components/src/`, y
  (3) la fila correspondiente de la tabla maestra del proyecto final.

### Cosas a vigilar en una revisión

- **Desfase de numeración** del frontmatter respecto a la carpeta (sección 2).
- **Referencias cruzadas** entre sesiones (enlaces `../sesion-NN-.../`) que apunten a la carpeta
  correcta tras renumeraciones.
- **Nombres de componentes/composables** citados en el texto que existan realmente en
  `vueua-components/src/` (la librería evoluciona; ver `CAMBIOS.md` del paquete).
- **Coherencia con la app demo**: que las rutas `ClientApp/src/views/sesiones-vue/sesion-N/`
  citadas existan y correspondan a la sesión (offset N+3).
