---
title: "Respuestas — Sesión 10: Directivas, eventos y datos"
description: "Solucionario razonado del test de 18 preguntas de la Sesión 10."
outline: [2, 2]
search: false
---

# Respuestas — Test Sesión 10: Directivas, eventos y datos

1. **c)** La forma o contrato de un objeto. Una `interface` describe qué propiedades tiene un objeto y de qué tipo es cada una. No genera código en runtime; solo aporta autocompletado y errores en compilación.

2. **d)** `src/interfaces/`. La convención del curso (`IClase<Nombre>`) guarda los contratos reutilizables en esa carpeta. Cuando una interface solo se usa dentro de un `.vue`, puede declararse local (§2.1).

3. **a)** No devuelve un valor útil. Se usa para handlers, side effects (`alert`, `console.log`, mutar un `ref`) y para que el llamador no espere un valor de retorno. No equivale a `null`: una función `void` puede devolver `undefined` implícitamente.

4. **d)** `v-if`. Si la condición es falsa, el elemento **no existe** en el DOM. Cuando la condición se vuelve verdadera, Vue lo crea desde cero y ejecuta sus hooks (`onMounted`, etc.).

5. **a)** `v-show`. Mantiene el elemento siempre en el DOM y solo alterna `display: none`. Más eficiente que `v-if` cuando la alternancia es frecuente (modales, tabs, paneles plegables).

6. **c)** `v-for`. `v-list`, `v-repeat` y `v-map` no existen en Vue.

7. **a)** `objeto.id`. Es estable (no cambia entre renders) y único (no se repite). Con `:key="index"`, al reordenar o eliminar elementos Vue reutiliza los nodos por posición y arrastra estados internos (checkbox marcado, foco activo) a la fila equivocada — exactamente el bug de la pregunta 15.

8. **b)** `:`. `:src="…"` es equivalente a `v-bind:src="…"`. El `@` es el atajo de `v-on`.

9. **d)** `v-model`. Azúcar sintáctico para `:value` + `@input` (o `:checked` + `@change` en checkboxes). Sincroniza el ref con el input en ambas direcciones.

10. **b)** `.prevent`. Equivale a `event.preventDefault()`. En `<form @submit.prevent="…">` evita que el navegador recargue la página al enviar el formulario — imprescindible en SPAs. `.stop` detiene la propagación; `.once` ejecuta el handler una sola vez; `.capture` cambia la fase del evento.

11. **b)** `.filter`. Devuelve un array nuevo con los elementos que cumplen la condición; el original no se toca. `.find` solo devuelve **uno** (el primero); `.reduce` acumula a un único valor; `.some` devuelve `true`/`false`.

12. **c)** `.find`. Si no encuentra ninguno devuelve `undefined`, por eso en plantillas se suele proteger con `v-if`: <code v-pre>&lt;p v-if="primera"&gt;{{ primera.recurso }}&lt;/p&gt;</code>.

13. **d)** `.sort`. Es la única excepción mutable entre los métodos vistos. Para no contaminar el array original (especialmente si es reactivo), clona antes: `[...productos].sort(...)`. Ver pregunta 16.

14. **c)** `??` (nullish coalescing). Solo cae al fallback con `null` o `undefined`. A diferencia de `||`, respeta valores "vacíos pero válidos": `0`, `''`, `false`. Patrón estándar al consumir datos de API: `respuesta.codigoPostal ?? 'sin CP'`.

15. **b)** Vue reutiliza los `<input>` por posición. Como las `:key` son `0, 1, 2…` (los índices), al eliminar la fila 1, el `<input>` que estaba en `index=1` (con `checked=true`) ahora muestra los datos de la antigua fila 2. El check marcado se queda donde estaba físicamente, no donde estaba lógicamente. Con `:key="tarea.id"` Vue identifica cada fila por su id estable y no se mezclan los estados. Es el ejemplo del recuadro "Zona peligrosa" de §2.5.

16. **c)** `productos` y `ordenados` valen ambos `[1, 2, 3]` y son **la misma referencia**. `.sort` muta el array original (única excepción entre los métodos vistos) y devuelve esa misma referencia, no una nueva. Para no mutar: `const ordenados = [...productos].sort((a, b) => a - b)` — el spread clona antes de ordenar.

17. **c)** `'Sin ciudad'`. `u.direccion` es `undefined`, así que `u.direccion?.ciudad` corta en el `?.` y devuelve `undefined` sin lanzar error. Luego `?? 'Sin ciudad'` sustituye el `undefined` por la cadena por defecto. Si `direccion` existiera y `ciudad` fuese `''`, el resultado sería `''` (no `'Sin ciudad'`), porque `??` solo cae con `null`/`undefined`.

18. **a)** `resultado = [2, 4, 6, 8]` y `numeros` sigue siendo `[1, 2, 3, 4]`. `.map` devuelve un array **nuevo** del mismo tamaño con cada elemento transformado por la función. No muta el original ni filtra ni acumula.
