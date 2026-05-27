---
url: /curso-normalizacion/03-vue/sesiones/sesion-10-directivas-eventos.md
description: >-
  Interfaces TypeScript, funciones tipadas, directivas de Vue, eventos del DOM y
  métodos de arrays para trabajar con datos
---

# Sesión 10: Directivas, eventos y datos

::: info CONTEXTO
En la sesión anterior vimos la estructura de un componente, TypeScript básico, reactividad e interpolación. Ahora damos el paso hacia la **interactividad real**: primero tipamos mejor nuestros datos con **interfaces** y **funciones**, y después construimos interfaces dinámicas con directivas, eventos y transformación de datos.

**Al terminar esta sesión sabrás:**

* Definir contratos de datos con interfaces y escribir funciones tipadas en componentes Vue
* Renderizar listas, mostrar/ocultar elementos y vincular atributos
* Manejar eventos del DOM con modificadores
* Transformar arrays con `.map()`, `.filter()`, `.find()` y `.reduce()`
* Trabajar con objetos con spread, destructuring y acceso seguro a propiedades
  :::

## Plan de sesión (90 min) {#plan-90}

| Bloque | Tiempo | Contenido |
|--------|--------|-----------|
| **Teoría guiada** | 45 min | 2.1 a 2.10 (interfaces, directivas, eventos, arrays y objetos) |
| **Práctica en aula** | 25 min | Lista de tareas tipada con filtros y eventos |
| **Test de sesión** | 15 min | Preguntas de comprensión y corrección inmediata |
| **Cierre** | 5 min | Dudas frecuentes y transición a componentes/comunicación |

::: tip OBJETIVO PEDAGÓGICO
La prioridad en esta sesión es que el alumno no solo "sepa usar" una directiva, sino que entienda cuándo elegir cada una y cómo evitar errores típicos de estado y renderizado.
:::

## 2.1 Interfaces y contratos de datos {#interfaces}

Antes de renderizar listas o construir formularios, necesitamos **describir la forma de los datos** con los que trabajamos. Para eso usamos **interfaces**.

### Interface local dentro de un componente

```html
<script setup lang="ts">
import { ref } from 'vue'

// Una interface describe la FORMA de un objeto: qué propiedades tiene
// y de qué tipo es cada una. No genera código en runtime, sólo le sirve
// a TypeScript para avisarte si te equivocas (autocompletado + errores
// en tiempo de compilación).
interface IClaseTarea {
  id: number          // identificador único — usado luego en :key
  texto: string       // descripción visible de la tarea
  completada: boolean // bandera para tachar / contar pendientes
}

// ref<IClaseTarea[]> declara una caja reactiva que SÓLO admite arrays
// de IClaseTarea. Si intentas { id: '1' } o falta una propiedad, TS falla.
const tareas = ref<IClaseTarea[]>([
  { id: 1, texto: 'Preparar demo', completada: false },
  { id: 2, texto: 'Revisar documentación', completada: true }
])
</script>
```

### ¿Dónde crear la interface?

| Ubicación | Cuándo usar | Ventaja |
|-----------|-------------|---------|
| Dentro del `.vue` | Solo se usa en ese componente | Más simple para empezar |
| `src/interfaces/IClaseNombre.ts` | Se reutiliza en varias vistas/componentes | Centraliza el contrato |

::: tip BUENA PRÁCTICA
En la UA usamos `IClase<Nombre>` para contratos reutilizables y los guardamos en `src/interfaces/` cuando dejan de ser locales.
:::

## 2.2 Funciones en TypeScript aplicadas a Vue {#funciones}

En Vue declaramos funciones dentro de `<script setup>` para responder a eventos, transformar datos o encapsular pequeñas reglas de negocio.

### Funciones tipadas

```typescript
// Cada parámetro lleva su tipo (a: number) y la función su tipo de retorno
// (: number). Si llamas sumar('1', 2) o asignas el resultado a un string,
// TypeScript se queja en el editor — antes de que el código llegue a correr.
const sumar = (a: number, b: number): number => a + b

// void = "esta función no devuelve nada útil". Sirve para handlers, side effects
// (alert, console.log, mutar un ref) y para que el llamador no espere un valor.
const mostrarAlerta = (mensaje: string): void => {
  alert(mensaje)
}

// El retorno declarado (: string) y el operador ternario garantizan que SIEMPRE
// salga un string, nunca undefined.
const obtenerEtiqueta = (completada: boolean): string => {
  return completada ? 'Hecha' : 'Pendiente'
}
```

### Parámetros opcionales y valores por defecto

```typescript
// El '?' marca apellido como OPCIONAL: puede no pasarse al llamar.
// Dentro de la función, su tipo real es 'string | undefined'.
const saludar = (nombre: string, apellido?: string): string => {
  return apellido ? `Hola ${nombre} ${apellido}` : `Hola ${nombre}`
}

// 'prefijo: string = "INFO"' = parámetro con valor por defecto. Si no se pasa,
// vale 'INFO'. A diferencia de '?', NUNCA es undefined dentro de la función.
const crearMensaje = (texto: string, prefijo: string = 'INFO'): string => {
  return `[${prefijo}] ${texto}`
}
```

### Funciones dentro de un componente Vue

```html
<script setup lang="ts">
import { ref } from 'vue'

// Estado reactivo para lo que teclea el usuario.
const nuevaTarea = ref<string>('')

// Helper puro: una entrada, una salida, sin tocar ningún ref.
// Mejor que repetir .trim() en cinco sitios.
const limpiarTexto = (texto: string): string => texto.trim()

// Handler que vamos a enganchar a un botón. Devuelve void = side effect.
const agregarTarea = (): void => {
  const textoLimpio = limpiarTexto(nuevaTarea.value)
  if (!textoLimpio) return                       // early return: nada que añadir
  console.log('Tarea válida:', textoLimpio)
}
</script>
```

::: tip IDEA CLAVE
Tipa siempre parámetros y retorno cuando la función tenga cierta importancia. En handlers pequeños como `@click="contador++"` no hace falta extraer función si no aporta claridad.
:::

## 2.3 Directivas: tabla resumen {#directivas-resumen}

Las directivas son atributos especiales que empiezan por `v-` y aplican comportamiento reactivo al DOM:

| Directiva | Atajo | Descripción | Uso principal |
|-----------|-------|-------------|---------------|
| `v-if` / `v-else-if` / `v-else` | — | Renderizado condicional (añade/elimina del DOM) | Condiciones que cambian poco |
| `v-show` | — | Visibilidad (CSS `display: none`) | Toggle frecuente (modales, tabs) |
| `v-for` | — | Renderizado de listas | Iterar arrays/objetos |
| `v-bind` | `:` | Vincular atributos HTML | class, style, src, href, props |
| `v-model` | — | Enlace bidireccional | Inputs, selects, textareas |
| `v-on` | `@` | Escuchar eventos | click, input, submit |
| `v-html` | — | Renderizar HTML | Contenido HTML confiable |

## 2.4 Renderizado condicional: `v-if` y `v-show` {#condicional}

### `v-if`, `v-else-if`, `v-else`

Controlan si un elemento **existe en el DOM**. Si la condición es falsa, el elemento se elimina completamente:

```html
<script setup lang="ts">
import { ref } from 'vue'

const edad = ref<number>(20)
</script>

<template>
  <!-- Vue evalúa las condiciones en orden. Sólo SE CREA EN EL DOM el <p>
       cuya condición es true; los demás ni siquiera existen como nodo. -->
  <p v-if="edad < 13">Eres un niño</p>
  <p v-else-if="edad < 18">Eres adolescente</p>
  <p v-else-if="edad < 65">Eres adulto</p>
  <p v-else>Eres mayor</p>
</template>
```

### `v-show`

El elemento **siempre está en el DOM**, solo se oculta con CSS:

```html
<script setup lang="ts">
import { ref } from 'vue'

const mostrarModal = ref<boolean>(false)
</script>

<template>
  <!-- Toggle: invierte el booleano. El texto del botón cambia con el ternario. -->
  <button @click="mostrarModal = !mostrarModal">
    {{ mostrarModal ? 'Ocultar' : 'Mostrar' }} Modal
  </button>

  <!-- v-show: el <div> SIEMPRE está en el DOM. Vue sólo cambia su
       atributo style="display: none". Inspecciónalo con F12 para verlo. -->
  <div v-show="mostrarModal" class="modal">
    <h2>Contenido del Modal</h2>
  </div>
</template>
```

### ¿Cuándo usar cada uno?

| Aspecto | `v-if` | `v-show` |
|---------|--------|----------|
| **DOM** | Añade / elimina el elemento | Siempre en el DOM (`display: none`) |
| **Rendimiento inicial** | Más rápido si la condición es falsa | Siempre renderiza |
| **Toggle frecuente** | Más costoso (recrea el elemento) | Más eficiente (solo cambia CSS) |
| **Cuándo usar** | Condiciones que cambian poco | Modales, tabs, toggles frecuentes |

El siguiente diagrama enseña la diferencia material: con `v-if` Vue **destruye y recrea** el nodo y dispara los hooks del ciclo de vida; con `v-show` el nodo **vive todo el tiempo** en el DOM y solo cambia su CSS:

```mermaid
flowchart TB
    subgraph vif["v-if (condicional)"]
        VIF_T["condicion = true<br/>(montado en DOM)"] -.->|condicion = false| VIF_F["Vue DESTRUYE<br/>el nodo del DOM<br/>+ hooks onUnmounted"]
        VIF_F -.->|condicion = true| VIF_T2["Vue CREA el nodo<br/>desde cero<br/>+ hooks onMounted"]
    end
    subgraph vshow["v-show (visibilidad)"]
        VS_T["condicion = true<br/>(visible)"] -.->|condicion = false| VS_F["display: none<br/>(sigue en DOM)"]
        VS_F -.->|condicion = true| VS_T2["display restaurado<br/>(sigue en DOM)"]
    end
    style vif fill:#fff3e0
    style vshow fill:#e8f5e9
```

::: tip CONSECUENCIA PRACTICA
Si un componente hijo dentro de `v-if` tiene `onMounted` con una llamada a la API, esa llamada se repetira CADA vez que `condicion` pase de false a true. Con `v-show` solo ocurre una vez (cuando se monta el padre).
:::

## 2.5 Renderizado de listas: `v-for` {#listas}

Itera sobre arrays, objetos o rangos numéricos:

### Arrays

```html
<script setup lang="ts">
import { ref } from 'vue'

interface IClaseUsuario {
  id: number
  nombre: string
  edad: number
}

const usuarios = ref<IClaseUsuario[]>([
  { id: 1, nombre: 'Ana',   edad: 25 },
  { id: 2, nombre: 'Juan',  edad: 30 },
  { id: 3, nombre: 'María', edad: 28 }
])
</script>

<template>
  <table>
    <tbody>
      <!-- v-for="usuario in usuarios" → genera un <tr> por cada elemento.
           :key="usuario.id" → identificador ÚNICO y ESTABLE de cada fila.
           Vue lo usa para saber qué fila actualizar, mover o eliminar
           cuando el array cambia, en lugar de redibujar todo. -->
      <tr v-for="usuario in usuarios" :key="usuario.id">
        <td>{{ usuario.id }}</td>
        <td>{{ usuario.nombre }}</td>
        <td>{{ usuario.edad }}</td>
      </tr>
    </tbody>
  </table>
</template>
```

### Objetos y rangos

```html
<template>
  <!-- Sobre un objeto, v-for entrega (valor, clave). El orden de los pares
       es el de inserción en el objeto. -->
  <ul>
    <li v-for="(valor, clave) in persona" :key="clave">
      {{ clave }}: {{ valor }}
    </li>
  </ul>

  <!-- Pasar un número a v-for itera de 1 hasta N (INCLUSIVE), no de 0 a N-1.
       Útil para listas de páginas, estrellas de valoración, etc. -->
  <span v-for="n in 5" :key="n">{{ n }} </span>
  <!-- Renderiza: 1 2 3 4 5 -->
</template>
```

### El atributo `:key`

`:key` es **obligatorio** con `v-for`. Ayuda a Vue a identificar cada elemento de forma única:

| Tipo de datos | `:key` recomendado | Ejemplo |
|---------------|-------------------|---------|
| Array de objetos | `:key="obj.id"` | `:key="usuario.id"` |
| Array de strings únicos | `:key="item"` | `:key="fruta"` |
| Objeto | `:key="clave"` | `:key="clave"` |
| Rango numérico | `:key="n"` | `:key="n"` |

::: danger ZONA PELIGROSA
No uses `:key="index"` en listas que se reordenan o eliminan elementos. Vue reutiliza el HTML por posición y los estados internos (checkboxes marcados, inputs con texto) se mezclan.

```html
<!-- ❌ Si eliminas un elemento, los estados se mezclan -->
<div v-for="(tarea, index) in tareas" :key="index">
  <input type="checkbox" /> {{ tarea }}
</div>

<!-- ✅ Usa un ID único -->
<div v-for="tarea in tareas" :key="tarea.id">
  <input type="checkbox" /> {{ tarea.texto }}
</div>
```

:::

::: details Por que :key="index" mezcla los estados

```svgbob
ANTES                            DESPUES de borrar B
                                 (con :key="index")

+----+---+                       +----+---+
| 0  | A |  foco activo          | 0  | A |  foco activo
+----+---+                       +----+---+
| 1  | B |  texto "editando"     | 1  | C |  texto "editando" (!)
+----+---+                       +----+---+      (era de B)
| 2  | C |  -                
+----+---+                       

Vue ve la misma clave 1, decide REUTILIZAR el <input>,
y conserva el estado interno de B en lo que ahora es C.
```

Con `:key="item.id"` no pasa: Vue ve que la id de B ya no esta y monta un nodo nuevo para C.
:::

### No mezcles `v-if` y `v-for`

```html
<!-- ❌ INCORRECTO: en Vue 3, v-if tiene PRIORIDAD sobre v-for en el mismo
     elemento. La condición se evalúa antes de que exista 'u', así que
     u.activo es undefined y aparece warning en consola. -->
<li v-for="u in usuarios" v-if="u.activo" :key="u.id">{{ u.nombre }}</li>

<!-- ✅ CORRECTO: <template> envuelve el v-for sin generar nodo extra en el DOM.
     El v-if se evalúa POR CADA u, ya con la variable disponible. -->
<template v-for="u in usuarios" :key="u.id">
  <li v-if="u.activo">{{ u.nombre }}</li>
</template>
```

::: tip BUENA PRÁCTICA
La mejor solución es usar una propiedad `computed` que filtre antes de renderizar (lo veremos en la sesión 11).
:::

## 2.6 Vincular atributos: `v-bind` (`:`) {#v-bind}

Vincula dinámicamente atributos HTML a valores reactivos:

```html
<script setup lang="ts">
import { ref } from 'vue'

const imagenUrl = ref<string>('https://example.com/logo.png')
const esActivo  = ref<boolean>(true)
</script>

<template>
  <!-- src="imagenUrl" → pinta literalmente la cadena "imagenUrl".
       :src="imagenUrl" → evalúa la expresión y usa el valor del ref. -->
  <img :src="imagenUrl" alt="Logo">

  <!-- Cualquier atributo HTML acepta el ':'. Las expresiones pueden ser
       ternarios, llamadas a función, concatenaciones... siempre que devuelvan
       el tipo esperado (boolean para :disabled, string para :title). -->
  <button :disabled="!esActivo" :title="esActivo ? 'Activo' : 'Inactivo'">
    Botón
  </button>
</template>
```

### Vincular clases CSS (muy común)

Las llaves `{ }` representan un objeto donde la **clave** es el nombre de la clase y el **valor** es una condición booleana. La demo `Sesion7Semaforo.vue` lo combina con un **union type** para que TypeScript impida valores fuera del dominio:

```html
<script setup lang="ts">
import { ref } from 'vue'

// Union type: 'estado' SÓLO puede ser uno de estos tres literales.
// Cualquier otra cadena ('azul', 'rojo ' con espacio...) es error de TS.
type EstadoSemaforo = 'rojo' | 'ambar' | 'verde'
const estado = ref<EstadoSemaforo>('rojo')
</script>

<template>
  <!-- class="semaforo" → clase FIJA, siempre presente.
       :class="{ ... }" → clases DINÁMICAS: cada par 'clase: condición'
       añade la clase si la condición es true. Vue combina ambas en el DOM.
       Resultado: <div class="semaforo semaforo--rojo"> cuando estado es 'rojo'. -->
  <div
    class="semaforo"
    :class="{
      'semaforo--rojo':  estado === 'rojo',
      'semaforo--ambar': estado === 'ambar',
      'semaforo--verde': estado === 'verde',
    }"
  >
    Estado actual: <strong>{{ estado }}</strong>
  </div>

  <!-- Asignación inline al ref: como 'estado' es ref<EstadoSemaforo>,
       sólo se aceptan los tres literales. Probar @click="estado = 'azul'"
       y verás el error rojo en el editor. -->
  <button class="btn btn-danger"  @click="estado = 'rojo'">Rojo</button>
  <button class="btn btn-warning" @click="estado = 'ambar'">Ambar</button>
  <button class="btn btn-success" @click="estado = 'verde'">Verde</button>
</template>
```

> Fichero real: `ClientApp/src/views/sesiones-vue/sesion-7/Sesion7Semaforo.vue`. Intentar `estado.value = 'azul'` en el script falla en compilación: ese es el valor del union type.

::: warning IMPORTANTE
Si el nombre de clase tiene guion (ej: `btn-activo`), debe ir entre comillas: `'btn-activo'`.
:::

## 2.7 Enlace bidireccional: `v-model` {#v-model}

`v-model` sincroniza automáticamente un dato reactivo con un elemento de formulario:

```html
<script setup lang="ts">
import { ref } from 'vue'

// Un ref por cada campo. Vue elige automáticamente la propiedad correcta
// del input según el type: .value para text, .checked para checkbox,
// .value (cadena) para select. Por eso 'acepto' es boolean, no string.
const nombre = ref<string>('')
const acepto = ref<boolean>(false)
const opcion = ref<string>('a')
</script>

<template>
  <form>
    <!-- v-model es azúcar sintáctico para :value="x" + @input="x = $event.target.value".
         La diferencia con :value: aquí Vue ESCRIBE en el ref cuando el usuario teclea. -->
    <input v-model="nombre" placeholder="Nombre" />

    <!-- En checkbox, v-model usa el atributo 'checked' (boolean), no 'value'. -->
    <input type="checkbox" v-model="acepto" /> Acepto condiciones

    <!-- En select, v-model toma el 'value' del <option> elegido. -->
    <select v-model="opcion">
      <option value="a">Opción A</option>
      <option value="b">Opción B</option>
    </select>

    <!-- Los tres <p> se actualizan automáticamente con cada pulsación / click. -->
    <p>Nombre: {{ nombre }}</p>
    <p>Aceptado: {{ acepto }}</p>
    <p>Opción: {{ opcion }}</p>
  </form>
</template>
```

Soporta: `<input>` (text, checkbox, radio), `<select>`, `<textarea>`. El valor de la variable se actualiza automáticamente al cambiar el input y viceversa.

## 2.8 Eventos del DOM {#eventos}

Se usa `v-on` (atajo `@`) para escuchar eventos:

```html
<script setup lang="ts">
import { ref } from 'vue'

const contador = ref<number>(0)

// El parámetro 'event' lo recibe automáticamente cuando enganchas la función
// SIN paréntesis (@input="handleInput"). Es el Event nativo del DOM.
function handleInput(event: Event) {
  // event.target es de tipo EventTarget | null. Lo "casteamos" a HTMLInputElement
  // con 'as' para acceder a .value. Si el casting es incorrecto, falla en runtime.
  const valor = (event.target as HTMLInputElement).value
  console.log('Escribiste:', valor)
}

function enviarFormulario() {
  console.log('Formulario enviado')
}
</script>

<template>
  <!-- Expresión inline: incrementa el ref directamente. Para acciones de 1 línea. -->
  <button @click="contador++">Sumar</button>

  <!-- Cualquier expresión JS válida vale: llamadas a funciones globales, etc. -->
  <button @click="alert('¡Hola!')">Saludar</button>

  <!-- SIN paréntesis → Vue pasa el Event automáticamente al handler.
       CON paréntesis (handleInput($event)) tendrías que escribir $event a mano. -->
  <input @input="handleInput" placeholder="Escribe algo">

  <!-- .prevent = event.preventDefault(). Aquí evita que el submit recargue
       la página, que es el comportamiento por defecto de los formularios HTML.
       Imprescindible en SPAs. -->
  <form @submit.prevent="enviarFormulario">
    <button type="submit">Enviar</button>
  </form>
</template>
```

### Eventos más comunes

| Evento | Descripción | Ejemplo de uso |
|--------|-------------|----------------|
| `@click` | Click del ratón | Botones, enlaces |
| `@input` | Cambio en input (tiempo real) | Búsqueda en vivo |
| `@change` | Cambio confirmado | Select, checkbox |
| `@submit` | Envío de formulario | Formularios |
| `@keyup` / `@keydown` | Tecla presionada/soltada | Atajos de teclado |
| `@focus` / `@blur` | Enfocado / desenfocado | Validación de campos |

### Modificadores

| Modificador | Descripción | Ejemplo |
|-------------|-------------|---------|
| `.prevent` | Evita la acción por defecto | `@submit.prevent` |
| `.stop` | Detiene la propagación | `@click.stop` |
| `.once` | Se ejecuta solo una vez | `@click.once` |
| `.self` | Solo si proviene del propio elemento | `@click.self` |

### Modificadores de teclado

```html
<!-- @keyup escucha TODAS las teclas; con .enter Vue filtra y sólo dispara
     'buscar' cuando la tecla soltada es Enter. Es lo que esperan los usuarios
     en un campo de búsqueda. -->
<input @keyup.enter="buscar">

<!-- Se pueden encadenar modificadores: aquí exige Ctrl + Enter a la vez.
     Útil para enviar formularios complejos sin tener que pulsar el botón. -->
<input @keyup.ctrl.enter="enviar">

<!-- Otros: .tab, .delete, .esc, .space, .up, .down, .left, .right -->
```

## 2.9 Métodos de arrays {#metodos-arrays}

Los métodos de arrays son fundamentales en Vue para transformar, filtrar y agregar datos. Todos son **inmutables** (no modifican el array original, excepto `.sort()`).

La demo `Sesion7MetodosArrays.vue` muestra los cuatro métodos clave sobre el mismo array de reservas y todos como `computed`:

```typescript
interface IClaseReserva {
  id: number
  recurso: string
  horas: number
  confirmada: boolean
}

const reservas = ref<IClaseReserva[]>([
  { id: 1, recurso: 'Aula 12',          horas: 2, confirmada: true },
  { id: 2, recurso: 'Sala reuniones A', horas: 1, confirmada: false },
  { id: 3, recurso: 'Aula 12',          horas: 3, confirmada: true },
  { id: 4, recurso: 'Proyector',        horas: 1, confirmada: true },
])

// .map → transforma cada elemento; mismo tamaño que el original.
const titulares = computed(() =>
  reservas.value.map(r => `${r.recurso} (${r.horas}h)`)
)

// .filter → deja solo los que cumplen.
const confirmadas = computed(() =>
  reservas.value.filter(r => r.confirmada)
)

// .find → primero que cumple, o undefined.
const primeraSinConfirmar = computed(() =>
  reservas.value.find(r => !r.confirmada)
)

// .reduce → acumula. Aquí, horas confirmadas totales.
const horasConfirmadas = computed(() =>
  reservas.value
    .filter(r => r.confirmada)
    .reduce((total, r) => total + r.horas, 0)
)
```

> Fichero real: `ClientApp/src/views/sesiones-vue/sesion-7/Sesion7MetodosArrays.vue`. Encadenar `.filter().reduce()` es legible y no muta el array original.

### `.some()` y `.every()` — Verificar condiciones

```typescript
// .some  → true en cuanto encuentra UN elemento que cumple. Corta búsqueda.
// .every → true sólo si TODOS cumplen. Corta al primer false.
const hayCaros     = productos.some (p => p.precio > 500)   // ¿alguno > 500?
const todosBaratos = productos.every(p => p.precio < 100)   // ¿todos < 100?
```

### `.sort()` — Ordenar

```typescript
// ⚠️ .sort() es la EXCEPCIÓN: muta el array original. Si pasaras 'productos'
// directo, cambiarías la fuente y, si es reactiva, dispararías renders no deseados.
// El truco: clonar con spread ([...productos]) y ordenar la copia.
const ordenados = [...productos].sort((a, b) => a.precio - b.precio)
// Comparator: número negativo → a antes que b. Por eso (a-b) = ascendente,
// (b-a) = descendente.
```

### Encadenamiento de métodos

```typescript
interface IClaseEstudiante {
  nombre: string
  nota: number
}

const estudiantes: IClaseEstudiante[] = [
  { nombre: 'Ana',   nota: 8 },
  { nombre: 'Juan',  nota: 4 },
  { nombre: 'María', nota: 9 },
  { nombre: 'Pedro', nota: 6 }
]

// Pipeline en 3 pasos. Cada método devuelve un array NUEVO, por eso se pueden
// encadenar con el punto. Se lee de arriba a abajo como una receta:
const mejoresAprobados = estudiantes
  .filter(e => e.nota >= 5)         // 1) quita los suspensos
  .sort((a, b) => b.nota - a.nota)  // 2) ordena de mayor a menor nota
  .map(e => e.nombre)               // 3) quédate sólo con los nombres
// → ['María', 'Ana', 'Pedro']
```

### Tabla resumen

| Método | Retorna | Propósito | Ejemplo típico |
|--------|---------|-----------|----------------|
| `.map()` | Array mismo tamaño | Transformar | Extraer nombres, añadir IVA |
| `.filter()` | Array menor o igual | Filtrar | Solo activos, buscar por texto |
| `.find()` | 1 elemento o `undefined` | Buscar uno | Buscar por ID |
| `.reduce()` | Cualquier valor | Acumular | Sumar, contar, agrupar |
| `.some()` | `boolean` | ¿Alguno cumple? | ¿Hay errores? |
| `.every()` | `boolean` | ¿Todos cumplen? | ¿Todo validado? |
| `.sort()` | Array (mutado) | Ordenar | Ordenar por precio |

## 2.10 Objetos y acceso seguro a datos {#metodos-objetos}

### Spread operator (`...`) y clonación superficial

La demo `Sesion7SpreadDestructuring.vue` recorre los cuatro patrones (spread, destructuring, `?.` y `??`) sobre un mismo `IClaseUsuario`:

```typescript
interface IClaseUsuario {
  nombre: string
  email?: string
  direccion?: { ciudad: string; codigoPostal?: string }
}

const usuario = ref<IClaseUsuario>({
  nombre: 'Ada Lovelace',
  email: 'ada@uacloud.ua.es',
  direccion: { ciudad: 'Alicante' },
})

// 1) Spread para clonar y modificar SIN mutar el original.
const usuarioRenombrado = { ...usuario.value, nombre: 'Ada L.' }

// 2) Spread con arrays.
const numeros = [1, 2, 3]
const numerosAmpliados = [0, ...numeros, 4]
```

::: warning IMPORTANTE
El spread operator es **superficial** (shallow). Para objetos con propiedades anidadas, los cambios en la copia afectan al original:

```typescript
const copia = { ...usuario }
copia.direccion.ciudad = 'Valencia'  // ⚠️ Modifica también el original

// Para copia profunda (deep copy):
const copiaReal = structuredClone(usuario)
```

:::

### Destructuring

Extrae propiedades de un objeto en variables individuales. Continuando con el mismo `usuario` de la demo:

```typescript
// Destructuring con renombrado y default.
const { nombre: nombreUsuario, email = '(sin correo)' } = usuario.value

// Acceso seguro a campos opcionales anidados.
const codigoPostal = usuario.value.direccion?.codigoPostal

// Nullish: '' es válido, solo cae al fallback con null/undefined.
const cpVisible = codigoPostal ?? 'sin CP'
```

### Optional chaining (`?.`) y Nullish coalescing (`??`)

Dos operadores fundamentales para trabajar con datos de APIs que pueden tener propiedades opcionales:

```typescript
interface IClaseUsuario {
  nombre: string
  direccion?: {
    ciudad: string
    codigoPostal?: string
  }
}

const usuario: IClaseUsuario = { nombre: 'Ana' }

// ?.  → Acceso seguro (retorna undefined si no existe, sin error)
const ciudad = usuario.direccion?.ciudad          // undefined (no da error)
const cp = usuario.direccion?.codigoPostal        // undefined

// ??  → Valor por defecto SOLO si es null o undefined
const ciudadFinal = usuario.direccion?.ciudad ?? 'Sin ciudad'  // 'Sin ciudad'
```

**Diferencia entre `??` y `||`:**

| Expresión | `\|\|` (OR) | `??` (Nullish) |
|-----------|------------|----------------|
| `0 \|\| 10` | `10` (0 es falsy) | `0` |
| `'' \|\| 'default'` | `'default'` ('' es falsy) | `''` |
| `false \|\| true` | `true` (false es falsy) | `false` |
| `null \|\| 10` | `10` | `10` |
| `undefined \|\| 10` | `10` | `10` |

::: tip BUENA PRÁCTICA
Usa `??` en lugar de `||` cuando quieras distinguir entre "valor vacío pero válido" (0, '', false) y "valor ausente" (null, undefined). Es el patrón estándar con datos de API.
:::

::: info PUENTE A LA SESIÓN 3
En esta sesión trabajamos `v-model`, handlers y validaciones básicas. En la sesión 11 verás el patrón completo de formulario con **estado derivado** usando `computed`: normalización de entrada, habilitar/deshabilitar acciones y criterio `computed` vs método.
:::

## 2.11 Pruébalo en el proyecto {#sandbox}

En `uaReservas/ClientApp/src/views/sesiones-vue/sesion-7/` hay seis demos navegables, una por concepto. Arranca la app y entra en `/uareservas/sesiones-vue/sesion-7`:

| Demo | Concepto que ilustra | Fichero |
|------|----------------------|---------|
| `Sesion7Semaforo.vue` | `:class` con objeto + union type (`'rojo' \| 'ambar' \| 'verde'`) | `sesion-7/Sesion7Semaforo.vue` |
| `Sesion7VifVshow.vue` | `v-if` destruye/crea nodo; `v-show` solo cambia `display` | `sesion-7/Sesion7VifVshow.vue` |
| `Sesion7ListaTareas.vue` | `v-for`, `:key` estable, `v-model` en checkbox, `@keyup.enter` | `sesion-7/Sesion7ListaTareas.vue` |
| `Sesion7MetodosArrays.vue` | `.map / .filter / .find / .reduce` sobre reservas, todos como `computed` | `sesion-7/Sesion7MetodosArrays.vue` |
| `Sesion7SpreadDestructuring.vue` | Spread, destructuring, `?.`, `??` sobre `IClaseUsuario` | `sesion-7/Sesion7SpreadDestructuring.vue` |
| `Sesion7TablaRecursos.vue` | Demo integradora: filtro + checkbox + tabla con clases dinámicas | `sesion-7/Sesion7TablaRecursos.vue` |

::: tip CÓMO TRABAJAR LAS DEMOS
Abre `Sesion7TablaRecursos.vue` con F12 abierto y mira cómo Vue solo redibuja las filas afectadas al teclear en el filtro o marcar "solo activos". Esta vista es el "antes" del DataTable con paginación servidor que veremos en la sesión 14.
:::

***

## Ejercicio Sesión 10 {#ejercicio}

::: info ENUNCIADO
Debes implementar una mini lista de tareas para validar que dominas el flujo completo de esta sesión: tipado de datos con interface, renderizado de listas, formulario con `v-model`, eventos de usuario y transformación de arrays para actualizar estado.

**Resultado esperado:** un componente `ListaTareas.vue` donde el usuario pueda crear, marcar y eliminar tareas, y vea el estado de la lista actualizado en tiempo real.
:::

**Objetivo:** Practicar interfaces, funciones tipadas, directivas (`v-for`, `v-if`, `v-model`), eventos y métodos de arrays creando una lista de tareas interactiva.

Crea un componente `ListaTareas.vue` con:

1. Una interface `IClaseTarea` con: `id` (number), `texto` (string), `completada` (boolean)
2. Un array reactivo `tareas` con 2-3 tareas iniciales
3. Un `<input>` con `v-model` para escribir nuevas tareas
4. Un botón "Añadir" que cree una tarea nueva (genera `id` con `Date.now()`)
5. Renderiza cada tarea con `v-for` mostrando:
   * Un checkbox (`v-model` con `tarea.completada`)
   * El texto de la tarea (con estilo tachado si está completada usando `:class` o `:style`)
   * Un botón "Eliminar" que quite la tarea del array (`.filter()`)
6. Muestra un contador: "X tareas pendientes" usando `.filter()` para contar las no completadas
7. Un mensaje con `v-if`: si no hay tareas, muestra "¡No hay tareas! 🎉"

::: details Solución

```html
<script setup lang="ts">
import { ref } from 'vue'

// Contrato de cada tarea. La interface vive dentro del componente porque
// no se reutiliza fuera. Si la usaras en dos vistas, la moverías a
// src/interfaces/IClaseTarea.ts (ver §2.1).
interface IClaseTarea {
  id: number
  texto: string
  completada: boolean
}

// Estado principal: array reactivo de tareas, con datos iniciales.
const tareas = ref<IClaseTarea[]>([
  { id: 1, texto: 'Aprender Vue 3',             completada: false },
  { id: 2, texto: 'Practicar TypeScript',       completada: true  },
  { id: 3, texto: 'Crear mi primer componente', completada: false }
])

// Estado secundario: lo que teclea el usuario en el input.
const nuevaTarea = ref<string>('')

// ── Añadir tarea ─────────────────────────────────────────────────────────
const agregarTarea = (): void => {
  const textoLimpio = nuevaTarea.value.trim()
  if (!textoLimpio) return                     // descarta espacios en blanco

  // push muta el array, y Vue lo detecta porque ref<T[]> envuelve el array
  // en un Proxy reactivo. Date.now() devuelve un timestamp único como id.
  tareas.value.push({
    id: Date.now(),
    texto: textoLimpio,
    completada: false
  })
  nuevaTarea.value = ''                        // limpia el input para la siguiente
}

// ── Eliminar tarea ───────────────────────────────────────────────────────
// .filter devuelve un ARRAY NUEVO sin el id indicado. Reasignamos a .value
// para que el reactivity system de Vue lo detecte y redibuje la lista.
const eliminarTarea = (id: number): void => {
  tareas.value = tareas.value.filter(t => t.id !== id)
}

// ── Pendientes (función, no computed) ────────────────────────────────────
// En esta sesión todavía no hemos visto 'computed'. Por eso lo resolvemos
// como función. En la sesión 11 lo refactorizaremos a computed para que
// el resultado se cachee entre renders.
const pendientes = (): number => {
  return tareas.value.filter(t => !t.completada).length
}
</script>

<template>
  <div class="p-4" style="max-width: 500px">
    <h2>Lista de Tareas</h2>

    <div class="d-flex gap-2 mb-3">
      <!-- v-model: input ↔ ref bidireccional.
           @keyup.enter: enviar con la tecla Enter, sin tocar el ratón. -->
      <input
        v-model="nuevaTarea"
        @keyup.enter="agregarTarea"
        placeholder="Nueva tarea..."
        class="form-control"
      />
      <button @click="agregarTarea" class="btn btn-primary">Añadir</button>
    </div>

    <!-- v-if/v-else: o se ve el mensaje vacío o la lista, nunca los dos. -->
    <p v-if="tareas.length === 0">¡No hay tareas! 🎉</p>

    <ul class="list-group" v-else>
      <!-- :key="tarea.id" es CRÍTICO: si usáramos :key="index", al eliminar
           una tarea los checkboxes se mezclarían (ver §2.5 - zona peligrosa). -->
      <li
        v-for="tarea in tareas"
        :key="tarea.id"
        class="list-group-item d-flex align-items-center gap-2"
      >
        <!-- v-model directo sobre la propiedad del objeto: cambia la tarea
             dentro del array y dispara el re-render correspondiente. -->
        <input type="checkbox" v-model="tarea.completada" />

        <!-- :style con objeto: aplica line-through sólo cuando completada=true. -->
        <span :style="{ textDecoration: tarea.completada ? 'line-through' : 'none' }">
          {{ tarea.texto }}
        </span>

        <!-- Pasar argumento al handler: usar paréntesis. ms-auto empuja
             el botón al borde derecho con flexbox. -->
        <button
          @click="eliminarTarea(tarea.id)"
          class="btn btn-sm btn-danger ms-auto"
        >
          Eliminar
        </button>
      </li>
    </ul>

    <!-- pendientes() se llama en CADA render del template (todavía no usamos
         computed). Como la lista es corta, no importa. -->
    <p class="mt-2" v-if="tareas.length > 0">
      {{ pendientes() }} tareas pendientes
    </p>
  </div>
</template>
```

:::

## Test Sesión 10 {#test}

### Preguntas (desplegables)

::: details 1. ¿Qué describe una interface en TypeScript?

* a) Un componente visual
* b) La forma o contrato de un objeto
* c) Un evento del DOM
* d) Un tipo de directiva
  :::

::: details 2. ¿Dónde suele colocarse una interface reutilizable según la convención explicada?

* a) src/assets
* b) src/interfaces
* c) src/styles
* d) src/router
  :::

::: details 3. ¿Qué significa que una función esté tipada como void?

* a) Que devuelve siempre null
* b) Que no devuelve un valor útil
* c) Que no puede recibir parámetros
* d) Que solo se usa en Vue
  :::

::: details 4. ¿Por qué conviene tipar un handler o una función de negocio sencilla?

* a) Porque Vue deja de ser reactivo si no la tipas
* b) Porque mejora legibilidad y evita errores de uso
* c) Porque sustituye a v-model
* d) Porque elimina la necesidad de probar
  :::

::: details 5. ¿Qué directiva elimina o crea nodos del DOM según una condición?

* a) v-show
* b) v-if
* c) v-bind
* d) v-model
  :::

::: details 6. ¿Qué directiva encaja mejor cuando una zona se muestra y oculta con mucha frecuencia?

* a) v-for
* b) v-show
* c) v-slot
* d) v-pre
  :::

::: details 7. ¿Qué directiva se usa para iterar una lista?

* a) v-for
* b) v-repeat
* c) v-list
* d) v-map
  :::

::: details 8. ¿Cuál es la mejor key en un v-for si cada objeto tiene id?

* a) El índice del array
* b) Math.random()
* c) objeto.id
* d) El texto visible
  :::

::: details 9. ¿Qué atajo representa v-bind?

* a) @
* b) :
* c) #
* d) $
  :::

::: details 10. ¿Qué directiva conecta un input con una variable reactiva de forma bidireccional?

* a) v-if
* b) v-model
* c) v-html
* d) v-once
  :::

::: details 11. ¿Qué modificador evita el comportamiento por defecto de un formulario al enviarlo?

* a) .stop
* b) .once
* c) .prevent
* d) .capture
  :::

::: details 12. ¿Qué método devuelve un nuevo array con solo los elementos que cumplen una condición?

* a) find
* b) filter
* c) reduce
* d) some
  :::

::: details 13. ¿Qué método devuelve el primer elemento que cumple una condición?

* a) map
* b) filter
* c) find
* d) every
  :::

::: details 14. ¿Qué método modifica el array original?

* a) filter
* b) map
* c) sort
* d) find
  :::

::: details 15. ¿Qué operador usa un valor por defecto solo cuando el de la izquierda es null o undefined?

* a) ||
* b) &&
* c) ??
* d) ?.
  :::

### Respuestas (Autoevaluación)

::: details Ver respuestas

1. b) La forma o contrato de un objeto.
2. b) src/interfaces.
3. b) No devuelve un valor útil.
4. b) Mejora legibilidad y evita errores de uso.
5. b) v-if. Crea o elimina nodos según la condición.
6. b) v-show. Encaja mejor en cambios frecuentes de visibilidad.
7. a) v-for.
8. c) objeto.id. Es una key estable y única.
9. b) :
10. b) v-model.
11. c) .prevent.
12. b) filter.
13. c) find.
14. c) sort. Muta el array original.
15. c) ??.
    :::

***

| Anterior | Inicio | Siguiente |
|---|---|---|
| [← Sesión 9: Vue 3, TypeScript y primer componente](../../../03-vue/sesiones/sesion-09-vue-typescript-fundamentos/) | [Índice del curso](../../../) | [Sesión 11: Componentes y comunicación →](../../../03-vue/sesiones/sesion-11-componentes-estado/) |
