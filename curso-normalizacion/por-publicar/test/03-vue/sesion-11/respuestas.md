---
title: "Respuestas — Sesión 11: Componentes, comunicación y estado derivado"
description: "Solucionario razonado del test de 16 preguntas de la Sesión 11."
outline: [2, 2]
search: false
---

# Respuestas — Test Sesión 11: Componentes, comunicación y estado derivado

1. **b)** Para derivar un valor reactivo a partir de otro estado. Una `computed` envuelve una función pura cuyo resultado depende de otras `ref`/`reactive`; cuando alguna cambia, el valor derivado se recalcula automáticamente.

2. **b)** Se cachea según sus dependencias. Si el template usa el mismo valor en cinco sitios, la `computed` se ejecuta una sola vez; un método se ejecutaría cinco veces. Solo recalcula cuando alguna de sus dependencias reactivas cambia.

3. **b)** `defineProps`. Es la macro de Composition API que el hijo usa para declarar qué datos acepta del padre. El padre los pasa con `:nombre="valor"`.

4. **b)** Son de solo lectura en el hijo. Vue avisa en consola si intentas mutarlos. Para "modificar" un prop, el hijo emite un evento al padre y este actualiza su propio estado (regla "datos bajan, eventos suben").

5. **c)** `defineEmits`. Es la macro complementaria a `defineProps`: declara qué eventos personalizados emite el hijo. El padre los escucha con `@nombre="handler"`.

6. **a)** `defineModel`. Macro introducida en Vue 3.4 que reemplaza el patrón antiguo `prop + emit('update:modelValue', ...)`. Permite usar `v-model` sobre tu componente con dos líneas en lugar de diez.

7. **b)** En el padre. Es la regla "single source of truth": una sola variable es la fuente, y los componentes que la necesitan la reciben como prop. Duplicar estado en padre e hijo lleva a desincronización.

8. **b)** Asigna valores por defecto a props opcionales. Sintaxis: `withDefaults(defineProps<{...}>(), { campo: 'valor' })`. Sin `withDefaults`, una prop opcional declarada con `?` llega como `undefined`.

9. **b)** Para efectos secundarios. `watch` ejecuta código cuando cambia un valor reactivo: guardar en `localStorage`, llamar a una API, lanzar un log o un toast. **Nunca** lo uses para calcular un valor mostrado en pantalla — eso es trabajo de `computed`.

10. **b)** Detecta dependencias automáticamente. En `watch(consulta, cb)` indicas explícitamente qué observar; en `watchEffect(cb)` Vue analiza la función y se suscribe a cualquier `ref`/`reactive` que se lea dentro. Útil para lógica corta; menos para casos donde necesites el valor anterior.

11. **b)** `onMounted`. Se ejecuta cuando el componente ya está en el DOM. Es el sitio típico para `await api.listar()`, foco inicial, integraciones con librerías de DOM, etc.

12. **a)** Un hueco de contenido que el componente padre rellena. El hijo declara `<slot>`; el padre lo "rellena" desde fuera con contenido HTML/componentes. Permite hacer componentes contenedores reutilizables (cards, modales, layouts).

13. **b)** Compartir contexto sin pasar props por muchos niveles. Útil para tema, locale, sesión del usuario, etc. **No** sustituye a props/emits para comunicación entre dos componentes cercanos. Para estado global se prefiere Pinia (sesión 17).

14. **a)** `computed`. Es un valor derivado mostrado en UI: dependencias reactivas claras (la lista), sin efectos secundarios, cacheado. Un `watch` que actualice una variable separada introduce desincronización y duplicación de estado.

15. **b)** `defineEmits`. El hijo declara el evento (`const emit = defineEmits<{ guardar: [] }>()`) y lo dispara con `emit('guardar')`; el padre lo escucha con `@guardar="handler"`. `defineModel` es para datos editables compartidos, no para acciones puntuales.

16. **b)** Entrada (`ref`) + derivado (`computed`) + acción (método). Los tres roles quedan separados y son fáciles de leer: el `ref` guarda lo que el usuario escribe, el `computed` calcula si es válido (o lo normaliza), y el método ejecuta la acción al pulsar el botón. Es el escalón previo a extraer todo a un composable de dominio que llame al servicio HTTP (sesión 12).
