---
title: "Sesión 14: DataTable de extremo a extremo"
description: DataTable server-side con ClaseCrudUtils en .NET y vueua-datatable en Vue — paginación, filtros y ordenación
outline: deep
---

# Sesión 14: DataTable de extremo a extremo

[[toc]]

::: info CONTEXTO
Cuando una tabla tiene miles de registros, no podemos cargarlos todos en el cliente. En esta sesión construimos un DataTable server-side completo: desde el endpoint .NET con `ClaseCrudUtils` hasta el componente `vueua-datatable` en Vue, pasando por filtros, paginación y ordenación.
:::

## Objetivos

Al finalizar esta sesión, el alumno será capaz de:
- Decidir cuándo usar un listado simple y cuándo un DataTable server-side
- Configurar `ClaseCrudUtils` y `CamposFiltros` en el servicio .NET
- Implementar paginación, filtros y ordenación en el endpoint
- Conectar el componente `vueua-datatable` de Vue con el endpoint
- Tener un flujo completo funcionando de extremo a extremo

## 14.1 Listado simple vs DataTable server-side {#cuando-usar}

::: warning IMPORTANTE
El contenido detallado de esta sesión está pendiente de publicación.
:::

Pendiente de publicación.

Material de referencia: [DataTable server-side (.NET)](../../parte-dotnet/sesiones/sesion-4-datatable-clasecrud/)

## 14.2 Lado servidor: ClaseCrudUtils {#servidor}

Pendiente de publicación.

## 14.3 Lado cliente: vueua-datatable {#cliente}

Pendiente de publicación.

## 14.4 Conectando las dos partes {#conexion}

Pendiente de publicación.

## 14.5 Tarea progresiva del proyecto final {#tarea-pf}

::: tip MÓDULO 2 · CIERRE DEL DATATABLE DE RECURSO + MÓDULO 4 · DISPONIBILIDAD
**Módulo 2 (`recurso-<nombre>`) — cierre:**

- DataTable server-side de `Recurso` con paginación, ordenación y filtros.
- **Filtro desplegable** por `TipoRecurso` (usando `vueua-autocomplete` o un `<select>` con los tipos cargados al `onMounted`).
- Acciones por fila: editar, activar/desactivar, marcar mantenimiento, eliminar (con confirmación).
- Botón "Calendario" en cada fila que aún no enlaza a nada — déjalo preparado para el módulo 4.

**Módulo 4 (`reserva-<nombre>`) — arranque:**

- Endpoint `GET /api/Reservas/disponibilidad?recursoId=…&fecha=…` que devuelve las franjas libres del día (consultando horario, festivos y reservas existentes).
- Vista de lista de reservas del usuario actual con DataTable server-side filtrado por `CodPer = User.CodPer`.

Mapa completo: [Proyecto final del curso](../../../06-proyecto-final/).
:::
