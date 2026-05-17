# Plan de alineación — Sesiones Vue del curso ↔ `uaReservas` ↔ `vueua-lib`

> Objetivo: completar el sandbox `uaReservas/ClientApp/src/views/sesiones-vue/` para que **cada concepto del temario Vue tenga una demo abrible en el navegador**, introduciendo los componentes simples de `vueua-lib` solo cuando aportan claridad didáctica. No se trata de mostrar todos los componentes — se trata de explicar bien cada concepto.

Referencias:

- Temario maestro: [`organizacion-del-curso.md`](./organizacion-del-curso.md) (sesiones 6–10)
- Documentación de sesiones: [`03-vue/sesiones/`](./03-vue/sesiones/)
- Sandbox: `C:\Users\Tortosa.CAMPUS\source\repos\documentacion\cursos\CursoNormalizacionApps\uaReservas\ClientApp\src\views\sesiones-vue\`
- Librería UA: `C:\Users\Tortosa.CAMPUS\source\repos\componentes\vue\vueua-lib\` — paquete npm `@vueua/components`

---

## 1. Principios

1. **Una demo, un concepto.** Cada `.vue` aísla una idea (patrón ya establecido en `Sesion6HolaVue.vue`, etc.).
2. **No forzar componentes.** Solo se introduce un componente de `vueua-lib` cuando ilustra mejor el concepto que un ejemplo casero (slots → `DialogModal`, lifecycle → `SpinnerModal`, composable → `useToast`).
3. **Solo componentes simples por ahora.** Quedan fuera de este plan: `Autocomplete`, `QuillEditor`, `SelectorFicheros`, `advanced/*`, `graficas/*`. Se cubrirán cuando el alumno tenga ya la base.
4. **Vue puro hasta donde sea posible.** Sesiones 6 y 7 no necesitan `vueua-lib`; la introducción de la librería empieza en la sesión 8 con slots.
5. **Cada demo cita el fichero real** del proyecto, igual que ya hace `Sesion6Indice.vue`.

---

## 2. Catálogo de piezas simples de `vueua-lib` que usaremos

| Pieza | Tipo | Importación | Dónde encaja didácticamente |
|---|---|---|---|
| `useToast` (`avisar`, `avisarError`, …) | Composable + componente | `@vueua/components/composables/use-toast` | **S9** ejemplo canónico de composable |
| `BotonLoading` | UI | `@vueua/components/ui/boton-loading` | **S9** patrón "ocupado" reutilizable |
| `PopUpModal` | UI (API imperativa, `show()` → Promise) | `@vueua/components/ui/popup-modal` | **S8** Props/Emits vs API imperativa · **S10** confirmaciones |
| `DialogModal` | UI (API declarativa, `v-model:visible` + slots) | `@vueua/components/ui/dialog-modal` | **S8** slots reales · **S10** formularios en modal |
| `SpinnerModal` | UI (`show()` / `hide()`) | `@vueua/components/ui/spinner-modal` | **S8** `onMounted` + async · **S10** bloqueo de pantalla |
| `Checkbox3estados` | UI | `@vueua/components/ui/checkbox-3-estados` | **S10** caso real de `v-model` con `boolean \| null` |
| `useUtils` (`generateUniqueId`, `deepClone`) | Composable | `@vueua/components/composables/use-utils` | **S9** ejemplo de composable sin estado |

Componentes **fuera de este plan** (complejos): `Autocomplete`, `QuillEditor`, `SelectorFicheros`, `advanced/*`. Se mencionan en la sesión 10 como "existen y los veremos cuando los necesitemos en integración".

Composables fuera de este plan: `useAxios`, `useGestionFormularios` (van en sesiones 11–12, no aquí).

---

## 3. Estado actual del sandbox

```
ClientApp/src/views/sesiones-vue/
├── IndiceSesionesVue.vue                   ✅ completo (cards a S6/S7/S8)
├── sesion-6/                               ✅ 5/5 demos disponibles
│   ├── Sesion6Indice.vue
│   ├── Sesion6HolaVue.vue
│   ├── Sesion6TypeScriptBasico.vue
│   ├── Sesion6RefVsReactive.vue
│   ├── Sesion6Interpolacion.vue
│   └── Sesion6DemoTipoRecurso.vue
├── sesion-7/                               🟡 0/6 demos (solo índice, todas "Próximamente")
│   └── Sesion7Indice.vue
└── sesion-8/                               🟡 0/7 demos (solo índice, todas "Próximamente")
    └── Sesion8Indice.vue
```

**No existen**: `sesion-9/` ni `sesion-10/`. Hay que crearlas.

`router.ts` solo tiene rutas registradas para los índices de S7/S8 — habrá que ampliarlo a medida que se creen las demos.

`App.vue` debe montar `<ToastContainer />` una sola vez para que `avisar()` funcione desde cualquier vista (verificar; si falta, añadirlo en la S9 cuando se introduce `useToast`).

---

## 4. Plan por sesión

### Sesión 6 — Fundamentos *(✅ completa, sin cambios)*

| Concepto | Demo | `vueua-lib` |
|---|---|---|
| Estructura `.vue`, `ref`, `v-model` | `Sesion6HolaVue.vue` | — |
| Tipos primitivos, `union`, `any` vs `unknown` | `Sesion6TypeScriptBasico.vue` | — |
| `ref` vs `reactive` | `Sesion6RefVsReactive.vue` | — |
| Interpolación | `Sesion6Interpolacion.vue` | — |
| Integradora (TipoRecurso mock) | `Sesion6DemoTipoRecurso.vue` | — |

**Acción**: ninguna. Demasiado pronto para introducir librería.

---

### Sesión 7 — Directivas, eventos y datos *(🟡 crear las 6 demos)*

**Política**: Vue puro. Sin `vueua-lib`. Si introducimos toasts aquí, el alumno mezcla "directiva" con "API externa" y se confunde.

| Concepto del temario | Demo a crear | Notas didácticas |
|---|---|---|
| `v-bind` + clases dinámicas + union types | `Sesion7Semaforo.vue` | Estado `'rojo' \| 'ambar' \| 'verde'`, botón cambia |
| `v-if` vs `v-show` | `Sesion7VifVshow.vue` | Inspeccionar DOM en DevTools |
| `v-for`, `:key`, `v-model`, `@keyup.enter` | `Sesion7ListaTareas.vue` | Sigue el modelo `IClaseTarea` del temario |
| `.map`, `.filter`, `.find`, `.reduce` | `Sesion7MetodosArrays.vue` | Cada método con su salida visible |
| Spread, destructuring, `?.`, `??` | `Sesion7SpreadDestructuring.vue` | Sin Vue: solo TS en panel |
| Integradora dominio | `Sesion7TablaRecursos.vue` | Tabla mock de recursos con filtro, orden y `v-model` en checkbox |

**Acción**: 6 demos nuevas + 6 rutas en `router.ts`. Marcar `disponible: true` en `Sesion7Indice.vue`.

---

### Sesión 8 — Componentes y comunicación *(🟡 crear las 7 demos + introducir `vueua-lib`)*

Aquí **sí entran** las primeras piezas de `vueua-lib`, pero con cuidado: la demo enseña el concepto Vue, y el componente UA aparece como **ejemplo real del patrón**.

| Concepto | Demo a crear | `vueua-lib` integrado | Justificación didáctica |
|---|---|---|---|
| `computed` | `Sesion8Computed.vue` | — | Precio + IVA. Concepto puro. |
| Props / Emits | `Sesion8PropsEmits.vue` | — | `TarjetaContador.vue` casero |
| Props / Emits — API imperativa | `Sesion8PropsEmitsModal.vue` *(nuevo, opcional)* | `PopUpModal` | Mostrar que `ref + show()` es **otra forma** legítima de comunicar; comparar con props/emits |
| `defineModel` | `Sesion8DefineModel.vue` | — | Input casero con `v-model` |
| `watch` / `watchEffect` | `Sesion8Watchers.vue` | — | Concepto puro |
| Lifecycle + async | `Sesion8Lifecycle.vue` | `SpinnerModal` | `onMounted` con `setTimeout(2s)` + spinner real mientras carga |
| Slots | `Sesion8Slots.vue` | `DialogModal` (lectura) | Construir un `TarjetaUA.vue` casero con slot default/header/footer y **enseñar** que `DialogModal` usa exactamente este patrón (`#header`, `#body`, `#buttons`). Mostrar el código mínimo de uso. |
| Integradora dominio | `Sesion8FormularioReserva.vue` | — | Formulario mock con `computed` + `defineModel` + slot |

**Acción**:

1. Crear las 7 demos listadas en `Sesion8Indice.vue` + (opcional) `Sesion8PropsEmitsModal.vue`.
2. Añadir entrada para la demo opcional en el índice si se incluye.
3. Registrar rutas en `router.ts`.
4. **Verificar** `App.vue`: si `SpinnerModal` necesita estar montado a nivel app, montarlo aquí o usar el modo `ref` por demo (preferible: por demo, así el alumno ve el componente al lado del código).

---

### Sesión 9 — Arquitectura de componentes y servicios *(🆕 crear estructura + 5 demos)*

Esta es **la sesión natural** para introducir composables UA. El temario es claro: `useAxios` y `useGestionFormularios` se ven en S11/S12 — aquí mostramos composables **sin red**.

Crear:

```
sesion-9/
├── Sesion9Indice.vue
├── Sesion9ContadorComposable.vue           ← composable casero useContador
├── Sesion9UseUtils.vue                     ← @vueua/components/composables/use-utils
├── Sesion9UseToast.vue                     ← @vueua/components/composables/use-toast (ejemplo canónico)
├── Sesion9BotonLoading.vue                 ← @vueua/components/ui/boton-loading
└── Sesion9ArquitecturaTresCapas.vue        ← Vista → composable → "servicio" mock (sin axios real)
```

| Demo | Concepto del temario | `vueua-lib` |
|---|---|---|
| `Sesion9ContadorComposable.vue` | "Estructura básica" de un composable | — (casero) |
| `Sesion9UseUtils.vue` | Composable sin estado | `useUtils` → `generateUniqueId`, `deepClone` |
| `Sesion9UseToast.vue` | Composable + componente con `Teleport` | `useToast`, `ToastContainer` |
| `Sesion9BotonLoading.vue` | Encapsular patrón reutilizable en un componente | `BotonLoading` (componente y directiva `v-loading`) |
| `Sesion9ArquitecturaTresCapas.vue` | Vista → Composable → Servicio | Servicio devuelve datos mock con `Promise<>` (sin axios) |

**Acción**:

1. Crear carpeta `sesion-9/` con los 5 ficheros.
2. Registrar `<ToastContainer />` en `App.vue` si no está (requisito de `useToast`).
3. Añadir card "Sesión 9" en `IndiceSesionesVue.vue`.
4. Registrar rutas en `router.ts`.

---

### Sesión 10 — Otros componentes internos UA *(🆕 reorientar + crear demos)*

El temario actual cita `vueua-autocomplete`, `vueua-dialogmodal` y `Teleport`. **Reorientamos** para que esta sesión sea el **escaparate de componentes UA simples** (los complejos quedan diferidos):

| Tema temario | Demo a crear | `vueua-lib` |
|---|---|---|
| Modales de confirmación | `Sesion10PopUpModal.vue` | `PopUpModal` — flujo "eliminar reserva" con `await show()` |
| Modales con formulario | `Sesion10DialogModal.vue` | `DialogModal` — editar Recurso con `v-model:visible` y slots |
| Bloqueo de pantalla | `Sesion10SpinnerModal.vue` | `SpinnerModal` — guardar tipo de recurso |
| `v-model` triestado en filtros | `Sesion10Checkbox3estados.vue` | `Checkbox3estados` — filtro "activo / inactivo / todos" |
| Teleport (Vue nativo) | `Sesion10Teleport.vue` | — | Renderizar fuera del árbol. Conectar con cómo lo usan internamente los modales. |
| Integradora CRUD | `Sesion10CrudRecursos.vue` | `PopUpModal` + `DialogModal` + `SpinnerModal` + `useToast` + `BotonLoading` | Flujo CRUD mock completo sin red real |

**Sobre `Autocomplete`**: lo mencionamos en la documentación con un ejemplo de uso (no demo abrible) y aplazamos la demo a una sesión avanzada — necesita comprender `useAxios` (S11) para tener sentido.

**Acción**:

1. Crear carpeta `sesion-10/` con los 6 ficheros.
2. Actualizar el `.md` de la sesión 10 ([`03-vue/sesiones/sesion-5-componentes-ua/index.md`](./03-vue/sesiones/sesion-5-componentes-ua/)) reemplazando los "Pendiente de publicación" por el contenido real.
3. Añadir card "Sesión 10" en `IndiceSesionesVue.vue`.
4. Registrar rutas en `router.ts`.

---

## 5. Cambios transversales

| Cambio | Dónde | Cuándo |
|---|---|---|
| Montar `<ToastContainer />` una vez | `ClientApp/src/App.vue` | Inicio de S9 (antes de la demo de `useToast`) |
| Comprobar `toastPlugin` en `main.ts` | `ClientApp/src/main.ts` | Inicio de S9 |
| Verificar versión de `@vueua/components` | `ClientApp/package.json` actualmente `^1.1.8` | Antes de empezar S8 — confirmar que expone los símbolos usados |
| Ampliar `IndiceSesionesVue.vue` | mismo fichero | Tras cada sesión nueva (S9, S10) |
| Ampliar `router.ts` | mismo fichero | Tras cada demo nueva |
| Actualizar las páginas `.md` del curso | `03-vue/sesiones/sesion-{1..5}-*/index.md` | Cuando una demo está lista, enlazar desde el `.md` con `/uareservas/sesiones-vue/...` |

---

## 6. Orden de ejecución sugerido

Trabajamos sesión a sesión, en orden del temario, porque cada una se apoya en la anterior:

1. **S7 completa** (6 demos, Vue puro). Cierra el bloque "Vue puro".
2. **S8 completa** (7 demos + opcional con `PopUpModal`). Primer contacto con `vueua-lib` vía slots/lifecycle.
3. **S9 completa** (5 demos, composables UA). Introducir `<ToastContainer />` y verificar pipeline.
4. **S10 completa** (6 demos, escaparate UA simple). Cierra el módulo Vue antes de integración.
5. **Repaso final**: revisar que cada `.md` de sesión enlaza a la demo correspondiente y que el sidebar lo refleja.

Cada paso se cierra con: demos en sandbox + rutas en `router.ts` + cards en índices + (opcional) bloques `::: tip` en el `.md` enlazando a `/uareservas/sesiones-vue/...`.

---

## 7. Lo que este plan NO incluye

- Cualquier `vueua-lib` etiquetado como complejo: `Autocomplete`, `QuillEditor`, `SelectorFicheros`, todo lo de `advanced/` y `graficas/`.
- `useAxios` y `useGestionFormularios` — sesiones 11–12 (módulo de integración), no aquí.
- Pinia — sesión 17.
- Tests Playwright del sandbox — no son objeto del curso en este punto.
- Cambios en el backend `.NET` ni en el SQL — todas las demos S7-S10 trabajan con mocks en memoria.
