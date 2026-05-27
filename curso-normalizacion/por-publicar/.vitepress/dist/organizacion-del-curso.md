---
url: /curso-normalizacion/organizacion-del-curso.md
description: >-
  Índice y estructura completa del curso de normalización de la Universidad de
  Alicante — 25 sesiones de 1 h 30 min.
---

# Organización del curso

El curso consta de **25 sesiones de 1 h 30 min** organizadas en seis bloques temáticos, más una sesión previa de preparación del entorno (no cuenta en la numeración) y un proyecto final transversal.

## Sesión previa — Preparación del entorno

[Bloque 0 · 00-preparacion](./00-preparacion/) · **1 h 30 min**

* Herramientas a instalar: Git for Windows, Node.js, .NET SDK 10, Visual Studio 2022, VS Code.
* Configuración de Git: identidad (`user.name`, `user.email`), `autocrlf`, editor, rama por defecto.
* Clave SSH: generación RSA, `ssh-agent` automático en PowerShell, `~/.ssh/config`.
* Registrar clave pública en el servidor TFS.
* Autenticación HTTPS con TFS y Git Credential Manager.
* Configuración npm: `~/.npmrc` con PAT (Personal Access Token) codificado en Base64.
* Configuración NuGet: fuentes `nuget.org`, `NUGET UA`, `ServidorTFS` y paquetes locales.
* Clonar un repositorio por SSH y por HTTPS.
* Extensiones de VS Code recomendadas: Vue - Official, C# Dev Kit, i18n Ally, Oracle SQL Developer, Playwright.
* Permiso COPILOT y extensión de accesibilidad.

***

## Bloque 1 — Oracle (Sesiones 1 a 5)

### Sesión 1 — Fundamentos Oracle

* Arquitectura de dos esquemas: propietario de datos vs usuario de aplicación.
* Cómo se relacionan las tablas, vistas y paquetes con el código .NET.
* Convenciones de nombres en cada capa: base de datos, C# y TypeScript.
* Cómo se traducen los tipos de Oracle a .NET: los casos que requieren atención.
* Cuándo el mapeo es automático y cuándo hay que hacerlo a mano.
* Cómo se controla el acceso: qué puede hacer el usuario de aplicación y qué no.
* Buenas prácticas de diseño de esquema.

### Sesión 2 — Ejercicio: inspección del schema y diseño de un catálogo

* Inspeccionar el schema con `oracle-schema-extractor` y SQL Developer.
* Diseñar e implementar un catálogo simple respetando las convenciones del bloque.

### Sesión 3 — Tablas, vistas y paquetes

* Tablas: PK, FK, restricciones `CHECK`, índices y comentarios; tablespaces `OTRAS_APP_DAT` / `OTRAS_APP_IND`.
* Vistas orientadas al usuario WEB: alias para el automapeo .NET, sin `SELECT *`, uso del Explain Plan.
* Operaciones estándar de un package CRUD: `INSERTAR`, `ACTUALIZAR`, `ELIMINAR`, `LISTAR`, `OBTENER_POR_ID`.
* Ocultar y mostrar registros usando eliminación lógica con un campo `ACTIVO` y filtros en la vista.
* Flujo completo: `TABLA → VISTA → DTO .NET → API → Vue`.

### Sesión 4 — Ejercicio: diseño de vistas

* Diseñar `VRES_FRANJA_HORARIO` y `VRES_HORARIO_DIA` con alias listos para el automapeo.
* Validar con Explain Plan y consultar desde el usuario WEB.

### Sesión 5 — Ejercicio: procedimientos en paquetes

* Implementar `ACTUALIZAR_BLOQUEADO`, `CREAR_HORARIO_DIA` y `CREAR_RESERVA`.
* Detección de solapamiento entre reservas en el propio paquete.

***

## Bloque 2 — .NET Core 10 (Sesiones 6 a 8)

### Sesión 6 — Introducción a .NET

* Crear proyecto desde VS 2022, configuración inicial y uso de GIT.
* ¿Qué es .NET? Versiones y novedades de .NET 10.
* Anatomía del proyecto (`PlantillaMVCCore`): estructura de carpetas y archivos clave.
* `Program.cs`: registro de servicios y pipeline de middleware.
* Inyección de dependencias: interfaz, implementación y `ServicesExtensionsApp`.
* Ciclos de vida: `AddTransient`, `AddScoped`, `AddSingleton`.
* C# útil en el contexto del curso: pattern matching, null-conditional, null-coalescing, tuplas internas.
* Novedades reales de .NET 10 y C# 14 con impacto práctico: OpenAPI en ASP.NET Core, `dotnet test` con Microsoft.Testing.Platform, null-conditional assignment y `field` backed properties.

### Sesión 7 — Modelos y primer API

* Modelos (DTO): qué son y convenciones de nombres.
* Anatomía de un controlador API.
* Verbos HTTP y códigos de estado.
* Diseño de respuestas de la API: respuestas tipadas (`Ok()`, `NotFound()`, `BadRequest()`) frente a respuestas uniformes, ventajas e inconvenientes.
* Probar la API sin base de datos.
* Llamar a la API desde Vue con TypeScript.

### Sesión 8 — Servicios y acceso a Oracle

* Separar la lógica en capas: controlador, servicio e interfaz.
* Cómo acceder a Oracle desde .NET y mapear los datos a objetos.
* Cómo registrar y conectar las piezas entre sí.
* Flujo completo de una petición: desde Vue hasta Oracle y de vuelta.

> Validación avanzada, gestión global de errores, DataTable server-side y documentación OpenAPI se cubren de extremo a extremo en el bloque **Integración** (sesiones 14-17).

***

## Bloque 3 — Vue 3 con TypeScript (Sesiones 9 a 13)

### Sesión 9 — Vue 3, TypeScript y primer componente

* ¿Por qué Vue 3 en la UA?
* Estructura de un `.vue`: script, template y style.
* Vistas vs componentes.
* TypeScript básico: tipos, `const`/`let`, union types, `any` vs `unknown`.
* Reactividad con `ref` y `reactive`.
* Interpolación en el template.
* Depuración básica con Vue Devtools.

### Sesión 10 — Directivas, eventos y datos

* Interfaces TypeScript: contratos de datos.
* Funciones tipadas en componentes Vue.
* Renderizado condicional: `v-if` vs `v-show`.
* Renderizado de listas con `v-for` y `:key`.
* Vincular atributos con `v-bind` y clases CSS dinámicas.
* Enlace bidireccional con `v-model`.
* Eventos del DOM y modificadores.
* Métodos de arrays: `.map()`, `.filter()`, `.find()`, `.reduce()`.
* Spread, destructuring, optional chaining y nullish coalescing.

### Sesión 11 — Componentes y comunicación

* Propiedades computadas con `computed`.
* Patrón de formulario: entrada → derivado → acción.
* Comunicación padre → hijo con Props (`defineProps`).
* Comunicación hijo → padre con Emits (`defineEmits`).
* Comunicación bidireccional con `defineModel`.
* Watchers: `watch` y `watchEffect`.
* Lifecycle hooks y carga asíncrona con `onMounted`.
* Slots: contenido dinámico y layouts reutilizables.

### Sesión 12 — Arquitectura de componentes y servicios

* Composables vs Servicios: cuándo usar cada uno.
* Arquitectura Vista → Composable → Servicio.
* Herramientas de depuración: Vue Devtools, `vue-tsc` y Network.

### Sesión 13 — Otros componentes internos

* `PopUpModal`, `DialogModal`, `SpinnerModal`: modales reutilizables y patrones de uso.
* `BotonLoading` y directiva `v-loading`.
* `useToast` para notificaciones, `Checkbox3estados`.
* `Teleport`: renderizar elementos fuera del árbol de componentes.

***

## Bloque 4 — Integración full-stack (Sesiones 14 a 17)

### Sesión 14 — Llamadas a la API y autenticación

* Cómo funciona la autenticación: CAS, cookies de sesión y tokens JWT.
* Claims del usuario: cómo leerlos en .NET y en Vue.
* Estados de carga: spinners y variables reactivas en Vue; cuándo usar `onMounted` vs `watchEffect`.
* Llamadas a la API con `useAxios` y `HttpApi`: verbos, modos y gestión de errores.
* Explorar y probar la API con OpenAPI y Scalar.

### Sesión 15 — Validación en todas las capas

* Validaciones simples con DataAnnotations.
* Validaciones complejas con FluentValidation: reglas cruzadas y dependientes.
* Uso del ModelState para devolver errores específicos por campo.
* Cómo el servidor devuelve errores de validación y cómo Vue los pinta en el formulario.
* Validación de formularios en Vue con `useGestionFormularios`.

### Sesión 16 — Gestión de errores de extremo a extremo

* Cómo se propaga un error desde Oracle hasta el usuario.
* Tipos de excepción UA: `BDException` (Usuario/Sistema), `AppException`, `InfoException`, `MantenimientoException`.
* `ErrorHandlerMiddleware` de `PlantillaMVCCore.Errores`: decisión JSON vs MVC, notificación por correo, fallback a v1.x.
* `AddClaseErrores()`: enriquecedores de petición, usuario CAS y aplicación; throttling y `EnvioEnDesarrollo`.
* Notificaciones al usuario: toasts de confirmación, error e información.
* Modales de confirmación antes de operaciones destructivas.

### Sesión 17 — DataTable de extremo a extremo

* Listado simple vs DataTable con paginación en servidor: cuándo usar cada uno.
* Lado servidor .NET: `ClaseCrudUtils`, `CamposFiltros`, paginación, filtros y ordenación.
* Lado cliente Vue: componente `vueua-datatable` y su configuración.
* Conectar las dos partes: del endpoint al componente en una sola sesión.

***

## Bloque 5 — Sesiones avanzadas (Sesiones 18 a 25)

### Sesión 18 — Internacionalización

* Localización con `IStringLocalizer` y archivos `.resx`: organización por idioma y acceso desde .NET y Vue.
* Archivos de traducción con `vue-i18n` y cambio de idioma.
* Acceso al idioma del usuario desde el token JWT en .NET.
* Extensión i18n Ally para gestionar traducciones desde VS Code.

### Sesión 19 — Seguridad, menús y perfiles de aplicación

* Autorización basada en roles y políticas en .NET.
* Perfiles de aplicación: qué ve cada usuario según su rol.
* Menú dinámico según permisos: cómo construirlo en Vue.
* Layout general de la aplicación: cabecera, menú lateral y pie.
* Protección de rutas en Vue Router y de endpoints en .NET.
* Verificación múltiple de datos en cliente, servidor y paquete Oracle.

### Sesión 20 — Estado global y persistencia

* Estado global con Pinia: cuándo elevar el estado y cuándo mantenerlo local.
* Persistencia de estado: `localStorage` vs `sessionStorage` vs cookies.
* Patrones de store: stores simples vs stores con acciones asíncronas.
* `provide` / `inject` para dependencias transversales.

### Sesión 21 — Tests y calidad de código

* Tests unitarios en .NET con xUnit: controladores y servicios.
* Tests de integración con `WebApplicationFactory`.
* Pruebas manuales de la API con archivos `.http`: variables, entornos y request variables.
* `httpRepl` como alternativa CLI para explorar la API y ejecutar scripts.
* Automatizar comprobaciones de API para IA con `Invoke-RestMethod` o `curl`.
* ActionFilters: qué son y casos de uso.
* Naming JSON: camelCase vs PascalCase.
* Patrón GET comprobación + POST ejecución con token.

### Sesión 22 — Trabajo con ficheros

* Subida de ficheros desde Vue al servidor .NET.
* Almacenamiento de ficheros en Oracle (BLOB) y en disco.
* Descarga y visualización de ficheros desde Vue.
* Validaciones de tipo, tamaño y nombre en cliente y servidor.
* Gestión de recursos adjuntos en un CRUD completo.

### Sesión 23 — Logs y diagnóstico

* Logging estructurado con Serilog: niveles y cuándo usar cada uno.
* Sinks disponibles: consola, Oracle, fichero y correo electrónico.
* Enriquecimiento del log con datos del usuario y la petición.
* Consultas de diagnóstico sobre los logs almacenados en Oracle.
* VS Code como IDE alternativo: configuración y depuración de .NET.

### Sesión 24 — Accesibilidad y cumplimiento normativo

* Por qué importa la accesibilidad y qué exige el ENS.
* WCAG 2.1 nivel AA: los criterios más relevantes para aplicaciones internas.
* Herramientas de auditoría: axe, Lighthouse.
* Cómo aplicar accesibilidad en componentes Vue: `aria-*`, roles, foco.
* Normalización de datos y cumplimiento ENS.
* Documentación técnica, manual de usuario e integración con CAU.
* Uso de la extensión de accesibilidad de la Unidad de Accesibilidad.

### Sesión 25 — Copilot y organización del proyecto

* Copilot en modo agente: cómo delegar tareas completas.
* Prompts efectivos para generación de código en el contexto del proyecto.
* Revisión crítica del código generado: qué aceptar y qué corregir.
* Organización del repositorio: ramas, convenciones de commits y flujo de trabajo.
* Snippets de VS Code: crear y compartir fragmentos reutilizables.
* Retrospectiva del curso: qué hemos construido y cómo seguir aprendiendo.

***

## Proyecto final — Aplicación de reservas

A lo largo de las 25 sesiones el alumno construye una **aplicación de reservas** en cuatro módulos progresivos:

1. **Tipo de recurso** — Hilo conductor del curso. El material lo construye en clase.
2. **Recurso** — Ejercicio guiado: aplica el patrón con auditoría y seguridad.
3. **Horario** — Profundización: objetos complejos y estado compartido.
4. **Reserva** — Cierre integrador: combina todo con las sesiones avanzadas.

Cada módulo tiene su propia rama de Git (`tiporecurso-<nombre>`, `recurso-<nombre>`, `horario-<nombre>`, `reserva-<nombre>`) y cada día arranca con la solución del día anterior publicada en `master`.

Mapa maestro, hitos por sesión y criterios de aceptación en: [Proyecto final del curso](./06-proyecto-final/).
