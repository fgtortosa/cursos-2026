---
title: "Sesión 9: Vue 3, TypeScript y tu primer componente"
description: Fundamentos de Vue 3 con Composition API, TypeScript básico, reactividad e interpolación
outline: deep
---

# Sesión 9: Vue 3, TypeScript y tu primer componente

<!-- [[toc]] -->

::: info CONTEXTO
Esta sesión sienta las bases para el resto del módulo. Si ya conoces Vue 3, sirve como repaso rápido de sintaxis con TypeScript. Si vienes de otros frameworks, aquí encontrarás todo lo que necesitas para seguir las sesiones siguientes.

**Sesiones de Vue en este curso:**

| Sesión       | Tema                       | Qué aprenderás                                                                |
| ------------ | -------------------------- | ----------------------------------------------------------------------------- |
| **6 (esta)** | Fundamentos                | Estructura `.vue`, TypeScript básico, reactividad, interpolación              |
| **7**        | Datos e interactividad     | Interfaces, funciones, `v-if`, `v-for`, `v-model`, eventos, métodos de arrays |
| **8**        | Componentes y comunicación | Props, Emits, `defineModel`, `computed`, `watch`, slots                       |
| **9**        | Arquitectura y servicios   | Composables, servicios, Vista → Composable → Servicio                         |
| **10**       | Componentes internos UA    | `vueua-autocomplete`, `vueua-dialogmodal`, Teleport                           |

Los temas de `useAxios`, validación y Pinia se cubren en las sesiones de **Integración full-stack** (14-17).
:::

## Plan de sesión (90 min) {#plan-90}

| Bloque               | Tiempo | Contenido                                                                   |
| -------------------- | ------ | --------------------------------------------------------------------------- |
| **Teoría guiada**    | 45 min | 1.1 a 1.6 (fundamentos, TS, reactividad, interpolación y depuración básica) |
| **Práctica en aula** | 25 min | Ejercicio de tarjeta personal + revisión en directo                         |
| **Test de sesión**   | 15 min | Preguntas rápidas en formato desplegable y corrección grupal                |
| **Cierre**           | 5 min  | Dudas, errores frecuentes y preparación de la sesión 10                     |

::: tip ENFOQUE DIDÁCTICO
Con 90 minutos buscamos no solo explicar sintaxis, sino también consolidar hábitos: leer errores, comprobar tipos y validar que cada alumno pueda crear y entender un componente básico sin ayuda.
:::

## 1.1 ¿Por qué Vue 3 en la UA? {#por-que-vue}

Vue 3 es el framework seleccionado para el desarrollo de la parte cliente en el Servicio de Informática de la UA por:

| Ventaja                        | Descripción                                                                                                       |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| **Curva de aprendizaje suave** | Principal razón frente a Angular o React. Especialmente asequible para desarrolladores con HTML, CSS y JavaScript |
| **Estructura clara**           | Separación en `<script>`, `<template>` y `<style>` que mejora legibilidad y mantenimiento                         |
| **Reactividad**                | Actualización automática de la interfaz cuando cambian los datos                                                  |
| **TypeScript integrado**       | Tipado estático, autocompletado inteligente y detección temprana de errores                                       |
| **Composition API**            | Código reutilizable, organizado y escalable                                                                       |
| **Vue Devtools**               | Depuración directa en el navegador con inspección de componentes y estado                                         |

::: tip BUENA PRÁCTICA
Usamos **Composition API** (`<script setup>`) en el curso, no la Options API de Vue 2. Es más moderna, más flexible y tiene mejor soporte de TypeScript.
:::

## 1.2 Estructura de un componente Vue {#estructura-componente}

Un archivo `.vue` se divide en tres secciones:

```html
<script setup lang="ts">
  // 1. SCRIPT: Lógica del componente (TypeScript)
</script>

<template>
  <!-- 2. TEMPLATE: HTML que renderiza el componente -->
</template>

<style lang="scss" scoped>
  /* 3. STYLE: CSS específico de este componente */
</style>
```

```svgbob
+---------------------------+
| <script setup lang="ts">  |   <- LOGICA TypeScript
|   imports                 |      (lo que el componente sabe hacer)
|   ref / reactive          |
|   funciones               |
| </script>                 |
+---------------------------+
| <template>                |   <- VISTA (HTML + directivas)
|   {{ interpolacion }}     |      (lo que el componente pinta)
|   v-if / v-for / @click   |
| </template>               |
+---------------------------+
| <style scoped lang="scss">|   <- ESTILO local
|   .clase { ... }          |      (CSS encapsulado al componente)
| </style>                  |
+---------------------------+
```

<!-- diagram id="s6-anatomia-vue" caption: "Las tres secciones de un componente .vue" -->

| Sección                    | Qué contiene                          | Notas                                                           |
| -------------------------- | ------------------------------------- | --------------------------------------------------------------- |
| `<script setup lang="ts">` | Imports, variables, funciones, lógica | `setup` activa Composition API, `lang="ts"` activa TypeScript   |
| `<template>`               | HTML con directivas Vue               | Todo lo declarado en script está disponible automáticamente     |
| `<style scoped>`           | CSS/SCSS del componente               | `scoped` asegura que los estilos no afecten a otros componentes |

### Diferencia entre Vista y Componente

| Aspecto          | Vista                                 | Componente                               |
| ---------------- | ------------------------------------- | ---------------------------------------- |
| **Ubicación**    | `src/views/`                          | `src/components/`                        |
| **Propósito**    | Página completa (asociada a ruta URL) | Pieza reutilizable de la interfaz        |
| **Router**       | ✅ Tiene ruta asociada                | ❌ No tiene ruta                         |
| **Uso**          | Se carga desde el router              | Se importa en vistas u otros componentes |
| **Nomenclatura** | `PascalCase` (`Home.vue`)             | `PascalCase` (`SelectorFechas.vue`)      |

::: tip REGLA PRÁCTICA
Si el usuario puede navegar directamente a ello con una URL → es una **Vista**. Si se usa como pieza dentro de otras partes → es un **Componente**.
:::

### Orden recomendado en `<script setup>`

```html
<script setup lang="ts">
  // 1. Imports
  import { ref, computed } from "vue";
  import MiComponente from "@/components/MiComponente.vue";

  // 2. Interfaces locales
  interface IDatos {
    id: number;
    nombre: string;
  }

  // 3. Props / Emits (si es componente)
  const props = defineProps<{ titulo: string }>();

  // 4. Variables reactivas
  const contador = ref<number>(0);

  // 5. Computed
  const doble = computed(() => contador.value * 2);

  // 6. Watchers

  // 7. Lifecycle hooks

  // 8. Funciones
  function incrementar() {
    contador.value++;
  }
</script>
```

## 1.3 TypeScript: lo que necesitas saber {#typescript-basico}

TypeScript es un **superset de JavaScript** que añade tipado estático. Esto significa que puedes especificar qué tipo de dato debe tener cada variable, y el compilador te avisa si cometes un error.

### Declaración de variables y tipos principales

```typescript
// Tipo explícito
const nombre: string = "Juan";
const edad: number = 25;
const activo: boolean = true;

// Inferencia de tipos (TypeScript deduce el tipo automáticamente)
const ciudad = "Alicante"; // TypeScript sabe que es string
const contador = 0; // TypeScript sabe que es number
```

### `let`, `const` y `var`: qué usar y cuándo

En esta sesión conviene fijar una regla clara:

- **`const` por defecto**.
- **`let` solo si vas a reasignar**.
- **`var` no se usa en código actual** (comportamiento más confuso por alcance de función).

```typescript
const curso = "Vue 3"; // ✅ no se reasigna
let pagina = 1; // ✅ puede cambiar
pagina = 2;

// curso = 'React'      // ❌ error: no puedes reasignar un const
```

Diferencia importante con objetos:

```typescript
const usuario = { nombre: "Ana", edad: 25 };
usuario.edad = 26; // ✅ permitido (cambia propiedad interna)

// usuario = { nombre: 'Luis', edad: 30 }   // ❌ no permitido (reasignar referencia)
```

Comparación rápida:

| Declaración | Reasignable | Alcance       | Recomendación               |
| ----------- | ----------- | ------------- | --------------------------- |
| `const`     | ❌          | bloque (`{}`) | ✅ opción por defecto       |
| `let`       | ✅          | bloque (`{}`) | ✅ cuando debe cambiar      |
| `var`       | ✅          | función       | ❌ evitar en código moderno |

::: tip REGLA PRÁCTICA
Si dudas entre `let` y `const`, empieza por `const`. Solo cambia a `let` cuando realmente necesites reasignar.
:::

### Otras posibilidades útiles: `as const` y `readonly`

No es imprescindible dominarlas hoy, pero conviene conocerlas:

```typescript
// as const: convierte literales en valores inmutables y más específicos
const estado = "activo" as const;
// estado = 'inactivo'   // ❌ error

interface IConfig {
  readonly apiBase: string;
  timeout: number;
}

const config: IConfig = {
  apiBase: "/api",
  timeout: 5000,
};

config.timeout = 7000; // ✅ permitido
// config.apiBase = '/v2'   // ❌ error (readonly)
```

En esta sesión basta con recordar:

- `as const` fija literales.
- `readonly` protege propiedades que no deberían modificarse.

### Resumen rápido de tipos más usados

| Tipo        | Ejemplo         | Descripción                                          |
| ----------- | --------------- | ---------------------------------------------------- |
| `string`    | `"Hola"`        | Texto                                                |
| `number`    | `42`, `3.14`    | Números enteros y decimales                          |
| `boolean`   | `true`, `false` | Verdadero / Falso                                    |
| `string[]`  | `["a", "b"]`    | Array de strings                                     |
| `number[]`  | `[1, 2, 3]`     | Array de números                                     |
| `any`       | Cualquier valor | ❌ Evitar: desactiva la verificación de tipos        |
| `unknown`   | Cualquier valor | Como `any` pero más seguro (obliga a comprobar tipo) |
| `null`      | `null`          | Valor nulo                                           |
| `undefined` | `undefined`     | Valor indefinido                                     |

### Union Types: varios tipos posibles

```typescript
let resultado: string | number;

resultado = "éxito"; // ✅ válido
resultado = 200; // ✅ válido
resultado = true; // ❌ error de compilación
```

### Tipos especiales: `null`, `undefined`, `any` y `unknown`

Los cuatro existen para casos muy concretos. La regla general: **elige siempre el tipo real** (o una unión con `null`) antes de caer en `any`.

```typescript
// ── null y undefined ──────────────────────────────────────────────
// Úsalos en uniones para indicar "puede no haber valor todavía".
// Es lo habitual cuando una variable se rellena tras una llamada async.
let usuarioCargado: string | null = null; // luego: "Ana Garcia"
let idSeleccionado: number | undefined = undefined; // luego: 42

// ── any → desactiva TypeScript (EVITAR) ───────────────────────────
let valor: any = "texto";
valor = 42; // No hay error... pero pierdes la red de seguridad
valor.noExiste(); // No hay error en compilación; revienta en ejecución

// ── unknown → la versión segura de any ────────────────────────────
// Útil cuando recibes un dato del exterior y aún no sabes su forma
// (respuesta de fetch, mensaje de postMessage, contenido de localStorage).
let dato: unknown = JSON.parse(localStorage.getItem("config") ?? "{}");
// dato.toUpperCase()  // ❌ Error: TS te obliga a comprobar primero
if (typeof dato === "string") {
  dato.toUpperCase(); // ✅ Dentro del if, TS sabe que es string
}
```

::: tip BUENA PRÁCTICA — qué tipo real poner en el ejemplo de arriba
| En el ejemplo... | El tipo "de juguete" | El tipo real que pondrías en código de producción |
| ---------------- | --------------------- | ------------------------------------------------- |
| `valor: any` | `any` (no escribir) | `string \| number` si admite los dos, o crear una _union type_ concreta |
| `dato: unknown` | `unknown` (genérico) | Una **interface** que describa la forma esperada (`interface Config { ... }`) y un _type guard_ que la valide |
| `usuarioCargado` | `string \| null` | `Usuario \| null` con `interface Usuario { id: number; nombre: string }` |
| `idSeleccionado` | `number \| undefined` | Mejor `number \| null` para distinguir "aún no elegido" (lo idiomático en formularios UA) |

La idea: `any`/`unknown` son **comodines de paso**. En cuanto sepas la forma, define una `interface` o un `type` y úsalo.
:::

::: danger ZONA PELIGROSA
Nunca uses `any` salvo en casos muy justificados (librerías sin tipos, migración de JS). Pierdes toda la protección que ofrece TypeScript y los `.d.ts` que vienen con Vue, Axios y los componentes UA.
:::

## 1.4 Reactividad: ref y reactive {#reactividad}

La reactividad es la capacidad de Vue de **actualizar automáticamente** el DOM cuando cambian los datos. La mecánica se entiende mejor leyendo el código que con un diagrama:

```typescript
// 1) Declaras una variable reactiva con ref(...).
const contador = ref<number>(0);

// 2) La usas en el template: {{ contador }}.
//    Vue "anota" que ese nodo del DOM depende de 'contador'.

// 3) Cuando cambias el valor con contador.value++,
//    Vue dispara automáticamente un re-renderizado
//    pero SOLO de los nodos que dependen de esa variable.
```

Lo importante: **tú no escribes ningún `document.getElementById` ni ningún `innerHTML = ...`**. Vue lo hace por ti porque sabe quién depende de quién.

### ¿Por qué usamos `const` con variables reactivas?

Al principio resulta raro ver esto:

```typescript
const contador = ref(0);
```

Usamos `const` porque lo que protegemos es la **referencia reactiva**, no su contenido interno:

```typescript
const contador = ref(0);
contador.value = 10; // ✅ correcto
contador.value++; // ✅ correcto

// contador = ref(20)   // ❌ error: estarías reasignando la referencia
```

Con `reactive` ocurre lo mismo:

```typescript
const usuario = reactive({ nombre: "Ana" });
usuario.nombre = "Juan"; // ✅ correcto

// usuario = reactive({ nombre: 'María' })  // ❌ error
```

::: tip IDEA CLAVE
Con `const` no decimos "el dato no cambia". Decimos "esta referencia reactiva no se reemplaza".
:::

### `ref` — Referencia reactiva

`ref` crea una referencia reactiva a cualquier valor. Este es el ejemplo de la demo `Sesion6HolaVue.vue` del sandbox: dos botones que cambian un mismo `ref<string>` y el saludo se actualiza solo. Además, una `computed` deriva la URL de la foto de la mascota que toca, y `v-if` la muestra solo cuando hay foto.

```html
<script setup lang="ts">
  import { ref, computed } from "vue";

  // 'nombre' es una "caja" que Vue vigila. Cuando cambia el valor
  // interno, el template se vuelve a pintar solo.
  const nombre = ref<string>("Mundo");

  function saludarALola() {
    nombre.value = "Lola, mi perro";
  } // .value en el script
  function saludarATiger() {
    nombre.value = "Tiger, mi super gato";
  }

  // 'computed' recalcula automaticamente la URL cada vez que cambia 'nombre'.
  // Las fotos viven en ClientApp/public/ (lola.jpg, tiger.jpg). Vite las sirve
  // bajo import.meta.env.BASE_URL → en producción "/uareservas/lola.jpg".
  const fotoMascota = computed<string | null>(() => {
    const base = import.meta.env.BASE_URL;
    if (nombre.value === "Lola, mi perro") return `${base}lola.jpg`;
    if (nombre.value === "Tiger, mi super gato") return `${base}tiger.jpg`;
    return null;
  });
</script>

<template>
  <!-- En template: sin .value (Vue lo desempaqueta solo) -->
  <div class="display-4 my-3">Hola, {{ nombre }} 👋</div>

  <!-- v-if monta/desmonta el bloque segun la computed.
       Sin foto cuando 'nombre' no coincide con ninguna mascota. -->
  <img
    v-if="fotoMascota"
    :src="fotoMascota"
    :alt="nombre"
    style="max-height: 240px"
  />

  <!-- v-model: enlace bidireccional con el input -->
  <input v-model="nombre" type="text" class="form-control" />

  <button class="btn btn-primary" @click="saludarALola">
    Saluda a Lola, mi perro
  </button>
  <button class="btn btn-primary" @click="saludarATiger">
    Saluda a Tiger, mi super gato
  </button>
</template>
```

> Fichero real: `ClientApp/src/views/sesiones-vue/sesion-6/Sesion6HolaVue.vue`. Las fotos están en `ClientApp/public/lola.jpg` y `ClientApp/public/tiger.jpg`.

::: tip BUENA PRÁCTICA — assets desde `public/` y `import.meta.env.BASE_URL`
Todo lo que metes en `ClientApp/public/` se sirve **tal cual** bajo la URL base de la app (`/uareservas/` en producción, `/` en dev). Si escribes `<img src="/lola.jpg">`, en producción falla porque la URL real es `/uareservas/lola.jpg`. Por eso usamos `import.meta.env.BASE_URL` como prefijo: Vite lo resuelve correctamente en ambos entornos sin tocar el código.
:::

::: warning IMPORTANTE

- En el `<script>`: usa `contador.value`
- En el `<template>`: usa `contador` (sin `.value`)

Si olvidas `.value` en el script, el código no funciona. Si pones `.value` en el template, sobra.
:::

### `reactive` — Objeto reactivo

Para **objetos** existe `reactive`. La demo `Sesion6RefVsReactive.vue` coloca un `ref` y un `reactive` lado a lado para que se vea la diferencia:

```html
<script setup lang="ts">
  import { ref, reactive } from "vue";

  // ---- Izquierda: ref<number> ----
  const contadorA = ref<number>(0);
  function incrementarA() {
    contadorA.value++;
  }

  // ---- Derecha: reactive({ ... }) ----
  const estadoB = reactive({
    count: 0,
    ultimaAccion: "ninguna",
  });
  function incrementarB() {
    estadoB.count++; // ✓ modifica propiedad → reactivo
    estadoB.ultimaAccion = "increment";
    // estadoB = { count: 0, ... }        // ✗ NO reasignar: rompe la reactividad
  }
</script>

<template>
  <div>Contador A (ref): {{ contadorA }}</div>
  <div>
    Contador B (reactive): {{ estadoB.count }} — última acción: {{
    estadoB.ultimaAccion }}
  </div>
</template>
```

> Fichero real: `ClientApp/src/views/sesiones-vue/sesion-6/Sesion6RefVsReactive.vue`.

### `ref` vs `reactive` — Cuándo usar cada uno

| Aspecto                  | `ref`                                   | `reactive`              |
| ------------------------ | --------------------------------------- | ----------------------- |
| **Uso**                  | Valores simples, arrays, cualquier cosa | Objetos complejos       |
| **Sintaxis en script**   | `.value`                                | Acceso directo          |
| **Sintaxis en template** | Sin `.value`                            | Sin `.value`            |
| **Tipado TypeScript**    | `ref<Tipo>(valor)`                      | `reactive<Tipo>({...})` |

::: tip BUENA PRÁCTICA
Prefiere **`ref`** en la mayoría de casos. Es más clara, funciona con todo y tiene mejor soporte TypeScript. Usa `reactive` solo para objetos donde te resulte más cómodo.
:::

## 1.5 Interpolación: mostrar datos en el template {#interpolacion}

Usa llaves dobles <code v-pre>{{ }}</code> para mostrar valores reactivos en el template. La demo `Sesion6Interpolacion.vue` agrupa los siete usos típicos partiendo de un objeto `persona`:

```html
<script setup lang="ts">
  import { ref } from "vue";

  const persona = ref({
    nombre: "Ana Garcia",
    edad: 27,
    email: "ana@ua.es",
    notas: [7.5, 8.2, 9.0, 6.5],
    rol: "PDI" as "PDI" | "PTGAS" | "Alumno",
  });

  function aniosDesdeNacimiento(edad: number): number {
    return new Date().getFullYear() - edad;
  }
</script>

<template>
  <!-- 1. Propiedades simples -->
  <p>Nombre: <strong>{{ persona.nombre }}</strong></p>

  <!-- 2. Aritmética -->
  <p>Edad en meses: {{ persona.edad * 12 }}</p>

  <!-- 3. Concatenación y template literals -->
  <p>{{ `${persona.nombre} (${persona.rol})` }}</p>

  <!-- 4. Ternario inline -->
  <p>¿Mayor de edad? {{ persona.edad >= 18 ? 'Si' : 'No' }}</p>

  <!-- 5. Llamadas a funciones del script -->
  <p>Año aproximado: {{ aniosDesdeNacimiento(persona.edad) }}</p>

  <!-- 6. Métodos de arrays/strings -->
  <p>
    Media: {{ (persona.notas.reduce((a, b) => a + b, 0) /
    persona.notas.length).toFixed(2) }}
  </p>

  <!-- 7. Atributos: ':' (alias de v-bind), no llaves -->
  <a :href="`mailto:${persona.email}`">Escribir a {{ persona.nombre }}</a>
</template>
```

> Fichero real: `ClientApp/src/views/sesiones-vue/sesion-6/Sesion6Interpolacion.vue`.

::: warning IMPORTANTE
La interpolación solo acepta **expresiones** (que devuelven un valor). No acepta sentencias como `if`, `for` o asignaciones (<code v-pre>{{ x = 5 }}</code> está prohibido). Para lógica condicional en templates usamos directivas (`v-if`, `v-for`), que veremos en la sesión 7.
:::

## 1.6 Depuración básica {#debug-basico}

Antes de avanzar a directivas y comunicación entre componentes, conviene establecer una rutina corta de depuración. La idea es simple: cuando algo falla, no adivinar; comprobar.

::: info PUNTO DE PARTIDA PARA DESARROLLADORES DE VISUAL STUDIO
Si vienes de depurar aplicaciones .NET con **F5 en Visual Studio**, el rol del depurador aquí lo tiene el **navegador** — no el IDE. La aplicación Vue corre en Chrome o Edge, así que abre `F12` → pestaña **Sources** para poner breakpoints y usa la **Console** para ejecutar expresiones.

Lo bueno: los atajos principales son los **mismos** (`F10`, `F11`, `Shift+F11`). El panel **Scope** sustituye a _Autos/Locals_, y la **Console** mientras el código está pausado actúa como la _Ventana inmediata_. Todo esto se desarrolla en el apartado [1.6.3](#debugger).
:::

### 1.6.1 Preparación mínima (navegador + extensión)

**DevTools del navegador**

- Abrir con `F12` o `Ctrl + Shift + I`
- Para esta sesión usaremos sobre todo: **Console** y **Elements**

**Vue Devtools (extensión del navegador)**

1. Instalar la extensión **Vue.js devtools** desde la tienda de extensiones del navegador.
2. Recargar la aplicación Vue después de instalarla.
3. Abrir DevTools y localizar la pestaña **Vue**.
4. Seleccionar el componente actual y revisar sus `ref` en tiempo real.

Si no aparece la pestaña Vue:

- Verifica que la app está en modo desarrollo.
- Recarga la página con DevTools abiertas.
- Comprueba que la extensión está habilitada.

### 1.6.2 Ejemplo rápido con `console.log` y otras variantes

```html
<script setup lang="ts">
  import { ref } from "vue";

  const contador = ref<number>(0);

  function incrementar() {
    console.log("[click] incrementar");
    console.log("Antes:", contador.value);
    contador.value++;
    console.log("Despues:", contador.value);
  }
</script>

<template>
  <button @click="incrementar">+1</button>
  <p>Contador: {{ contador }}</p>
</template>
```

Qué debes comprobar en este ejemplo:

1. Cada clic genera logs en consola.
2. El valor "Antes" y "Despues" cambia correctamente.
3. El texto en pantalla se actualiza sin recargar.

Si falla alguno de los tres puntos, ya tienes una pista de dónde está el problema (evento, estado o renderizado).

#### Más variantes de `console` que te ahorran tiempo

`console.log` no es la única. DevTools agrupa, colorea y formatea distinto según la variante que uses:

| Variante                                           | Cuándo usarla                                                                                                                 |
| -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `console.log(...)`                                 | Información general. Sale en negro.                                                                                           |
| `console.info(...)`                                | Información destacada (icono azul ℹ). Útil para hitos del flujo.                                                              |
| `console.warn(...)`                                | Aviso amarillo. Algo no está bien pero no rompe — perfecto para "estás usando una API obsoleta".                              |
| `console.error(...)`                               | Rojo + stack trace. Para errores que has detectado tú (en un `catch`, por ejemplo).                                           |
| `console.table(arrayDeObjetos)`                    | Pinta un array de objetos como tabla con columnas ordenables. Ideal para arrays de DTOs.                                      |
| `console.dir(obj)`                                 | Imprime el objeto como árbol explorable (mejor que `log` para objetos profundos / proxies Vue).                               |
| `console.group('etiqueta')` + `console.groupEnd()` | Agrupa logs entre las dos llamadas → árbol plegable en la consola.                                                            |
| `console.time('t')` + `console.timeEnd('t')`       | Mide milisegundos entre las dos llamadas. Útil para detectar bucles lentos.                                                   |
| `console.count('clave')`                           | Cuenta cuántas veces se ha invocado. Útil para detectar renders duplicados o handlers que se disparan más veces de la cuenta. |
| `console.assert(cond, 'msg')`                      | Solo imprime si `cond` es falsa. Más limpio que un `if (!cond) console.error(...)`.                                           |
| `console.trace('etiqueta')`                        | Imprime la pila completa de llamadas hasta este punto. Brutal para "¿quién está llamando a esta función?".                    |

Ejemplo aplicado a la demo:

```typescript
function incrementar() {
  console.group("[click] incrementar");
  console.count("renders del botón"); // 1, 2, 3...
  console.table([{ estado: "antes", valor: contador.value }]);
  console.time("tiempoIncremento");
  contador.value++;
  console.timeEnd("tiempoIncremento"); // "tiempoIncremento: 0.12 ms"
  console.groupEnd();
}
```

::: warning TRUCO — qué ves en consola cuando logueas un `ref` o `reactive`
Si haces `console.log(contador)` sin `.value` vers `RefImpl { value: 0, ... }` en lugar del número. Si logueas un `reactive`, vers `Proxy { ... }`. Esto sorprende a quien viene de depurar variables C# donde siempre ves el valor directamente.

Para obtener el valor limpio:

```typescript
// ref
console.log(contador.value); // ✅ 0  (el número puro)
console.log(contador); // ⚠️ RefImpl { value: 0, ... }

// reactive
console.log(JSON.stringify(estado)); // ✅ '{"count":0,"ultimaAccion":"ninguna"}'
console.dir(estado); // ✅ árbol explorable (el más cómodo para objetos profundos)
```

**Vue Devtools** muestra los valores directamente, sin el envoltorio Proxy — úsala siempre que quieras ver el estado reactivo de un vistazo.
:::

### 1.6.3 Parar el código con el `debugger` y los breakpoints {#debugger}

El `console.log` te dice **qué** valor hay; el **debugger** te deja inspeccionar **todo** el estado en ese instante (variables locales, refs, scope, pila de llamadas) y avanzar paso a paso.

#### Equivalencias con Visual Studio

Para quienes estéis acostumbrados al depurador de VS, el contexto cambia (navegador en lugar del IDE) pero la experiencia es muy parecida:

| Visual Studio                  | Browser DevTools                       | Notas                                           |
| ------------------------------ | -------------------------------------- | ----------------------------------------------- |
| F9 — poner / quitar breakpoint | Clic en número de línea en **Sources** | Aparece un punto azul en el margen              |
| F5 — Continuar                 | F8 — **Resume** (o botón ▶)            |                                                 |
| F10 — Step over                | F10 — **Step over**                    | Mismo atajo                                     |
| F11 — Step into                | F11 — **Step into**                    | Mismo atajo                                     |
| Shift+F11 — Step out           | Shift+F11 — **Step out**               | Mismo atajo                                     |
| Ventana _Locals / Autos_       | Panel **Scope**                        | Variables locales del frame actual              |
| Ventana _Watch_                | Panel **Watch**                        | Añade expresiones tipo `contador.value`         |
| _Ventana inmediata_            | **Console** mientras está pausado      | Ejecuta cualquier expresión con el scope actual |
| Pila de llamadas               | Panel **Call Stack**                   | Clic en un frame para inspeccionar su scope     |
| `Debugger.Break()` en C#       | Sentencia `debugger` en TS             | Solo pausa si DevTools está abierto             |
| Hover sobre variable           | Hover sobre variable en Sources        | Muestra un tooltip con el valor actual          |

::: tip VS Code también puede depurar TypeScript
Para quienes prefieran no salir del IDE: VS Code incluye un **JavaScript Debugger** integrado que puede conectarse a Chrome/Edge con un `launch.json` de tipo `"type": "chrome"`. En esta sesión usamos las DevTools del navegador porque son inmediatas y no requieren configuración, pero la alternativa existe.
:::

#### Opción A — La sentencia `debugger`

Inserta la palabra `debugger` en tu código. Cuando el navegador llega a esa línea **con DevTools abierto**, la ejecución se pausa automáticamente:

```typescript
function incrementar() {
  console.log("Antes:", contador.value);
  debugger; // ← Vue para aquí; puedes inspeccionar contador.value, scope local...
  contador.value++;
}
```

::: warning Acuérdate de quitar los `debugger`
Si te queda un `debugger` en una rama del código y un compañero abre DevTools, la app le va a parar de repente. Quítalos antes de subir a `main` (los linters de la UA los detectan como `no-debugger`).
:::

#### Opción B — Breakpoints desde DevTools (sin tocar el código)

1. Abre DevTools → pestaña **Sources** (Chrome/Edge) o **Debugger** (Firefox).
2. En el árbol de archivos navega hasta tu `.vue` (verás el bloque `<script setup>`).
3. Pulsa el **número de línea** donde quieras parar → aparece un punto azul.
4. Interactúa con la app: cuando se ejecute esa línea, la pestaña se pondrá en pausa.

Botones útiles una vez parado:

| Botón                      | Atajo     | Qué hace                                                       |
| -------------------------- | --------- | -------------------------------------------------------------- |
| **Resume** (▶)             | F8        | Continúa hasta el siguiente breakpoint.                        |
| **Step over** (↷)          | F10       | Ejecuta la línea actual sin entrar en las funciones que llame. |
| **Step into** (↓)          | F11       | Entra dentro de la función llamada en esta línea.              |
| **Step out** (↑)           | Shift+F11 | Sale de la función actual y vuelve al llamador.                |
| **Deactivate breakpoints** | Ctrl+F8   | Desactiva todos sin perderlos.                                 |

Mientras estás parado puedes:

- Pasar el ratón sobre cualquier variable → ves su valor actual.
- Usar la pestaña **Scope** → variables locales, `this`, closures.
- En **Watch** → añadir expresiones tipo `contador.value`, `nombre.value === 'Lola, mi perro'` para que se evalúen en cada paso.
- En la **Console** mientras está pausada → ejecutas cualquier expresión con el scope actual (`contador.value = 100`, por ejemplo).

#### Breakpoints condicionales

Click derecho sobre el número de línea → **Add conditional breakpoint** → escribe `contador.value > 5`. Solo para cuando se cumpla. Imprescindible cuando un fallo solo ocurre tras N clics.

### 1.6.4 TypeScript en el navegador: las líneas que ves son las que escribiste {#sourcemaps}

Pregunta natural en cuanto abres DevTools:

> "Pero si yo escribí TypeScript… ¿por qué la consola pone la línea exacta de mi `.vue`? El navegador no entiende TS, ¿no?"

Correcto. El navegador **solo ejecuta JavaScript**. Vite (el bundler que usa el proyecto) compila tu `.vue` + `.ts` a JavaScript antes de servirlo. Pero junto al JS genera un fichero `.map` (un **source map**) que asocia cada línea del JS compilado con la línea original de tu fichero. DevTools usa ese mapa para mostrarte **tu código fuente** en lugar del JavaScript compilado.

Esto importa para entender lo siguiente:

| Lo que ves en DevTools                            | Lo que ocurre por debajo                                                                        |
| ------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Tu `Sesion6HolaVue.vue` línea 24 en **Sources**   | Es una "vista" del source map. El fichero que ejecuta el navegador es un `.js` compilado.       |
| El breakpoint funciona en una línea TypeScript    | Vite añade source maps en `dev` por defecto → el breakpoint se traduce a la línea JS correcta.  |
| A veces el breakpoint salta a una línea "cercana" | El compilador puede haber fusionado líneas. Si te pasa, pon `debugger` en la línea exacta.      |
| Una variable se llama distinto en _Scope_         | TypeScript usa anotaciones de tipo (`: string`) que el JS no tiene; pero la lógica es la misma. |

::: tip BUENA PRÁCTICA — qué explicar antes de un debugger en TypeScript
Cuando enseñes el debugger a otro programador junior, deja claro tres cosas:

1. **El navegador ejecuta JavaScript**, no TypeScript.
2. **Los source maps** son los que permiten parar en tu `.ts`/`.vue` "como si fuera el código real".
3. Si DevTools de pronto te muestra **JavaScript ofuscado** en vez de tu fuente, es que falta o se ha perdido el source map (compilación en producción sin maps, recurso cacheado antiguo, etc.).
   :::

### 1.6.5 Qué mirar en DevTools (resumen de pestañas)

| Pestaña            | Qué revisar                                       | Para qué sirve                                                 |
| ------------------ | ------------------------------------------------- | -------------------------------------------------------------- |
| **Console**        | Errores, warnings y `console.*`                   | Detectar fallos de ejecución y trazar el flujo.                |
| **Elements**       | Si el DOM refleja los cambios esperados           | Confirmar que la UI se está renderizando.                      |
| **Sources**        | Tu código `.vue`/`.ts`, breakpoints, scope, watch | Pausar el código y leer el estado real en ese instante.        |
| **Network**        | Llamadas HTTP (`/api/...`), status, payload       | Ver qué pide la app y qué responde el backend. Imprescindible. |
| **Vue (Devtools)** | Árbol de componentes, props, `ref`, eventos       | Verificar valores reactivos y eventos sin tocar el código.     |

::: tip Truco rápido — `$0` en la consola
Selecciona un elemento en la pestaña **Elements**; en la **Console**, `$0` te lo devuelve como variable. Combinado con `console.dir($0)` ves todas sus propiedades. `$_` es el resultado de la última expresión evaluada.
:::

### 1.6.6 Checklist mínimo de depuración

1. Reproducir el fallo con un caso simple.
2. Revisar la **Console** tras cada cambio importante.
3. Comprobar que no hay errores de TypeScript en el editor.
4. Verificar en **Vue Devtools** que las variables reactivas cambian cuando esperas.
5. Si el log no basta, poner un `debugger` (o un breakpoint) y leer el scope.
6. Confirmar que la UI refleja el estado sin recargar manualmente.

### 1.6.7 Qué revisar cuando algo "no aparece"

| Síntoma                        | Comprobación rápida                                                                               |
| ------------------------------ | ------------------------------------------------------------------------------------------------- |
| El valor no se actualiza       | ¿La variable es reactiva (`ref` o `reactive`)?                                                    |
| El valor no cambia en script   | ¿Estás usando `.value` en `ref` dentro de `<script setup>`?                                       |
| Error de tipo en editor        | ¿Coincide el tipo declarado con el valor asignado?                                                |
| En template sale vacío         | ¿La variable existe en `<script setup>` y tiene valor inicial?                                    |
| El botón no hace nada          | ¿El `@click` apunta a una función existente? ¿Hay un `console.log` que confirme que entra?        |
| Vue Devtools no muestra estado | ¿Extensión instalada, habilitada y app recargada?                                                 |
| El breakpoint no se dispara    | ¿DevTools está abierto antes de hacer la acción? ¿La pestaña Sources tiene puntos azules activos? |
| DevTools muestra JS ofuscado   | Falta el source map. Recarga sin caché (`Ctrl+Shift+R`) o vuelve a `dotnet watch`.                |

::: tip BUENA PRÁCTICA — orden de búsqueda
En esta sesión no necesitas una depuración avanzada. Sigue siempre el mismo orden: **Console → Vue Devtools → breakpoint en Sources**. El 80 % de los fallos se diagnostican antes de llegar al breakpoint.
:::

## 1.7 Pruébalo en el proyecto {#sandbox}

En `uaReservas/ClientApp/src/views/sesiones-vue/sesion-6/` viven cinco demos navegables, una por concepto. Arranca la app y entra en `/uareservas/sesiones-vue/sesion-6`:

| Demo                          | Concepto que ilustra                                                             | Fichero                                |
| ----------------------------- | -------------------------------------------------------------------------------- | -------------------------------------- |
| `Sesion6HolaVue.vue`          | Estructura `.vue` mínima, `ref<string>`, `v-model`                               | `sesion-6/Sesion6HolaVue.vue`          |
| `Sesion6TypeScriptBasico.vue` | Primitivos, arrays, `const`/`let`, union types, `any` vs `unknown`               | `sesion-6/Sesion6TypeScriptBasico.vue` |
| `Sesion6RefVsReactive.vue`    | Dos contadores lado a lado: `ref<number>` vs `reactive({...})`                   | `sesion-6/Sesion6RefVsReactive.vue`    |
| `Sesion6Interpolacion.vue`    | Los siete usos típicos de <code v-pre>{{ ... }}</code> sobre un objeto `persona` | `sesion-6/Sesion6Interpolacion.vue`    |
| `Sesion6DemoTipoRecurso.vue`  | Demo integradora con un `TipoRecursoLectura[]` mock y navegación                 | `sesion-6/Sesion6DemoTipoRecurso.vue`  |

::: tip CÓMO TRABAJAR LAS DEMOS
Abre cada fichero en VS Code, lee el `<script setup>` y luego el `<template>`. Modifica un valor, guarda y observa cómo Vue redibuja **solo** lo que ha cambiado. La integradora `Sesion6DemoTipoRecurso.vue` ya usa el mismo DTO (`TipoRecursoLectura`) que devolverá la API real en la sesión 9; cambiar el mock por una llamada axios no toca el template.
:::

## 1.8 Lo que viene en las próximas sesiones {#preview}

### Sesión 10: Directivas, eventos y datos

Aprenderemos a definir contratos de datos con **interfaces**, a escribir **funciones tipadas** y a construir interfaces interactivas con `v-if`, `v-for`, `v-bind`, `v-model` y eventos. También veremos los métodos de arrays (`.map()`, `.filter()`, `.find()`, `.reduce()`) que usaremos constantemente.

### Sesión 11: Componentes, comunicación y estado derivado

Crearemos componentes reutilizables y aprenderemos a pasar datos entre ellos con Props, Emits y `defineModel`. Implementaremos `computed`, `watch` y `onMounted` para construir componentes más completos.

### Sesión 12: Arquitectura profesional, APIs y flujo de trabajo

Estructuraremos nuestra aplicación con el patrón Vista → Composable → Servicio. Consumiremos APIs REST con `useAxios` y validaremos formularios con `useGestionFormularios`.

### Sesión 13: Otros componentes UA

Veremos los componentes de la librería `vueua-lib` (modales, toasts, `BotonLoading`, checkbox triestado, Teleport) que estandarizan el aspecto y comportamiento de las apps internas de la UA.

---

## Ejercicio Sesión 9 {#ejercicio}

::: info ENUNCIADO
Acabas de incorporarte a un proyecto Vue y tu primera tarea es crear una tarjeta de presentación de un miembro del equipo. El objetivo no es el diseño visual, sino demostrar que sabes declarar estado reactivo con `ref` y pintarlo correctamente en el template con interpolación y expresiones simples.

**Resultado esperado:** un único componente funcional (`TarjetaPresentacion.vue`) que muestre datos personales y cálculos básicos sin usar aún interfaces ni lógica compleja.
:::

**Objetivo:** Crear un componente Vue que muestre una tarjeta de presentación personal usando `ref`, interpolación y template literals.

Crea un componente `TarjetaPresentacion.vue` con:

1. Variables reactivas separadas con `ref` para: `nombre`, `edad`, `ciudad`, `profesion`, `hobbies` y `activo`
2. En el template, muestra:
   - Un título `<h2>` con el nombre
   - Un párrafo con template literal: `"Tengo X años"`
   - Un párrafo: `"Vivo en [ciudad] y soy [profesion]"`
   - Los hobbies en una lista `<ul>` (manual, sin `v-for` por ahora)
   - Estado con operador ternario: "Activo" / "Inactivo"
   - Año aproximado de nacimiento: <code v-pre>{{ 2025 - edad }}</code>
   - Un mensaje con ternario: <code v-pre>{{ edad >= 50 ? '¡Veterano!' : '¡Joven aún!' }}</code>

::: tip PISTA DIDÁCTICA
En esta sesión todavía **no** usamos interfaces. Primero asentamos `ref`, `.value` e interpolación. Los contratos de datos llegarán en la sesión 10.
:::

::: details Solución

```html
<script setup lang="ts">
  import { ref } from "vue";

  const nombre = ref<string>("Juan García López");
  const edad = ref<number>(28);
  const ciudad = ref<string>("Alicante");
  const profesion = ref<string>("Desarrollador Frontend");
  const hobbies = ref<string[]>(["Programación", "Fotografía", "Senderismo"]);
  const activo = ref<boolean>(true);
</script>

<template>
  <div class="card p-4" style="max-width: 400px">
    <h2>{{ nombre }}</h2>
    <p>{{ `Tengo ${edad} años` }}</p>
    <p>Vivo en {{ ciudad }} y soy {{ profesion }}</p>

    <h4>Mis hobbies:</h4>
    <ul>
      <li>{{ hobbies[0] }}</li>
      <li>{{ hobbies[1] }}</li>
      <li>{{ hobbies[2] }}</li>
    </ul>

    <p>Estado: {{ activo ? 'Activo ✅' : 'Inactivo ❌' }}</p>
    <p>Nací aproximadamente en {{ 2025 - edad }}</p>
    <p>{{ edad >= 50 ? '¡Veterano!' : '¡Joven aún!' }}</p>
  </div>
</template>
```

:::

## Test Sesión 9 {#test}

### Preguntas (desplegables)

::: details 1. ¿Qué bloque concentra la lógica principal en un componente Vue con Composition API?

- a) template
- b) style scoped
- c) script setup
- d) router-view
  :::

::: details 2. ¿Qué bloque se encarga del marcado que se renderiza en pantalla?

- a) template
- b) script setup
- c) composable
- d) interface
  :::

::: details 3. En script, ¿cómo accedes al valor interno de un ref llamado contador?

- a) contador
- b) contador.value
- c) value(contador)
- d) contador.current
  :::

::: details 4. En el template, ¿cómo se usa normalmente un ref?

- a) Siempre con .value
- b) Sin .value
- c) Solo con .value si es number
- d) No se puede usar en template
  :::

::: details 5. ¿Qué describe mejor la reactividad en Vue?

- a) El DOM se actualiza manualmente con JavaScript puro
- b) La interfaz responde cuando cambia el estado reactivo
- c) El CSS se recompila al cambiar una variable
- d) Las props se convierten en rutas
  :::

::: details 6. ¿Por qué const contador = ref(0) sigue siendo correcto si el contador cambia?

- a) Porque const hace inmutable tambien contador.value
- b) Porque cambia el valor interno, no la referencia
- c) Porque Vue ignora const
- d) Porque ref solo funciona con const por sintaxis
  :::

::: details 7. ¿Cuál es la opción más segura entre any y unknown?

- a) any
- b) unknown
- c) Son equivalentes
- d) Ninguna de las dos se puede usar
  :::

::: details 8. ¿Qué es un union type en TypeScript?

- a) Un tipo exclusivo de Vue
- b) Un tipo que admite varios tipos válidos
- c) Un tipo reservado para arrays
- d) Una versión corta de interface
  :::

::: details 9. ¿Qué significa que TypeScript infiera un tipo?

- a) Que desactiva el tipado para esa variable
- b) Que deduce el tipo a partir del valor inicial
- c) Que obliga a importar una interface
- d) Que convierte automáticamente todo en string
  :::

::: details 10. En TypeScript moderno, ¿qué regla práctica es más recomendable?

- a) Usar var para evitar errores de bloque
- b) Usar let siempre, incluso si no reasignas
- c) Usar const por defecto y let solo si reasignas
- d) Evitar const cuando trabajas con Vue
  :::

::: details 11. ¿Qué efecto tiene style scoped en un componente?

- a) Aplica estilos a toda la aplicación
- b) Limita los estilos al componente actual
- c) Desactiva CSS en Vue
- d) Obliga a usar Bootstrap
  :::

::: details 12. ¿Qué opción encaja mejor con ref al empezar?

- a) Valores simples como string, number o boolean
- b) Solo arrays grandes
- c) Solo props del hijo
- d) Exclusivamente llamadas HTTP
  :::

::: details 13. ¿Cuándo puede resultar más cómodo reactive?

- a) Cuando trabajas con un objeto con varias propiedades
- b) Cuando solo tienes un número
- c) Cuando quieres evitar toda reactividad
- d) Cuando defines estilos CSS
  :::

::: details 14. ¿Qué permite la interpolación de dobles llaves en el template?

- a) Sentencias for completas
- b) Expresiones que devuelven un valor
- c) Declarar interfaces
- d) Ejecutar varias líneas de lógica compleja
  :::

::: details 15. ¿Qué debería evitarse dentro de una interpolación?

- a) Mostrar un dato simple
- b) Concatenar texto corto
- c) Meter lógica de negocio compleja
- d) Usar un ternario sencillo
  :::

::: details 16. ¿Qué ventaja principal aporta TypeScript en un proyecto de equipo?

- a) Elimina por completo la necesidad de probar
- b) Detecta errores antes y mejora el autocompletado
- c) Hace que Vue no necesite reactividad
- d) Sustituye las interfaces visuales
  :::

### Respuestas (Autoevaluación)

::: details Ver respuestas

1. c) script setup.
2. a) template.
3. b) contador.value.
4. b) Sin .value.
5. b) La interfaz responde cuando cambia el estado reactivo.
6. b) Cambia el valor interno, no la referencia.
7. b) unknown.
8. b) Un tipo que admite varios tipos válidos.
9. b) TypeScript deduce el tipo desde el valor inicial.
10. c) Usar const por defecto y let solo si reasignas.
11. b) Limita los estilos al componente actual.
12. a) Valores simples como string, number o boolean.
13. a) Cuando trabajas con un objeto con varias propiedades.
14. b) Permite expresiones que devuelven valor.
15. c) Debe evitarse meter lógica de negocio compleja.
16. b) Detecta errores antes y mejora el autocompletado.
    :::

---

<!-- NAV:START -->

| Anterior                                                                                           | Inicio                        | Siguiente                                                                                          |
| -------------------------------------------------------------------------------------------------- | ----------------------------- | -------------------------------------------------------------------------------------------------- |
| [← Sesión 8: Servicios y acceso a Oracle](../../../02-dotnet/sesiones/sesion-08-servicios-oracle/) | [Índice del curso](../../../) | [Sesión 10: Directivas, eventos y datos →](../../../03-vue/sesiones/sesion-10-directivas-eventos/) |

<!-- NAV:END -->
