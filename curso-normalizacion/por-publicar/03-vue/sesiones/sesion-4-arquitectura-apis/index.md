---
title: "Sesión 9: Arquitectura de componentes y servicios"
description: Composables vs Servicios, arquitectura Vista → Composable → Servicio y herramientas de depuración
outline: deep
---

# Sesión 9: Arquitectura de componentes y servicios (~90 min)

::: tip SESIÓN DE INTEGRACIÓN
Esta sesión se centra en la **arquitectura** (Composables vs Servicios). Los temas de `useAxios`, validación de formularios (`useGestionFormularios`) y estado global (Pinia) se cubren en:
- **Sesión 11** — Llamadas a la API y autenticación
- **Sesión 12** — Validación en todas las capas
- **Sesión 17** — Estado global y persistencia
:::

<!-- [[toc]] -->

::: info CONTEXTO
En las sesiones anteriores aprendimos a crear componentes, comunicar datos y derivar estado. Ahora damos el paso a una forma de trabajo más cercana a un proyecto real: **arquitectura por capas**, consumo de APIs, validación y criterio para gestionar el estado sin desordenarlo.

**Al terminar esta sesión sabrás:**
- Diferenciar composables de servicios y cuándo usar cada uno
- Estructurar tu aplicación con la arquitectura de tres capas
- Consumir APIs REST (GET, POST, PUT, DELETE) con `useAxios`
- Validar formularios en cliente y servidor con `useGestionFormularios`
- Gestionar estado local, compartido y persistente en frontend
- Usar herramientas de apoyo para depurar y verificar una aplicación Vue
:::

## Plan de sesión (90 min) {#plan-90}

| Bloque | Tiempo | Contenido |
|--------|--------|-----------|
| **Teoría guiada** | 55 min | 4.1 a 4.7 (arquitectura, APIs, validación, estado y flujo de depuración) |
| **Práctica en aula** | 20 min | Ejercicio completo Vista -> Composable -> Servicio |
| **Test de sesión** | 10 min | Preguntas de consolidación y corrección técnica |
| **Cierre** | 5 min | Checklist final de calidad y próximos pasos del módulo |

::: tip OBJETIVO PEDAGÓGICO
El foco de esta sesión es que el alumno tome decisiones de arquitectura con criterio, no solo que consiga "hacer funcionar" una llamada HTTP.
:::

## 4.1 Composables vs Servicios {#composables-servicios}

Ambos son funciones reutilizables que siguen el patrón `useNombre()`, pero tienen responsabilidades distintas:

| Aspecto | Composable | Servicio |
|---------|-----------|----------|
| **Ubicación** | `src/composables/` | `src/services/` |
| **Propósito** | Lógica reactiva reutilizable | Lógica de negocio y llamadas HTTP |
| **Contiene** | Estado, computed, watchers, utilidades | Operaciones CRUD con APIs |
| **Ejemplos** | `useContador`, `useFormato`, `useUsuarios` | `useUsuariosService`, `useAuth` |

### Estructura básica (igual para ambos)

```typescript
import { ref, computed } from 'vue'

export function useNombre() {
  // 1. Estado reactivo
  const variable = ref(valorInicial)

  // 2. Computed (opcional)
  const derivado = computed(() => /* ... */)

  // 3. Funciones
  const miFuncion = () => { /* ... */ }

  // 4. Retornar lo público
  return { variable, derivado, miFuncion }
}
```

### Ejemplo: Composable genérico

```typescript
// src/composables/useContador.ts
import { ref } from 'vue'

export function useContador(inicial: number = 0) {
  const contador = ref<number>(inicial)

  const incrementar = () => contador.value++
  const decrementar = () => contador.value--

  return { contador, incrementar, decrementar }
}
```

```html
<script setup lang="ts">
import { useContador } from '@/composables/useContador'

const { contador, incrementar, decrementar } = useContador(10)
</script>

<template>
  <button @click="decrementar">-</button>
  <span>{{ contador }}</span>
  <button @click="incrementar">+</button>
</template>
```

### ¿Cuándo usar cada uno?

- **Composable**: lógica reutilizable que no llama a APIs (contador, formateo, validaciones locales)
- **Servicio**: operaciones que comunican con el backend (CRUD de usuarios, productos, etc.)

## 4.2 Arquitectura Vista → Composable → Servicio {#arquitectura}

La arquitectura separa la aplicación en tres capas con responsabilidades claras:

```
┌─────────────────┐
│  Vista (.vue)   │  ← UI, eventos del usuario, template
└────────┬────────┘
         │ usa
         ↓
┌─────────────────┐
│  Composable     │  ← Lógica reactiva, estado, computed, watchers
│  useXxx.ts      │
└────────┬────────┘
         │ usa
         ↓
┌─────────────────┐
│  Servicio       │  ← Llamadas HTTP a API (CRUD)
│  useXxxService  │
└────────┬────────┘
         │ usa
         ↓
┌─────────────────┐
│  useAxios       │  ← HTTP client (GET, POST, PUT, DELETE)
└─────────────────┘
```

### Ejemplo completo: gestión de usuarios

**1. Servicio** — solo llamadas HTTP:

```typescript
// src/services/useUsuariosService.ts
import { llamadaAxios, verbosAxios } from 'vueua-useaxios/services/useAxios'

export function useUsuariosService() {
  const obtenerUsuarios = async () => {
    return await llamadaAxios('/usuarios', verbosAxios.GET)
  }

  const crearUsuario = async (usuario: { nombre: string; email: string }) => {
    return await llamadaAxios('/usuarios', verbosAxios.POST, usuario)
  }

  const eliminarUsuario = async (id: number) => {
    return await llamadaAxios(`/usuarios/${id}`, verbosAxios.DELETE)
  }

  return { obtenerUsuarios, crearUsuario, eliminarUsuario }
}
```

**2. Composable** — lógica reactiva de la vista:

```typescript
// src/composables/useUsuarios.ts
import { ref, computed } from 'vue'
import { useUsuariosService } from '@/services/useUsuariosService'

export function useUsuarios() {
  const { obtenerUsuarios, crearUsuario, eliminarUsuario } = useUsuariosService()

  const usuarios = ref<any[]>([])
  const cargando = ref<boolean>(false)
  const filtro = ref<string>('')

  const usuariosFiltrados = computed(() =>
    usuarios.value.filter((u: any) =>
      u.nombre.toLowerCase().includes(filtro.value.toLowerCase())
    )
  )

  const cargarUsuarios = async () => {
    cargando.value = true
    try {
      const response = await obtenerUsuarios()
      usuarios.value = response.data.value
    } finally {
      cargando.value = false
    }
  }

  const agregar = async (nombre: string, email: string) => {
    await crearUsuario({ nombre, email })
    await cargarUsuarios()
  }

  const eliminar = async (id: number) => {
    await eliminarUsuario(id)
    usuarios.value = usuarios.value.filter((u: any) => u.id !== id)
  }

  return { usuarios, cargando, filtro, usuariosFiltrados, cargarUsuarios, agregar, eliminar }
}
```

**3. Vista** — solo UI:

```html
<!-- src/views/Usuarios.vue -->
<script setup lang="ts">
import { onMounted } from 'vue'
import { useUsuarios } from '@/composables/useUsuarios'

const { usuariosFiltrados, filtro, cargando, cargarUsuarios, eliminar } = useUsuarios()

onMounted(() => cargarUsuarios())
</script>

<template>
  <div>
    <h1>Gestión de Usuarios</h1>
    <input v-model="filtro" placeholder="Buscar..." class="form-control mb-3" />

    <p v-if="cargando">Cargando...</p>
    <ul v-else class="list-group">
      <li v-for="u in usuariosFiltrados" :key="u.id" class="list-group-item d-flex justify-content-between">
        {{ u.nombre }} — {{ u.email }}
        <button @click="eliminar(u.id)" class="btn btn-sm btn-danger">Eliminar</button>
      </li>
    </ul>
  </div>
</template>
```

### Ventajas de esta arquitectura

| Ventaja | Descripción |
|---------|-------------|
| **Separación** | Vista = UI, Composable = lógica, Servicio = API |
| **Reutilización** | Composables y servicios usables desde cualquier vista |
| **Mantenibilidad** | Cambios en la API solo afectan al servicio |
| **Testabilidad** | Cada capa se puede probar de forma independiente |

### Nomenclatura y estructura de carpetas

```
src/
├── composables/
│   ├── useUsuarios.ts          ← Composable específico de vista
│   ├── useFormato.ts           ← Composable genérico (utilidad)
│   └── useValidacion.ts
├── services/
│   ├── useUsuariosService.ts   ← Servicio de usuarios
│   └── useProductosService.ts
├── interfaces/
│   ├── IClaseUsuario.ts
│   └── IClaseProducto.ts
├── views/
│   └── Usuarios.vue
└── components/
    └── TarjetaUsuario.vue
```

## 4.3 Llamadas a API con useAxios {#useaxios}

`useAxios` es el composable de la UA para peticiones HTTP. Proporciona variables reactivas, gestión de errores y notificaciones toast integradas.

### Instalación e importación

```bash
pnpm install vueua-useaxios
```

```typescript
import { llamadaAxios, verbosAxios } from 'vueua-useaxios/services/useAxios'
```

### Sintaxis

```typescript
llamadaAxios(url, metodo, parametros?, mensajes?, redirigir?)
```

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `url` | `string` | Ruta del endpoint (sin `/api/`, se añade automáticamente) |
| `metodo` | `verbosAxios` | `GET`, `POST`, `PUT`, `DELETE` |
| `parametros` | `any` | Datos a enviar (opcional) |
| `mensajes` | `MensajesAxios` | Textos toast personalizados (opcional) |
| `redirigir` | `boolean` | Redirigir a página de error (opcional) |

::: warning IMPORTANTE
No incluyas `/api/` en las URLs. `useAxios` lo añade automáticamente mediante `baseURL`.
:::

### Modo 1: Reactividad automática (recomendado para cargas simples)

```html
<script setup lang="ts">
import { llamadaAxios, verbosAxios } from 'vueua-useaxios/services/useAxios'

// Las variables data, isLoading, error se actualizan automáticamente
const { data: usuarios, isLoading, error } = llamadaAxios('/usuarios/listado', verbosAxios.GET)
</script>

<template>
  <div v-if="isLoading">Cargando...</div>
  <div v-else-if="error" class="alert alert-danger">{{ error }}</div>
  <ul v-else>
    <li v-for="u in usuarios" :key="u.id">{{ u.nombre }}</li>
  </ul>
</template>
```

### Modo 2: Control manual con async/await

```typescript
import { ref, onMounted } from 'vue'
import { llamadaAxios, verbosAxios } from 'vueua-useaxios/services/useAxios'

const usuarios = ref<any[]>([])
const cargando = ref<boolean>(false)

const cargarUsuarios = async () => {
  cargando.value = true
  try {
    const response = await llamadaAxios('/usuarios/listado', verbosAxios.GET)
    usuarios.value = response.data.value
  } finally {
    cargando.value = false
  }
}

onMounted(cargarUsuarios)
```

### ¿Cuándo usar cada modo?

| Modo | Cuándo usar |
|------|-------------|
| **Modo 1** (reactivo) | Cargas simples al montar el componente |
| **Modo 2** (manual) | Botones de recarga, validaciones, operaciones con múltiples pasos |

### Operaciones CRUD

```typescript
// GET — Obtener datos
await llamadaAxios('/usuarios', verbosAxios.GET)

// GET con parámetros
await llamadaAxios('/usuarios/buscar', verbosAxios.GET, { nombre: 'Juan' })

// POST — Crear
await llamadaAxios('/usuarios', verbosAxios.POST, { nombre: 'Ana', email: 'ana@ua.es' })

// PUT — Actualizar
await llamadaAxios(`/usuarios/${id}`, verbosAxios.PUT, datosActualizados)

// DELETE — Eliminar
await llamadaAxios(`/usuarios/${id}`, verbosAxios.DELETE)
```

## 4.4 Validación de formularios {#validacion}

La validación se realiza en **dos niveles**:

1. **Cliente** (HTML5 + Bootstrap): inmediata, mejora UX
2. **Servidor** (HTTP 400): reglas de negocio, seguridad

### useGestionFormularios

```bash
pnpm install vueua-usegestionformularios
```

```typescript
import {
  validarFormulario,
  adaptarMensajesError,
  inicializarMensajeError,
  modelState
} from 'vueua-usegestionformularios/services/useGestionFormularios'
```

### Flujo de validación

```
Usuario hace clic en "Guardar"
         │
         ▼
  validarFormulario('idForm')  ← Validación HTML5
         │
    ¿Es válido?
    /         \
  ❌ No       ✅ Sí
   │           │
   │     llamadaAxios(url, POST)  ← Envío al servidor
   │           │
   │     ¿Respuesta?
   │     /         \
   │   200 OK    400 Error
   │     │         │
   │   Éxito   adaptarMensajesError()  ← Mapeo errores servidor
   │             │
   │           Errores en campos
   │
  Errores HTML5 en campos (Bootstrap)
```

### Ejemplo completo

```html
<script setup lang="ts">
import { ref } from 'vue'
import { llamadaAxios, verbosAxios } from 'vueua-useaxios/services/useAxios'
import {
  validarFormulario,
  adaptarMensajesError,
  inicializarMensajeError,
  modelState
} from 'vueua-usegestionformularios/services/useGestionFormularios'

interface IClaseUsuario {
  nombre: string
  email: string
  edad: number
}

const usuario = ref<IClaseUsuario>({ nombre: '', email: '', edad: 0 })

const guardarUsuario = async () => {
  // 1. Limpiar errores previos
  inicializarMensajeError()

  // 2. Validar en cliente (HTML5 + Bootstrap)
  if (!validarFormulario('formUsuario')) return

  // 3. Enviar al servidor
  const response = await llamadaAxios('/usuarios', verbosAxios.POST, usuario.value)

  // 4. Si el servidor retorna errores de validación (HTTP 400)
  if (response.Estado === 'Error') {
    adaptarMensajesError(response.Datos, 'formUsuario')
    return
  }

  // 5. Éxito
  console.log('Usuario creado:', response.data.value)
}
</script>

<template>
  <form id="formUsuario" @submit.prevent="guardarUsuario" novalidate>
    <div class="mb-3">
      <label for="nombre" class="form-label">Nombre *</label>
      <input
        type="text"
        class="form-control"
        id="nombre"
        v-model="usuario.nombre"
        required
        minlength="3"
        maxlength="50"
      />
      <div class="invalid-feedback">{{ modelState.nombre }}</div>
    </div>

    <div class="mb-3">
      <label for="email" class="form-label">Email *</label>
      <input
        type="email"
        class="form-control"
        id="email"
        v-model="usuario.email"
        required
      />
      <div class="invalid-feedback">{{ modelState.email }}</div>
    </div>

    <div class="mb-3">
      <label for="edad" class="form-label">Edad *</label>
      <input
        type="number"
        class="form-control"
        id="edad"
        v-model.number="usuario.edad"
        required
        min="18"
        max="120"
      />
      <div class="invalid-feedback">{{ modelState.edad }}</div>
    </div>

    <button type="submit" class="btn btn-primary">Guardar</button>
  </form>
</template>
```

### Funciones principales

| Función | Descripción |
|---------|-------------|
| `validarFormulario(id)` | Valida campos HTML5 y aplica clases Bootstrap |
| `adaptarMensajesError(errores, id)` | Mapea errores del servidor (HTTP 400) a campos |
| `inicializarMensajeError()` | Limpia todos los errores del `modelState` |
| `modelState` | Objeto reactivo con mensajes de error por campo |

### Atributos HTML5 más comunes

| Atributo | Descripción | Ejemplo |
|----------|-------------|---------|
| `required` | Campo obligatorio | `<input required>` |
| `type` | Tipo de dato | `<input type="email">` |
| `minlength` / `maxlength` | Longitud mín/máx | `<input minlength="3">` |
| `min` / `max` | Valor mín/máx | `<input type="number" min="18">` |
| `pattern` | Expresión regular | `<input pattern="[0-9]{9}">` |

::: tip BUENA PRÁCTICA
Valida siempre en **cliente y servidor**. La validación del cliente mejora la UX. La del servidor garantiza la seguridad. Usa `novalidate` en el `<form>` para controlar la validación manualmente.
:::

## 4.5 Estado de la aplicación {#estado}

Gestionar estado bien significa responder a estas tres preguntas:

1. ¿Quién necesita este dato? (solo un componente o muchos)
2. ¿Cuánto debe durar? (solo mientras está abierta la app o también tras recargar)
3. ¿Qué sensibilidad tiene? (preferencias, filtros, tokens, datos temporales)

### Niveles de estado en una SPA Vue

| Nivel | Dónde vive | Duración | Ejemplo típico |
|------|------------|----------|----------------|
| **Local de componente** | `ref`/`reactive` dentro de una vista/componente | Hasta desmontar componente | Modal abierto/cerrado, tab activo |
| **Compartido en memoria** | Store de Pinia | Hasta recargar página | Usuario en sesión, carrito, filtros globales |
| **Persistente en navegador** | `localStorage` o `sessionStorage` | Según almacenamiento | Tema, último filtro usado, borrador de formulario |

::: tip REGLA PRÁCTICA
Empieza por estado local. Solo sube a Pinia si el dato lo consumen varias vistas. Solo persiste en storage si realmente necesitas recuperar ese valor tras navegación o recarga.
:::

### `localStorage` vs `sessionStorage` vs Pinia

| Opción | Persistencia | Alcance | Cuándo usar |
|--------|-------------|---------|-------------|
| `localStorage` | Permanente (hasta borrar manualmente) | Todo el sitio en ese navegador | Preferencias de usuario (tema, idioma, columnas) |
| `sessionStorage` | Solo pestaña/sesión actual | Esa pestaña del navegador | Estado temporal de navegación (wizard, búsqueda puntual) |
| Pinia | Memoria de ejecución | Toda la SPA mientras esté cargada | Estado compartido entre vistas/componentes |

### Ejemplo 1: Preferencia persistente con `localStorage`

```typescript
import { ref, watch } from 'vue'

const tema = ref<string>(localStorage.getItem('tema') ?? 'claro')

watch(tema, (nuevoTema) => {
  localStorage.setItem('tema', nuevoTema)
})
```

Qué aporta este patrón:
- Al recargar la app, el usuario conserva su preferencia
- El componente sigue trabajando de forma reactiva
- Solo persistes un valor pequeño y estable

### Ejemplo 2: Filtro temporal con `sessionStorage`

```typescript
import { ref, watch } from 'vue'

const filtroBusqueda = ref<string>(sessionStorage.getItem('filtro-unidades') ?? '')

watch(filtroBusqueda, (nuevoFiltro) => {
  sessionStorage.setItem('filtro-unidades', nuevoFiltro)
})
```

Cuándo encaja:
- Quieres mantener estado durante la sesión actual
- No quieres arrastrar datos entre días o sesiones futuras

### Ejemplo 3: Estado compartido con Pinia

```typescript
// src/stores/useAuthStore.ts
import { defineStore } from 'pinia'

interface IAuthState {
  nombre: string
  token: string
  autenticado: boolean
}

export const useAuthStore = defineStore('auth', {
  state: (): IAuthState => ({
    nombre: '',
    token: '',
    autenticado: false
  }),
  getters: {
    nombreVisible: (state) => state.nombre || 'Invitado'
  },
  actions: {
    login(nombre: string, token: string) {
      this.nombre = nombre
      this.token = token
      this.autenticado = true
    },
    logout() {
      this.nombre = ''
      this.token = ''
      this.autenticado = false
    }
  }
})
```

```html
<script setup lang="ts">
import { useAuthStore } from '@/stores/useAuthStore'

const auth = useAuthStore()
</script>

<template>
  <p>Usuario: {{ auth.nombreVisible }}</p>
  <button v-if="!auth.autenticado" @click="auth.login('Ana', 'token-demo')">Entrar</button>
  <button v-else @click="auth.logout()">Salir</button>
</template>
```

### Diferencias importantes que suelen confundir

1. Pinia no persiste por sí sola: al recargar se reinicia.
2. `localStorage` y `sessionStorage` no son reactivos: guardar ahí no actualiza la UI por sí mismo.
3. El patrón habitual es combinar ambos: estado reactivo en Pinia o `ref` y sincronización a storage con `watch`.

### Patrón recomendado para la UA

| Tipo de dato | Solución recomendada |
|--------------|----------------------|
| Estado de una vista concreta | `ref`/`reactive` local |
| Estado compartido entre vistas | Pinia |
| Preferencias de usuario (tema, idioma) | Pinia o `ref` + `localStorage` |
| Filtros de búsqueda temporales | `sessionStorage` |
| Tokens / datos sensibles | Evitar almacenamiento innecesario; aplicar política de seguridad del proyecto |

::: warning IMPORTANTE
No conviertas todo en estado global. El exceso de estado compartido complica trazabilidad, pruebas y mantenimiento.
:::

::: tip BUENA PRÁCTICA
Documenta en cada store qué parte del estado es temporal y qué parte se persiste. Evita "persistir por defecto".
:::

## 4.6 Herramientas y flujo de trabajo {#herramientas}

En un proyecto real no basta con que la pantalla "funcione". Necesitamos herramientas para comprobar estado, tipos y peticiones.

### Vue Devtools

Permite inspeccionar componentes, props, estado reactivo y stores en el navegador.

Úsalo para:
- Ver qué props recibe un componente
- Comprobar si un `computed` cambia cuando esperas
- Inspeccionar estado de Pinia sin añadir `console.log`

### Comprobación de tipos

Antes de dar por buena una tarea, conviene ejecutar la comprobación de TypeScript:

```bash
pnpm vue-tsc --noEmit
```

Qué detecta:
- Props mal tipadas
- Interfaces incompletas
- Accesos a propiedades que no existen
- Funciones con tipos incompatibles

### Red del navegador

La pestaña Network ayuda a revisar:
- URL real que se ha llamado
- Código HTTP devuelto
- Tiempo de respuesta
- Payload enviado al backend

### Regla práctica de depuración

Si algo falla con datos remotos, revisa en este orden:

1. ¿Se dispara el evento correcto?
2. ¿El estado reactivo cambia?
3. ¿Sale la petición en Network?
4. ¿La respuesta tiene la forma esperada?
5. ¿El tipado refleja de verdad esa forma?

## 4.7 Checklist de entrega técnica {#checklist-entrega}

Antes de dar por buena una práctica de arquitectura, revisa estos puntos:

| Punto | Pregunta de control |
|-------|----------------------|
| Capas separadas | ¿La vista evita llamadas HTTP directas? |
| Tipado | ¿Interfaces y tipos reflejan la respuesta real de la API? |
| Estados de carga/error | ¿La UI informa cuando carga o falla? |
| Validación | ¿Hay validación mínima en cliente y control en servidor? |
| Estado compartido | ¿Solo se globaliza lo que realmente es compartido? |
| Revisión final | ¿Se ejecutó `pnpm vue-tsc --noEmit` y se comprobó Network? |

### Señales de alerta (antipatrones)

1. Un componente de vista con demasiada lógica de negocio y llamadas HTTP.
2. Uso de `any` sin justificación en datos de API.
3. Stores globales para estado temporal de una sola vista.
4. Falta de manejo de error en operaciones de red.

::: warning CRITERIO DE CALIDAD
Si un alumno solo prueba el "camino feliz" y no revisa errores de red o validación, la práctica no está completa aunque funcione visualmente.
:::

---

## Ejercicio Sesión 4

::: info ENUNCIADO
En esta práctica construirás una funcionalidad real con separación por capas: una vista para mostrar y filtrar datos, un composable para estado reactivo y derivados, y un servicio para llamadas HTTP. El objetivo no es solo que funcione, sino que cada responsabilidad quede en su sitio.
:::

**Objetivo:** Aplicar la arquitectura Vista → Composable → Servicio y realizar llamadas a API con `useAxios`.

Crea un **listado de unidades** con la siguiente estructura:

1. **Interface** `IClaseUnidad` en `src/interfaces/IClaseUnidad.ts`:
   - `id` (number), `nombre` (string), `codigo` (string), `activa` (boolean)

2. **Servicio** `useUnidadesService.ts` en `src/services/`:
   - `obtenerUnidades()`: GET a `/unidades/listado`
   - `crearUnidad(unidad)`: POST a `/unidades`
   - `eliminarUnidad(id)`: DELETE a `/unidades/{id}`

3. **Composable** `useUnidades.ts` en `src/composables/`:
   - Estado: `unidades`, `cargando`, `filtro`
   - Computed: `unidadesFiltradas` (filtrar por nombre)
   - Computed: `totalActivas` (contar unidades activas)
   - Funciones: `cargarUnidades`, `agregar`, `eliminar`

4. **Vista** `Unidades.vue`:
   - Input de búsqueda con `v-model` vinculado al filtro
   - Tabla con `v-for` mostrando las unidades filtradas
   - Indicador de carga con `v-if`
   - Botón de eliminar en cada fila
   - Contador: "X unidades activas de Y total"

::: details Solución

```typescript
// src/interfaces/IClaseUnidad.ts
export interface IClaseUnidad {
  id: number
  nombre: string
  codigo: string
  activa: boolean
}
```

```typescript
// src/services/useUnidadesService.ts
import { llamadaAxios, verbosAxios } from 'vueua-useaxios/services/useAxios'
import type { IClaseUnidad } from '@/interfaces/IClaseUnidad'

export function useUnidadesService() {
  const obtenerUnidades = async () => {
    return await llamadaAxios('/unidades/listado', verbosAxios.GET)
  }

  const crearUnidad = async (unidad: Omit<IClaseUnidad, 'id'>) => {
    return await llamadaAxios('/unidades', verbosAxios.POST, unidad)
  }

  const eliminarUnidad = async (id: number) => {
    return await llamadaAxios(`/unidades/${id}`, verbosAxios.DELETE)
  }

  return { obtenerUnidades, crearUnidad, eliminarUnidad }
}
```

```typescript
// src/composables/useUnidades.ts
import { ref, computed } from 'vue'
import { useUnidadesService } from '@/services/useUnidadesService'
import type { IClaseUnidad } from '@/interfaces/IClaseUnidad'

export function useUnidades() {
  const { obtenerUnidades, crearUnidad, eliminarUnidad } = useUnidadesService()

  const unidades = ref<IClaseUnidad[]>([])
  const cargando = ref<boolean>(false)
  const filtro = ref<string>('')

  const unidadesFiltradas = computed(() =>
    unidades.value.filter(u =>
      u.nombre.toLowerCase().includes(filtro.value.toLowerCase())
    )
  )

  const totalActivas = computed(() =>
    unidades.value.filter(u => u.activa).length
  )

  const cargarUnidades = async () => {
    cargando.value = true
    try {
      const response = await obtenerUnidades()
      unidades.value = response.data.value
    } finally {
      cargando.value = false
    }
  }

  const agregar = async (unidad: Omit<IClaseUnidad, 'id'>) => {
    await crearUnidad(unidad)
    await cargarUnidades()
  }

  const eliminar = async (id: number) => {
    await eliminarUnidad(id)
    unidades.value = unidades.value.filter(u => u.id !== id)
  }

  return {
    unidades, cargando, filtro,
    unidadesFiltradas, totalActivas,
    cargarUnidades, agregar, eliminar
  }
}
```

```html
<!-- src/views/Unidades.vue -->
<script setup lang="ts">
import { onMounted } from 'vue'
import { useUnidades } from '@/composables/useUnidades'

const {
  unidadesFiltradas, filtro, cargando,
  totalActivas, unidades,
  cargarUnidades, eliminar
} = useUnidades()

onMounted(() => cargarUnidades())
</script>

<template>
  <div class="container mt-4">
    <h1>Gestión de Unidades</h1>
    <p>{{ totalActivas }} unidades activas de {{ unidades.length }} total</p>

    <input v-model="filtro" placeholder="Buscar por nombre..." class="form-control mb-3" />

    <div v-if="cargando" class="text-center">
      <div class="spinner-border" role="status"></div>
      <p>Cargando unidades...</p>
    </div>

    <table v-else class="table table-striped">
      <thead>
        <tr>
          <th>ID</th>
          <th>Código</th>
          <th>Nombre</th>
          <th>Estado</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="unidad in unidadesFiltradas" :key="unidad.id">
          <td>{{ unidad.id }}</td>
          <td>{{ unidad.codigo }}</td>
          <td>{{ unidad.nombre }}</td>
          <td>
            <span :class="unidad.activa ? 'badge bg-success' : 'badge bg-secondary'">
              {{ unidad.activa ? 'Activa' : 'Inactiva' }}
            </span>
          </td>
          <td>
            <button @click="eliminar(unidad.id)" class="btn btn-sm btn-danger">
              Eliminar
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
```
:::

## Test Sesión 4

### Preguntas (desplegables)

::: details 1. En la arquitectura propuesta, ¿qué responsabilidad principal tiene la vista?
- a) Centralizar llamadas HTTP
- b) Renderizar UI y gestionar eventos del usuario
- c) Persistir el estado en storage
- d) Definir interfaces globales
:::

::: details 2. ¿Qué capa suele concentrar estado reactivo, computed y funciones de una vista?
- a) Servicio
- b) Composable
- c) Router
- d) CSS del componente
:::

::: details 3. ¿Dónde conviene centralizar las llamadas REST?
- a) En la vista
- b) En el servicio
- c) En el template
- d) En los estilos
:::

::: details 4. ¿Qué anti-patrón debería evitarse?
- a) Crear interfaces reutilizables
- b) Mezclar llamadas API directamente en una vista grande
- c) Usar computed
- d) Separar responsabilidades
:::

::: details 5. ¿Qué ofrece el modo reactivo de useAxios?
- a) data, isLoading y error listos para la interfaz
- b) Persistencia automática en Pinia
- c) Validación HTML5 incorporada
- d) Renderizado en servidor
:::

::: details 6. ¿Cuándo encaja mejor el modo manual con async/await?
- a) Cuando hay varios pasos o control más fino del flujo
- b) Solo en componentes sin formulario
- c) Nunca, porque el modo reactivo siempre es mejor
- d) Solo al trabajar con CSS
:::

::: details 7. Según la explicación de useAxios, ¿qué no debes incluir en la URL del endpoint?
- a) La barra inicial
- b) El nombre del recurso
- c) /api/
- d) El método HTTP
:::

::: details 8. ¿Por qué se valida tanto en cliente como en servidor?
- a) Porque el cliente reemplaza las reglas del servidor
- b) Porque cliente mejora UX y servidor garantiza reglas y seguridad
- c) Porque así no hace falta tipado
- d) Porque Vue lo exige por defecto
:::

::: details 9. ¿Qué función valida el formulario en cliente?
- a) adaptarMensajesError
- b) validarFormulario
- c) modelState
- d) watchFormulario
:::

::: details 10. ¿Qué función adapta errores del servidor a los campos del formulario?
- a) inicializarMensajeError
- b) validarFormulario
- c) adaptarMensajesError
- d) useErrores
:::

::: details 11. ¿Qué describe mejor a Pinia?
- a) Storage persistente por defecto
- b) Estado compartido reactivo en memoria
- c) Sustituto obligatorio de ref
- d) Cliente HTTP integrado
:::

::: details 12. ¿Qué almacenamiento se mantiene tras cerrar y volver a abrir el navegador?
- a) sessionStorage
- b) localStorage
- c) Pinia
- d) Un ref
:::

::: details 13. ¿Qué almacenamiento dura solo mientras la pestaña sigue abierta?
- a) localStorage
- b) sessionStorage
- c) Pinia persistente
- d) computed
:::

::: details 14. ¿Para qué sirve pnpm vue-tsc --noEmit?
- a) Para compilar CSS
- b) Para comprobar tipos sin generar salida de build
- c) Para levantar el servidor de desarrollo
- d) Para inspeccionar peticiones HTTP
:::

::: details 15. ¿Qué herramienta abrirías primero para inspeccionar una petición fallida al backend?
- a) Vue Devtools
- b) Pestaña Network del navegador
- c) El archivo de estilos
- d) Un slot del componente
:::

### Respuestas (Autoevaluación)

::: details Ver respuestas
1. b) Renderizar UI y gestionar eventos del usuario.
2. b) Composable. Suele concentrar estado reactivo y derivados de la vista.
3. b) En el servicio.
4. b) Mezclar llamadas API directamente en una vista grande.
5. a) data, isLoading y error listos para la interfaz.
6. a) Cuando hay varios pasos o control más fino del flujo.
7. c) /api/. Lo añade la configuración de useAxios.
8. b) Cliente mejora UX y servidor garantiza reglas y seguridad.
9. b) validarFormulario.
10. c) adaptarMensajesError.
11. b) Estado compartido reactivo en memoria.
12. b) localStorage.
13. b) sessionStorage.
14. b) Para comprobar tipos sin generar salida.
15. b) La pestaña Network del navegador.
:::


