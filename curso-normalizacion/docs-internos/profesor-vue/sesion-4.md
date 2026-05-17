# Guia del profesor — Sesion 9: Arquitectura de componentes y servicios

## Objetivo y material
- Duracion: 90 min
- Objetivo: Que el grupo cierre el bloque Vue entendiendo como se organiza una aplicacion real: capa de vista, composables, servicios, llamadas HTTP, validacion, gestion de estado y herramientas minimas de comprobacion.
- Material alumno: sesion-4-arquitectura-apis/index.md
- Material de refuerzo: bloque "Test Sesion 4" y "Respuestas (desplegables)" dentro de sesion-4-arquitectura-apis/index.md
- Ejercicio base: Listado de Unidades
- Prerequisitos: Sesiones 1, 2 y 3 completadas.

## Propuesta de ritmo

Distribucion sugerida:
- Teoria guiada: 55 min
- Practica: 20 min
- Test y correccion: 10 min
- Cierre: 5 min

### Bloque 4.1: Vista, composable y servicio (~10 min)
Objetivo didactico:
Que el alumnado vea que no todo debe vivir en un componente `.vue`.

Que mostrar:
- Responsabilidad de la vista
- Responsabilidad del composable
- Responsabilidad del servicio

Mensajes clave:
- La vista pinta y recoge eventos
- El composable organiza estado y reglas reactivas
- El servicio encapsula acceso a API

Pregunta al grupo:
- Que problema aparece cuando la vista hace tambien llamadas HTTP y reglas de negocio?

Respuesta esperada:
- Mucho acoplamiento, menos reutilizacion y mantenimiento mas dificil.

### Bloque 4.2: Arquitectura Vista -> Composable -> Servicio (~10 min)
Objetivo didactico:
Convertir la arquitectura en una decision practica, no en teoria vacia.

Que mostrar:
- Un ejemplo corto de las tres capas
- Flujo de datos desde la vista hasta la API
- Ventajas de mantenimiento y prueba

Mensajes clave:
- La arquitectura ordena responsabilidades
- No es burocracia: simplifica cambios futuros

### Bloque 4.3: `useAxios` en modo reactivo y modo manual (~10 min)
Objetivo didactico:
Dar criterio para elegir una forma simple o una forma controlada de cargar datos.

Que mostrar:
- Modo reactivo con `data`, `isLoading` y `error`
- Modo manual con `async/await`
- CRUD basico con verbos HTTP

Mensajes clave:
- El modo reactivo encaja bien en cargas sencillas
- El modo manual da mas control en flujos de negocio

Pregunta al grupo:
- En que caso preferirias `async/await` manual frente al modo reactivo?

Respuesta esperada:
- Cuando hay varios pasos, recargas manuales o logica adicional antes o despues de la peticion.

### Bloque 4.4: Validacion de formularios (~8 min)
Objetivo didactico:
Transmitir que validar bien no es solo una cuestion visual.

Que mostrar:
- `validarFormulario`
- `adaptarMensajesError`
- `modelState`
- Diferencia entre validacion cliente y servidor

Mensajes clave:
- El cliente mejora experiencia
- El servidor protege reglas reales del sistema
- Ambas validaciones se complementan

### Bloque 4.5: Estado local, Pinia y storage (~9 min)
Objetivo didactico:
Que el grupo salga con una regla simple para no convertir todo en estado global.

Que mostrar:
- Estado local con `ref` o `reactive`
- Estado compartido con Pinia
- Persistencia con `localStorage` y `sessionStorage`

Mensajes clave:
- Empieza local y solo sube de nivel si hace falta
- Storage no es reactivo por si solo
- Persistir por defecto suele ser una mala decision

Pregunta al grupo:
- Que diferencia importante hay entre Pinia y `localStorage`?

Respuesta esperada:
- Pinia es reactivo pero no persiste solo; `localStorage` persiste pero no es reactivo.

### Bloque 4.6: Herramientas y flujo de trabajo (~8 min)
Objetivo didactico:
Cerrar el modulo con practicas reales de comprobacion y depuracion.

Que mostrar:
- Vue Devtools para inspeccionar estado y componentes
- Pestaña Network del navegador
- Comprobacion de tipos con `pnpm vue-tsc --noEmit`

Mensajes clave:
- No basta con que la pantalla parezca funcionar
- El tipado, la red y las devtools ayudan a detectar errores antes de entregar

## Practica guiada (~20 min)

Objetivo:
Montar un ejemplo minimo de arquitectura por capas con filtro y contador derivados.

Secuencia recomendada:
1. Crear `IClaseUnidad`.
2. Crear `useUnidadesService` con la lectura principal y una operacion adicional.
3. Crear `useUnidades` con `unidades`, `cargando`, `filtro` y `totalActivas`.
4. Integrar la vista con `v-model`, `v-for` y un indicador de carga.
5. Revisar en voz alta que responsabilidad queda en cada capa.

Checklist rapido:
- La vista no contiene llamadas HTTP directas.
- El composable concentra el estado y los derivados.
- El servicio conoce los endpoints.
- El grupo puede justificar por que esa separacion mejora el mantenimiento.

## Test de sesion y correccion (~10 min)

Propuesta:
1. Abrir el bloque "Test Sesion 4" de la sesion del alumno.
2. Resolver preguntas de arquitectura, `useAxios`, validacion, estado y herramientas.
3. Corregir en grupo y cerrar con checklist tecnico de entrega.

Objetivo:
- Verificar que el alumnado toma decisiones de arquitectura con criterio y no solo por inercia.

## Cierre y comprobacion (~5 min)

Preguntas de salida:
- Donde pondrias la llamada HTTP y por que?
- Cuando eliges Pinia en lugar de estado local?
- Que herramienta abririas primero si la peticion no devuelve lo esperado?

Criterio minimo de sesion superada:
- El alumnado distingue vista, composable y servicio.
- El alumnado entiende la diferencia entre estado local, compartido y persistente.
- El alumnado sabe que comprobar con Devtools, Network y type-check.

## Si falta tiempo
1. Priorizar arquitectura, `useAxios` y criterio de estado.
2. Dejar la validacion completa del formulario como recorrido comentado.

## Si sobra tiempo
1. Resolver varias preguntas del banco de la sesion.
2. Lanzar un `type-check` y mostrar como leer un error real de tipos.
